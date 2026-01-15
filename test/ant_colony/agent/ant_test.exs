defmodule AntColony.Agent.AntTest do
  @moduledoc """
  Unit tests for the AntColony.Agent.Ant module.

  Tests agent creation, schema validation, FSM states, and helper functions.
  """

  use ExUnit.Case, async: true

  alias AntColony.Agent.Ant

  describe "Module Metadata" do
    test "defines correct metadata" do
      assert Ant.name() == "ant"
      assert Ant.description() == "An individual ant agent in the colony simulation"
      assert Ant.category() == "ant"
      assert Ant.tags() == ["forager", "colony"]
      assert Ant.vsn() == "1.0.0"
    end

    test "uses FSM strategy" do
      assert Ant.strategy() == Jido.Agent.Strategy.FSM
    end

    test "has correct strategy opts" do
      opts = Ant.strategy_opts()
      assert opts[:initial_state] == :at_nest
      assert opts[:auto_transition] == false
      assert is_map(opts[:transitions])
    end

    test "signal_routes returns empty list" do
      assert Ant.signal_routes() == []
    end
  end

  describe "Agent Creation (1.4.7)" do
    test "creates agent with auto-generated id" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert is_binary(agent.id)
      assert String.length(agent.id) > 0
    end

    test "creates agent with custom id" do
      agent = Ant.new(
        id: "ant_123",
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}}
      )

      assert agent.id == "ant_123"
    end

    test "applies schema defaults to state" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.path_memory == []
      assert agent.state.current_state == :at_nest
      assert agent.state.has_food? == false
      assert agent.state.known_food_sources == []
      assert agent.state.energy == 100
      assert agent.state.max_energy == 100
      assert agent.state.age == 0
    end

    test "merges initial state with defaults" do
      agent = Ant.new(
        state: %{
          generation_id: 1,
          position: {10, 10},
          nest_position: {25, 25},
          energy: 50,
          age: 5
        }
      )

      assert agent.state.position == {10, 10}
      assert agent.state.nest_position == {25, 25}
      assert agent.state.energy == 50
      assert agent.state.age == 5
      assert agent.state.max_energy == 100  # default preserved
    end

    test "populates agent metadata" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.name == "ant"
      assert agent.description == "An individual ant agent in the colony simulation"
      assert agent.category == "ant"
      assert agent.tags == ["forager", "colony"]
      assert agent.vsn == "1.0.0"
    end
  end

  describe "Schema Validation (1.4.5)" do
    test "requires generation_id" do
      # generation_id is required - validation returns error when missing
      agent = Ant.new(state: %{position: {25, 25}, nest_position: {25, 25}})
      assert {:error, _error} = Ant.validate(agent)
    end

    test "requires position" do
      agent = Ant.new(state: %{generation_id: 1, nest_position: {25, 25}})
      assert {:error, _error} = Ant.validate(agent)
    end

    test "requires nest_position" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}})
      assert {:error, _error} = Ant.validate(agent)
    end

    test "accepts valid position tuple" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {10, 20}, nest_position: {25, 25}}
      )

      assert agent.state.position == {10, 20}
    end

    test "accepts valid nest_position tuple" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {50, 50}}
      )

      assert agent.state.nest_position == {50, 50}
    end

    test "field values - id is optional" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      # id is auto-generated when not provided
      assert is_binary(agent.id)
    end

    test "field values - generation_id is positive integer" do
      agent = Ant.new(state: %{generation_id: 5, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.generation_id == 5
    end

    test "field values - position is tuple" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {15, 30}, nest_position: {25, 25}}
      )

      assert agent.state.position == {15, 30}
      assert is_tuple(agent.state.position)
      assert tuple_size(agent.state.position) == 2
    end

    test "field values - nest_position is tuple" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {40, 45}}
      )

      assert agent.state.nest_position == {40, 45}
      assert is_tuple(agent.state.nest_position)
      assert tuple_size(agent.state.nest_position) == 2
    end

    test "field values - path_memory defaults to empty list" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.path_memory == []
      assert is_list(agent.state.path_memory)
    end

    test "field values - current_state defaults to :at_nest" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.current_state == :at_nest
      assert is_atom(agent.state.current_state)
    end

    test "field values - has_food? defaults to false" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.has_food? == false
      assert is_boolean(agent.state.has_food?)
    end

    test "field values - carried_food_level is optional" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      # carried_food_level is not set by default
      refute Map.has_key?(agent.state, :carried_food_level)
    end

    test "field values - known_food_sources defaults to empty list" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.known_food_sources == []
      assert is_list(agent.state.known_food_sources)
    end

    test "field values - energy defaults to 100" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.energy == 100
      assert is_integer(agent.state.energy)
    end

    test "field values - max_energy defaults to 100" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.max_energy == 100
      assert is_integer(agent.state.max_energy)
    end

    test "field values - age defaults to 0" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert agent.state.age == 0
      assert is_integer(agent.state.age)
    end
  end

  describe "FSM States (1.4.6)" do
    test "initial state is :at_nest" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.current_state(agent) == :at_nest
    end

    test "can transition from :at_nest to :searching" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert {:ok, updated} = Ant.transition_to_state(agent, :searching)
      assert Ant.current_state(updated) == :searching
    end

    test "can transition from :searching to :at_nest" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, current_state: :searching}
      )

      assert {:ok, updated} = Ant.transition_to_state(agent, :at_nest)
      assert Ant.current_state(updated) == :at_nest
    end

    test "tracks previous state on transition" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert {:ok, updated} = Ant.transition_to_state(agent, :searching)
      assert Ant.previous_state(updated) == :at_nest
    end

    test "rejects invalid transition from :at_nest to :returning_to_nest" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert {:error, {:invalid_transition, from: :at_nest, to: :returning_to_nest, allowed: [:searching]}} =
               Ant.transition_to_state(agent, :returning_to_nest)
    end

    test "rejects invalid transition from :searching to :communicating" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, current_state: :searching}
      )

      assert {:error, {:invalid_transition, from: :searching, to: :communicating, allowed: [:at_nest]}} =
               Ant.transition_to_state(agent, :communicating)
    end

    test "state validation - allowed transitions from :at_nest" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      # Only :searching is allowed from :at_nest in Phase 1
      assert {:ok, _updated} = Ant.transition_to_state(agent, :searching)
    end

    test "state validation - allowed transitions from :searching" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, current_state: :searching}
      )

      # Only :at_nest is allowed from :searching in Phase 1
      assert {:ok, _updated} = Ant.transition_to_state(agent, :at_nest)
    end
  end

  describe "Helper Functions - Position Accessors" do
    test "position/1 returns current position" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {15, 20}, nest_position: {25, 25}}
      )

      assert Ant.position(agent) == {15, 20}
    end

    test "nest_position/1 returns nest position" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {40, 45}}
      )

      assert Ant.nest_position(agent) == {40, 45}
    end

    test "update_position/2 updates position" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}}
      )

      updated = Ant.update_position(agent, {26, 27})
      assert Ant.position(updated) == {26, 27}
    end

    test "at_nest?/1 returns true when at nest position" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}}
      )

      assert Ant.at_nest?(agent) == true
    end

    test "at_nest?/1 returns false when not at nest position" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {10, 10}, nest_position: {25, 25}}
      )

      assert Ant.at_nest?(agent) == false
    end
  end

  describe "Helper Functions - Energy Management" do
    test "energy/1 returns current energy" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 75}
      )

      assert Ant.energy(agent) == 75
    end

    test "consume_energy/2 decreases energy by amount" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 100}
      )

      updated = Ant.consume_energy(agent, 20)
      assert Ant.energy(updated) == 80
    end

    test "consume_energy/2 prevents energy from going below 0" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 10}
      )

      updated = Ant.consume_energy(agent, 20)
      assert Ant.energy(updated) == 0
    end

    test "has_energy?/2 returns true when sufficient energy" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 50}
      )

      assert Ant.has_energy?(agent, 30) == true
    end

    test "has_energy?/2 returns false when insufficient energy" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 20}
      )

      assert Ant.has_energy?(agent, 30) == false
    end

    test "has_energy?/2 returns true for exact energy match" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, energy: 30}
      )

      assert Ant.has_energy?(agent, 30) == true
    end
  end

  describe "Helper Functions - Food Handling" do
    test "has_food?/1 returns false by default" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.has_food?(agent) == false
    end

    test "pick_up_food/2 sets has_food? to true" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert {:ok, updated} = Ant.pick_up_food(agent, 4)
      assert Ant.has_food?(updated) == true
      assert updated.state.carried_food_level == 4
    end

    test "pick_up_food/2 returns error if already carrying" do
      agent = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25},
          has_food?: true,
          carried_food_level: 3
        }
      )

      assert {:error, :already_has_food} = Ant.pick_up_food(agent, 4)
    end

    test "drop_food/1 clears has_food? and returns level" do
      agent = Ant.new(
        state: %{
          generation_id: 1,
          position: {25, 25},
          nest_position: {25, 25},
          has_food?: true,
          carried_food_level: 5
        }
      )

      assert {:ok, updated, 5} = Ant.drop_food(agent)
      assert Ant.has_food?(updated) == false
      refute Map.has_key?(updated.state, :carried_food_level)
    end

    test "drop_food/1 returns error if not carrying" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert {:error, :no_food} = Ant.drop_food(agent)
    end
  end

  describe "Helper Functions - Memory Management" do
    test "path_memory/1 returns empty list by default" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.path_memory(agent) == []
    end

    test "remember_position/3 adds position to path memory" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      updated = Ant.remember_position(agent, {10, 10}, %{food?: true})
      updated = Ant.remember_position(updated, {11, 11}, %{food?: false})

      memory = Ant.path_memory(updated)
      assert length(memory) == 2
      assert [{{10, 10}, %{food?: true}}, {{11, 11}, %{food?: false}}] = memory
    end

    test "known_food_sources/1 returns empty list by default" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.known_food_sources(agent) == []
    end

    test "add_known_food_source/4 adds new food source" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})
      timestamp = DateTime.utc_now()

      assert {:ok, updated} = Ant.add_known_food_source(agent, {10, 10}, 4, timestamp)

      sources = Ant.known_food_sources(updated)
      assert length(sources) == 1
      assert %{position: {10, 10}, level: 4, last_updated: ^timestamp} = List.first(sources)
    end

    test "add_known_food_source/4 returns error for duplicate position" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})
      timestamp = DateTime.utc_now()

      assert {:ok, agent} = Ant.add_known_food_source(agent, {10, 10}, 4, timestamp)
      assert {:error, :already_known} = Ant.add_known_food_source(agent, {10, 10}, 5, timestamp)
    end

    test "add_known_food_source/4 allows different positions" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})
      timestamp = DateTime.utc_now()

      assert {:ok, agent} = Ant.add_known_food_source(agent, {10, 10}, 4, timestamp)
      assert {:ok, updated} = Ant.add_known_food_source(agent, {20, 20}, 3, timestamp)

      sources = Ant.known_food_sources(updated)
      assert length(sources) == 2
    end
  end

  describe "Helper Functions - Age and Generation" do
    test "generation_id/1 returns generation ID" do
      agent = Ant.new(state: %{generation_id: 5, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.generation_id(agent) == 5
    end

    test "age/1 returns current age" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      assert Ant.age(agent) == 0
    end

    test "increment_age/1 increases age by 1" do
      agent = Ant.new(
        state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}, age: 5}
      )

      updated = Ant.increment_age(agent)
      assert Ant.age(updated) == 6
    end

    test "increment_age/1 works from age 0" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      updated = Ant.increment_age(agent)
      assert Ant.age(updated) == 1
    end
  end

  describe "Type Specifications" do
    test "position type accepts {non_neg_integer, non_neg_integer}" do
      # Test origin
      agent = Ant.new(state: %{generation_id: 1, position: {0, 0}, nest_position: {0, 0}})
      assert Ant.position(agent) == {0, 0}

      # Test various valid positions
      agent = Ant.new(state: %{generation_id: 1, position: {10, 20}, nest_position: {25, 25}})
      assert Ant.position(agent) == {10, 20}

      agent = Ant.new(state: %{generation_id: 1, position: {100, 100}, nest_position: {100, 100}})
      assert Ant.position(agent) == {100, 100}
    end

    test "food source type is map with position, level, last_updated" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})
      timestamp = DateTime.utc_now()

      {:ok, updated} = Ant.add_known_food_source(agent, {15, 15}, 3, timestamp)

      [source | _] = Ant.known_food_sources(updated)
      assert Map.has_key?(source, :position)
      assert Map.has_key?(source, :level)
      assert Map.has_key?(source, :last_updated)
    end

    test "path memory type is list of {position, map} tuples" do
      agent = Ant.new(state: %{generation_id: 1, position: {25, 25}, nest_position: {25, 25}})

      updated = Ant.remember_position(agent, {10, 10}, %{food: true})
      updated = Ant.remember_position(updated, {11, 11}, %{obstacle: false})

      memory = Ant.path_memory(updated)

      assert is_list(memory)
      assert [{{10, 10}, %{food: true}}, {{11, 11}, %{obstacle: false}}] = memory
    end
  end
end
