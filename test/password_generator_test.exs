defmodule PasswordGeneratorTest do
  @moduledoc """
  Tests for `PasswordGenerator`.
  """
  use ExUnit.Case
  doctest PasswordGenerator

  setup do
    options = %{
      "numbers" => false,
      "uppercase" => false,
      "lowercase" => false,
      "symbols" => false
    }

    options_type = %{
      lowercase: Enum.map(?a..?z, &<<&1>>),
      uppercase: Enum.map(?A..?Z, &<<&1>>),
      numbers: Enum.map(0..9, &Integer.to_string(&1)),
      symbols: String.split("!@#$%^&*()_+", "", trim: true)
    }

    %{
      options: options,
      options_type: options_type
    }
  end

  test "returns an error if length is not an integer" do
    assert {:error, "Length must be an integer"} =
             PasswordGenerator.generate("10", %{"uppercase" => true})
  end

  test "returns an error if options have an invalid attribute" do
    assert {:error, "Option has an invalid attribute"} =
             PasswordGenerator.generate(10, %{"bleh" => false})
  end

  test "returns an error if options have an invalid values" do
    assert {:error, "Options must be boolean (true or false)"} =
             PasswordGenerator.generate(10, %{"uppercase" => 123})
  end

  test "returns an error if options is not a map" do
    assert {:error, "The options attribute must be a map"} = PasswordGenerator.generate(10, "Abc")
  end

  test "the password should have the same length as specified", %{options: options} do
    {:success, result} = PasswordGenerator.generate(5, options)
    assert 5 == String.length(result)
  end

  test "returns a string", %{options: options} do
    {:success, result} = PasswordGenerator.generate(10, options)
    assert is_bitstring(result)
  end

  test "Empty options should return lowercase password", %{options_type: options_type} do
    {:success, result} = PasswordGenerator.generate(10)

    assert String.split(result, "", trim: true)
           |> Enum.all?(fn v -> String.contains?(v, options_type.lowercase) end)
  end

  test "the password should contain just lowercases", %{
    options_type: options_type
  } do
    options = %{
      "numbers" => false,
      "uppercase" => false,
      "lowercase" => true,
      "symbols" => false
    }

    {:success, result} = PasswordGenerator.generate(10, options)

    assert String.split(result, "", trim: true)
           |> Enum.all?(fn v -> String.contains?(v, options_type.lowercase) end)
  end

  test "the password should contain just uppercase", %{
    options_type: options_type
  } do
    options = %{
      "numbers" => false,
      "uppercase" => true,
      "lowercase" => false,
      "symbols" => false
    }

    {:success, result} = PasswordGenerator.generate(10, options)

    assert String.split(result, "", trim: true)
           |> Enum.all?(fn v -> String.contains?(v, options_type.uppercase) end)
  end

  test "the password should contain just symbols", %{
    options_type: options_type
  } do
    options = %{
      "numbers" => false,
      "uppercase" => false,
      "lowercase" => false,
      "symbols" => true
    }

    {:success, result} = PasswordGenerator.generate(10, options)

    assert String.split(result, "", trim: true)
           |> Enum.all?(fn v -> String.contains?(v, options_type.symbols) end)
  end

  test "the password should contain just numbers", %{
    options_type: options_type
  } do
    options = %{
      "numbers" => true,
      "uppercase" => false,
      "lowercase" => false,
      "symbols" => false
    }

    {:success, result} = PasswordGenerator.generate(10, options)

    assert String.split(result, "", trim: true)
           |> Enum.all?(fn v -> String.contains?(v, options_type.numbers) end)
  end

  test "the password should contain at least one character of each selected option", %{
    options_type: options_type
  } do
    options = %{
      "numbers" => true,
      "uppercase" => true,
      "lowercase" => true,
      "symbols" => true
    }

    {:success, result} = PasswordGenerator.generate(10, options)
    assert String.contains?(result, options_type.numbers)
    assert String.contains?(result, options_type.uppercase)
    assert String.contains?(result, options_type.symbols)
    assert String.contains?(result, options_type.lowercase)
  end
end
