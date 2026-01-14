# Phase 1.9: ColonyIntelligenceAgent

Implement the ColonyIntelligenceAgent - a Jido Agent that manages generations, tracks KPIs, and spawns new generations of AntAgents. This is the orchestrator of the colony's meta-learning across generations.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                 AntColony.Agent.ColonyIntelligence                  │
│                      (Jido.Agent)                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Agent Schema:                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • current_generation_id: pos_integer()   - Current epoch  │    │
│  │  • agent_supervisor: pid() | nil        - AgentSupervisor │    │
│  │  • ant_count: pos_integer()              - Number of ants │    │
│  │  • food_delivered_count: non_neg_integer() - This gen     │    │
│  │  • generation_trigger_count: pos_integer() - Trigger at   │    │
│  │  • kpi_history: [%{generation_id, metrics}] - Performance │    │
│  │  • generation_start_time: DateTime.t() | nil - Tracking  │    │
│  │  • plane_pid: pid() | nil               - Plane reference │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  FSM States:                                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • :initializing     - Setting up supervisor and first gen │    │
│  │  • :running          - Active generation in progress       │    │
│  │  │  • :transitioning  - Spawning next generation           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Jido Agent Features:                                               │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Subscribes to PubSub events                             │    │
│  │  • Spawns AgentSupervisor via Directive.Supervisor         │    │
│  │  • Triggers generation transitions via Directive.Schedule   │    │
│  │  • Manages ant lifecycle across generations                 │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Event Subscriptions:                                               │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • {:food_delivered, ant_id, generation_id, qty, time}     │    │
│  │  • {:generation_started, generation_id}                    │    │
│  │  • {:generation_ended, generation_id, metrics}             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Actions (Phase 1):                                                 │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • SpawnInitialGeneration - Create AgentSupervisor + ants  │    │
│  │  • SpawnNextGeneration - Transition to new epoch           │    │
│  │  • RecordFoodDelivery - Update KPI tracking                │    │
│  │  • CheckGenerationTrigger - Evaluate if next gen needed    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Directives:                                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Emit events for generation lifecycle                    │    │
│  │  • Schedule periodic trigger checks                        │    │
│  │  • Supervisor to manage AgentSupervisor                    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Agent.ColonyIntelligence | Jido.Agent for generational orchestration |
| AntColony.Actions.SpawnInitialGeneration | Jido.Action to start first generation |
| AntColony.Actions.SpawnNextGeneration | Jido.Action to transition generations |
| AntColony.Actions.RecordFoodDelivery | Jido.Action for KPI tracking |
| AntColony.Actions.CheckGenerationTrigger | Jido.Action to evaluate triggers |

---

## 1.9.1 Create ColonyIntelligenceAgent Module Structure

Create the basic Jido.Agent module for colony intelligence.

### 1.9.1.1 Create Agent Module File

Create the colony intelligence agent module.

- [ ] 1.9.1.1.1 Create `lib/ant_colony/agent/colony_intelligence.ex`
- [ ] 1.9.1.1.2 Add `defmodule AntColony.Agent.ColonyIntelligence`
- [ ] 1.9.1.1.3 Add `use Jido.Agent, ...` with appropriate options
- [ ] 1.9.1.1.4 Add comprehensive `@moduledoc` describing the agent's role

### 1.9.1.2 Configure Jido.Agent Options

Set up the agent with proper Jido configuration.

- [ ] 1.9.1.2.1 Add `schema: AntColony.Agent.ColonyIntelligence.State` option
- [ ] 1.9.1.2.2 Add `actions: [...]` list with colony intelligence actions
- [ ] 1.9.1.2.3 Configure `initial_state: %{current_generation_id: 1}`
- [ ] 1.9.1.2.4 Add `strategy: Jido.Strategy.FSM` with initial state `:initializing`

### 1.9.1.3 Configure PubSub Subscriptions

Set up event subscriptions for monitoring the colony.

