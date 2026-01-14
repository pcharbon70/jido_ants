# Phase 1.6: Sense Food Action

Implement the SenseFoodAction for detecting food at the ant's current position. This enables ants to discover food sources in the environment.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                 AntColony.Actions.SenseFood                          │
│                      (Jido.Action)                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Parameters: (None - uses current position)                         │
│                                                                      │
│  Context (from Agent):                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • agent.state.position - Current position to check        │    │
│  │  • agent.state.id - Ant identifier                        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  External Dependencies:                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • AntColony.Plane.get_food_at/1 - Query for food          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Effects:                                                           │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  1. Query Plane for food at agent.state.position           │    │
│  │  2. If food found: Add to known_food_sources               │    │
│  │  3. Broadcast {:food_sensed, ant_id, position, food}       │    │
│  │  4. Return updated state with food information             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Return:                                                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  {:ok, updated_state_map}                                  │    │
│  │  - Includes :sensed_food key with food details or nil      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Actions.SenseFood | Jido.Action for food detection |
| AntColony.Plane | Source of food data |
| AntColony.Events | Event broadcasting for food_sensed |

---

## 1.6.1 Create SenseFoodAction Module Structure

Create the basic Jido.Action module for food sensing.

### 1.6.1.1 Create Action Module File

Create the sense food action module.

- [ ] 1.6.1.1.1 Create `lib/ant_colony/actions/sense_food.ex`
- [ ] 1.6.1.1.2 Add `defmodule AntColony.Actions.SenseFood`
- [ ] 1.6.1.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.6.1.1.4 Add comprehensive `@moduledoc` describing the action

### 1.6.1.2 Define Action Parameters Schema

Define that this action takes no parameters (uses context).

- [ ] 1.6.1.2.1 Define empty `param` schema (no required params)
- [ ] 1.6.1.2.2 Document that position comes from agent state
- [ ] 1.6.1.2.3 Add optional `include_details` boolean parameter
- [ ] 1.6.1.2.4 Configure parameter validation

### 1.6.1.3 Configure Jido.Action Options

Set up the action with proper Jido configuration.

- [ ] 1.6.1.3.1 Add `name: "sense_food"` to action options
- [ ] 1.6.1.3.2 Add `description: "Detect food at ant's current position"`
- [ ] 1.6.1.3.3 Configure any required action-level options

---

## 1.6.2 Implement Food Sensing Logic

Implement the core food detection logic.

### 1.6.2.1 Implement Query Plane Function

Query the Plane for food at the current position.

- [ ] 1.6.2.1.1 Implement `query_plane_for_food/1` - takes position
- [ ] 1.6.2.1.2 Call `AntColony.Plane.get_food_at(position)`
- [ ] 1.6.2.1.3 Handle `nil` return (no food at position)
- [ ] 1.6.2.1.4 Handle `FoodSource` struct return (food found)
- [ ] 1.6.2.1.5 Handle `{:error, reason}` return (Plane error)

### 1.6.2.2 Extract Position from Context

Get the ant's current position from the agent context.

- [ ] 1.6.2.2.1 Implement `get_current_position/1` - takes context
- [ ] 1.6.2.2.2 Extract `context.state.position`
- [ ] 1.6.2.2.3 Validate position is not nil
- [ ] 1.6.2.2.4 Return error if position is invalid

### 1.6.2.3 Implement Main run/2 Function

Implement the primary action execution function.

- [ ] 1.6.2.3.1 Define `run(params, context)` function
- [ ] 1.6.2.3.2 Get current position from context.state.position
- [ ] 1.6.2.3.3 Query Plane for food at position
- [ ] 1.6.2.3.4 Create result map with food details or nil
- [ ] 1.6.2.3.5 Return `{:ok, updated_state_map}`

---

## 1.6.3 Handle Food Not Found

Manage the case when no food is at the current position.

### 1.6.3.1 Return Unchanged State

When no food is found, return state without error.

- [ ] 1.6.3.1.1 Check if food query returned nil
- [ ] 1.6.3.1.2 Add `sensed_food: nil` to state updates
- [ ] 1.6.3.1.3 Return `{:ok, state_map}` without error
- [ ] 1.6.3.1.4 Document this as successful no-op

### 1.6.3.2 Add Optional Logging

Log food sensing results for debugging.

- [ ] 1.6.3.2.1 Add `require Logger` at module top
- [ ] 1.6.3.2.2 Log debug message when food not found
- [ ] 1.6.3.2.3 Include position and ant_id in log message
- [ ] 1.6.3.2.4 Make logging conditional on log level

