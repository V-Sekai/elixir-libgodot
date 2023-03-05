<!-- livebook:{"persist_outputs":true} -->

# Untitled notebook

```elixir
Mix.install([
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

defmodule Libgodot do
  def blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()
end

methods =
  Enum.flat_map(classes, fn c ->
    class_methods = Map.get(c, "methods")

    if class_methods do
      class_name = c["name"]

      Enum.concat(
        [],
        Enum.flat_map(class_methods, fn method ->
          method_name = method["name"]
          return_type = method["return_type"]
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
    else
      Enum.concat(
        [],
        Enum.flat_map(api["utility_functions"], fn method ->
          method_name = method["name"]
          return_type = method["return_type"]
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
            [["spec #{method_name}() :: {:ok :: label, state :: State, #{return_type}}"]]
          end
        end)
      )
    end
  end)

methods = Enum.uniq(methods)
methods = Enum.sort(methods)
File.write(spec, Enum.join(methods, "\n"))
```

<!-- livebook:{"output":true} -->

```
warning: variable "return_type" is unused (if the variable is not meant to be used, prefix it with an underscore)
  Documents/write_libgodot.livemd#cell:y3mk3asnpnc5x5txorn5pellkdbf73os:42

warning: variable "return_type" is unused (if the variable is not meant to be used, prefix it with an underscore)
  Documents/write_libgodot.livemd#cell:y3mk3asnpnc5x5txorn5pellkdbf73os:25


03:48:49.324 [warn] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'


```

<!-- livebook:{"output":true} -->

```
:ok
```