- [ ] 1.9.1.3.1 Add `dispatch: [subscribe: {...}]` configuration
- [ ] 1.9.1.3.2 Subscribe to `{:food_delivered, _, _, _, _}` events
- [ ] 1.9.1.3.3 Subscribe to `{:generation_started, _}` events
- [ ] 1.9.1.3.4 Subscribe to `{:generation_ended, _, _}` events

---

## 1.9.2 Define ColonyIntelligence State Schema

Define the complete state schema for the colony intelligence agent.

### 1.9.2.1 Create State Module

Create a dedicated module for the agent's state structure.

- [ ] 1.9.2.1.1 Add `defmodule State` within `AntColony.Agent.ColonyIntelligence`
- [ ] 1.9.2.1.2 Add `@moduledoc` for the state module
- [ ] 1.9.2.1.3 Use `defstruct` for state definition

### 1.9.2.2 Define Generation Management Fields

Add fields for managing the current generation.

- [ ] 1.9.2.2.1 Add `:current_generation_id` field - positive integer, default `1`
- [ ] 1.9.2.2.2 Add `:generation_start_time` field - DateTime or nil, default `nil`
- [ ] 1.9.2.2.3 Add `:generation_trigger_count` field - positive integer, default `50`
- [ ] 1.9.2.2.4 Document that trigger count is configurable

### 1.9.2.3 Define KPI Tracking Fields

Add fields for tracking colony performance metrics.

- [ ] 1.9.2.3.1 Add `:food_delivered_count` field - non-negative integer, default `0`
- [ ] 1.9.2.3.2 Add `:kpi_history` field - list of metric maps, default `[]`
- [ ] 1.9.2.3.3 Define KPI map structure: `%{generation_id, food_count, duration, avg_trip_time}`
- [ ] 1.9.2.3.4 Add type spec for kpi_history entry

### 1.9.2.4 Define Supervisor Management Fields

Add fields for managing the AgentSupervisor.

- [ ] 1.9.2.4.1 Add `:agent_supervisor` field - pid or nil, default `nil`
- [ ] 1.9.2.4.2 Add `:ant_count` field - positive integer, default `10`
- [ ] 1.9.2.4.3 Add `:plane_pid` field - pid or nil, default `nil`
- [ ] 1.9.2.4.4 Document that supervisor is spawned via Directive.Supervisor

### 1.9.2.5 Define Type Specifications

Add comprehensive type specifications.

- [ ] 1.9.2.5.1 Define `@type kpi_metrics :: %{generation_id: pos_integer(), food_count: non_neg_integer(), duration: Duration.t(), avg_trip_time: float() | nil}`
- [ ] 1.9.2.5.2 Define `@type kpi_history :: [kpi_metrics()]`
- [ ] 1.9.2.5.3 Define complete state type with all fields
- [ ] 1.9.2.5.4 Export types for use in other modules

---

## 1.9.3 Implement SpawnInitialGeneration Action

Create the action that starts the first generation of ants.

### 1.9.3.1 Create Action Module File

Create the spawn initial generation action.

- [ ] 1.9.3.1.1 Create `lib/ant_colony/actions/spawn_initial_generation.ex`
- [ ] 1.9.3.1.2 Add `defmodule AntColony.Actions.SpawnInitialGeneration`
- [ ] 1.9.3.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.9.3.1.4 Add `@moduledoc` describing the action

### 1.9.3.2 Define Action Parameters

Define parameters for the initial spawn.

- [ ] 1.9.3.2.1 Define `param` schema with `:ant_count` field (default 10)
- [ ] 1.9.3.2.2 Define `:nest_position` field - `{x, y}` tuple, required
- [ ] 1.9.3.2.3 Define `:plane_pid` field - pid, required
- [ ] 1.9.3.2.4 Define `:generation_trigger_count` field (default 50)

### 1.9.3.3 Implement AgentSupervisor Spawning

Implement supervisor creation via Jido.Directive.

- [ ] 1.9.3.3.1 Implement `run/2` function
- [ ] 1.9.3.3.2 Create child spec for `AntColony.AgentSupervisor`
- [ ] 1.9.3.3.3 Return directive: `{:ok, state, [directive: {:supervisor, ...}]}`
- [ ] 1.9.3.3.4 Store supervisor pid in state

