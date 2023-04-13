# Export elixir methods

```elixir
Mix.install([
  {:jason, "~> 1.4"}
])
```

<!-- livebook:{"output":true} -->

```
Resolving Hex dependencies...
Resolution completed in 0.039s
New:
  jason 1.4.0
* Getting jason (Hex package)
==> jason
Compiling 10 files (.ex)
Generated jason app
```

<!-- livebook:{"output":true} -->

```
:ok
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
File.write(spec, Enum.join(methods, "\n"))
```

<!-- livebook:{"output":true} -->

```

11:44:59.564 [warn] Description: 'Server authenticity is not verified since certificate path validation is not enabled'
     Reason: 'The option {verify, verify_peer} and one of the options \'cacertfile\' or \'cacerts\' are required to enable this.'


11:44:59.967 [warn] Description: 'Server authenticity is not verified since certificate path validation is not enabled'
     Reason: 'The option {verify, verify_peer} and one of the options \'cacertfile\' or \'cacerts\' are required to enable this.'

warning: variable "c" is unused (if the variable is not meant to be used, prefix it with an underscore)
  #cell:b5z5jydjthltcguhtunwuzk3a3kbrbdl:53: LibGodot.get_classes/3

warning: variable "methods" is unused (if the variable is not meant to be used, prefix it with an underscore)
  #cell:b5z5jydjthltcguhtunwuzk3a3kbrbdl:87: LibGodot.get_methods/2

```

<!-- livebook:{"output":true} -->

```
:ok
```
