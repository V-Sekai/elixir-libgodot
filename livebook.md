<!-- livebook:{"persist_outputs":true} -->

# Untitled notebook

```elixir
Mix.install([
  {:jason, "~> 1.4"}
])
```

<!-- livebook:{"output":true} -->

```

00:36:31.472 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


00:36:31.919 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


00:36:32.398 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


```

## Section

<!-- livebook:{"reevaluate_automatically":true} -->

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

    def get_methods(classes) do
      methods =
        Enum.flat_map(classes, fn c ->
          class_methods = Map.get(c, "methods")
          class_name = c["name"]

          unless class_name == Object do
            if class_methods do
              Libgodot.get_classes(class_methods, c)
            else
              Libgodot.get_builtin_functions(class_name, api, c)
            end
          end
        end)
    end
  end
end

methods = LibGodot.get_methods(classes)
methods = Enum.uniq(methods)
methods = Enum.sort(methods)
File.write(spec, Enum.join(methods, "\n"))
```

<!-- livebook:{"output":true} -->

```

00:35:19.168 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


00:35:19.562 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


00:35:20.051 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


```
