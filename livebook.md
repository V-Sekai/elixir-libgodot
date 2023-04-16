<!-- livebook:{"app_settings":{"access_type":"public","slug":"libgodot-upload"}} -->

# Godot Engine GDExtension API json upload

```elixir
Mix.install([
  {:kino, "~> 0.9.1"},
  {:jason, "~> 1.4"},
  {:briefly, "~> 0.4.0"}
])
```

## Section

```elixir
frame = Kino.Frame.new()

form =
  Kino.Control.form(
    [
      url:
        Kino.Input.url("extension_api.json",
          default: "https://github.com/V-Sekai/elixir-godot/raw/main/extension_api.json"
        )
    ],
    submit: "Process",
    report_changes: true
  )
```

```elixir
defmodule LibGodot do
  def blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  def get_builtin_functions(api) do
    Enum.concat(
      [],
      Enum.flat_map(api["utility_functions"], fn method ->
        method_name = method["name"]

        return_type =
          if method["return_type"] == nil do
            "void"
          else
            method["return_type"]
          end

        arguments = Map.get(method, "arguments")

        if arguments do
          argument_strings =
            Enum.flat_map(arguments, fn arg ->
              argument_name = arg["name"]
              argument_type = arg["type"]
              ["#{argument_name} :: #{argument_type}, "]
            end)

          [
            %{
              name: method_name,
              class_name: "",
              return: return_type,
              argument_strings: argument_strings
            }
          ]
        else
          [
            %{
              name: method_name,
              class_name: "",
              return: return_type,
              argument_strings: []
            }
          ]
        end
      end)
    )
  end

  def get_classes(class_name, class_methods) do
    Enum.concat(
      [],
      Enum.flat_map(class_methods, fn method ->
        method_name = method["name"]

        return_type =
          if method["return_type"] == nil do
            "void"
          else
            method["return_type"]
          end

        arguments = Map.get(method, "arguments")

        if arguments do
          argument_strings =
            Enum.flat_map(arguments, fn arg ->
              argument_name = arg["name"]
              argument_type = arg["type"]
              ["#{argument_name} :: #{argument_type}, "]
            end)

          [
            %{
              name: "#{class_name}.#{method_name}",
              class_name: class_name,
              return: return_type,
              argument_strings: argument_strings
            }
          ]
        else
          [
            %{
              name: "#{class_name}.#{method_name}",
              class_name: class_name,
              return: return_type,
              argument_strings: []
            }
          ]
        end
      end)
    )
  end

  def get_methods(classes, api) do
    Enum.flat_map(classes, fn c ->
      class_methods = Map.get(c, "methods")
      class_name = c["name"]

      unless class_name == Object do
        if class_methods do
          get_classes(class_name, class_methods)
        else
          get_builtin_functions(api)
        end
      end
    end)
  end
end
```

```elixir
Kino.listen(form, fn
  %{data: data, origin: origin} ->
    %{url: url} = data
    :inets.start()
    :ssl.start()
    {:ok, path} = Briefly.create()
    :inets.start()
    :ssl.start()

    {:ok, :saved_to_file} =
      :httpc.request(:get, {to_charlist(url), []}, [], stream: to_charlist(path))

    api =
      File.read!(path)
      |> Jason.decode!()

    classes = api["classes"]
    classes = Enum.concat(classes, api["builtin_classes"])
    methods = LibGodot.get_methods(classes, api)
    methods = Enum.uniq(methods)
    methods = Enum.sort(methods)
    Kino.Frame.render(frame, Kino.DataTable.new(methods), to: origin)
end)

frame
```
