defmodule Carrier do
  @moduledoc """
  Elixir library for interacting with Smarty's API.
  """

  # Get hostname from config instead of hardcoding it
  @hostname Application.compile_env(:carrier, Carrier)[:hostname] ||
              "https://us-street.api.smarty.com/street-address"

  def verify_many(addresses) do
    %{to_verify: addresses, cached: cached} =
      Enum.reduce(addresses, %{to_verify: [], cached: []}, fn address, acc ->
        Map.put(acc, :to_verify, [address | acc.to_verify])
      end)

    case client()
         |> Req.post(params: auth_params(), json: Enum.map(addresses, &standardize_request/1))
         |> standardize_response(force_list: true) do
      {:ok, result} -> {:ok, result ++ cached}
      error -> error
    end
  end

  def verify(address) do
    client()
    |> Req.get(params: Map.merge(auth_params(), standardize_request(address)))
    |> standardize_response()
  end

  defp standardize_response(resp, opts \\ [])

  defp standardize_response({:ok, %{status: 200, body: body}}, opts) when is_list(body) do
    force_list = Keyword.get(opts, :force_list)

    if force_list do
      {:ok, Enum.map(body, &standardize_result/1)}
    else
      case body do
        [] -> {:error, :no_results}
        [res] -> {:ok, standardize_result(res)}
        _ -> {:ok, Enum.map(body, &standardize_result/1)}
      end
    end
  end

  defp standardize_response(resp, _opts), do: resp

  defp auth_params do
    %{"auth-id" => auth_id(), "auth-token" => auth_token()}
  end

  def standardize_request(address) do
    address
    |> Enum.filter(fn {k, _} ->
      k in [:input_id, :street, :city, :state, :zip, "street", "city", "state", "zip", "input_id"]
    end)
    |> Enum.map(fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
    |> Enum.into(%{})
    |> Map.merge(%{"candidates" => 1})
  end

  def standardize_result(result) do
    zip =
      case result["components"] do
        %{"zipcode" => zip, "plus4_code" => plus4} -> "#{zip}-#{plus4}"
        %{"zipcode" => zip} -> zip
      end

    meta =
      case result do
        %{"input_id" => id} -> %{"input_id" => id}
        _ -> %{}
      end

    deliverable =
      case result["analysis"] do
        %{"dpv_match_code" => "Y", "dpv_vacant" => "N"} -> "deliverable"
        %{"dpv_match_code" => "Y", "dpv_vacant" => "Y"} -> "vacant"
        %{"dpv_match_code" => "D"} -> "incomplete"
        _ -> "undeliverable"
      end

    notes =
      case result["analysis"] do
        %{"dpv_footnotes" => footnotes} ->
          footnotes
          |> String.codepoints()
          |> Enum.chunk_every(2)
          |> Enum.map(&Enum.join/1)
          |> Enum.map(fn
            "AA" -> "valid"
            "A1" -> "invalid"
            "BB" -> "valid"
            "CC" -> "unknown_secondary"
            "M1" -> "missing_primary_number"
            "M3" -> "invalid_primary_number"
            "N1" -> "missing_secondary"
            "P1" -> "missing_po"
            "P3" -> "invalid_po"
            "RR" -> "valid"
            _note -> nil
          end)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        _ ->
          []
      end

    parsed_result = %{
      "street" => result["delivery_line_1"],
      "city" => result["components"]["city_name"],
      "state" => result["components"]["state_abbreviation"],
      "zip" => zip,
      "verified" => String.length(zip) == 10 && deliverable == "deliverable",
      "meta" => %{
        "latitude" => result["metadata"]["latitude"],
        "longitude" => result["metadata"]["longitude"],
        "county" => result["metadata"]["county_name"],
        "deliverable" => deliverable,
        "notes" => notes
      }
    }

    Map.merge(meta, parsed_result)
  end

  defp client do
    Req.new(base_url: @hostname, headers: [{"Accept", "application/json"}])
  end

  defp auth_id do
    Application.get_env(:carrier, Carrier)[:auth_id]
  end

  defp auth_token do
    Application.get_env(:carrier, Carrier)[:auth_token]
  end
end
