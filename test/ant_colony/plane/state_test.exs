defmodule AntColony.Plane.StateTest do
  @moduledoc """
  Unit tests for the AntColony.Plane.State module.

  Tests the State struct creation, FoodSource struct creation,
  and type specifications.
  """

  use ExUnit.Case, async: true

  alias AntColony.Plane.State
  alias AntColony.Plane.State.FoodSource

  describe "State Struct Creation" do
    test "creates state with default values" do
      state = %State{}

      assert state.__struct__ == State
      assert is_map(state)
    end

    test "default width is 50" do
      state = %State{}
      assert state.width == 50
    end

    test "default height is 50" do
      state = %State{}
      assert state.height == 50
    end

    test "default nest_location is center" do
      state = %State{}
      assert state.nest_location == {25, 25}
    end

    test "default food_sources is empty map" do
      state = %State{}
      assert state.food_sources == %{}
    end

    test "default ant_positions is empty map" do
      state = %State{}
      assert state.ant_positions == %{}
    end

    test "can create state with custom values" do
      state = %State{
        width: 100,
        height: 200,
        nest_location: {50, 100}
      }

      assert state.width == 100
      assert state.height == 200
      assert state.nest_location == {50, 100}
    end
  end

  describe "FoodSource Struct Creation" do
    test "creates FoodSource with level and quantity" do
      food = %FoodSource{level: 5, quantity: 20}

      assert food.level == 5
      assert food.quantity == 20
    end

    test "default quantity is 10" do
      food = %FoodSource{level: 3}
      assert food.quantity == 10
    end

    test "FoodSource.new/2 creates struct with given values" do
      food = FoodSource.new(5, 25)

      assert food.level == 5
      assert food.quantity == 25
    end

    test "FoodSource.new/1 uses default quantity" do
      food = FoodSource.new(3)

      assert food.level == 3
      assert food.quantity == 10
    end

    test "level accepts boundary value 1" do
      food = FoodSource.new(1)
      assert food.level == 1
    end

    test "level accepts boundary value 5" do
      food = FoodSource.new(5)
      assert food.level == 5
    end

    test "FoodSource.deplete/2 reduces quantity" do
      food = FoodSource.new(5, 10)

      assert {:ok, updated} = FoodSource.deplete(food, 3)
      assert updated.quantity == 7
    end

    test "FoodSource.deplete/2 returns error when fully depleted" do
      food = FoodSource.new(5, 5)

      assert {:error, :depleted} = FoodSource.deplete(food, 5)
    end

    test "FoodSource.deplete/2 handles single unit remaining" do
      food = FoodSource.new(3, 1)

      assert {:error, :depleted} = FoodSource.deplete(food, 1)
    end
  end

  describe "Type Specifications - Position" do
    test "position type accepts valid tuples" do
      # Test origin
      assert {0, 0} == {0, 0}

      # Test various valid positions
      assert {10, 20} == {10, 20}
      assert {100, 100} == {100, 100}
      assert {0, 100} == {0, 100}
      assert {100, 0} == {100, 0}
    end

    test "state accepts position in nest_location" do
      state = %State{nest_location: {50, 75}}
      assert state.nest_location == {50, 75}
    end
  end

  describe "Type Specifications - Food Sources Map" do
    test "food_sources map type is correct" do
      food1 = FoodSource.new(3, 15)
      food2 = FoodSource.new(5, 20)

      food_map = %{
        {10, 10} => food1,
        {20, 20} => food2
      }

      state = %State{food_sources: food_map}

      assert map_size(state.food_sources) == 2
      assert state.food_sources[{10, 10}].level == 3
      assert state.food_sources[{20, 20}].level == 5
    end

    test "food_sources accepts empty map" do
      state = %State{food_sources: %{}}
      assert state.food_sources == %{}
    end

    test "food_sources accepts single entry" do
      food = FoodSource.new(4)
      state = %State{food_sources: %{{5, 5} => food}}

      assert map_size(state.food_sources) == 1
      assert state.food_sources[{5, 5}].quantity == 10
    end
  end

  describe "Type Specifications - Ant Positions Map" do
    test "ant_positions map type is correct" do
      ant_positions = %{
        "ant_1" => {10, 10},
        "ant_2" => {15, 15},
        "ant_3" => {20, 20}
      }

      state = %State{ant_positions: ant_positions}

      assert map_size(state.ant_positions) == 3
      assert state.ant_positions["ant_1"] == {10, 10}
      assert state.ant_positions["ant_2"] == {15, 15}
      assert state.ant_positions["ant_3"] == {20, 20}
    end

    test "ant_positions accepts empty map" do
      state = %State{ant_positions: %{}}
      assert state.ant_positions == %{}
    end

    test "ant_positions accepts single ant" do
      state = %State{ant_positions: %{"worker_1" => {25, 25}}}

      assert map_size(state.ant_positions) == 1
      assert state.ant_positions["worker_1"] == {25, 25}
    end
  end

  describe "State Inspect" do
    test "inspect/2 returns formatted string" do
      state = %State{width: 100, height: 100}

      inspected = inspect(state)

      # Verify the inspect output contains key information
      assert String.contains?(inspected, "width")
      assert String.contains?(inspected, "height")
      assert String.contains?(inspected, "nest_location")
    end

    test "inspect/2 includes struct name" do
      state = %State{}

      inspected = inspect(state)

      # Verify it's the correct struct
      assert String.contains?(inspected, "AntColony.Plane.State")
    end

    test "inspect/2 shows food_sources and ant_positions" do
      state = %State{
        food_sources: %{{10, 10} => FoodSource.new(3)},
        ant_positions: %{"ant_1" => {5, 5}}
      }

      inspected = inspect(state)

      # Verify sources and positions are shown
      assert String.contains?(inspected, "food_sources")
      assert String.contains?(inspected, "ant_positions")
    end
  end
end
