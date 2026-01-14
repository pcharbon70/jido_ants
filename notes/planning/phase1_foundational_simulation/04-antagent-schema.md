# Phase 1.4: AntAgent Schema

Define the AntAgent schema using Jido.Agent framework. This establishes the core data model for individual ants in the simulation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AntColony.Agent.Ant                             │
│                       (Jido.Agent)                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Agent Schema:                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • id: String.t()                  - Unique identifier     │    │
│  │  • position: {x, y}                - Current coordinates   │    │
│  │  • nest_position: {x, y}           - Known nest location   │    │
│  │  • path_memory: [{pos, obs}]       - Visited positions     │    │
│  │  • current_state: atom()           - FSM state             │    │
│  │  • has_food?: boolean()            - Carrying food flag    │    │
│  │  • carried_food_level: integer()   - Food quality (1-5)    │    │
│  │  • known_food_sources: [map()]     - Discovered food       │    │
│  │  • energy: integer()               - Energy level          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  FSM States (Phase 1):                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • :at_nest       - Initial state, ant is at nest          │    │
│  │  • :searching     - Actively exploring for food            │    │
│  │  • :returning_to_nest - (Phase 2) Carrying food back      │    │
│  │  • :communicating - (Phase 2) Exchanging information      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Jido Agent Features:                                               │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Composable actions (Move, SenseFood, etc.)             │    │
│  │  • Directive-based side effects (Emit, Schedule, etc.)    │    │
│  │  • Pure state transitions via cmd/2                       │    │
│  │  • Runs under Jido.AgentServer (GenServer)                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Agent.Ant | Jido.Agent module for individual ants |
| Ant.State | Agent state struct with type specifications |
| Ant.AgentServer | Server wrapper for running ant agents |

---

## 1.4.1 Create AntAgent Module Structure

Create the basic Jido.Agent module structure.

### 1.4.1.1 Create Agent Module File

Create the ant agent module in the appropriate directory.

- [ ] 1.4.1.1.1 Create `lib/ant_colony/agent/ant.ex`
- [ ] 1.4.1.1.2 Add `defmodule AntColony.Agent.Ant`
- [ ] 1.4.1.1.3 Add `use Jido.Agent, ...` with appropriate options
- [ ] 1.4.1.1.4 Add comprehensive `@moduledoc` describing the agent

### 1.4.1.2 Configure Jido.Agent Options

Set up the agent with proper Jido configuration.

- [ ] 1.4.1.2.1 Add `schema: AntColony.Agent.Ant.State` option
- [ ] 1.4.1.2.2 Add `actions: [...]` list (empty initially, populated in later phases)
- [ ] 1.4.1.2.3 Configure initial state via `initial_state: %{}`
- [ ] 1.4.1.2.4 Add any required agent-level configuration

### 1.4.1.3 Add Module Documentation

Document the agent's purpose and usage.

- [ ] 1.4.1.3.1 Document the agent's role in the simulation
- [ ] 1.4.1.3.2 Document the FSM states and transitions
- [ ] 1.4.1.3.3 Add example usage in @moduledoc
- [ ] 1.4.1.3.4 Document the schema fields

---

## 1.4.2 Define AntAgent State Schema

Define the complete state schema for an ant agent.

### 1.4.2.1 Create State Module

Create a dedicated module for the agent's state structure.

- [ ] 1.4.2.1.1 Add `defmodule State` within `AntColony.Agent.Ant`
- [ ] 1.4.2.1.2 Add `@moduledoc` for the state module
- [ ] 1.4.2.1.3 Use `defstruct` for state definition

### 1.4.2.2 Define Core Identity Fields

Add fields identifying the ant.

- [ ] 1.4.2.2.1 Add `:id` field - unique string identifier, required
- [ ] 1.4.2.2.2 Add `:position` field - `{x, y}` tuple, required
- [ ] 1.4.2.2.3 Add `:nest_position` field - `{x, y}` tuple, required
- [ ] 1.4.2.2.4 Add type specs for identity fields

### 1.4.2.3 Define Movement/Memory Fields

Add fields for tracking movement and history.

- [ ] 1.4.2.3.1 Add `:path_memory` field - list of `{position, observations}` tuples
- [ ] 1.4.2.3.2 Set default for `path_memory` to `[]`
- [ ] 1.4.2.3.3 Add type spec for path_memory entry
- [ ] 1.4.2.3.4 Add type spec for observation map

### 1.4.2.4 Define State Machine Fields

Add fields for FSM state tracking.

- [ ] 1.4.2.4.1 Add `:current_state` field - atom, default `:at_nest`
- [ ] 1.4.2.4.2 Add `:previous_state` field - atom, optional
- [ ] 1.4.2.4.3 Add type spec for valid FSM states
- [ ] 1.4.2.4.4 Document valid states in comments

### 1.4.2.5 Define Food-Related Fields

Add fields for tracking food carrying and knowledge.

