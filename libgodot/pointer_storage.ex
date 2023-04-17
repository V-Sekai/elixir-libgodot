# Copyright (c) 2023-present K. S. Ernest (iFire) Lee
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule Godot.PointerStorage do
  use GenServer

  alias Godot.Pointer

  # Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def store_pointer(pid, pointer) do
    GenServer.call(pid, {:store, pointer})
  end

  def release_pointer(pid, pointer_id) do
    GenServer.call(pid, {:release, pointer_id})
  end

  # Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:store, pointer}, _from, pointers) do
    pointer_id = make_pointer_id(pointers)
    {:reply, {:ok, pointer_id}, Map.put(pointers, pointer_id, pointer)}
  end

  @impl true
  def handle_call({:release, pointer_id}, _from, pointers) do
    {:reply, :ok, Map.delete(pointers, pointer_id)}
  end

  # Helper functions

  defp make_pointer_id(pointers) do
    Enum.reduce_while(1..(map_size(pointers) + 1), nil, fn id, _acc ->
      if Map.has_key?(pointers, id) do
        {:cont, id}
      else
        {:halt, id}
      end
    end)
  end
end