### 1.9.3.4 Implement AntAgent Spawning

Spawn the first generation of AntAgents.

- [ ] 1.9.3.4.1 Implement `spawn_ants/3` helper - takes supervisor, count, gen_id
- [ ] 1.9.3.4.2 Use `Jido.AgentServer.start_child/3` for each ant
- [ ] 1.9.3.4.3 Pass `generation_id: 1` to each ant
- [ ] 1.9.3.4.4 Store ant count in returned state map

### 1.9.3.5 Broadcast Generation Started Event

Publish event for the new generation.

- [ ] 1.9.3.5.1 Call `AntColony.Events.broadcast_generation_started/1`
- [ ] 1.9.3.5.2 Pass `current_generation_id` from state
- [ ] 1.9.3.5.3 Include timestamp in event payload
- [ ] 1.9.3.5.4 Handle broadcast errors gracefully

---

## 1.9.4 Implement RecordFoodDelivery Action

Create the action that tracks food deliveries for KPI calculation.

### 1.9.4.1 Create Action Module File

Create the record food delivery action.

- [ ] 1.9.4.1.1 Create `lib/ant_colony/actions/record_food_delivery.ex`
- [ ] 1.9.4.1.2 Add `defmodule AntColony.Actions.RecordFoodDelivery`
- [ ] 1.9.4.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.9.4.1.4 Add `@moduledoc` describing the action

### 1.9.4.2 Define Action Parameters

Define parameters for food delivery recording.

- [ ] 1.9.4.2.1 Define `param` schema with `:ant_id` field
- [ ] 1.9.4.2.2 Define `:generation_id` field - positive integer, required
- [ ] 1.9.4.2.3 Define `:food_level` field - integer 1-5, required
- [ ] 1.9.4.2.4 Define `:trip_time` field - duration, optional

### 1.9.4.3 Implement Counter Update Logic

Update the food delivery counters.

- [ ] 1.9.4.3.1 Implement `run/2` function
- [ ] 1.9.4.3.2 Increment `food_delivered_count` in state
- [ ] 1.9.4.3.3 Verify `generation_id` matches `current_generation_id`
- [ ] 1.9.4.3.4 Return `{:ok, updated_state_map}`

### 1.9.4.4 Handle Mismatched Generation IDs

Manage deliveries from previous generations.

- [ ] 1.9.4.4.1 Check if `generation_id == current_generation_id`
- [ ] 1.9.4.4.2 Log warning if generation ID mismatch
- [ ] 1.9.4.4.3 Return state without incrementing counter if mismatch
- [ ] 1.9.4.4.4 Document this as edge case handling

---

## 1.9.5 Implement CheckGenerationTrigger Action

Create the action that evaluates whether to trigger the next generation.

### 1.9.5.1 Create Action Module File

Create the check generation trigger action.

- [ ] 1.9.5.1.1 Create `lib/ant_colony/actions/check_generation_trigger.ex`
- [ ] 1.9.5.1.2 Add `defmodule AntColony.Actions.CheckGenerationTrigger`
- [ ] 1.9.5.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.9.5.1.4 Add `@moduledoc` describing the action

### 1.9.5.2 Implement Count-Based Trigger Logic

Implement Phase 1's simple count-based trigger.

- [ ] 1.9.5.2.1 Implement `run/2` function with empty params
- [ ] 1.9.5.2.2 Compare `food_delivered_count >= generation_trigger_count`
- [ ] 1.9.5.2.3 Return `{:ok, state, [directive: {...}]}` if trigger met
- [ ] 1.9.5.2.4 Return `{:ok, state}` if trigger not met

### 1.9.5.3 Add Schedule Directive for Periodic Checks

Schedule periodic trigger evaluations.

- [ ] 1.9.5.3.1 Add `Directive.Schedule` to action result
- [ ] 1.9.5.3.2 Schedule `CheckGenerationTrigger` action every 1 second
- [ ] 1.9.5.3.3 Use `Jido.Directive.Schedule` with `:run_after` option
- [ ] 1.9.5.3.4 Document scheduling behavior in @moduledoc

