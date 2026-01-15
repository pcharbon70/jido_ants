defmodule AntColony.PlaneTest do
  @moduledoc """
  Unit tests for the AntColony.Plane GenServer.

  Tests the Plane initialization, state query functions, food source management,
  ant position registry, nearby ants detection, and concurrent access.
  """

  use ExUnit.Case, async: false

  alias AntColony.Plane
  alias AntColony.Plane.State.FoodSource

  describe "Plane Initialization" do
    setup do
      # Start a fresh Plane for each test with default dimensions
      start_supervised!({Plane, []})
      :ok
    end

    test "plane starts with default dimensions" do
      {width, height} = Plane.get_dimensions()
      assert width == 50
      assert height == 50
    end

    test "nest is at center of grid" do
      nest_location = Plane.get_nest_location()
      {width, height} = Plane.get_dimensions()

      expected_x = div(width, 2)
      expected_y = div(height, 2)

      assert nest_location == {expected_x, expected_y}
    end

    test "plane starts with no food sources" do
      {:ok, state} = Plane.get_state()
      assert state.food_sources == %{}
    end

    test "plane starts with no ants registered" do
      ant_positions = Plane.get_ant_positions()
      assert ant_positions == %{}
    end
  end

  describe "Plane Initialization with Custom Dimensions" do
    setup do
      # Start Plane with custom dimensions for these tests
      # We don't use start_supervised! to avoid conflicts with the default setup
      {:ok, _pid} = Plane.start_link(width: 100, height: 200)

      on_exit(fn ->
        # Ensure Plane is stopped after this describe block
        Plane.stop()
      end)

      :ok
    end

    test "plane starts with custom dimensions" do
      {width, height} = Plane.get_dimensions()
      assert width == 100
      assert height == 200
    end

    test "nest is at center of custom grid" do
      nest_location = Plane.get_nest_location()
      assert nest_location == {50, 100}
    end
  end

  describe "State Query Functions" do
    setup do
      start_supervised!({Plane, []})
      :ok
    end

    test "get_state/0 returns full state" do
      {:ok, state} = Plane.get_state()

      assert is_map(state)
      assert state.width == 50
      assert state.height == 50
      assert is_tuple(state.nest_location)
      assert is_map(state.food_sources)
      assert is_map(state.ant_positions)
    end

    test "get_dimensions/0 returns width and height" do
      {width, height} = Plane.get_dimensions()

      assert is_integer(width)
      assert is_integer(height)
      assert width > 0
      assert height > 0
    end

    test "get_nest_location/0 returns nest position" do
      nest_location = Plane.get_nest_location()

      assert is_tuple(nest_location)
      assert tuple_size(nest_location) == 2
    end

    test "get_food_at/1 returns food source when present" do
      food = FoodSource.new(3, 15)
      :ok = Plane.set_food_sources(%{{10, 10} => food})

      retrieved = Plane.get_food_at({10, 10})

      assert retrieved.level == 3
      assert retrieved.quantity == 15
    end

    test "get_food_at/1 returns nil when no food" do
      retrieved = Plane.get_food_at({99, 99})
      assert is_nil(retrieved)
    end
  end

  describe "Food Source Management" do
    setup do
      start_supervised!({Plane, []})
      :ok
    end

    test "set_food_sources/1 adds food to plane" do
      food = FoodSource.new(5, 20)
      :ok = Plane.set_food_sources(%{{5, 5} => food})

      retrieved = Plane.get_food_at({5, 5})
      assert retrieved.level == 5
      assert retrieved.quantity == 20
    end

    test "set_food_sources/1 replaces existing food" do
      food1 = FoodSource.new(3, 10)
      food2 = FoodSource.new(4, 25)

      :ok = Plane.set_food_sources(%{{5, 5} => food1})
      :ok = Plane.set_food_sources(%{{10, 10} => food2})

      # First food should be gone
      assert Plane.get_food_at({5, 5}) == nil

      # Second food should be present
      retrieved = Plane.get_food_at({10, 10})
      assert retrieved.level == 4
      assert retrieved.quantity == 25
    end

    test "deplete_food/2 reduces quantity" do
      food = FoodSource.new(3, 10)
      :ok = Plane.set_food_sources(%{{5, 5} => food})

      assert {:ok, 7} = Plane.deplete_food({5, 5}, 3)

      retrieved = Plane.get_food_at({5, 5})
      assert retrieved.quantity == 7
    end

    test "deplete_food/2 removes food when quantity reaches 0" do
      food = FoodSource.new(3, 5)
      :ok = Plane.set_food_sources(%{{5, 5} => food})

      assert {:ok, 0} = Plane.deplete_food({5, 5}, 5)

      # Food should be removed
      assert Plane.get_food_at({5, 5}) == nil
    end

    test "deplete_food/2 returns error when no food" do
      assert {:error, :no_food} = Plane.deplete_food({99, 99}, 1)
    end
  end

  describe "Ant Position Registry" do
    setup do
      start_supervised!({Plane, []})
      :ok
    end

    test "register_ant/2 adds ant to registry" do
      :ok = Plane.register_ant("ant_1", {10, 10})

      ant_positions = Plane.get_ant_positions()
      assert ant_positions["ant_1"] == {10, 10}
    end

    test "register_ant/2 replaces existing ant position" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_1", {20, 20})

      {:ok, position} = Plane.get_ant_position("ant_1")
      assert position == {20, 20}
    end

    test "unregister_ant/1 removes ant from registry" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.unregister_ant("ant_1")

      ant_positions = Plane.get_ant_positions()
      assert Map.has_key?(ant_positions, "ant_1") == false
    end

    test "unregister_ant/1 succeeds even for unknown ant" do
      # Unregistering a non-existent ant should succeed silently
      :ok = Plane.unregister_ant("unknown_ant")
    end

    test "update_ant_position/2 updates ant position" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.update_ant_position("ant_1", {15, 15})

      {:ok, position} = Plane.get_ant_position("ant_1")
      assert position == {15, 15}
    end

    test "get_ant_position/1 returns ant position when found" do
      :ok = Plane.register_ant("worker_1", {25, 25})

      assert {:ok, {25, 25}} = Plane.get_ant_position("worker_1")
    end

    test "get_ant_position/1 returns error for unknown ant" do
      assert {:error, :not_found} = Plane.get_ant_position("unknown")
    end
  end

  describe "Nearby Ants Detection" do
    setup do
      start_supervised!({Plane, []})
      :ok
    end

    test "get_nearby_ants/2 finds ants within radius" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_2", {11, 10})
      :ok = Plane.register_ant("ant_3", {10, 12})
      :ok = Plane.register_ant("ant_4", {15, 15})

      nearby = Plane.get_nearby_ants({10, 10}, 3)

      # ant_2 is at distance 1, ant_3 is at distance 2
      # ant_4 is at distance ~7.07 (outside radius)
      ant_ids = Enum.map(nearby, fn {ant_id, _pos} -> ant_id end)

      assert "ant_1" in ant_ids
      assert "ant_2" in ant_ids
      assert "ant_3" in ant_ids
      refute "ant_4" in ant_ids
    end

    test "get_nearby_ants/2 excludes ants outside radius" do
      :ok = Plane.register_ant("close_ant", {10, 10})
      :ok = Plane.register_ant("far_ant", {20, 20})

      nearby = Plane.get_nearby_ants({10, 10}, 3)

      ant_ids = Enum.map(nearby, fn {ant_id, _pos} -> ant_id end)

      assert "close_ant" in ant_ids
      refute "far_ant" in ant_ids
    end

    test "get_nearby_ants/2 returns empty when no ants nearby" do
      :ok = Plane.register_ant("distant_ant", {50, 50})

      nearby = Plane.get_nearby_ants({10, 10}, 5)

      assert nearby == []
    end

    test "get_nearby_ants/3 excludes specified ant_id" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_2", {11, 10})

      nearby = Plane.get_nearby_ants({10, 10}, 3, exclude_ant_id: "ant_1")

      ant_ids = Enum.map(nearby, fn {ant_id, _pos} -> ant_id end)

      refute "ant_1" in ant_ids
      assert "ant_2" in ant_ids
    end

    test "get_nearby_ants/2 uses Euclidean distance" do
      # Place ant diagonally at distance sqrt(3^2 + 4^2) = 5
      :ok = Plane.register_ant("diagonal_ant", {13, 14})

      # Center at {10, 10}, radius 5 should include diagonal ant
      nearby = Plane.get_nearby_ants({10, 10}, 5)

      assert [{"diagonal_ant", {13, 14}}] = nearby
    end
  end

  describe "Concurrent Access" do
    setup do
      start_supervised!({Plane, []})
      :ok
    end

    test "concurrent ant registrations succeed" do
      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            ant_id = "ant_#{i}"
            position = {i * 5, i * 5}
            Plane.register_ant(ant_id, position)
          end)
        end

      results = Task.await_many(tasks, 5000)

      assert Enum.all?(results, fn result -> result == :ok end)

      # Verify all ants were registered
      ant_positions = Plane.get_ant_positions()
      assert map_size(ant_positions) == 10
    end

    test "concurrent position updates succeed" do
      # Register an ant
      :ok = Plane.register_ant("mobile_ant", {10, 10})

      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            new_position = {i, i}
            Plane.update_ant_position("mobile_ant", new_position)
          end)
        end

      results = Task.await_many(tasks, 5000)

      # All updates should succeed
      assert Enum.all?(results, fn result -> result == :ok end)

      # Final position should be one of the updates
      {:ok, _final_position} = Plane.get_ant_position("mobile_ant")
    end

    test "concurrent queries return consistent state" do
      :ok = Plane.register_ant("ant_1", {10, 10})
      :ok = Plane.register_ant("ant_2", {20, 20})

      tasks =
        for _i <- 1..10 do
          Task.async(fn ->
            Plane.get_ant_positions()
          end)
        end

      results = Task.await_many(tasks, 5000)

      # All queries should return the same state
      assert Enum.all?(results, fn positions ->
               map_size(positions) == 2 and
                 Map.has_key?(positions, "ant_1") and
                 Map.has_key?(positions, "ant_2")
             end)
    end
  end
end
