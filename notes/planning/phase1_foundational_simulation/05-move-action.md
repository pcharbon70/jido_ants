# Phase 1.5: Move Action

Implement the MoveAction for ant movement with event publishing. This enables ants to move through the simulated environment and broadcast their position changes.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AntColony.Actions.Move                            │
│                      (Jido.Action)                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Parameters:                                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • direction: :north | :south | :east | :west | :random   │    │
│  │  • steps: integer() (default: 1)                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Context (from Agent):                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • agent.state.position - Current position                 │    │
│  │  • agent.state.path_memory - Movement history              │    │
│  │  • agent.state.id - Ant identifier                        │    │
│  │  • agent.state.current_state - FSM state                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Effects:                                                           │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  1. Update agent.state.position to new coordinates         │    │
│  │  2. Append {old_pos, observations} to path_memory           │    │
│  │  3. Call AntColony.Plane.update_ant_position/2             │    │
│  │  4. Broadcast {:ant_moved, ant_id, old_pos, new_pos}       │    │
│  │     via AntColony.Events.broadcast_ant_moved/4             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Return:                                                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  {:ok, updated_state_map}                                  │    │
│  │  {:error, reason}                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Actions.Move | Jido.Action for ant movement |
| AntColony.Plane | Environment for position updates |
| AntColony.Events | Event broadcasting for ant_moved |

---

## 1.5.1 Create MoveAction Module Structure

Create the basic Jido.Action module for ant movement.

### 1.5.1.1 Create Action Module File

Create the move action module in the actions directory.

- [ ] 1.5.1.1.1 Create `lib/ant_colony/actions/move.ex`
- [ ] 1.5.1.1.2 Add `defmodule AntColony.Actions.Move`
- [ ] 1.5.1.1.3 Add `use Jido.Action, ...` with appropriate options
- [ ] 1.5.1.1.4 Add comprehensive `@moduledoc` describing the action

### 1.5.1.2 Define Action Parameters Schema

Define the parameters that the action accepts.

- [ ] 1.5.1.2.1 Define `param` schema with `:direction` field
- [ ] 1.5.1.2.2 Set direction type as atom with allowed values
- [ ] 1.5.1.2.3 Define `:steps` field with default value of 1
- [ ] 1.5.1.2.4 Add validation for direction values: `:north, :south, :east, :west, :random`

### 1.5.1.3 Configure Jido.Action Options

Set up the action with proper Jido configuration.

- [ ] 1.5.1.3.1 Add `name: "move"` to action options
- [ ] 1.5.1.3.2 Add `description: "Move the ant in the specified direction"`
- [ ] 1.5.1.3.3 Configure any required action-level options

---

## 1.5.2 Implement Movement Logic

Implement the core movement calculation logic.

### 1.5.2.1 Implement Direction Calculation

Create functions to calculate new position based on direction.

- [ ] 1.5.2.1.1 Implement `calculate_new_position/2` - takes position and direction
- [ ] 1.5.2.1.2 Handle `:north` - decrement y: `{x, y - 1}`
- [ ] 1.5.2.1.3 Handle `:south` - increment y: `{x, y + 1}`
- [ ] 1.5.2.1.4 Handle `:east` - increment x: `{x + 1, y}`
- [ ] 1.5.2.1.5 Handle `:west` - decrement x: `{x - 1, y}`
- [ ] 1.5.2.1.6 Handle `:random` - randomly select from four directions

### 1.5.2.2 Implement Steps Handling

Support moving multiple steps in one action.

- [ ] 1.5.2.2.1 Implement `apply_steps/3` - takes position, direction, steps
- [ ] 1.5.2.2.2 Call calculate_new_position recursively for each step
- [ ] 1.5.2.2.3 Return final position after all steps
- [ ] 1.5.2.2.4 Handle steps = 0 (no movement)

### 1.5.2.3 Implement Boundary Validation

Add optional boundary checking for grid constraints.