### 1.9.5.4 Emit Directive for SpawnNextGeneration

Trigger next generation action when count is reached.

- [ ] 1.9.5.4.1 Add `Directive.Emit` when trigger condition met
- [ ] 1.9.5.4.2 Emit `{:generation_trigger_reached, generation_id, metrics}`
- [ ] 1.9.5.4.3 Include `Dispatch` directive to call `SpawnNextGeneration`
- [ ] 1.9.5.4.4 Document this triggers the generation transition

---

## 1.9.6 Implement SpawnNextGeneration Action

Create the action that transitions to a new generation.

### 1.9.6.1 Create Action Module File

Create the spawn next generation action.

- [ ] 1.9.6.1.1 Create `lib/ant_colony/actions/spawn_next_generation.ex`
- [ ] 1.9.6.1.2 Add `defmodule AntColony.Actions.SpawnNextGeneration`
- [ ] 1.9.6.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.9.6.1.4 Add `@moduledoc` describing the action

### 1.9.6.2 Record Generation Metrics

Calculate and store the current generation's performance.

- [ ] 1.9.6.2.1 Calculate generation duration from `generation_start_time`
- [ ] 1.9.6.2.2 Create KPI metrics map with food_count, duration
- [ ] 1.9.6.2.3 Prepend metrics to `kpi_history` list
- [ ] 1.9.6.2.4 Limit `kpi_history` size (e.g., keep last 100 generations)

### 1.9.6.3 Terminate Current AntAgents

Stop all AntAgents from the current generation.

- [ ] 1.9.6.3.1 Call `DynamicSupervisor.which_children/1` to get all ants
- [ ] 1.9.6.3.2 Call `DynamicSupervisor.terminate_child/2` for each ant
- [ ] 1.9.6.3.3 Handle `{:error, :not_found}` gracefully
- [ ] 1.9.6.3.4 Log termination of each ant

### 1.9.6.4 Broadcast Generation Ended Event

Publish event for the ending generation.

- [ ] 1.9.6.4.1 Call `AntColony.Events.broadcast_generation_ended/2`
- [ ] 1.9.6.4.2 Pass `current_generation_id` and metrics map
- [ ] 1.9.6.4.3 Include timestamp in event payload
- [ ] 1.9.6.4.4 Handle broadcast errors gracefully

### 1.9.6.5 Increment and Spawn New Generation

Create the next generation of AntAgents.

- [ ] 1.9.6.5.1 Increment `current_generation_id` in state
- [ ] 1.9.6.5.2 Reset `food_delivered_count` to 0
- [ ] 1.9.6.5.3 Update `generation_start_time` to `DateTime.utc_now()`
- [ ] 1.9.6.5.4 Call `spawn_ants/3` with new `generation_id`
- [ ] 1.9.6.5.5 Broadcast `{:generation_started, new_generation_id}` event

---

## 1.9.7 Implement PubSub Event Handlers

Add event handlers to respond to colony events.

### 1.9.7.1 Handle Food Delivered Events

Process food delivery events from ants.

- [ ] 1.9.7.1.1 Implement `handle_info/2` for `{:food_delivered, ...}` messages
- [ ] 1.9.7.1.2 Extract ant_id, generation_id, food_level, trip_time from event
- [ ] 1.9.7.1.3 Dispatch `RecordFoodDelivery` action via `Jido.Agent.cmd/2`
- [ ] 1.9.7.1.4 Dispatch `CheckGenerationTrigger` action via `Jido.Agent.cmd/2`

### 1.9.7.2 Handle Ant Moved Events

Process ant movement events (optional tracking).

- [ ] 1.9.7.2.1 Implement `handle_info/2` for `{:ant_moved, ...}` messages
- [ ] 1.9.7.2.2 Extract ant_id, generation_id, positions from event
- [ ] 1.9.7.2.3 Optionally track activity level per generation
- [ ] 1.9.7.2.4 Return `{:noreply, state}` without side effects

