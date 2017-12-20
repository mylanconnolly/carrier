defmodule Carrier do
  use Application

  alias Carrier.Server

  @doc """
  Set up the GenServer API. Should be called before usage either implicitly by
  adding to `application` in `mix.exs` or explicitly by calling it directly.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Server, [])]
    opts     = [strategy: :one_for_one, name: Carrier.Supervisor]

    Supervisor.start_link children, opts
  end

  @doc """
  This is the public method for validating one address. The only parameter is a
  four-tuple containing the following fields:

  1. Street address (including suite, apt., etc.)
  2. City
  3. State
  4. ZIP Code

  Results are in the form of a two-tuple. Valid addresses are returned like
  `{:valid, validated_address}` and invalid ones are returned like
  `{:invalid, original_address}`.

  ## Examples

  A pretty well-formed and complete address to query:

      iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "CA", "95014"}
      {:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

  Note that the addresses are also standardized (to follow USPS guidelines):

      iex> Carrier.verify_one {"1 infinite loop", "cupertino", "ca", "95014"}
      {:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

      iex> Carrier.verify_one {"1096 Rainer Dr, Suite 1001", "", "", "32714"}
      {:valid, {"1096 Rainer Dr Ste 1001", "Altamonte Springs", "FL", "32714-3855"}}

  You can supply empty strings for fields you don't know:

      iex> Carrier.verify_one {"1 Infinite Loop", "", "", "95014"}
      {:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

      iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "", "95014"}
      {:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

      iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "CA", ""}
      {:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

  If an address is invalid, we'll let you know and provide the original back:

      iex> Carrier.verify_one {"123 Fake St", "Anytown", "FL", "12345"}
      {:invalid, {"123 Fake St", "Anytown", "FL", "12345"}}

  Easy!
  """
  def verify_one({street, city, state, zip}),
    do: Server.verify_one({street, city, state, zip})

  @doc """
  This is the public method for validating many addresses. This accepts a list
  of four-tuples representing addresses. Behavior works identically to the
  `verify_one/1` method, except results are in a list.

  Please see `verify_one/1` for more information.

  ## Examples

  Validating two addresses:

      iex> Carrier.verify_many [{"1 Infinite Loop", "", "", "95014"},
      ...>                      {"1096 Rainer Dr, Suite 1001", "", "", "32714"}]
      [valid: {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"},
       valid: {"1096 Rainer Dr Ste 1001", "Altamonte Springs", "FL", "32714-3855"}]
  """
  def verify_many(addresses), do: Server.verify_many(addresses)
end
