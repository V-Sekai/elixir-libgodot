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
            Enum.join(
              Enum.flat_map(arguments, fn arg ->
                argument_name = arg["name"]
                argument_type = arg["type"]
                ["#{argument_name} :: #{argument_type}, "]
              end),
              ", "
            )

          [
            %{
              class_name: "",
              method_name: method_name,
              return: return_type,
              spec:
                "spec #{method_name}(#{argument_strings}) :: {:ok :: label, state :: State, #{return_type}}"
            }
          ]
        else
          [
            %{
              class_name: "",
              method_name: method_name,
              return: return_type,
              spec: "spec #{method_name}() :: {:ok :: label, #{return_type}}"
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
            Enum.join(
              Enum.flat_map(arguments, fn arg ->
                argument_name = arg["name"]
                argument_type = arg["type"]
                ["#{argument_name} :: #{argument_type}, "]
              end)
            )

          [
            %{
              class_name: class_name,
              method_name: method_name,
              return: return_type,
              spec:
                "spec #{class_name}.#{method_name}(#{argument_strings}) :: {:ok :: label, state :: State, #{return_type}}"
            }
          ]
        else
          [
            %{
              class_name: class_name,
              method_name: method_name,
              return: return_type,
              spec:
                "spec #{class_name}.#{method_name}() :: {:ok :: label, state :: State, #{return_type}}"
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
    {:ok, dir} = Briefly.create(directory: true)
    file = 'extension_api.json'
    path = Path.join(dir, file)
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