### 1.9.7.3 Handle Generation Events

Process generation lifecycle events.

- [ ] 1.9.7.3.1 Implement `handle_info/2` for `{:generation_started, ...}` messages
- [ ] 1.9.7.3.2 Implement `handle_info/2` for `{:generation_ended, ...}` messages
- [ ] 1.9.7.3.3 Update internal state tracking
- [ ] 1.9.7.3.4 Log generation transitions

---

## 1.9.8 Unit Tests for ColonyIntelligenceAgent

Test the colony intelligence agent functionality.

### 1.9.8.1 Test Agent State Creation

Verify the agent state struct can be created.

- [ ] 1.9.8.1.1 Create `test/ant_colony/agent/colony_intelligence_test.exs`
- [ ] 1.9.8.1.2 Add test: `test "creates state with default values"` - check all defaults
- [ ] 1.9.8.1.3 Add test: `test "current_generation_id defaults to 1"` - check initial
- [ ] 1.9.8.1.4 Add test: `test "food_delivered_count defaults to 0"` - check counter
- [ ] 1.9.8.1.5 Add test: `test "kpi_history defaults to empty list"` - check history

### 1.9.8.2 Test SpawnInitialGeneration Action

Verify initial generation spawning works.

- [ ] 1.9.8.2.1 Add test: `test "spawns AgentSupervisor"` - verify supervisor started
- [ ] 1.9.8.2.2 Add test: `test "spawns correct number of ants"` - count matches
- [ ] 1.9.8.2.3 Add test: `test "sets generation_id to 1 for initial ants"` - verify gen_id
- [ ] 1.9.8.2.4 Add test: `test "broadcasts generation_started event"` - verify event
- [ ] 1.9.8.2.5 Add test: `test "stores supervisor pid in state"` - pid check

### 1.9.8.3 Test RecordFoodDelivery Action

Verify food delivery tracking works.

- [ ] 1.9.8.3.1 Add test: `test "increments food_delivered_count"` - counter +1
- [ ] 1.9.8.3.2 Add test: `test "ignores delivery from previous generation"` - mismatch
- [ ] 1.9.8.3.3 Add test: `test "stores trip time in state"` - optional field
- [ ] 1.9.8.3.4 Add test: `test "validates generation_id parameter"` - required check

### 1.9.8.4 Test CheckGenerationTrigger Action

Verify trigger evaluation logic works.

- [ ] 1.9.8.4.1 Add test: `test "returns no directive when count below trigger"` - no trigger
- [ ] 1.9.8.4.2 Add test: `test "returns emit directive when count reached"` - trigger met
- [ ] 1.9.8.4.3 Add test: `test "uses configurable trigger count"` - custom threshold
- [ ] 1.9.8.4.4 Add test: `test "includes schedule directive for periodic check"` - scheduling

### 1.9.8.5 Test SpawnNextGeneration Action

Verify generation transition works.

- [ ] 1.9.8.5.1 Add test: `test "increments current_generation_id"` - gen_id +1
- [ ] 1.9.8.5.2 Add test: `test "resets food_delivered_count"` - counter to 0
- [ ] 1.9.8.5.3 Add test: `test "stores generation metrics in kpi_history"` - history
- [ ] 1.9.8.5.4 Add test: `test "terminates all AntAgents from previous gen"` - cleanup
- [ ] 1.9.8.5.5 Add test: `test "spawns new generation with incremented gen_id"` - new ants
- [ ] 1.9.8.5.6 Add test: `test "broadcasts generation_started event"` - verify event

### 1.9.8.6 Test KPI History Tracking

Verify metrics are tracked across generations.

- [ ] 1.9.8.6.1 Add test: `test "kpi_history stores generation metrics"` - entry added
- [ ] 1.9.8.6.2 Add test: `test "kpi_history entry includes generation_id"` - field check
- [ ] 1.9.8.6.3 Add test: `test "kpi_history entry includes food_count"` - field check
- [ ] 1.9.8.6.4 Add test: `test "kpi_history entry includes duration"` - field check
- [ ] 1.9.8.6.5 Add test: `test "kpi_history limits size to max generations"` - truncation

