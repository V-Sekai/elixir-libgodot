import Briefly

defmodule ElixirLibgodot do
  @moduledoc """
  Documentation for `ElixirLibgodot`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ElixirLibgodot.hello()
      :world

  """
  def blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  defp create_method_map(method_name, return_type, arguments \\ []) do
    argument_strings =
      Enum.map(arguments, fn %{"name" => name, "type" => type} ->
        "#{name} :: #{type}"
      end)

    %{
      name: method_name,
      class_name: "",
      return: return_type,
      argument_strings: argument_strings
    }
  end

  def get_builtin_functions(%{"utility_functions" => utility_functions}) do
    Enum.flat_map(utility_functions, fn %{
                                          "name" => method_name,
                                          "return_type" => return_type,
                                          "arguments" => arguments
                                        } ->
      return_type = if return_type, do: return_type, else: "void"
      [create_method_map(method_name, return_type, arguments)]
    end)
  end

  def get_methods(classes, api) do
    Enum.flat_map(classes, fn class ->
      case class do
        %{"name" => class_name, "methods" => class_methods} when is_list(class_methods) ->
          unless class_name == Object do
            if class_methods do
              Enum.flat_map(class_methods, &get_class_method(class_name, &1))
            else
              get_builtin_functions(api)
            end
          end

        _ ->
          []
      end
    end)
  end

  defp get_class_method(class_name, method) do
    return_type = Map.get(method, "return_value", "void")
    arguments = Map.get(method, "arguments", [])
    method_name = Map.get(method, "name")

    method_map = create_method_map(method_name, return_type, arguments)
    [%{method_map | name: "#{class_name}.#{method_name}", class_name: class_name}]
  end

  def io() do
    IO.puts("Enter URL (press Enter for default):")
    url = IO.gets("") |> String.trim()
    default_url = "https://github.com/V-Sekai/elixir-godot/raw/main/extension_api.json"
    url = if(url == "", do: default_url, else: url)

    :inets.start()
    :ssl.start()
    {:ok, path} = Briefly.create("elixir_libgodot_temp")
    :inets.start()
    :ssl.start()

    {:ok, :saved_to_file} =
      :httpc.request(:get, {to_charlist(url), []}, [], stream: to_charlist(path))

    api =
      File.read!(path)
      |> Jason.decode!()

    classes = api["classes"]
    classes = Enum.concat(classes, api["builtin_classes"])
    methods = get_methods(classes, api)
    methods = Enum.uniq(methods)
    methods = Enum.sort(methods)
    write_to_disk(methods)
  end

  defp write_to_disk(methods) do
    File.write("methods.exs", inspect(methods))
  end
end