- [ ] 1.4.2.5.1 Add `:has_food?` field - boolean, default `false`
- [ ] 1.4.2.5.2 Add `:carried_food_level` field - integer 1-5, optional
- [ ] 1.4.2.5.3 Add `:known_food_sources` field - list of maps, default `[]`
- [ ] 1.4.2.5.4 Add type spec for food_source map structure

### 1.4.2.6 Define Optional Fields

Add optional fields for extended functionality.

- [ ] 1.4.2.6.1 Add `:energy` field - integer, default `100`
- [ ] 1.4.2.6.2 Add `:max_energy` field - integer, default `100`
- [ ] 1.4.2.6.3 Add `:age` field - integer, default `0` (simulation ticks)
- [ ] 1.4.2.6.4 Add type specs for optional fields

---

## 1.4.3 Add Type Specifications

Define comprehensive type specifications for the agent state.

### 1.4.3.1 Define Position Types

Add type specifications for positions.

- [ ] 1.4.3.1.1 Define `@type position :: {non_neg_integer(), non_neg_integer()}`
- [ ] 1.4.3.1.2 Define `@type path_entry :: {position(), map()}`
- [ ] 1.4.3.1.3 Define `@type path_memory :: [path_entry()]`

### 1.4.3.2 Define Food Source Types

Add type specifications for food-related data.

- [ ] 1.4.3.2.1 Define `@type food_level :: 1..5`
- [ ] 1.4.3.2.2 Define `@type food_source :: %{position: position(), level: food_level(), last_updated: DateTime.t()}`
- [ ] 1.4.3.2.3 Define `@type known_food_sources :: [food_source()]`

### 1.4.3.3 Define Agent State Types

Add type specifications for agent states.

- [ ] 1.4.3.3.1 Define `@type ant_state :: :at_nest | :searching | :returning_to_nest | :communicating`
- [ ] 1.4.3.3.2 Define complete state type with all fields
- [ ] 1.4.3.3.3 Export types for use in other modules

### 1.4.3.4 Define Helper Types

Add utility type specifications.

- [ ] 1.4.3.4.1 Define `@type ant_id :: String.t()`
- [ ] 1.4.3.4.2 Define `@type energy :: non_neg_integer()`
- [ ] 1.4.3.4.3 Define `@type observation :: %{optional(atom()) => any()}`

---

## 1.4.4 Configure Basic FSM Strategy

Set up the finite state machine for agent behavior.

### 1.4.4.1 Define FSM States

Define the states for the agent's behavior.

- [ ] 1.4.4.1.1 Document `:at_nest` state - ant is at the nest
- [ ] 1.4.4.1.2 Document `:searching` state - ant is exploring
- [ ] 1.4.4.1.3 Document `:returning_to_nest` state - ant has food (future)
- [ ] 1.4.4.1.4 Document `:communicating` state - ant is exchanging info (future)

### 1.4.4.2 Define State Transitions

Define valid transitions between states.

- [ ] 1.4.4.2.1 Define transition `:at_nest -> :searching` - ant leaves nest to explore
- [ ] 1.4.4.2.2 Define transition `:searching -> :at_nest` - ant returns without food
- [ ] 1.4.4.2.3 Document `:searching -> :returning_to_nest` for future (when food found)
- [ ] 1.4.4.2.4 Document `:searching -> :communicating` for future (proximity event)

### 1.4.4.3 Configure Jido FSM Strategy

Set up FSM in Jido.Agent configuration.

- [ ] 1.4.4.3.1 Add `strategy: Jido.Strategy.FSM` to agent options
- [ ] 1.4.4.3.2 Configure `initial_state: :at_nest`
- [ ] 1.4.4.3.3 Define state transition rules if Jido supports it
- [ ] 1.4.4.3.4 Document any manual state management needed

---

## 1.4.5 Unit Tests for AntAgent Schema

Test the agent schema structure and type specifications.

### 1.4.5.1 Test Agent Struct Creation

Verify the agent state struct can be created.

- [ ] 1.4.5.1.1 Create `test/ant_colony/agent/ant_test.exs`
- [ ] 1.4.5.1.2 Add test: `test "creates state with default values"` - check all defaults
- [ ] 1.4.5.1.3 Add test: `test "id field is required"` - missing id behavior
- [ ] 1.4.5.1.4 Add test: `test "position field is required"` - missing position behavior
- [ ] 1.4.5.1.5 Add test: `test "nest_position field is required"` - missing nest behavior

### 1.4.5.2 Test Field Values

Verify each field has correct type and value.

- [ ] 1.4.5.2.1 Add test: `test "current_state defaults to :at_nest"` - check initial state
- [ ] 1.4.5.2.2 Add test: `test "has_food? defaults to false"` - check default
- [ ] 1.4.5.2.3 Add test: `test "path_memory defaults to empty list"` - check default
- [ ] 1.4.5.2.4 Add test: `test "energy defaults to 100"` - check default
- [ ] 1.4.5.2.5 Add test: `test "known_food_sources defaults to empty list"` - check default