---

## 1.9.9 Phase 1.9 Integration Tests

End-to-end tests for ColonyIntelligenceAgent functionality.

### 1.9.9.1 Create Integration Test File

Create the integration test file.

- [ ] 1.9.9.1.1 Create `test/ant_colony/agent/integration/colony_intelligence_integration_test.exs`
- [ ] 1.9.9.1.2 Add setup starting Plane and PubSub
- [ ] 1.9.9.1.3 Add setup starting ColonyIntelligenceAgent

### 1.9.9.2 Generational Lifecycle Test

Test complete generation lifecycle.

- [ ] 1.9.9.2.1 Add test: `test "initial generation spawns successfully"` - first gen
- [ ] 1.9.9.2.2 Add test: `test "generation transitions after trigger count"` - transition
- [ ] 1.9.9.2.3 Add test: `test "multiple generations can cycle"` - 2+ transitions
- [ ] 1.9.9.2.4 Add test: `test "generation_id increments each transition"` - sequential

### 1.9.9.3 Event Flow Integration Test

Test event-driven generation triggers.

- [ ] 1.9.9.3.1 Add test: `test "food_delivered events trigger counter updates"` - flow
- [ ] 1.9.9.3.2 Add test: `test "trigger count causes generation transition"` - chain
- [ ] 1.9.9.3.3 Add test: `test "generation events are published to PubSub"` - broadcast
- [ ] 1.9.9.3.4 Add test: `test "observers receive generation lifecycle events"` - subscribe

### 1.9.9.4 Supervisor Integration Test

Test AgentSupervisor lifecycle management.

- [ ] 1.9.9.4.1 Add test: `test "AgentSupervisor is started on init"` - startup
- [ ] 1.9.9.4.2 Add test: `test "AgentSupervisor children are terminated between generations"` - cleanup
- [ ] 1.9.9.4.3 Add test: `test "AgentSupervisor survives generation transitions"` - persistence
- [ ] 1.9.9.4.4 Add test: `test "new generation agents are under same supervisor"` - structure

---

## Phase 1.9 Success Criteria

1. **ColonyIntelligenceAgent Module**: Jido.Agent compiles and executes ✅
2. **State Schema**: All fields defined with types (including current_generation_id) ✅
3. **SpawnInitialGeneration**: Creates supervisor and first generation of ants ✅
4. **RecordFoodDelivery**: Tracks food deliveries for KPI calculation ✅
5. **CheckGenerationTrigger**: Count-based trigger evaluates correctly ✅
6. **SpawnNextGeneration**: Transitions to new generation with cleanup ✅
7. **KPI History**: Metrics tracked across generations ✅
8. **Event Subscriptions**: ColonyIntelligenceAgent receives colony events ✅
9. **Tests**: All unit and integration tests pass ✅

## Phase 1.9 Critical Files

**New Files:**
- `lib/ant_colony/agent/colony_intelligence.ex` - ColonyIntelligenceAgent module
- `lib/ant_colony/actions/spawn_initial_generation.ex` - SpawnInitialGeneration action
- `lib/ant_colony/actions/record_food_delivery.ex` - RecordFoodDelivery action
- `lib/ant_colony/actions/check_generation_trigger.ex` - CheckGenerationTrigger action
- `lib/ant_colony/actions/spawn_next_generation.ex` - SpawnNextGeneration action
- `test/ant_colony/agent/colony_intelligence_test.exs` - Unit tests
- `test/ant_colony/agent/integration/colony_intelligence_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/application.ex` - Add ColonyIntelligenceAgent to supervision tree (from Phase 1.7)
- `lib/ant_colony/events.ex` - Ensure generation lifecycle events exist

---

## Next Phase

Proceed to [Phase 2: Initial UI Integration](../../phase2_initial_ui_integration/overview.md) to create the terminal UI that visualizes the simulation and displays generation information.
