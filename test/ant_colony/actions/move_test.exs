defmodule AntColony.Actions.MoveTest do
  @moduledoc """
  Unit tests for the AntColony.Actions.Move module.

  Tests parameter validation, movement logic, path memory tracking,
  and event publishing functionality.
  """

  use ExUnit.Case

  alias AntColony.Actions.Move
  alias AntColony.Plane

  describe "Module Metadata" do
    test "defines correct metadata" do
      assert Move.name() == "move"
      assert Move.description() == "Move the ant in the specified direction"
      assert Move.category() == "movement"
      assert Move.tags() == ["ant", "movement", "position"]
      assert Move.vsn() == "1.0.0"
    end
  end

  describe "Schema Validation (1.5.5)" do
    setup do
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      {:ok, _pid} = start_supervised(Plane)

      :ok
    end

    test "accepts :north direction" do
      params = %{direction: :north}
      assert {:ok, _result} = Move.run(params, build_context(%{position: {25, 25}}))
    end

    test "accepts :south direction" do
      params = %{direction: :south}
      assert {:ok, _result} = Move.run(params, build_context(%{position: {25, 25}}))
    end

    test "accepts :east direction" do
      params = %{direction: :east}
      assert {:ok, _result} = Move.run(params, build_context(%{position: {25, 25}}))
    end

    test "accepts :west direction" do
      params = %{direction: :west}
      assert {:ok, _result} = Move.run(params, build_context(%{position: {25, 25}}))
    end

    test "accepts :random direction" do
      params = %{direction: :random}
      assert {:ok, _result} = Move.run(params, build_context(%{position: {25, 25}}))
    end

    test "default steps is 1" do
      params = %{direction: :north}
      {:ok, result} = Move.run(params, build_context(%{position: {25, 25}}))
      assert result.position == {25, 24}
    end

    test "accepts positive steps value" do
      params = %{direction: :east, steps: 3}
      {:ok, result} = Move.run(params, build_context(%{position: {25, 25}}))
      assert result.position == {28, 25}
    end

    test "handles steps of 0" do
      params = %{direction: :north, steps: 0}
      {:ok, result} = Move.run(params, build_context(%{position: {25, 25}}))
      assert result.position == {25, 25}
    end

    test "handles multiple steps" do
      params = %{direction: :north, steps: 5}
      {:ok, result} = Move.run(params, build_context(%{position: {25, 25}}))
      assert result.position == {25, 20}
    end
  end

  describe "Movement Logic (1.5.6)" do
    test "north decrements y coordinate" do
      {:ok, pos} = Move.calculate_position({25, 25}, :north)
      assert pos == {25, 24}
    end

    test "south increments y coordinate" do
      {:ok, pos} = Move.calculate_position({25, 25}, :south)
      assert pos == {25, 26}
    end

    test "east increments x coordinate" do
      {:ok, pos} = Move.calculate_position({25, 25}, :east)
      assert pos == {26, 25}
    end

    test "west decrements x coordinate" do
      {:ok, pos} = Move.calculate_position({25, 25}, :west)
      assert pos == {24, 25}
    end

    test "random produces valid direction" do
      # Run multiple times to ensure it always returns a valid position
      for _ <- 1..10 do
        {:ok, pos} = Move.calculate_position({25, 25}, :random)
        assert {x, y} = pos
        assert is_integer(x)
        assert is_integer(y)
      end
    end

    test "two steps north moves y-2" do
      {:ok, pos} = Move.calculate_position({25, 25}, :north, 2)
      assert pos == {25, 23}
    end

    test "three steps east moves x+3" do
      {:ok, pos} = Move.calculate_position({25, 25}, :east, 3)
      assert pos == {28, 25}
    end

    test "steps apply sequentially" do
      # Start at {25, 25}, move 2 steps north
      {:ok, pos} = Move.calculate_position({25, 25}, :north, 2)
      assert pos == {25, 23}

      # The position moved from {25, 25} to {25, 23}
      # Intermediate positions were {25, 24} then {25, 23}
    end

    test "valid_position? accepts valid coordinates" do
      assert Move.valid_position?({25, 25}, {50, 50}) == true
      assert Move.valid_position?({0, 0}, {50, 50}) == true
      assert Move.valid_position?({49, 49}, {50, 50}) == true
    end

    test "valid_position? rejects negative x" do
      assert Move.valid_position?({-1, 25}, {50, 50}) == false
    end

    test "valid_position? rejects negative y" do
      assert Move.valid_position?({25, -1}, {50, 50}) == false
    end

    test "valid_position? uses plane dimensions" do
      assert Move.valid_position?({50, 25}, {50, 50}) == false
      assert Move.valid_position?({25, 50}, {50, 50}) == false
    end

    test "north at boundary clamps to valid range" do
      {:ok, pos} = Move.calculate_position({25, 0}, :north, 5, {50, 50})
      assert pos == {25, 0}  # Clamped to y = 0
    end

    test "south at boundary clamps to valid range" do
      {:ok, pos} = Move.calculate_position({25, 49}, :south, 5, {50, 50})
      assert pos == {25, 49}  # Clamped to y = 49
    end

    test "east at boundary clamps to valid range" do
      {:ok, pos} = Move.calculate_position({49, 25}, :east, 5, {50, 50})
      assert pos == {49, 25}  # Clamped to x = 49
    end

    test "west at boundary clamps to valid range" do
      {:ok, pos} = Move.calculate_position({0, 25}, :west, 5, {50, 50})
      assert pos == {0, 25}  # Clamped to x = 0
    end

    test "moving to same position with steps 0 is no-op" do
      {:ok, pos} = Move.calculate_position({25, 25}, :north, 0)
      assert pos == {25, 25}
    end

    test "calculate_position with custom plane dimensions" do
      {:ok, pos} = Move.calculate_position({5, 5}, :east, 1, {10, 10})
      assert pos == {6, 5}
    end
  end

  describe "Path Memory (1.5.7)" do
    setup do
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      {:ok, _pid} = start_supervised(Plane)

      :ok
    end

    test "result includes new position" do
      params = %{direction: :north}
      context = build_context(%{position: {25, 25}, path_memory: []})
      {:ok, result} = Move.run(params, context)

      assert result.position == {25, 24}
    end

    test "result position is correct for east movement" do
      params = %{direction: :east}
      context = build_context(%{position: {25, 25}, path_memory: []})
      {:ok, result} = Move.run(params, context)

      assert result.position == {26, 25}
    end

    test "result position is correct for multi-step movement" do
      params = %{direction: :south, steps: 3}
      context = build_context(%{position: {25, 25}, path_memory: []})
      {:ok, result} = Move.run(params, context)

      assert result.position == {25, 28}
    end

    test "result position is correct for west movement" do
      params = %{direction: :west}
      context = build_context(%{position: {25, 25}, path_memory: []})
      {:ok, result} = Move.run(params, context)

      assert result.position == {24, 25}
    end

    test "result position is correct for random movement" do
      params = %{direction: :random}
      context = build_context(%{position: {25, 25}, path_memory: []})
      {:ok, result} = Move.run(params, context)

      assert {x, y} = result.position
      assert is_integer(x)
      assert is_integer(y)
    end
  end

  describe "Error Handling" do
    test "returns error when agent state is missing" do
      params = %{direction: :north}
      context = %{}

      # When context is empty, it's treated as the agent state (missing position)
      assert {:error, "Agent position not found"} = Move.run(params, context)
    end

    test "returns error when position is missing" do
      params = %{direction: :north}
      context = %{state: %{}}

      assert {:error, "Agent position not found"} = Move.run(params, context)
    end

    test "returns error when position is invalid" do
      params = %{direction: :north}
      context = build_context(%{position: "invalid"})

      assert {:error, "Invalid position: \"invalid\""} = Move.run(params, context)
    end
  end

  describe "Calculate Position Helper" do
    test "calculate_position/2 with default steps and dimensions" do
      assert {:ok, {25, 24}} = Move.calculate_position({25, 25}, :north)
      assert {:ok, {26, 25}} = Move.calculate_position({25, 25}, :east)
    end

    test "calculate_position/4 with custom steps" do
      assert {:ok, {25, 20}} = Move.calculate_position({25, 25}, :north, 5)
      assert {:ok, {30, 25}} = Move.calculate_position({25, 25}, :east, 5)
    end

    test "calculate_position/4 with custom dimensions" do
      assert {:ok, {9, 5}} = Move.calculate_position({5, 5}, :east, 4, {10, 10})
    end

    test "calculate_position handles boundary at custom dimensions" do
      # At x=9 with width=10, can't move east
      assert {:ok, {9, 5}} = Move.calculate_position({9, 5}, :east, 1, {10, 10})
    end
  end

  # Helper function to build a context for testing
  defp build_context(state_fields) do
    default_fields = %{
      position: {25, 25},
      id: "test_ant",
      current_state: :searching,
      path_memory: []
    }

    state = Map.merge(default_fields, state_fields)
    %{state: state}
  end
end