### 1.6.3.3 Handle Plane Errors

Gracefully handle errors from Plane queries.

- [ ] 1.6.3.3.1 Match on `{:error, reason}` from Plane
- [ ] 1.6.3.3.2 Log error message with reason
- [ ] 1.6.3.3.3 Return `{:ok, %{sensed_food: :error}}`
- [ ] 1.6.3.3.4 Don't fail the action for Plane errors

---

## 1.6.4 Add Known Food Sources Tracking

Track discovered food sources in the agent's memory.

### 1.6.4.1 Create Food Source Entry

Create a structured entry for a discovered food source.

- [ ] 1.6.4.1.1 Implement `create_food_entry/3` - position, level, timestamp
- [ ] 1.6.4.1.2 Include position in entry map
- [ ] 1.6.4.1.3 Include level in entry map
- [ ] 1.6.4.1.4 Include `last_updated: DateTime.utc_now()` in entry

### 1.6.4.2 Update Known Food Sources

Add newly discovered food to agent's known sources.

- [ ] 1.6.4.2.1 Get existing `known_food_sources` from context.state
- [ ] 1.6.4.2.2 Check if food at position already known
- [ ] 1.6.4.2.3 Add new entry if not already known
- [ ] 1.6.4.2.4 Update entry if existing but outdated
- [ ] 1.6.4.2.5 Include updated list in returned state map

### 1.6.4.3 Prevent Duplicate Entries

Ensure food sources aren't duplicated in known list.

- [ ] 1.6.4.3.1 Implement `already_known?/2` - check position in list
- [ ] 1.6.4.3.2 Compare positions for equality
- [ ] 1.6.4.3.3 Return true/false for known status
- [ ] 1.6.4.3.4 Use in update logic to prevent duplicates

---

## 1.6.5 Publish Food Sensed Events

Broadcast events when food is discovered.

### 1.6.5.1 Broadcast on Food Discovery

Publish event when food is found at current position.

- [ ] 1.6.5.1.1 Check if food was found (not nil)
- [ ] 1.6.5.1.2 Call `AntColony.Events.broadcast_food_sensed/4`
- [ ] 1.6.5.1.3 Pass ant_id from context.state.id
- [ ] 1.6.5.1.4 Pass position where food was found
- [ ] 1.6.5.1.5 Pass food details map (level, quantity)

### 1.6.5.2 Create Food Details Map

Structure the food information for the event.

- [ ] 1.6.5.2.1 Extract level from FoodSource struct
- [ ] 1.6.5.2.2 Extract quantity from FoodSource struct
- [ ] 1.6.5.2.3 Create map with position, level, quantity
- [ ] 1.6.5.2.4 Include timestamp in details map

### 1.6.5.3 Handle Broadcast Errors

Gracefully handle PubSub broadcast failures.

- [ ] 1.6.5.3.1 Match on `{:error, reason}` from broadcast
- [ ] 1.6.5.3.2 Log warning with error reason
- [ ] 1.6.5.3.3 Continue action execution despite broadcast failure
- [ ] 1.6.5.3.4 Don't fail action for PubSub errors

---

## 1.6.6 Unit Tests for SenseFoodAction

Test the SenseFoodAction functionality.

### 1.6.6.1 Test Action with No Parameters

Verify action executes without required parameters.

- [ ] 1.6.6.1.1 Create `test/ant_colony/actions/sense_food_test.exs`
- [ ] 1.6.6.1.2 Add test: `test "executes with no parameters"` - empty params
- [ ] 1.6.6.1.3 Add test: `test "executes with empty params map"` - %{}
- [ ] 1.6.6.1.4 Add test: `test "returns ok tuple with no parameters"` - check return

### 1.6.6.2 Test Food Detection

Verify food is detected when present.

- [ ] 1.6.6.2.1 Add test: `test "returns food details when food present"` - with food
- [ ] 1.6.6.2.2 Add test: `test "includes food level in result"` - check level
- [ ] 1.6.6.2.3 Add test: `test "includes food quantity in result"` - check quantity
- [ ] 1.6.6.2.4 Add test: `test "includes position in result"` - check position

### 1.6.6.3 Test No Food Found

Verify behavior when no food is present.

- [ ] 1.6.6.3.1 Add test: `test "returns nil when no food at position"` - empty check
- [ ] 1.6.6.3.2 Add test: `test "returns ok tuple when no food"` - no error
- [ ] 1.6.6.3.3 Add test: `test "does not modify state when no food"` - unchanged

