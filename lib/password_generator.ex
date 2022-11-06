defmodule PasswordGenerator do
  @moduledoc """
  Documentation for `PasswordGenerator`.
  """

  @doc """
  Generate a random password with a given length and with characters
  from options.

  ## Examples
      iex> options = %{
      ...>  "numbers" => true,
      ...>  "uppercase" => false,
      ...>  "lowercase" => false,
      ...>  "symbols" => false,
      ...>}
      ...> :rand.seed(:exsplus, {1, 2, 3})
      ...> PasswordGenerator.generate(5, options)
      {:success, "05237"}

  """
  @default_options %{
    "numbers" => false,
    "uppercase" => false,
    "lowercase" => true,
    "symbols" => false
  }

  def generate(length, options \\ %{}) do
    password =
      parse_options(options)
      |> validate_length(length)
      |> generate_password(length)
      |> shuffle_password

    case password do
      {:error, _} ->
        password

      _ ->
        {:success, password}
    end
  end

  defp shuffle_password(password) when is_bitstring(password) do
    String.split(password, "", trim: true)
    |> Enum.shuffle()
    |> Enum.join()
  end

  defp shuffle_password({:error, _} = error), do: error

  defp generate_password(options, length)
       when is_map(options) and is_integer(length) and length > 0 do
    password_value =
      Map.filter(options, fn {_, v} -> v end)
      |> Map.keys()
      |> Enum.at(rem(length, selected_options_length(options)))
      |> passible_password_values
      |> Enum.random()

    password_value <> generate_password(options, length - 1)
  end

  defp generate_password(options, 0) when is_map(options) do
    ""
  end

  defp generate_password({:error, _} = error, _), do: error

  defp options_keys_are_valid(options) when is_map(options) do
    valid =
      Map.keys(options)
      |> Enum.all?(fn k -> Map.has_key?(@default_options, k) end)

    case valid do
      true ->
        options

      false ->
        {:error, "Option has an invalid attribute"}
    end
  end

  defp all_options_are_booleans(options) when is_map(options) do
    valid =
      Map.values(options)
      |> Enum.all?(fn v -> is_boolean(v) end)

    case valid do
      true ->
        options

      false ->
        {:error, "Options must be boolean (true or false)"}
    end
  end

  defp all_options_are_booleans({:error, _} = error), do: error

  defp selected_options_length(options) when is_map(options) do
    Map.values(options)
    |> Enum.filter(fn v -> v end)
    |> length
  end

  defp validate_length(options, length) when is_map(options) and is_integer(length) do
    case length >= selected_options_length(options) do
      true ->
        options

      false ->
        {:error, "The length must be higher or equal than the number of selected options"}
    end
  end

  defp validate_length({:error, _} = error, _), do: error

  defp validate_length(_, _) do
    {:error, "Length must be an integer"}
  end

  defp parse_options(options) when is_map(options) do
    options_keys_are_valid(options)
    |> all_options_are_booleans()
    |> extract_selected_options()
    |> default_options_if_nothing_selected()
  end

  defp parse_options({:error, _} = error), do: error

  defp parse_options(_) do
    {:error, "The options attribute must be a map"}
  end

  defp default_options_if_nothing_selected(options) when is_map(options) do
    case map_size(options) do
      0 ->
        @default_options |> Map.filter(fn {_k, v} -> v end)

      _ ->
        options
    end
  end

  defp default_options_if_nothing_selected({:error, _} = error), do: error

  defp extract_selected_options(options) when is_map(options) do
    Map.filter(options, fn {_, v} -> v end)
  end

  defp extract_selected_options({:error, _} = error), do: error

  def passible_password_values("numbers") do
    Enum.map(0..9, &Integer.to_string(&1))
  end

  def passible_password_values("uppercase") do
    Enum.map(?A..?Z, &<<&1>>)
  end

  def passible_password_values("lowercase") do
    Enum.map(?a..?z, &<<&1>>)
  end

  def passible_password_values("symbols") do
    String.split("!@#$%^&*()_+", "", trim: true)
  end
end