- [ ] 1.5.2.3.1 Implement `valid_position?/2` - takes position and plane dimensions
- [ ] 1.5.2.3.2 Check x >= 0 and x < width
- [ ] 1.5.2.3.3 Check y >= 0 and y < height
- [ ] 1.5.2.3.4 Return `true/false` for validity

### 1.5.2.4 Implement Main run/2 Function

Implement the primary action execution function.

- [ ] 1.5.2.4.1 Define `run(params, context)` function
- [ ] 1.5.2.4.2 Extract direction from params
- [ ] 1.5.2.4.3 Extract steps from params (default to 1)
- [ ] 1.5.2.4.4 Get current position from context.state.position
- [ ] 1.5.2.4.5 Calculate new_position using direction/steps
- [ ] 1.5.2.4.6 Return updated state map with new position

---

## 1.5.3 Add Path Memory Tracking

Implement tracking of visited positions.

### 1.5.3.1 Create Path Memory Entry

Create an entry for the current position before moving.

- [ ] 1.5.3.1.1 Create observation map for current position
- [ ] 1.5.3.1.2 Include timestamp in observation map
- [ ] 1.5.3.1.3 Include current_state in observation map
- [ ] 1.5.3.1.4 Create `{old_position, observation}` tuple

### 1.5.3.2 Update Path Memory

Append the new entry to the agent's path memory.

- [ ] 1.5.3.2.1 Get existing path_memory from context.state
- [ ] 1.5.3.2.2 Prepend new entry to maintain chronological order
- [ ] 1.5.3.2.3 Limit path_memory size (optional, e.g., 100 entries)
- [ ] 1.5.3.2.4 Include updated path_memory in returned state map

---

## 1.5.4 Publish Ant Moved Events

Integrate event publishing for position changes.

### 1.5.4.1 Publish to Plane

Update the Plane's ant position registry.

- [ ] 1.5.4.1.1 Call `AntColony.Plane.update_ant_position(ant_id, new_position)`
- [ ] 1.5.4.1.2 Handle `:ok` response
- [ ] 1.5.4.1.3 Handle `{:error, :not_found}` (ant not registered)
- [ ] 1.5.4.1.4 Log error if Plane update fails

### 1.5.4.2 Broadcast Event

Broadcast the ant_moved event via PubSub.

- [ ] 1.5.4.2.1 Call `AntColony.Events.broadcast_ant_moved/4`
- [ ] 1.5.4.2.2 Pass ant_id from context.state.id
- [ ] 1.5.4.2.3 Pass old_position and new_position
- [ ] 1.5.4.2.4 Pass AntColony.PubSub as pubsub_name
- [ ] 1.5.4.2.5 Handle broadcast errors gracefully

### 1.5.4.3 Handle Edge Cases

Manage special movement scenarios.

- [ ] 1.5.4.3.1 Handle movement to same position (no-op)
- [ ] 1.5.4.3.2 Handle boundary cases (clamp or bounce)
- [ ] 1.5.4.3.3 Handle invalid direction parameter
- [ ] 1.5.4.3.4 Return appropriate error tuples

---

## 1.5.5 Unit Tests for MoveAction Parameters

Test parameter validation and schema.

### 1.5.5.1 Test Direction Parameter

Verify direction parameter handling.

- [ ] 1.5.5.1.1 Create `test/ant_colony/actions/move_test.exs`
- [ ] 1.5.5.1.2 Add test: `test "accepts :north direction"` - valid direction
- [ ] 1.5.5.1.3 Add test: `test "accepts :south direction"` - valid direction
- [ ] 1.5.5.1.4 Add test: `test "accepts :east direction"` - valid direction
- [ ] 1.5.5.1.5 Add test: `test "accepts :west direction"` - valid direction
- [ ] 1.5.5.1.6 Add test: `test "accepts :random direction"` - valid direction
- [ ] 1.5.5.1.7 Add test: `test "rejects invalid direction"` - error case

### 1.5.5.2 Test Steps Parameter

Verify steps parameter handling.

