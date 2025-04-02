defmodule CarrierTest do
  use ExUnit.Case
  doctest Carrier

  describe "standardize_request/1" do
    test "filters out irrelevant fields" do
      address = %{
        street: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip: "12345",
        irrelevant_field: "should be removed"
      }

      result = Carrier.standardize_request(address)

      assert Map.has_key?(result, "street")
      assert Map.has_key?(result, "city")
      assert Map.has_key?(result, "state")
      assert Map.has_key?(result, "zip")
      refute Map.has_key?(result, "irrelevant_field")
    end

    test "converts atom keys to strings" do
      address = %{
        street: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip: "12345"
      }

      result = Carrier.standardize_request(address)

      assert result["street"] == "123 Main St"
      assert result["city"] == "Anytown"
      assert result["state"] == "CA"
      assert result["zip"] == "12345"
    end

    test "preserves string keys" do
      address = %{
        "street" => "123 Main St",
        "city" => "Anytown",
        "state" => "CA",
        "zip" => "12345"
      }

      result = Carrier.standardize_request(address)

      assert result["street"] == "123 Main St"
      assert result["city"] == "Anytown"
      assert result["state"] == "CA"
      assert result["zip"] == "12345"
    end

    test "handles mixed string and atom keys" do
      address = %{
        :street => "123 Main St",
        "city" => "Anytown",
        :state => "CA",
        "zip" => "12345"
      }

      result = Carrier.standardize_request(address)

      assert result["street"] == "123 Main St"
      assert result["city"] == "Anytown"
      assert result["state"] == "CA"
      assert result["zip"] == "12345"
    end

    test "adds candidates parameter with value 1" do
      address = %{
        street: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip: "12345"
      }

      result = Carrier.standardize_request(address)

      assert result["candidates"] == 1
    end

    test "preserves input_id if present" do
      address = %{
        street: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip: "12345",
        input_id: "test-id-123"
      }

      result = Carrier.standardize_request(address)

      assert result["input_id"] == "test-id-123"
    end

    test "handles empty address" do
      address = %{}

      result = Carrier.standardize_request(address)

      assert result == %{"candidates" => 1}
    end

    test "handles nil values" do
      address = %{
        street: "123 Main St",
        city: nil,
        state: "CA",
        zip: "12345"
      }

      result = Carrier.standardize_request(address)

      assert result["street"] == "123 Main St"
      assert result["city"] == nil
      assert result["state"] == "CA"
      assert result["zip"] == "12345"
      assert result["candidates"] == 1
    end

    test "handles both input_id formats (string and atom)" do
      # Test with atom key
      address1 = %{input_id: "test-id-atom"}
      result1 = Carrier.standardize_request(address1)
      assert result1["input_id"] == "test-id-atom"

      # Test with string key
      address2 = %{"input_id" => "test-id-string"}
      result2 = Carrier.standardize_request(address2)
      assert result2["input_id"] == "test-id-string"
    end
  end

  describe "standardize_result/1" do
    test "formats address with full zip code" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345",
          "plus4_code" => "6789"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_match_code" => "Y",
          "dpv_vacant" => "N",
          "dpv_footnotes" => "AABB"
        }
      }

      result = Carrier.standardize_result(api_result)

      assert result["street"] == "123 Main St"
      assert result["city"] == "Anytown"
      assert result["state"] == "CA"
      assert result["zip"] == "12345-6789"
      assert result["verified"] == true
      assert result["meta"]["latitude"] == 37.7749
      assert result["meta"]["longitude"] == -122.4194
      assert result["meta"]["county"] == "Sample County"
      assert result["meta"]["deliverable"] == "deliverable"
      assert result["meta"]["notes"] == ["valid"]
    end

    test "formats address with partial zip code" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_match_code" => "Y",
          "dpv_vacant" => "N"
        }
      }

      result = Carrier.standardize_result(api_result)

      assert result["street"] == "123 Main St"
      assert result["city"] == "Anytown"
      assert result["state"] == "CA"
      assert result["zip"] == "12345"
      assert result["verified"] == false # Not verified because zip is not full
      assert result["meta"]["deliverable"] == "deliverable"
    end

    test "handles vacant address" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345",
          "plus4_code" => "6789"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_match_code" => "Y",
          "dpv_vacant" => "Y"
        }
      }

      result = Carrier.standardize_result(api_result)

      assert result["zip"] == "12345-6789"
      assert result["verified"] == false # Not verified because vacant
      assert result["meta"]["deliverable"] == "vacant"
    end

    test "handles incomplete address" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345",
          "plus4_code" => "6789"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_match_code" => "D"
        }
      }

      result = Carrier.standardize_result(api_result)

      assert result["zip"] == "12345-6789"
      assert result["verified"] == false
      assert result["meta"]["deliverable"] == "incomplete"
    end

    test "handles undeliverable address" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345",
          "plus4_code" => "6789"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_match_code" => "N"
        }
      }

      result = Carrier.standardize_result(api_result)

      assert result["zip"] == "12345-6789"
      assert result["verified"] == false
      assert result["meta"]["deliverable"] == "undeliverable"
    end

    test "preserves input_id if present" do
      api_result = %{
        "input_id" => "test-id-123",
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{}
      }

      result = Carrier.standardize_result(api_result)

      assert result["input_id"] == "test-id-123"
    end

    test "processes all footnote codes" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{
          "dpv_footnotes" => "AAA1BBCCM1M3N1P1P3RR"
        }
      }

      result = Carrier.standardize_result(api_result)

      expected_notes = [
        "valid",
        "invalid",
        "unknown_secondary",
        "missing_primary_number",
        "invalid_primary_number",
        "missing_secondary",
        "missing_po",
        "invalid_po"
      ]

      assert Enum.sort(result["meta"]["notes"]) == Enum.sort(expected_notes)
    end

    test "handles missing footnotes" do
      api_result = %{
        "delivery_line_1" => "123 Main St",
        "components" => %{
          "city_name" => "Anytown",
          "state_abbreviation" => "CA",
          "zipcode" => "12345"
        },
        "metadata" => %{
          "latitude" => 37.7749,
          "longitude" => -122.4194,
          "county_name" => "Sample County"
        },
        "analysis" => %{}
      }

      result = Carrier.standardize_result(api_result)

      assert result["meta"]["notes"] == []
    end
  end
end
