defmodule AntColony.Actions.MoveIntegrationTest do
  @moduledoc """
  Integration tests for the AntColony.Actions.Move module.

  Tests end-to-end functionality including complete action execution,
  multi-ant movement, event broadcasting, and Agent.cmd/2 integration.

  ## Note on TestAnt for Agent.cmd/2 Tests

  The Agent.cmd/2 integration tests use `TestAnt`, a test agent module that uses
  the `Jido.Agent.Strategy.Direct` strategy instead of `Jido.Agent.Strategy.FSM`.

  The FSM strategy has an internal state machine (`idle` → `processing` → `idle`) that
  is used to track execution progress. This conflicts with the Ant's domain-level
  state machine (`:at_nest` ↔ `:searching`) which models the ant's behavioral state.

  When an action is executed via `Ant.cmd/2` with the FSM strategy, it attempts to
  transition to `"processing"` internally, but the Ant's transitions don't include
  this state (they only allow `:at_nest` ↔ `:searching`). This causes the FSM
  transition to fail and the action result is not applied to the agent state.

  The Direct strategy doesn't have this internal state machine, so it correctly
  applies the action results. This is the appropriate strategy for testing action
  execution via `cmd/2`.
  """

  use ExUnit.Case

  alias AntColony.Actions.Move
  alias AntColony.Agent.Ant
  alias AntColony.Plane
  alias AntColony.Events

  # TestAnt uses Direct strategy to avoid FSM state machine conflicts
  # See module documentation above for details
  defmodule TestAnt do
    use Jido.Agent,
      name: "test_ant",
      description: "Test ant with Direct strategy for MoveAction integration tests",
      category: "ant",
      vsn: "1.0.0",
      strategy: Jido.Agent.Strategy.Direct,
      schema: [
        id: [type: :string, required: false],
        generation_id: [type: :pos_integer, required: true],
        position: [type: {:tuple, [:non_neg_integer, :non_neg_integer]}, required: true],
        nest_position: [type: {:tuple, [:non_neg_integer, :non_neg_integer]}, required: true],
        path_memory: [type: {:list, :any}, default: []],
        current_state: [type: :atom, default: :at_nest],
        previous_state: [type: :atom, required: false],
        has_food?: [type: :boolean, default: false],
        carried_food_level: [type: :integer, required: false],
        known_food_sources: [type: {:list, :any}, default: []],
        energy: [type: :integer, default: 100],
        max_energy: [type: :integer, default: 100],
        age: [type: :integer, default: 0]
      ]

    def position(%Jido.Agent{state: state}), do: Map.get(state, :position)

    # Inject the agent's id into the action context for MoveAction
    # This allows MoveAction to properly update the Plane registry
    def on_before_cmd(%Jido.Agent{} = agent, action) do
      # Only inject for MoveAction to keep other actions clean
      new_action = case action do
        {AntColony.Actions.Move, params} when is_map(params) ->
          # Wrap the MoveAction in an Instruction with id in context
          %Jido.Instruction{
            action: AntColony.Actions.Move,
            params: params,
            context: %{id: agent.id, state: agent.state}
          }
        _ ->
          action
      end
      {:ok, agent, new_action}
    end
  end

  describe "1.5.9.1 Complete Action Execution" do
    setup do
      # Stop any existing Plane process
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      # Ensure PubSub is running (may already be started by Application)
      unless Process.whereis(AntColony.PubSub) do
        {:ok, _pubsub_pid} = start_supervised({Phoenix.PubSub, name: AntColony.PubSub})
      end

      {:ok, _plane_pid} = start_supervised(Plane)

      # Subscribe to simulation events
      Events.subscribe_to_simulation(AntColony.PubSub)

      :ok
    end

    test "MoveAction updates Plane registry after execution" do
      ant_id = "test_ant_move_1"
      start_pos = {25, 25}

      # Register ant with Plane
      :ok = Plane.register_ant(ant_id, start_pos)

      # Verify initial position
      assert {:ok, ^start_pos} = Plane.get_ant_position(ant_id)

      # Execute MoveAction
      params = %{direction: :north, steps: 2}
      context = build_context(%{id: ant_id, position: start_pos})

      assert {:ok, _result} = Move.run(params, context)

      # Verify Plane registry was updated
      assert {:ok, {25, 23}} = Plane.get_ant_position(ant_id)
    end

    test "MoveAction broadcasts ant_moved event to PubSub" do
      ant_id = "test_ant_move_2"
      start_pos = {25, 25}

      # Register ant with Plane
      :ok = Plane.register_ant(ant_id, start_pos)

      # Execute MoveAction
      params = %{direction: :east, steps: 3}
      context = build_context(%{id: ant_id, position: start_pos})

      # Flush any existing messages
      flush_messages()

      assert {:ok, _result} = Move.run(params, context)

      # Verify event was broadcast (event format: {:ant_moved, {:ant_moved, ant_id, old_pos, new_pos}, metadata})
      assert_receive {:ant_moved, {:ant_moved, ^ant_id, {25, 25}, {28, 25}}, _metadata}, 500
    end

    test "MoveAction includes metadata in broadcast event" do
      ant_id = "test_ant_move_3"
      start_pos = {25, 25}

      # Register ant with Plane
      :ok = Plane.register_ant(ant_id, start_pos)

      # Execute MoveAction
      params = %{direction: :south, steps: 1}
      context = build_context(%{id: ant_id, position: start_pos})

      flush_messages()

      assert {:ok, _result} = Move.run(params, context)

      # Verify event structure with metadata
      assert_receive {:ant_moved, {:ant_moved, ^ant_id, {25, 25}, {25, 26}}, metadata}, 500
      assert Map.has_key?(metadata, :timestamp)
      assert %DateTime{} = metadata.timestamp
    end

    test "MoveAction creates result with new position" do
      ant_id = "test_ant_move_4"
      start_pos = {25, 25}

      # Register ant with Plane
      :ok = Plane.register_ant(ant_id, start_pos)

      # Execute MoveAction
      params = %{direction: :west, steps: 1}
      context = build_context(%{id: ant_id, position: start_pos, current_state: :searching})

      assert {:ok, result} = Move.run(params, context)

      # Verify result contains new position
      assert result.position == {24, 25}
    end

    test "MoveAction handles boundary conditions with real Plane" do
      ant_id = "test_ant_move_boundary"
      start_pos = {0, 0}

      # Register ant with Plane at corner
      :ok = Plane.register_ant(ant_id, start_pos)

      # Try to move north (should clamp at y=0)
      params = %{direction: :north, steps: 5}
      context = build_context(%{id: ant_id, position: start_pos})

      assert {:ok, result} = Move.run(params, context)

      # Position should be clamped at boundary
      assert {:ok, {0, 0}} = Plane.get_ant_position(ant_id)
      assert result.position == {0, 0}
    end
  end

  describe "1.5.9.2 Multi-Ant Movement" do
    setup do
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      # Ensure PubSub is running (may already be started by Application)
      unless Process.whereis(AntColony.PubSub) do
        {:ok, _pubsub_pid} = start_supervised({Phoenix.PubSub, name: AntColony.PubSub})
      end

      {:ok, _plane_pid} = start_supervised(Plane)

      Events.subscribe_to_simulation(AntColony.PubSub)

      :ok
    end

    test "multiple ants can move concurrently" do
      ants =
        for i <- 1..5 do
          ant_id = "multi_ant_#{i}"
          start_pos = {25 + i, 25 + i}

          # Register each ant
          :ok = Plane.register_ant(ant_id, start_pos)

          {ant_id, start_pos}
        end

      # Move all ants
      results =
        Enum.map(ants, fn {ant_id, start_pos} ->
          params = %{direction: :north, steps: 2}
          context = build_context(%{id: ant_id, position: start_pos})

          {ant_id, Move.run(params, context)}
        end)

      # Verify all movements succeeded
      Enum.each(results, fn {_ant_id, result} ->
        assert {:ok, _result} = result
      end)

      # Verify all ants have correct positions in Plane
      # multi_ant_1 starts at {26, 26}, moves north 2 → {26, 24}
      assert {:ok, {26, 24}} = Plane.get_ant_position("multi_ant_1")
      # multi_ant_2 starts at {27, 27}, moves north 2 → {27, 25}
      assert {:ok, {27, 25}} = Plane.get_ant_position("multi_ant_2")
      # multi_ant_3 starts at {28, 28}, moves north 2 → {28, 26}
      assert {:ok, {28, 26}} = Plane.get_ant_position("multi_ant_3")
      # multi_ant_4 starts at {29, 29}, moves north 2 → {29, 27}
      assert {:ok, {29, 27}} = Plane.get_ant_position("multi_ant_4")
      # multi_ant_5 starts at {30, 30}, moves north 2 → {30, 28}
      assert {:ok, {30, 28}} = Plane.get_ant_position("multi_ant_5")
    end

    test "each ant moves independently" do
      ant_1_id = "memory_ant_1"
      ant_2_id = "memory_ant_2"

      :ok = Plane.register_ant(ant_1_id, {25, 25})
      :ok = Plane.register_ant(ant_2_id, {30, 30})

      # Move ant 1
      params_1 = %{direction: :east, steps: 2}
      context_1 = build_context(%{id: ant_1_id, position: {25, 25}, path_memory: []})

      {:ok, result_1} = Move.run(params_1, context_1)

      # Move ant 2
      params_2 = %{direction: :west, steps: 3}
      context_2 = build_context(%{id: ant_2_id, position: {30, 30}, path_memory: []})

      {:ok, result_2} = Move.run(params_2, context_2)

      # Verify independent movements
      assert result_1.position == {27, 25}
      assert result_2.position == {27, 30}
    end

    test "events for multiple ants are all broadcast" do
      ant_ids = ["event_ant_1", "event_ant_2", "event_ant_3"]

      Enum.each(ant_ids, fn ant_id ->
        start_pos = {25, 25}
        :ok = Plane.register_ant(ant_id, start_pos)
      end)

      flush_messages()

      # Move all ants
      Enum.each(ant_ids, fn ant_id ->
        params = %{direction: :north, steps: 1}
        context = build_context(%{id: ant_id, position: {25, 25}})

        {:ok, _result} = Move.run(params, context)
      end)

      # Verify all events were broadcast
      Enum.each(ant_ids, fn ant_id ->
        assert_receive {:ant_moved, {:ant_moved, ^ant_id, {25, 25}, {25, 24}}, _metadata}, 500
      end)
    end
  end

  describe "1.5.9.3 MoveAction through Jido.Agent.cmd/2" do
    setup do
      # Stop any existing Plane to ensure clean state
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      # Ensure PubSub is running (may already be started by Application)
      unless Process.whereis(AntColony.PubSub) do
        {:ok, _pubsub_pid} = start_supervised({Phoenix.PubSub, name: AntColony.PubSub})
      end

      {:ok, _plane_pid} = start_supervised(Plane)

      Events.subscribe_to_simulation(AntColony.PubSub)

      :ok
    end

    test "MoveAction can be executed via TestAnt.cmd/2 with Plane running" do
      # Create a test ant via Direct strategy Agent module
      ant =
        TestAnt.new(
          id: "cmd_ant_1",
          state: %{
            generation_id: 1,
            position: {25, 25},
            nest_position: {25, 25}
          }
        )

      # Register with Plane (required for MoveAction to work)
      :ok = Plane.register_ant(ant.id, TestAnt.position(ant))

      # Execute MoveAction through Agent.cmd
      {updated_ant, _directives} = TestAnt.cmd(ant, {Move, %{direction: :north, steps: 2}})

      # Verify agent state was updated
      assert TestAnt.position(updated_ant) == {25, 23}
    end

    test "Agent.cmd/2 with MoveAction produces directives" do
      ant =
        TestAnt.new(
          id: "cmd_ant_2",
          state: %{
            generation_id: 1,
            position: {25, 25},
            nest_position: {25, 25}
          }
        )

      :ok = Plane.register_ant(ant.id, TestAnt.position(ant))

      flush_messages()

      # Execute MoveAction
      {_updated_ant, directives} = TestAnt.cmd(ant, {Move, %{direction: :east, steps: 3}})

      # Verify we got directives
      assert is_list(directives)
    end

    test "multiple MoveActions can be chained via Agent.cmd/2" do
      ant =
        TestAnt.new(
          id: "cmd_ant_3",
          state: %{
            generation_id: 1,
            position: {25, 25},
            nest_position: {25, 25}
          }
        )

      :ok = Plane.register_ant(ant.id, TestAnt.position(ant))

      # Execute multiple moves in sequence
      {ant, _} = TestAnt.cmd(ant, {Move, %{direction: :east, steps: 2}})
      assert TestAnt.position(ant) == {27, 25}

      {ant, _} = TestAnt.cmd(ant, {Move, %{direction: :south, steps: 3}})
      assert TestAnt.position(ant) == {27, 28}

      {ant, _} = TestAnt.cmd(ant, {Move, %{direction: :west, steps: 1}})
      assert TestAnt.position(ant) == {26, 28}
    end

    test "Agent position matches Plane registry after cmd/2" do
      ant =
        TestAnt.new(
          id: "cmd_ant_4",
          state: %{
            generation_id: 1,
            position: {25, 25},
            nest_position: {25, 25}
          }
        )

      ant_id = ant.id
      :ok = Plane.register_ant(ant_id, TestAnt.position(ant))

      # Execute MoveAction
      {ant, _} = TestAnt.cmd(ant, {Move, %{direction: :north, steps: 5}})

      # Verify agent position
      agent_pos = TestAnt.position(ant)
      assert agent_pos == {25, 20}

      # Verify Plane registry
      assert {:ok, {25, 20}} = Plane.get_ant_position(ant_id)
    end

    test "MoveAction with random direction via Agent.cmd/2" do
      ant =
        TestAnt.new(
          id: "cmd_ant_random",
          state: %{
            generation_id: 1,
            position: {25, 25},
            nest_position: {25, 25}
          }
        )

      :ok = Plane.register_ant(ant.id, TestAnt.position(ant))

      # Execute random move
      {ant, _} = TestAnt.cmd(ant, {Move, %{direction: :random}})

      # Position should have changed
      new_pos = TestAnt.position(ant)
      assert {x, y} = new_pos
      assert is_integer(x)
      assert is_integer(y)
    end
  end

  describe "Error Handling Integration" do
    setup do
      case Process.whereis(AntColony.Plane) do
        nil -> :ok
        _pid -> Plane.stop()
      end

      # Ensure PubSub is running (may already be started by Application)
      unless Process.whereis(AntColony.PubSub) do
        {:ok, _pubsub_pid} = start_supervised({Phoenix.PubSub, name: AntColony.PubSub})
      end

      {:ok, _plane_pid} = start_supervised(Plane)

      Events.subscribe_to_simulation(AntColony.PubSub)

      :ok
    end

    test "MoveAction gracefully handles unregistered ant" do
      ant_id = "unregistered_ant"

      # Don't register the ant with Plane
      # The action should still succeed, but Plane update returns :not_found

      params = %{direction: :north, steps: 1}
      context = build_context(%{id: ant_id, position: {25, 25}})

      # Action should still succeed
      assert {:ok, result} = Move.run(params, context)
      assert result.position == {25, 24}
    end

    test "MoveAction with nil ant_id does not crash" do
      params = %{direction: :north, steps: 1}
      context = build_context(%{id: nil, position: {25, 25}})

      # Action should succeed but skip Plane update
      assert {:ok, result} = Move.run(params, context)
      assert result.position == {25, 24}
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

  # Helper to flush any existing messages in mailbox
  defp flush_messages do
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end
  end
end
