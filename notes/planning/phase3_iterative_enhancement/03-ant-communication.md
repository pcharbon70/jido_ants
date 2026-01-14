# Phase 3.3: Ant-to-Ant Communication

Implement direct communication between ants when they encounter each other within a defined radius. This allows rapid dissemination of high-quality food source information, supplementing the indirect pheromone communication.

## Architecture

```
Ant Communication System
├── Proximity Detection:
│   └── Plane checks: distance(ant1, ant2) <= 3
│   └── Triggered on position updates
│
├── Communication Event:
│   └── Plane sends: {:ant_encounter, ant1_id, ant2_id, position}
│
├── Information Exchange:
│   └── known_food_sources: [
│       %{position: {x, y}, level: 1-5, last_updated: DateTime}
│     ]
│   └── Rule: Higher level overrides lower level
│
├── CommunicateAction:
│   └── Format and share food source info
│   └── Receive and update known_food_sources
│
└── UI Visualization:
    └── Brief highlight or indicator for communicating ants
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Proximity Detection | Detect when ants are within communication range |
| CommunicateAction | Exchange known food source information |
| Conflict Resolution | Merge food information based on quality |
| State Management | Update known_food_sources in agent state |
| UI Visualization | Show communication events |
| Communication Events | PubSub events for ant encounters |

---

## 3.3.1 Implement Proximity Detection

Detect when ants are within communication range.

### 3.3.1.1 Define Communication Constants

Establish constants for communication behavior.

- [ ] 3.3.1.1.1 Create `lib/ant_colony/communication.ex` module
- [ ] 3.3.1.1.2 Define `@communication_radius 3` (squares)
- [ ] 3.3.1.1.3 Define `@communication_cooldown_ms 5000` (min time between exchanges)
- [ ] 3.3.1.1.4 Define `@max_known_sources 10` (max food sources to remember)
- [ ] 3.3.1.1.5 Document constants in @moduledoc

### 3.3.1.2 Add Distance Calculation Helper

Create helper for calculating distance between positions.

- [ ] 3.3.1.2.1 Define `def distance(pos1, pos2)` returns float
- [ ] 3.3.1.2.2 Implement Euclidean distance: `sqrt((x2-x1)^2 + (y2-y1)^2)`
- [ ] 3.3.1.2.3 Define `def within_radius?(pos1, pos2, radius)` returns boolean
- [ ] 3.3.1.2.4 Add `@spec` definitions

### 3.3.1.3 Extend Plane with Proximity Detection

Add proximity checking to Plane.

- [ ] 3.3.1.3.1 Open `lib/ant_colony/plane.ex`
- [ ] 3.3.1.3.2 Add `:last_proximity_check` timestamp to state (default: nil)
- [ ] 3.3.1.3.3 Add `:communication_cooldowns` map to state (default: %{})
  - Format: `%{ant_id => last_communication_time}`
- [ ] 3.3.1.3.4 Document new fields

### 3.3.1.4 Implement check_proximity API

Create API for triggering proximity detection.

- [ ] 3.3.1.4.1 Define client function: `def check_proximity(ant_id)`
- [ ] 3.3.1.4.2 Implement as `GenServer.call(__MODULE__, {:check_proximity, ant_id})`
- [ ] 3.3.1.4.3 Add handle_call clause for `:check_proximity`
- [ ] 3.3.1.4.4 Get ant's position from `ant_positions` map
- [ ] 3.3.1.4.5 Iterate over all other ant positions:
  - Calculate distance
  - Collect ants within `@communication_radius`
- [ ] 3.3.1.4.6 Filter out ants on cooldown
- [ ] 3.3.1.4.7 For each nearby ant:
  - Publish `{:ant_encounter, ant_id, nearby_ant_id, position}`
  - Update cooldowns for both ants
- [ ] 3.3.1.4.8 Return `{:reply, nearby_ants, updated_state}`

### 3.3.1.5 Integrate Proximity Check with MoveAction

Trigger proximity detection after movement.

- [ ] 3.3.1.5.1 Open `lib/ant_colony/actions/move_action.ex`
- [ ] 3.3.1.5.2 After updating position in run/2:
  - Call `Plane.check_proximity(ant_id)`
- [ ] 3.3.1.5.3 Handle any encounter events returned
- [ ] 3.3.1.5.4 Add `:check_proximity` option (default: `true`)

---

## 3.3.2 Implement CommunicateAction

Create action for ant-to-ant information exchange.

### 3.3.2.1 Create CommunicateAction Module

Set up the action module structure.

- [ ] 3.3.2.1.1 Create `lib/ant_colony/actions/communicate_action.ex`
- [ ] 3.3.2.1.2 Add `defmodule AntColony.Actions.CommunicateAction`
- [ ] 3.3.2.1.3 Add `use Jido.Action`
- [ ] 3.3.2.1.4 Add comprehensive `@moduledoc`

### 3.3.2.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.3.2.2.1 Define `@param_schema` with fields:
  - `:with_ant_id` - type: `:string`, required: true
  - `:share_sources` - type: `:boolean`, default: `true`
  - `:receive_sources` - type: `:boolean`, default: `true`
- [ ] 3.3.2.2.2 Add validation for with_ant_id

### 3.3.2.3 Implement run/2 Function

Execute the communication logic.

- [ ] 3.3.2.3.1 Define `def run(params, context)` function
- [ ] 3.3.2.3.2 Extract `with_ant_id` from params
- [ ] 3.3.2.3.3 Get current ant's `known_food_sources` from state
- [ ] 3.3.2.3.4 If `:share_sources` is true:
  - Format message: `%{from: context.state.id, sources: known_food_sources}`
  - Send signal to `with_ant_id` (via Plane or direct)
  - Publish `{:communication_started, context.state.id, with_ant_id}` event
- [ ] 3.3.2.3.5 If `:receive_sources` is true:
  - Wait for response from other ant (timeout: 1000ms)
  - Receive other ant's food sources
- [ ] 3.3.2.3.6 Merge received sources with own (see conflict resolution)
- [ ] 3.3.2.3.7 Update agent state with merged `known_food_sources`
- [ ] 3.3.2.3.8 Publish `{:communication_completed, ant1_id, ant2_id, shared_count}` event
- [ ] 3.3.2.3.9 Return `{:ok, updated_state}`

### 3.3.2.4 Add Signal Handling

Handle incoming communication signals.

- [ ] 3.3.2.4.1 Add `handle_info/2` clause for `{:communication_request, from_ant_id, sources}`
- [ ] 3.3.2.4.2 Extract own `known_food_sources`
- [ ] 3.3.2.4.3 Perform conflict resolution (see next section)
- [ ] 3.3.2.4.4 Send reply with own sources
- [ ] 3.3.2.4.5 Update state with merged sources
- [ ] 3.3.2.4.6 Return `{:noreply, updated_state}`

---

## 3.3.3 Implement Conflict Resolution

Merge food source information based on quality rules.

### 3.3.3.1 Define Merge Strategy

Establish rules for combining food information.

- [ ] 3.3.3.1.1 Define rule: Higher level overrides lower level for same position
- [ ] 3.3.3.1.2 Define rule: More recent timestamp preferred
- [ ] 3.3.3.1.3 Define rule: Keep only `@max_known_sources` best sources
- [ ] 3.3.3.1.4 Document merge strategy in @moduledoc

### 3.3.3.2 Implement merge_food_sources Function

Create helper for merging food source lists.

- [ ] 3.3.3.2.1 Define `def merge_food_sources(my_sources, their_sources)`
- [ ] 3.3.3.2.2 Create map from position → best source:
  ```elixir
  combined = my_sources ++ their_sources
  |> Enum.group_by(fn s -> s.position end)
  |> Enum.map(fn {pos, sources} ->
    Enum.max_by(sources, fn s ->
      {s.level, DateTime.to_unix(s.last_updated)}
    end)
  end)
  ```
- [ ] 3.3.3.2.3 Sort by level (descending), then recency
- [ ] 3.3.3.2.4 Take first `@max_known_sources` entries
- [ ] 3.3.3.2.5 Return merged list

### 3.3.3.3 Implement Update Rule

Apply the update logic: higher nutrient level wins.

- [ ] 3.3.3.3.1 Define `def should_update_source?(my_source, their_source)`
- [ ] 3.3.3.3.2 Compare levels:
  - If `their_source.level > my_source.level`: return `true`
  - If levels equal: compare timestamps
- [ ] 3.3.3.3.3 Return `true` if theirs is more recent
- [ ] 3.3.3.3.4 Otherwise return `false`

---

## 3.3.4 Extend Agent with Communication State

Add communication-related state to AntAgent.

### 3.3.4.1 Add Communication Fields to Agent Schema

Extend AntAgent schema with communication state.

- [ ] 3.3.4.1.1 Open `lib/ant_colony/agent.ex`
- [ ] 3.3.4.1.2 Add `:known_food_sources` field:
  - Type: `[%{position: {x, y}, level: 1-5, last_updated: DateTime}]`
  - Default: `[]`
- [ ] 3.3.4.1.3 Add `:last_communication_time` field:
  - Type: `DateTime | nil`
  - Default: `nil`
- [ ] 3.3.4.1.4 Add `:communicating_with` field:
  - Type: `String.t() | nil`
  - Default: `nil` (currently communicating with this ant)
- [ ] 3.3.4.1.5 Document new fields

### 3.3.4.2 Add Communication FSM State

Integrate communication into state machine.

- [ ] 3.3.4.2.1 Open `lib/ant_colony/agent/state_machine.ex`
- [ ] 3.3.4.2.2 Add `@communicating` state constant
- [ ] 3.3.4.2.3 Add transitions:
  - `:searching` → `:communicating` (on encounter)
  - `:returning_to_nest` → `:communicating` (optional, may skip)
  - `:communicating` → previous state (after exchange)
- [ ] 3.3.4.2.4 Store previous state before entering `:communicating`
- [ ] 3.3.4.2.5 Restore previous state after communication

### 3.3.4.3 Handle Encounter Events in Agent

Process ant_encounter events.

- [ ] 3.3.4.3.1 Add `handle_info/2` for `{:ant_encounter, other_ant_id, position}`
- [ ] 3.3.4.3.2 Check if agent should communicate:
  - Not already communicating
  - Not on cooldown
  - Not in critical state (urgently returning with high-value food)
- [ ] 3.3.4.3.3 If should communicate:
  - Transition to `:communicating` state
  - Store previous state
  - Execute `CommunicateAction.run(%{with_ant_id: other_ant_id}, context)`
  - Schedule return to previous state after timeout
- [ ] 3.3.4.3.4 Otherwise: ignore encounter

---

## 3.3.5 UI Communication Visualization

Add visual feedback for communication events.

### 3.3.5.1 Extend UI State for Communication

Add communication tracking to UI.

- [ ] 3.3.5.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.3.5.1.2 Add `:active_communications` field to UI struct
  - Type: `%{ant_id => %{with: ant_id, started_at: DateTime}}`
  - Default: `%{}`
- [ ] 3.3.5.1.3 Add `:show_communications` boolean (default: `true`)

### 3.3.5.2 Handle Communication Events

Process communication-related events.

- [ ] 3.3.5.2.1 Add update clause for `{:communication_started, ant1_id, ant2_id}`
  - Add entry to `active_communications` for both ants
  - Set `started_at: DateTime.utc_now()`
- [ ] 3.3.5.2.2 Add update clause for `{:communication_completed, ant1_id, ant2_id, count}`
  - Remove entries from `active_communications`
  - Optionally show brief indicator of shared count
- [ ] 3.3.5.2.3 Clean up stale communications (older than 2 seconds)

### 3.3.5.3 Render Communication Indicators

Display visual feedback for communicating ants.

- [ ] 3.3.5.3.1 In view/1, when drawing ants:
  - Check if ant is in `active_communications`
  - If communicating and `:show_communications`:
    - Draw special character: "☻" or "@"
    - Use bright color (cyan or magenta)
    - Optionally draw line between communicating ants
- [ ] 3.3.5.3.2 Show communication for brief period after completion
  - Keep indicator for 500ms after event
  - Use fading intensity if possible

### 3.3.5.4 Add Communication Log (Optional)

Create a log panel for communication events.

- [ ] 3.3.5.4.1 Add `:communication_log` field to UI state
  - Type: `[%{time: DateTime, message: String}]`
  - Default: `[]`
  - Max length: 10 entries
- [ ] 3.3.5.4.2 On `:communication_completed`:
  - Add log entry: `"Ant #{ant1_id} ↔ Ant #{ant2_id}: #{count} sources"`
- [ ] 3.3.5.4.3 Display log in corner of canvas or status bar
- [ ] 3.3.5.4.4 Color-code based on information value

### 3.3.5.5 Add Toggle for Communication Display

Allow user to show/hide communication indicators.

- [ ] 3.3.5.5.1 Add update clause for `%Event.Key{key: "c"}`:
  - Toggle `:show_communications`
- [ ] 3.3.5.5.2 Display current toggle state in help/status

---

## 3.3.6 Unit Tests for Communication System

Test all communication-related functionality.

### 3.3.6.1 Test Distance Calculation

Verify proximity detection math.

- [ ] 3.3.6.1.1 Create `test/ant_colony/communication_test.exs`
- [ ] 3.3.6.1.2 Add test: `test "distance calculates Euclidean distance correctly"` - basic
- [ ] 3.3.6.1.3 Add test: `test "within_radius? returns correct boolean"` - radius check
- [ ] 3.3.6.1.4 Add test: `test "distance handles edge cases"` - boundaries

### 3.3.6.2 Test Plane Proximity Detection

Verify Plane detects nearby ants correctly.

- [ ] 3.3.6.2.1 Create `test/ant_colony/plane_proximity_test.exs`
- [ ] 3.3.6.2.2 Add test: `test "check_proximity finds ants within radius"` - detection
- [ ] 3.3.6.2.3 Add test: `test "check_proximity excludes ants outside radius"` - exclusion
- [ ] 3.3.6.2.4 Add test: `test "check_proximity respects cooldowns"` - cooldowns
- [ ] 3.3.6.2.5 Add test: `test "check_proximity publishes ant_encounter events"` - events
- [ ] 3.3.6.2.6 Add test: `test "multiple ants detected in same area"` - multiple

### 3.3.6.3 Test CommunicateAction

Verify communication action works.

- [ ] 3.3.6.3.1 Create `test/ant_colony/actions/communicate_action_test.exs`
- [ ] 3.3.6.3.2 Add test: `test "run shares known_food_sources"` - sharing
- [ ] 3.3.6.3.3 Add test: `test "run receives sources from other ant"` - receiving
- [ ] 3.3.6.3.4 Add test: `test "run updates state with merged sources"` - merge
- [ ] 3.3.6.3.5 Add test: `test "run publishes communication events"` - events
- [ ] 3.3.6.3.6 Add test: `test "run handles timeout waiting for response"` - timeout

### 3.3.6.4 Test Conflict Resolution

Verify merge strategy works correctly.

- [ ] 3.3.6.4.1 Add test: `test "merge_food_sources keeps higher level"` - level priority
- [ ] 3.3.6.4.2 Add test: `test "merge_food_sources keeps more recent timestamp"` - time priority
- [ ] 3.3.6.4.3 Add test: `test "merge_food_sources limits to max_known_sources"` - limit
- [ ] 3.3.6.4.4 Add test: `test "should_update_source? returns correct boolean"` - comparison
- [ ] 3.3.6.4.5 Add test: `test "merge handles duplicate positions"` - duplicates

### 3.3.6.5 Test Agent Communication State

Verify agent manages communication state correctly.

- [ ] 3.3.6.5.1 Add test: `test "agent adds sources to known_food_sources"` - storage
- [ ] 3.3.6.5.2 Add test: `test "agent transitions to communicating state"` - state change
- [ ] 3.3.6.5.3 Add test: `test "agent returns to previous state after communication"` - restore
- [ ] 3.3.6.5.4 Add test: `test "agent respects communication cooldown"` - cooldown
- [ ] 3.3.6.5.5 Add test: `test "agent skips communication when carrying high-value food"` - priority

### 3.3.6.6 Test UI Communication Display

Verify UI shows communication events.

- [ ] 3.3.6.6.1 Add test: `test "UI receives communication events"` - event handling
- [ ] 3.3.6.6.2 Add test: `test "UI displays communication indicator"` - rendering
- [ ] 3.3.6.6.3 Add test: `test "UI toggles communication display"` - toggle
- [ ] 3.3.6.6.4 Add test: `test "UI log shows communication messages"` - logging

---

## 3.3.7 Phase 3.3 Integration Tests

End-to-end tests for communication system.

### 3.3.7.1 Encounter Detection Test

Verify proximity detection works in simulation.

- [ ] 3.3.7.1.1 Create `test/ant_colony/integration/communication_integration_test.exs`
- [ ] 3.3.7.1.2 Add test: `test "ants within 3 squares trigger encounter"` - detection
- [ ] 3.3.7.1.3 Add test: `test "ants outside 3 squares don't trigger encounter"` - boundary
- [ ] 3.3.7.1.4 Add test: `test "multiple encounters detected correctly"` - multiple
- [ ] 3.3.7.1.5 Add test: `test "cooldown prevents repeated encounters"` - cooldown

### 3.3.7.2 Information Exchange Test

Verify information is shared correctly.

- [ ] 3.3.7.2.1 Add test: `test "ants exchange food source information"` - exchange
- [ ] 3.3.7.2.2 Add test: `test "ant with better source convinces other"` - persuasion
- [ ] 3.3.7.2.3 Add test: `test "both ants end up with best known sources"` - merge
- [ ] 3.3.7.2.4 Add test: `test "new information influences ant behavior"` - behavior

### 3.3.7.3 Communication Impact Test

Verify communication improves foraging efficiency.

- [ ] 3.3.7.3.1 Add test: `test "ants find food faster with communication"` - speed
- [ ] 3.3.7.3.2 Add test: `test "colony converges on high-quality sources"` - convergence
- [ ] 3.3.7.3.3 Add test: `test "communication accelerates pheromone trail formation"` - pheromones
- [ ] 3.3.7.3.4 Add test: `test "absence of communication slows optimization"` - comparison

### 3.3.7.4 UI Communication Visualization Test

Verify UI correctly shows communication.

- [ ] 3.3.7.4.1 Add test: `test "UI highlights communicating ants"` - highlight
- [ ] 3.3.7.4.2 Add test: `test "communication indicators fade after completion"` - fade
- [ ] 3.3.7.4.3 Add test: `test "UI log captures all communication events"` - log
- [ ] 3.3.7.4.4 Add test: `test "toggle hides/shows communication indicators"` - toggle

---

## Phase 3.3 Success Criteria

1. **Proximity Detection**: Plane detects ants within 3 squares ✅
2. **CommunicateAction**: Information exchange works ✅
3. **Conflict Resolution**: Higher quality sources override lower ✅
4. **Agent State**: known_food_sources managed correctly ✅
5. **FSM Integration**: Communicating state works ✅
6. **Cooldown**: Repeated encounters throttled ✅
7. **UI Visualization**: Communication events visible ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 3.3 Critical Files

**New Files:**
- `lib/ant_colony/communication.ex` - Communication constants and helpers
- `lib/ant_colony/actions/communicate_action.ex` - Communication action
- `test/ant_colony/communication_test.exs` - Communication unit tests
- `test/ant_colony/plane_proximity_test.exs` - Proximity tests
- `test/ant_colony/actions/communicate_action_test.exs` - Action tests
- `test/ant_colony/integration/communication_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/plane.ex` - Add proximity detection
- `lib/ant_colony/agent.ex` - Add communication state fields
- `lib/ant_colony/agent/state_machine.ex` - Add communicating state
- `lib/ant_colony/actions/move_action.ex` - Trigger proximity check
- `lib/ant_colony/ui.ex` - Add communication visualization

---

## Next Phase

Proceed to [Phase 3.4: Machine Learning Integration](./04-ml-integration.md) to implement Axon-based learning for search pattern optimization.