### 1.6.6.4 Test Known Food Sources Tracking

Verify discovered food is tracked in agent memory.

- [ ] 1.6.6.4.1 Add test: `test "adds food to known_food_sources"` - new entry
- [ ] 1.6.6.4.2 Add test: `test "includes timestamp in food entry"` - DateTime
- [ ] 1.6.6.4.3 Add test: `test "prevents duplicate food entries"` - unique
- [ ] 1.6.6.4.4 Add test: `test "updates existing food entry"` - refresh

### 1.6.6.5 Test Plane Queries

Verify Plane is queried correctly.

- [ ] 1.6.6.5.1 Add test: `test "queries Plane at current position"` - mock call
- [ ] 1.6.6.5.2 Add test: `test "passes correct position to Plane"` - verify param
- [ ] 1.6.6.5.3 Add test: `test "handles Plane error gracefully"` - error case

### 1.6.6.6 Test Event Broadcasting

Verify food_sensed events are published.

- [ ] 1.6.6.6.1 Add test: `test "broadcasts food_sensed event when food found"` - mock
- [ ] 1.6.6.6.2 Add test: `test "includes ant_id in event"` - verify field
- [ ] 1.6.6.6.3 Add test: `test "includes position in event"` - verify field
- [ ] 1.6.6.6.4 Add test: `test "includes food details in event"` - verify details
- [ ] 1.6.6.6.5 Add test: `test "does not broadcast when no food found"` - no event

---

## 1.6.7 Phase 1.6 Integration Tests

End-to-end tests for SenseFoodAction functionality.

### 1.6.7.1 Sense Food with Real Plane Test

Test action with actual Plane GenServer.

- [ ] 1.6.7.1.1 Create `test/ant_colony/actions/integration/sense_food_integration_test.exs`
- [ ] 1.6.7.1.2 Add setup starting Plane with food sources
- [ ] 1.6.7.1.3 Add test: `test "senses food at ant's position"` - on food
- [ ] 1.6.7.1.4 Add test: `test "returns nil when not on food"` - off food
- [ ] 1.6.7.1.5 Add test: `test "detects food level correctly"` - verify level

### 1.6.7.2 Food Discovery Workflow Test

Test complete food discovery and tracking workflow.

- [ ] 1.6.7.2.1 Add test: `test "ant discovers and tracks food source"` - full flow
- [ ] 1.6.7.2.2 Add test: `test "multiple ants can discover same food"` - shared
- [ ] 1.6.7.2.3 Add test: `test "known_food_sources persists across actions"` - retention
- [ ] 1.6.7.2.4 Add test: `test "re-sensing updates timestamp"` - refresh

### 1.6.7.3 PubSub Event Flow Test

Test event publishing to subscribers.

- [ ] 1.6.7.3.1 Add test: `test "subscribers receive food_sensed events"` - PubSub
- [ ] 1.6.7.3.2 Add test: `test "event includes complete food information"` - data
- [ ] 1.6.7.3.3 Add test: `test "multiple subscribers all receive event"` - broadcast

### 1.6.7.4 Combined Move and Sense Test

Test moving to food and sensing it.

- [ ] 1.6.7.4.1 Add test: `test "move then sense finds food"` - sequence
- [ ] 1.6.7.4.2 Add test: `test "sense at nest finds nothing"` - initial state
- [ ] 1.6.7.4.3 Add test: `test "sense after move to food location"` - discovery

---

## Phase 1.6 Success Criteria

1. **SenseFoodAction Module**: Jido.Action compiles and executes ✅
2. **Plane Queries**: Correctly queries Plane for food ✅
3. **No Food Handling**: Returns nil gracefully when no food ✅
4. **Food Tracking**: Updates known_food_sources ✅
5. **Event Publishing**: food_sensed events broadcast ✅
6. **Tests**: All unit and integration tests pass ✅

## Phase 1.6 Critical Files

**New Files:**
- `lib/ant_colony/actions/sense_food.ex` - SenseFoodAction module
- `test/ant_colony/actions/sense_food_test.exs` - Unit tests
- `test/ant_colony/actions/integration/sense_food_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/agent/ant.ex` - Add SenseFoodAction to actions list
- `lib/ant_colony/events.ex` - Ensure broadcast_food_sensed exists (from Phase 1.2)

---

## Next Phase

Proceed to [Phase 1.7: Supervision Tree](./07-supervision-tree.md) to set up the application supervision tree.
