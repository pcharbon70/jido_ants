defmodule AntColony.PlaneIntegrationTest do
  @moduledoc """
  Integration tests for the Plane GenServer.

  These tests verify end-to-end functionality including complete lifecycle,
  multi-ant simulation, and food source interactions.
  """

  use ExUnit.Case

  alias AntColony.Plane
  alias AntColony.Plane.State.FoodSource

  describe "Plane Lifecycle" do
    test "plane starts and stops cleanly" do
      # Ensure Plane is not running
      Plane.stop()

      # Start the Plane
      assert {:ok, pid} = Plane.start_link([])
      assert is_pid(pid)
      assert Process.alive?(pid)

      # Verify it's accessible
      {width, height} = Plane.get_dimensions()
      assert width == 50
      assert height == 50

      # Stop the Plane
      assert :ok = Plane.stop()

      # Verify it's no longer accessible
      refute Process.alive?(pid)
    end

    test "plane state persists across calls" do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      # Set initial state
      food = FoodSource.new(3, 15)
      :ok = Plane.set_food_sources(%{{10, 10} => food})
      :ok = Plane.register_ant("ant_1", {5, 5})

      # Verify state persists across multiple calls
      assert {:ok, state} = Plane.get_state()
      assert state.food_sources == %{{10, 10} => food}

      assert Plane.get_ant_positions() == %{"ant_1" => {5, 5}}

      # Update state
      :ok = Plane.update_ant_position("ant_1", {10, 10})

      # Verify update persists
      assert {:ok, {10, 10}} = Plane.get_ant_position("ant_1")

      Plane.stop()
    end

    test "plane can be restarted" do
      Plane.stop()

      # First run
      {:ok, pid1} = Plane.start_link([])
      :ok = Plane.register_ant("ant_1", {10, 10})

      Plane.stop()
      refute Process.alive?(pid1)

      # Second run - should start fresh
      {:ok, pid2} = Plane.start_link([])

      # State should be reset
      ant_positions = Plane.get_ant_positions()
      assert ant_positions == %{}

      # Verify new pid
      assert pid2 != pid1

      Plane.stop()
    end
  end

  describe "Multi-Ant Simulation" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "multiple ants can register simultaneously" do
      ant_ids = ["forager_1", "forager_2", "forager_3", "forager_4", "forager_5"]

      # Register all ants
      Enum.each(ant_ids, fn ant_id ->
        :ok = Plane.register_ant(ant_id, {25, 25})
      end)

      # Verify all are registered
      ant_positions = Plane.get_ant_positions()
      assert map_size(ant_positions) == 5

      # Verify each ant has its position
      Enum.each(ant_ids, fn ant_id ->
        assert {:ok, {25, 25}} = Plane.get_ant_position(ant_id)
      end)
    end

    test "ants can move independently" do
      # Register 3 ants
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_2", {20, 20})
      :ok = Plane.register_ant("ant_3", {30, 30})

      # Move each ant independently
      :ok = Plane.update_ant_position("ant_1", {11, 11})
      :ok = Plane.update_ant_position("ant_2", {21, 21})
      :ok = Plane.update_ant_position("ant_3", {31, 31})

      # Verify each ant moved correctly
      assert {:ok, {11, 11}} = Plane.get_ant_position("ant_1")
      assert {:ok, {21, 21}} = Plane.get_ant_position("ant_2")
      assert {:ok, {31, 31}} = Plane.get_ant_position("ant_3")
    end

    test "nearby ants are detected correctly" do
      # Create a scenario with 10 ants spread across the plane
      ant_positions = %{
        "cluster_center" => {25, 25},
        "north" => {25, 22},
        "south" => {25, 28},
        "east" => {28, 25},
        "west" => {22, 25},
        "far_north" => {25, 10},
        "far_south" => {25, 40},
        "far_east" => {40, 25},
        "far_west" => {10, 25},
        "diagonal" => {27, 27}
      }

      # Register all ants
      Enum.each(ant_positions, fn {ant_id, pos} ->
        :ok = Plane.register_ant(ant_id, pos)
      end)

      # Find ants within radius 3 of center
      nearby = Plane.get_nearby_ants({25, 25}, 3)
      nearby_ids = Enum.map(nearby, fn {ant_id, _pos} -> ant_id end)

      # Should include cluster ants (distance <= 3)
      assert "cluster_center" in nearby_ids
      assert "north" in nearby_ids  # distance 3
      assert "south" in nearby_ids  # distance 3
      assert "east" in nearby_ids   # distance 3
      assert "west" in nearby_ids   # distance 3
      assert "diagonal" in nearby_ids  # distance sqrt(8) ≈ 2.83

      # Should NOT include far ants
      refute "far_north" in nearby_ids
      refute "far_south" in nearby_ids
      refute "far_east" in nearby_ids
      refute "far_west" in nearby_ids
    end

    test "ants can unregister independently" do
      # Register multiple ants
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_2", {20, 20})
      :ok = Plane.register_ant("ant_3", {30, 30})

      # Unregister one ant
      :ok = Plane.unregister_ant("ant_2")

      # Verify only ant_2 is gone
      assert {:ok, {10, 10}} = Plane.get_ant_position("ant_1")
      assert {:error, :not_found} = Plane.get_ant_position("ant_2")
      assert {:ok, {30, 30}} = Plane.get_ant_position("ant_3")

      # Remaining count should be 2
      ant_positions = Plane.get_ant_positions()
      assert map_size(ant_positions) == 2
    end
  end

  describe "Food Interaction" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "multiple food sources exist independently" do
      # Create 3 food sources at different locations with different levels
      food1 = FoodSource.new(5, 20)
      food2 = FoodSource.new(3, 15)
      food3 = FoodSource.new(1, 10)

      food_sources = %{
        {10, 10} => food1,
        {25, 25} => food2,
        {40, 40} => food3
      }

      :ok = Plane.set_food_sources(food_sources)

      # Verify each food source exists independently
      retrieved1 = Plane.get_food_at({10, 10})
      assert retrieved1.level == 5
      assert retrieved1.quantity == 20

      retrieved2 = Plane.get_food_at({25, 25})
      assert retrieved2.level == 3
      assert retrieved2.quantity == 15

      retrieved3 = Plane.get_food_at({40, 40})
      assert retrieved3.level == 1
      assert retrieved3.quantity == 10
    end

    test "ants can deplete food independently" do
      # Create food source with large quantity
      food = FoodSource.new(5, 100)
      :ok = Plane.set_food_sources(%{{25, 25} => food})

      # Register two ants at the food location
      :ok = Plane.register_ant("ant_1", {25, 25})
      :ok = Plane.register_ant("ant_2", {25, 25})

      # Both ants deplete food independently
      assert {:ok, 90} = Plane.deplete_food({25, 25}, 10)
      assert {:ok, 80} = Plane.deplete_food({25, 25}, 10)

      # Verify remaining quantity
      remaining = Plane.get_food_at({25, 25})
      assert remaining.quantity == 80
    end

    test "food is removed when depleted" do
      # Create food source
      food = FoodSource.new(3, 5)
      :ok = Plane.set_food_sources(%{{15, 15} => food})

      # Verify food exists
      assert %FoodSource{} = Plane.get_food_at({15, 15})

      # Deplete all food
      assert {:ok, 0} = Plane.deplete_food({15, 15}, 5)

      # Verify food is removed
      assert nil == Plane.get_food_at({15, 15})

      # Attempting to deplete again should error
      assert {:error, :no_food} = Plane.deplete_food({15, 15}, 1)
    end

    test "food state is consistent across queries" do
      # Create multiple food sources
      food_sources = %{
        {10, 10} => FoodSource.new(3, 30),
        {20, 20} => FoodSource.new(4, 25),
        {30, 30} => FoodSource.new(5, 20)
      }

      :ok = Plane.set_food_sources(food_sources)

      # Query each position multiple times
      for _ <- 1..5 do
        assert Plane.get_food_at({10, 10}).quantity == 30
        assert Plane.get_food_at({20, 20}).quantity == 25
        assert Plane.get_food_at({30, 30}).quantity == 20
      end

      # Deplete from one source
      assert {:ok, 25} = Plane.deplete_food({10, 10}, 5)

      # Verify consistency - only depleted source changed
      assert Plane.get_food_at({10, 10}).quantity == 25
      assert Plane.get_food_at({20, 20}).quantity == 25
      assert Plane.get_food_at({30, 30}).quantity == 20

      # Get full state and verify
      {:ok, state} = Plane.get_state()
      assert state.food_sources[{10, 10}].quantity == 25
      assert state.food_sources[{20, 20}].quantity == 25
      assert state.food_sources[{30, 30}].quantity == 20
    end
  end
end
