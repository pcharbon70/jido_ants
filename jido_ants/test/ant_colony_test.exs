defmodule AntColonyTest do
  use ExUnit.Case
  doctest AntColony

  test "greets the world" do
    assert AntColony.hello() == :world
  end
end
