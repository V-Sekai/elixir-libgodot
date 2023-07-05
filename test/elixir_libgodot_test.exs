defmodule ElixirLibgodotTest do
  use ExUnit.Case
  doctest ElixirLibgodot

  test "greets the world" do
    assert ElixirLibgodot.hello() == :world
  end
end
