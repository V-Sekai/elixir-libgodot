<!-- livebook:{"app_settings":{"access_type":"public","slug":"kino-dir"}} -->

# Button clicker __DIR__

```elixir
Mix.install([
  {:kino, "~> 0.9.1"},
  {:jason, "~> 1.4"}
])
```

## Section

```elixir
frame = Kino.Frame.new()
button = Kino.Control.button("Click") |> Kino.render()

Kino.animate(button, 0, fn _event, counter ->
  new_message = Path.absname(__DIR__)
  new_counter = counter + 1
  md = Kino.Markdown.new("**Clicks: `#{new_counter}`** `#{new_message}`")
  {:cont, md, new_counter}
end)
```
