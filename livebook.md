<!-- livebook:{"app_settings":{"access_type":"public","slug":"libgodot-upload"}} -->

# Godot Engine API json upload - fork

```elixir
Mix.install([
  {:kino, "~> 0.9.1"},
  {:jason, "~> 1.4"}
])
```

## Section

```elixir
form = Kino.Control.form([data: Kino.Input.file("JSON API")], report_changes: true)
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
        return_type = method["return_type"]
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
            [
              "spec #{method_name}(#{argument_strings}) :: {:ok :: label, state :: State, #{return_type}}"
            ]
          ]
        else
          [["spec #{method_name}() :: {:ok :: label, #{return_type}}"]]
        end
      end)
    )
  end

  def get_classes(class_name, class_methods, c) do
    Enum.concat(
      [],
      Enum.flat_map(class_methods, fn method ->
        method_name = method["name"]
        return_type = method["return_type"]
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
            [
              "spec #{class_name}.#{method_name}(#{argument_strings}) :: {:ok :: label, state :: State, #{return_type}}"
            ]
          ]
        else
          [
            [
              "spec #{class_name}.#{method_name}() :: {:ok :: label, state :: State, #{return_type}}"
            ]
          ]
        end
      end)
    )
  end

  def get_methods(classes, api) do
    methods =
      Enum.flat_map(classes, fn c ->
        class_methods = Map.get(c, "methods")
        class_name = c["name"]

        unless class_name == Object do
          if class_methods do
            get_classes(class_name, class_methods, c)
          else
            get_builtin_functions(api)
          end
        end
      end)
  end
end
```

```elixir
Kino.animate(form, fn %{data: %{data: %{file_ref: file_ref}}} ->
  path = Kino.Input.file_path(file_ref)
  content = File.read!(path)
  api = Jason.decode!(content)
  classes = api["classes"]
  classes = Enum.concat(classes, api["builtin_classes"])
  methods = LibGodot.get_methods(classes, api)
  methods = Enum.uniq(methods)
  methods = Enum.sort(methods)
  output = Enum.join(methods, "\n")
  Kino.Text.new(output)
end)
```