- [ ] 1.5.5.2.1 Add test: `test "default steps is 1"` - check default
- [ ] 1.5.5.2.2 Add test: `test "accepts positive steps value"` - valid input
- [ ] 1.5.5.2.3 Add test: `test "handles steps of 0"` - no movement
- [ ] 1.5.5.2.4 Add test: `test "handles multiple steps"` - check result

### 1.5.5.3 Test Parameter Validation

Verify parameter schema validation.

- [ ] 1.5.5.3.1 Add test: `test "validates required direction"` - missing param
- [ ] 1.5.5.3.2 Add test: `test "validates steps type"` - wrong type
- [ ] 1.5.5.3.3 Add test: `test "rejects negative steps"` - invalid value

---

## 1.5.6 Unit Tests for Movement Logic

Test the core movement calculation.

### 1.5.6.1 Test Direction Calculations

Verify each direction moves correctly.

- [ ] 1.5.6.1.1 Add test: `test "north decrements y coordinate"` - check {x, y-1}
- [ ] 1.5.6.1.2 Add test: `test "south increments y coordinate"` - check {x, y+1}
- [ ] 1.5.6.1.3 Add test: `test "east increments x coordinate"` - check {x+1, y}
- [ ] 1.5.6.1.4 Add test: `test "west decrements x coordinate"` - check {x-1, y}
- [ ] 1.5.6.1.5 Add test: `test "random produces valid direction"` - check result

### 1.5.6.2 Test Multi-Step Movement

Verify moving multiple steps works correctly.

- [ ] 1.5.6.2.1 Add test: `test "two steps north moves y-2"` - check result
- [ ] 1.5.6.2.2 Add test: `test "three steps east moves x+3"` - check result
- [ ] 1.5.6.2.3 Add test: `test "steps apply sequentially"` - check intermediate positions

### 1.5.6.3 Test Boundary Handling

Verify boundary validation works correctly.

- [ ] 1.5.6.3.1 Add test: `test "valid_position? accepts valid coordinates"` - within bounds
- [ ] 1.5.6.3.2 Add test: `test "valid_position? rejects negative x"` - out of bounds
- [ ] 1.5.6.3.3 Add test: `test "valid_position? rejects negative y"` - out of bounds
- [ ] 1.5.6.3.4 Add test: `test "valid_position? uses plane dimensions"` - check limits

### 1.5.6.4 Test Edge Cases

Verify edge cases are handled correctly.

- [ ] 1.5.6.4.1 Add test: `test "moving to same position is no-op"` - {0,0} with no actual move
- [ ] 1.5.6.4.2 Add test: `test "wraps at boundaries (if implemented)"` - or clamp
- [ ] 1.5.6.4.3 Add test: `test "handles nil position gracefully"` - error handling

---

## 1.5.7 Unit Tests for Path Memory

Test path memory tracking functionality.

### 1.5.7.1 Test Path Memory Updates

Verify path memory is updated on move.

- [ ] 1.5.7.1.1 Add test: `test "path_memory is updated after move"` - check entry added
- [ ] 1.5.7.1.2 Add test: `test "path_memory entry includes old position"` - check tuple
- [ ] 1.5.7.1.3 Add test: `test "path_memory entry includes observation"` - check map
- [ ] 1.5.7.1.4 Add test: `test "path_memory maintains order"` - newest first

### 1.5.7.2 Test Observation Map

Verify observation map structure.

- [ ] 1.5.7.2.1 Add test: `test "observation includes timestamp"` - check DateTime
- [ ] 1.5.7.2.2 Add test: `test "observation includes current_state"` - check FSM state
- [ ] 1.5.7.2.3 Add test: `test "observation can include additional data"` - extensible

### 1.5.7.3 Test Path Memory Limits

Verify path memory size limiting (if implemented).

- [ ] 1.5.7.3.1 Add test: `test "path_memory is limited to max size"` - check truncation
- [ ] 1.5.7.3.2 Add test: `test "oldest entries are dropped first"` - FIFO order
- [ ] 1.5.7.3.3 Add test: `test "path_memory limit is configurable"` - check option

---

## 1.5.8 Unit Tests for Event Publishing

