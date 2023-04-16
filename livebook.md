<!-- livebook:{"app_settings":{"access_type":"public","slug":"kino-dir"}} -->

# Printer

```elixir
Mix.install([
  {:kino, "~> 0.9.1"},
  {:jason, "~> 1.4"}
])
```

<!-- livebook:{"output":true} -->

```
:ok
```

## Section

```elixir
url = 'https://github.com/V-Sekai/elixir-godot/raw/main/extension_api.json'
:inets.start()
:ssl.start()

file = 'extension_api.json'
File.rm(file)
{:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [], stream: file)

api =
  File.read!(file)
  |> Jason.decode!()

spec = "godot_elixir.spec.exs"
File.rm(spec)
classes = api["classes"]
classes = Enum.concat(classes, api["builtin_classes"])

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

methods = LibGodot.get_methods(classes, api)
methods = Enum.uniq(methods)
methods = Enum.sort(methods)

text = Enum.join(methods, "\n")
Kino.Text.new(text)
```

<!-- livebook:{"output":true} -->

```

15:30:43.321 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


15:30:43.375 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'

warning: variable "c" is unused (if the variable is not meant to be used, prefix it with an underscore)
  #cell:2tgdulekflt6nsqxpb7zqqbwaxjz42j6:53: LibGodot.get_classes/3

warning: variable "methods" is unused (if the variable is not meant to be used, prefix it with an underscore)
  #cell:2tgdulekflt6nsqxpb7zqqbwaxjz42j6:88: LibGodot.get_methods/2

```