### 1.4.5.3 Test Type Specifications

Verify type specs are correctly defined.

- [ ] 1.4.5.3.1 Add test: `test "position type accepts valid tuple"` - check `{x, y}`
- [ ] 1.4.5.3.2 Add test: `test "ant_state type accepts valid states"` - check all states
- [ ] 1.4.5.3.3 Add test: `test "food_level type accepts 1-5"` - check boundaries
- [ ] 1.4.5.3.4 Add test: `test "path_memory type accepts list of entries"` - check structure

---

## 1.4.6 Unit Tests for FSM States

Test the FSM state configuration and transitions.

### 1.4.6.1 Test Initial State

Verify agent starts in correct initial state.

- [ ] 1.4.6.1.1 Add test: `test "agent starts in :at_nest state"` - check initial
- [ ] 1.4.6.1.2 Add test: `test "agent has no previous state initially"` - check nil
- [ ] 1.4.6.1.3 Add test: `test "agent state can be queried"` - accessor test

### 1.4.6.2 Test State Transitions

Verify valid state transitions work.

- [ ] 1.4.6.2.1 Add test: `test "can transition from :at_nest to :searching"` - valid transition
- [ ] 1.4.6.2.2 Add test: `test "can transition from :searching to :at_nest"` - valid transition
- [ ] 1.4.6.2.3 Add test: `test "previous_state is updated on transition"` - history tracking
- [ ] 1.4.6.2.4 Add test: `test "state transition preserves other fields"` - field retention

### 1.4.6.3 Test State Validation

Verify invalid transitions are handled.

- [ ] 1.4.6.3.1 Add test: `test "invalid state transition returns error"` - reject invalid
- [ ] 1.4.6.3.2 Add test: `test "state remains unchanged on invalid transition"` - rollback
- [ ] 1.4.6.3.3 Add test: `test "unknown state returns error"` - validation

---

## 1.4.7 Unit Tests for Agent Creation

Test creating and starting ant agents.

### 1.4.7.1 Test Agent Factory Functions

Test helper functions for creating agents.

- [ ] 1.4.7.1.1 Add test: `test "new/1 creates agent with id"` - factory function
- [ ] 1.4.7.1.2 Add test: `test "new/1 creates agent with custom position"` - custom pos
- [ ] 1.4.7.1.3 Add test: `test "new/1 sets nest_position from params"` - nest config
- [ ] 1.4.7.1.4 Add test: `test "new/1 generates unique id if not provided"` - id generation

### 1.4.7.2 Test Agent State Initialization

Test agent starts with correct initial values.

- [ ] 1.4.7.2.1 Add test: `test "agent initializes at given position"` - position check
- [ ] 1.4.7.2.2 Add test: `test "agent path_memory is empty initially"` - memory check
- [ ] 1.4.7.2.3 Add test: `test "agent has full energy initially"` - energy check
- [ ] 1.4.7.2.4 Add test: `test "agent has no food initially"` - food check

---

## 1.4.8 Phase 1.4 Integration Tests

End-to-end tests for AntAgent functionality.

### 1.4.8.1 Agent Lifecycle Test

Test complete agent lifecycle from creation to termination.

- [ ] 1.4.8.1.1 Create `test/ant_colony/agent/integration/ant_integration_test.exs`
- [ ] 1.4.8.1.2 Add test: `test "agent can be started and stopped"` - lifecycle
- [ ] 1.4.8.1.3 Add test: `test "agent state persists across commands"` - state retention
- [ ] 1.4.8.1.4 Add test: `test "agent can be restarted"` - restart test

### 1.4.8.2 Agent with Plane Test

Test agent interaction with the Plane.

- [ ] 1.4.8.2.1 Add test: `test "agent registers with Plane on start"` - registration
- [ ] 1.4.8.2.2 Add test: `test "agent unregisters from Plane on stop"` - cleanup
- [ ] 1.4.8.2.3 Add test: `test "agent position matches Plane registry"` - consistency
- [ ] 1.4.8.2.4 Add test: `test "multiple agents can coexist"` - multi-agent

---

## Phase 1.4 Success Criteria

1. **Agent Module**: Jido.Agent module compiles ✅
2. **State Schema**: All fields defined with types ✅
3. **FSM States**: Initial state configured ✅
4. **Type Specs**: Complete type specifications ✅
5. **Defaults**: All defaults correctly set ✅
6. **Tests**: All unit and integration tests pass ✅

## Phase 1.4 Critical Files

**New Files:**
- `lib/ant_colony/agent/ant.ex` - AntAgent Jido.Agent module
- `test/ant_colony/agent/ant_test.exs` - Agent unit tests
- `test/ant_colony/agent/integration/ant_integration_test.exs` - Integration tests

**Modified Files:**
- None

---

## Next Phase

Proceed to [Phase 1.5: Move Action](./05-move-action.md) to implement ant movement with event publishing.