Test event publishing functionality.

### 1.5.8.1 Test Plane Updates

Verify Plane is updated with new position.

- [ ] 1.5.8.1.1 Add test: `test "calls Plane.update_ant_position/2"` - mock verification
- [ ] 1.5.8.1.2 Add test: `test "passes correct ant_id to Plane"` - verify parameter
- [ ] 1.5.8.1.3 Add test: `test "passes correct new_position to Plane"` - verify parameter
- [ ] 1.5.8.1.4 Add test: `test "handles Plane error gracefully"` - error case

### 1.5.8.2 Test Event Broadcasting

Verify ant_moved event is broadcast.

- [ ] 1.5.8.2.1 Add test: `test "broadcasts ant_moved event"` - mock call verification
- [ ] 1.5.8.2.2 Add test: `test "includes ant_id in event"` - verify field
- [ ] 1.5.8.2.3 Add test: `test "includes old_position in event"` - verify field
- [ ] 1.5.8.2.4 Add test: `test "includes new_position in event"` - verify field
- [ ] 1.5.8.2.5 Add test: `test "broadcasts to correct PubSub"` - verify pubsub_name

### 1.5.8.3 Test Event Order

Verify events are published in correct order.

- [ ] 1.5.8.3.1 Add test: `test "updates Plane before broadcasting"` - order check
- [ ] 1.5.8.3.2 Add test: `test "state change completes before event"` - consistency

---

## 1.5.9 Phase 1.5 Integration Tests

End-to-end tests for MoveAction functionality.

### 1.5.9.1 Action Execution Test

Test complete action execution with real components.

- [ ] 1.5.9.1.1 Create `test/ant_colony/actions/integration/move_integration_test.exs`
- [ ] 1.5.9.1.2 Add setup starting Plane and PubSub
- [ ] 1.5.9.1.3 Add test: `test "executing move updates agent position"` - agent state
- [ ] 1.5.9.1.4 Add test: `test "executing move updates Plane registry"` - Plane check
- [ ] 1.5.9.1.5 Add test: `test "executing move broadcasts event"` - PubSub check

### 1.5.9.2 Multi-Ant Movement Test

Test multiple ants moving concurrently.

- [ ] 1.5.9.2.1 Add test: `test "multiple ants can move independently"` - concurrent
- [ ] 1.5.9.2.2 Add test: `test "each ant broadcasts unique events"` - distinct ids
- [ ] 1.5.9.2.3 Add test: `test "Plane tracks all ant positions correctly"` - consistency

### 1.5.9.3 Move with Agent Test

Test MoveAction through Jido.Agent.cmd/2.

- [ ] 1.5.9.3.1 Add test: `test "agent can execute MoveAction via cmd"` - Jido API
- [ ] 1.5.9.3.2 Add test: `test "agent state is updated after move"` - state update
- [ ] 1.5.9.3.3 Add test: `test "agent path_memory is updated after move"` - memory
- [ ] 1.5.9.3.4 Add test: `test "move returns directives"` - Jido directives

---

## Phase 1.5 Success Criteria

1. **MoveAction Module**: Jido.Action compiles and executes ✅
2. **Direction Logic**: All four directions work correctly ✅
3. **Random Movement**: Random direction produces valid move ✅
4. **Path Memory**: Moves are tracked in path_memory ✅
5. **Plane Updates**: Plane registry is updated ✅
6. **Event Publishing**: ant_moved events are broadcast ✅
7. **Tests**: All unit and integration tests pass ✅

## Phase 1.5 Critical Files

**New Files:**
- `lib/ant_colony/actions/move.ex` - MoveAction module
- `test/ant_colony/actions/move_test.exs` - Unit tests
- `test/ant_colony/actions/integration/move_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/agent/ant.ex` - Add MoveAction to actions list
- `lib/ant_colony/events.ex` - Ensure broadcast_ant_moved exists (from Phase 1.2)

---

## Next Phase

Proceed to [Phase 1.6: Sense Food Action](./06-sense-food-action.md) to implement food detection.
