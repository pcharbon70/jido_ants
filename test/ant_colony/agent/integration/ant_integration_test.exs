defmodule AntColony.Agent.AntIntegrationTest do
  @moduledoc """
  Integration tests for the AntColony.Agent.Ant module.

  Tests end-to-end functionality including agent lifecycle,
  interaction with the Plane environment, and state transitions.
  """

  use ExUnit.Case

  alias AntColony.Agent.Ant
  alias AntColony.Plane

  describe "Agent Lifecycle" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "ant can be created with required fields" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      assert is_binary(ant.id)
      assert ant.state.generation_id == 1
      assert ant.state.position == {25, 25}
      assert ant.state.nest_position == {25, 25}
    end

    test "ant state persists across operations" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25},
          energy: 80,
          age: 5
        }
      )

      # Update position
      updated = Ant.update_position(ant, {26, 26})
      assert Ant.position(updated) == {26, 26}

      # Energy is preserved
      assert Ant.energy(updated) == 80
      assert Ant.age(updated) == 5
    end

    test "ant can transition between states" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      assert Ant.current_state(ant) == :at_nest

      {:ok, ant} = Ant.transition_to_state(ant, :searching)
      assert Ant.current_state(ant) == :searching
      assert Ant.previous_state(ant) == :at_nest

      {:ok, ant} = Ant.transition_to_state(ant, :at_nest)
      assert Ant.current_state(ant) == :at_nest
      assert Ant.previous_state(ant) == :searching
    end

    test "ant food handling lifecycle" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      # Initially not carrying food
      refute Ant.has_food?(ant)

      # Pick up food
      {:ok, ant} = Ant.pick_up_food(ant, 4)
      assert Ant.has_food?(ant)
      assert ant.state.carried_food_level == 4

      # Cannot pick up again
      assert {:error, :already_has_food} = Ant.pick_up_food(ant, 5)

      # Drop food
      {:ok, ant, level} = Ant.drop_food(ant)
      refute Ant.has_food?(ant)
      assert level == 4

      # Cannot drop again
      assert {:error, :no_food} = Ant.drop_food(ant)
    end
  end

  describe "Agent with Plane" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "ant position can be registered with Plane" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      ant_id = ant.id
      ant_position = Ant.position(ant)

      # Register ant with Plane
      :ok = Plane.register_ant(ant_id, ant_position)

      # Verify registration
      assert {:ok, {25, 25}} = Plane.get_ant_position(ant_id)

      # Ant is at its registered position
      assert Ant.at_nest?(ant)
    end

    test "multiple ants can be registered independently" do
      ants =
        for i <- 1..5 do
          Ant.new(
            id: "ant_#{i}",
            state: %{
              generation_id: 1,
              position: {25 + i, 25 + i},
              nest_position: {25, 25}
            }
          )
        end

      # Register all ants
      Enum.each(ants, fn ant ->
        :ok = Plane.register_ant(ant.id, Ant.position(ant))
      end)

      # Verify all are registered
      positions = Plane.get_ant_positions()
      assert map_size(positions) == 5

      # Verify each ant's position
      Enum.each(ants, fn ant ->
        assert {:ok, pos} = Plane.get_ant_position(ant.id)
        assert pos == Ant.position(ant)
      end)
    end

    test "ant can sense food sources from Plane" do
      # Set up food on the Plane
      food = AntColony.Plane.State.FoodSource.new(4, 20)
      :ok = Plane.set_food_sources(%{{30, 30} => food})

      # Create ant
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      # Check if food exists at position (using Plane API)
      food_at_position = Plane.get_food_at({30, 30})
      assert food_at_position.level == 4

      # Ant can remember the food source
      timestamp = DateTime.utc_now()
      {:ok, ant} = Ant.add_known_food_source(ant, {30, 30}, 4, timestamp)

      sources = Ant.known_food_sources(ant)
      assert length(sources) == 1
      assert %{position: {30, 30}, level: 4} = List.first(sources)
    end

    test "ant movement updates Plane registration" do
      ant = Ant.new(
        id: "forager_1",
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      ant_id = ant.id

      # Register initial position
      :ok = Plane.register_ant(ant_id, {25, 25})

      # Move ant
      ant = Ant.update_position(ant, {26, 26})

      # Update Plane
      :ok = Plane.update_ant_position(ant_id, {26, 26})

      # Verify updated position
      assert {:ok, {26, 26}} = Plane.get_ant_position(ant_id)
      assert Ant.position(ant) == {26, 26}
    end

    test "ant path memory tracks movement" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      # Simulate movement and memory
      positions = [{26, 26}, {27, 27}, {28, 28}, {29, 29}]

      ant =
        Enum.reduce(positions, ant, fn pos, acc ->
          Ant.remember_position(acc, pos, %{visited: true})
        end)

      memory = Ant.path_memory(ant)
      assert length(memory) == 4

      # Verify path order
      assert [{{26, 26}, %{visited: true}}, {{27, 27}, %{visited: true}}, {{28, 28}, %{visited: true}}, {{29, 29}, %{visited: true}}] =
               memory
    end

    test "ant energy decreases with movement" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25},
          energy: 100
        }
      )

      # Simulate energy consumption per move
      move_cost = 2

      ant =
        Enum.reduce(1..10, ant, fn _i, acc ->
          acc
          |> Ant.consume_energy(move_cost)
          |> Ant.increment_age()
        end)

      assert Ant.energy(ant) == 80
      assert Ant.age(ant) == 10
    end

    test "ant at_nest? check works with Plane nest location" do
      # Use default Plane nest location
      {:ok, plane_state} = Plane.get_state()
      nest_location = plane_state.nest_location

      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: nest_location,
          nest_position: nest_location
        }
      )

      assert Ant.at_nest?(ant)

      # Move ant away from nest
      ant = Ant.update_position(ant, {nest_location |> elem(0) |> Kernel.+(5), nest_location |> elem(1)})
      refute Ant.at_nest?(ant)
    end
  end

  describe "Agent FSM Transitions with Plane Context" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "at_nest state - ant at nest position" do
      {:ok, plane_state} = Plane.get_state()
      nest_location = plane_state.nest_location

      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: nest_location,
          nest_position: nest_location,
          current_state: :at_nest
        }
      )

      assert Ant.current_state(ant) == :at_nest
      assert Ant.at_nest?(ant)
    end

    test "searching state - ant leaves nest to explore" do
      {:ok, plane_state} = Plane.get_state()
      nest_location = plane_state.nest_location

      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: nest_location,
          nest_position: nest_location,
          current_state: :at_nest
        }
      )

      # Transition to searching
      {:ok, ant} = Ant.transition_to_state(ant, :searching)

      assert Ant.current_state(ant) == :searching
      assert Ant.previous_state(ant) == :at_nest

      # Register with Plane at new position
      new_position = {nest_location |> elem(0) |> Kernel.+(5), nest_location |> elem(1)}
      ant = Ant.update_position(ant, new_position)

      :ok = Plane.register_ant(ant.id, new_position)

      assert {:ok, ^new_position} = Plane.get_ant_position(ant.id)
      refute Ant.at_nest?(ant)
    end
  end

  describe "Agent FSM Validation" do
    test "returning_to_nest is invalid in Phase 1" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      # Cannot transition directly to :returning_to_nest in Phase 1
      assert {:error, {:invalid_transition, from: :at_nest, to: :returning_to_nest, allowed: [:searching]}} =
               Ant.transition_to_state(ant, :returning_to_nest)
    end
  end

  describe "Agent Memory Integration" do
    setup do
      Plane.stop()
      {:ok, _pid} = Plane.start_link([])

      on_exit(fn ->
        Plane.stop()
      end)

      :ok
    end

    test "ant discovers and remembers food sources" do
      # Set up multiple food sources on Plane
      food_sources = %{
        {10, 10} => AntColony.Plane.State.FoodSource.new(3, 15),
        {20, 20} => AntColony.Plane.State.FoodSource.new(5, 25),
        {30, 30} => AntColony.Plane.State.FoodSource.new(2, 10)
      }

      :ok = Plane.set_food_sources(food_sources)

      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      timestamp = DateTime.utc_now()

      # Ant discovers all three food sources
      {:ok, ant} = Ant.add_known_food_source(ant, {10, 10}, 3, timestamp)
      {:ok, ant} = Ant.add_known_food_source(ant, {20, 20}, 5, timestamp)
      {:ok, ant} = Ant.add_known_food_source(ant, {30, 30}, 2, timestamp)

      known = Ant.known_food_sources(ant)
      assert length(known) == 3

      # Verify all sources are remembered
      positions = Enum.map(known, fn fs -> fs.position end)
      assert {10, 10} in positions
      assert {20, 20} in positions
      assert {30, 30} in positions
    end

    test "ant does not add duplicate food sources" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      timestamp = DateTime.utc_now()

      {:ok, ant} = Ant.add_known_food_source(ant, {15, 15}, 3, timestamp)
      {:ok, ant} = Ant.add_known_food_source(ant, {20, 20}, 4, timestamp)

      # Try to add duplicate
      assert {:error, :already_known} = Ant.add_known_food_source(ant, {15, 15}, 5, timestamp)

      # Original source is preserved
      known = Ant.known_food_sources(ant)
      assert length(known) == 2

      source = Enum.find(known, fn fs -> fs.position == {15, 15} end)
      assert source.level == 3  # Original level, not 5
    end

    test "path memory persists across state transitions" do
      ant = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25}
        }
      )

      # Build path memory
      ant = Ant.remember_position(ant, {26, 26}, %{food_found?: false})
      ant = Ant.remember_position(ant, {27, 27}, %{food_found?: false})
      ant = Ant.remember_position(ant, {28, 28}, %{food_found?: true})

      # Transition through states
      {:ok, ant} = Ant.transition_to_state(ant, :searching)
      {:ok, ant} = Ant.transition_to_state(ant, :at_nest)

      # Path memory is preserved
      memory = Ant.path_memory(ant)
      assert length(memory) == 3
    end
  end
end
