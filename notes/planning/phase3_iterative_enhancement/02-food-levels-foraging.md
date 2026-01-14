# Phase 3.2: Food Levels and Foraging Logic

Implement food level-based foraging behavior where ants evaluate food quality, pick up food, return to the nest following their path memory, and deposit food. This cycle adds sophistication to the foraging decision-making process.

## Architecture

```
Food-Based Foraging System
├── Food Sources:
│   └── %{{x, y} => %{level: 1-5, quantity: integer()}}
│       ├── level 1-2: Low quality (ants may ignore)
│       ├── level 3: Medium quality
│       └── level 4-5: High quality (highly desirable)
│
├── AntAgent State Machine:
│   ├── :at_nest → :searching (when ready to forage)
│   ├── :searching → :returning_to_nest (when food found, level > 2)
│   ├── :returning_to_nest → :at_nest (when nest reached)
│   └── :at_nest → :searching (after dropping food, if energy allows)
│
├── Actions:
│   ├── PickUpFoodAction - Pick up food at current position
│   ├── DropFoodAction - Drop food at nest
│   └── RetracePathAction - Follow path_memory back to nest
│
├── Plane State:
│   └── total_food_collected: integer() (colony-wide total)
│
└── UI Display:
    ├── Food: "F1"-"F5" with color coding (yellow to red)
    ├── Ant: "a" (searching), "A" (returning with food)
    └── Status: Total food collected at nest
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Food level evaluation | Ants decide whether to pick up food based on quality |
| PickUpFoodAction | Ant picks up food at current position |
| DropFoodAction | Ant deposits food at nest |
| RetracePathAction | Ant follows path_memory back to nest |
| Ant state machine | Behavioral states for foraging cycle |
| Colony food tracking | Total food collected by colony |
| UI enhancements | Food levels, ant states, colony statistics |

---

## 3.2.1 Define Food Level Evaluation

Implement food quality assessment logic.

### 3.2.1.1 Define Food Quality Thresholds

Establish constants for food evaluation.

- [ ] 3.2.1.1.1 Create `lib/ant_colony/food.ex` module
- [ ] 3.2.1.1.2 Define `@low_quality_threshold 2` (below this, ignore)
- [ ] 3.2.1.1.3 Define `@medium_quality_threshold 3`
- [ ] 3.2.1.1.4 Define `@high_quality_threshold 4`
- [ ] 3.2.1.1.5 Define `@pickup_threshold 2` (pickup if level > 2)
- [ ] 3.2.1.1.6 Document food quality decision logic in @moduledoc

### 3.2.1.2 Create Food Evaluation Helper

Add functions for food quality assessment.

- [ ] 3.2.1.2.1 Define `def should_pickup?(level)` returns boolean
- [ ] 3.2.1.2.2 Define `def quality_category(level)` returns `:low | :medium | :high`
- [ ] 3.2.1.2.3 Define `def pickup_probability(level)` returns float (0.0-1.0)
- [ ] 3.2.1.2.4 Implement probability curve:
  - Level 1-2: 0.0 probability
  - Level 3: 0.5 probability
  - Level 4-5: 1.0 probability
- [ ] 3.2.1.2.5 Add `@spec` definitions for all functions

### 3.2.1.3 Extend SenseFoodAction

Add food level evaluation to sensing.

- [ ] 3.2.1.3.1 Open `lib/ant_colony/actions/sense_food_action.ex`
- [ ] 3.2.1.3.2 Add `:evaluate_quality` option to param schema
- [ ] 3.2.1.3.3 In run/2, if food detected:
  - Extract food level from Plane response
  - Call `Food.should_pickup?(level)`
  - Store result in agent state as `:food_sensed_quality`
- [ ] 3.2.1.3.4 Return pickup recommendation in result

---

## 3.2.2 Implement PickUpFoodAction

Create action for ants to pick up food.

### 3.2.2.1 Create PickUpFoodAction Module

Set up the action module structure.

- [ ] 3.2.2.1.1 Create `lib/ant_colony/actions/pick_up_food_action.ex`
- [ ] 3.2.2.1.2 Add `defmodule AntColony.Actions.PickUpFoodAction`
- [ ] 3.2.2.1.3 Add `use Jido.Action`
- [ ] 3.2.2.1.4 Add comprehensive `@moduledoc`

### 3.2.2.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.2.2.2.1 Define `@param_schema` with fields:
  - `:position` - type: `:tuple`, default: `nil` (uses current position)
  - `:force` - type: `:boolean`, default: `false` (ignore threshold)
- [ ] 3.2.2.2.2 Add validation for position format
- [ ] 3.2.2.2.3 Add validation for force flag

### 3.2.2.3 Implement run/2 Function

Execute the food pickup logic.

- [ ] 3.2.2.3.1 Define `def run(params, context)` function
- [ ] 3.2.2.3.2 Extract position from params or `context.state.position`
- [ ] 3.2.2.3.3 Check if ant already has food (`context.state.has_food?`)
  - Return `{:error, :already_carrying}` if true
- [ ] 3.2.2.3.4 Query Plane for food at position
- [ ] 3.2.2.3.5 If no food or quantity is 0:
  - Return `{:error, :no_food}`
- [ ] 3.2.2.3.6 Extract food level from Plane response
- [ ] 3.2.2.3.7 If not `:force` and level <= `@pickup_threshold`:
  - Return `{:ok, context.state, []}` (don't pick up)
- [ ] 3.2.2.3.8 Call `Plane.pick_up_food(position, ant_id)`
- [ ] 3.2.2.3.9 Update agent state:
  - Set `has_food?: true`
  - Set `carried_food_level: level`
  - Set `current_state: :returning_to_nest`
- [ ] 3.2.2.3.10 Publish `{:food_picked_up, ant_id, position, level}` event
- [ ] 3.2.2.3.11 Return `{:ok, updated_state}`

---

## 3.2.3 Implement DropFoodAction

Create action for ants to deposit food at nest.

### 3.2.3.1 Create DropFoodAction Module

Set up the action module structure.

- [ ] 3.2.3.1.1 Create `lib/ant_colony/actions/drop_food_action.ex`
- [ ] 3.2.3.1.2 Add `defmodule AntColony.Actions.DropFoodAction`
- [ ] 3.2.3.1.3 Add `use Jido.Action`
- [ ] 3.2.3.1.4 Add comprehensive `@moduledoc`

### 3.2.3.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.2.3.2.1 Define `@param_schema` with fields:
  - `:position` - type: `:tuple`, default: `nil` (uses current position)
- [ ] 3.2.3.2.2 Add validation for position format

### 3.2.3.3 Implement run/2 Function

Execute the food drop logic.

- [ ] 3.2.3.3.1 Define `def run(params, context)` function
- [ ] 3.2.3.3.2 Extract position from params or `context.state.position`
- [ ] 3.2.3.3.3 Check if ant is at nest (`position == context.state.nest_position`)
  - Return `{:error, :not_at_nest}` if false
- [ ] 3.2.3.3.4 Check if ant has food (`context.state.has_food?`)
  - Return `{:error, :not_carrying}` if false
- [ ] 3.2.3.3.5 Extract `carried_food_level` from state
- [ ] 3.2.3.3.6 Call `Plane.deposit_food(position, carried_food_level, ant_id)`
- [ ] 3.2.3.3.7 Update agent state:
  - Set `has_food?: false`
  - Set `carried_food_level: nil`
  - Set `current_state: :at_nest`
  - Clear `path_memory: []`
- [ ] 3.2.3.3.8 Publish `{:food_dropped_at_nest, ant_id, carried_food_level}` event
- [ ] 3.2.3.3.9 Return `{:ok, updated_state}`

---

## 3.2.4 Implement RetracePathAction

Create action for ants to follow their path back to the nest.

### 3.2.4.1 Create RetracePathAction Module

Set up the action module structure.

- [ ] 3.2.4.1.1 Create `lib/ant_colony/actions/retrace_path_action.ex`
- [ ] 3.2.4.1.2 Add `defmodule AntColony.Actions.RetracePathAction`
- [ ] 3.2.4.1.3 Add `use Jido.Action`
- [ ] 3.2.4.1.4 Add comprehensive `@moduledoc`

### 3.2.4.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.2.4.2.1 Define `@param_schema` with fields:
  - `:step_count` - type: `:integer`, default: `1` (steps to retrace)
- [ ] 3.2.4.2.2 Add validation for step_count (1-5)

### 3.2.4.3 Implement run/2 Function

Execute the path retracing logic.

- [ ] 3.2.4.3.1 Define `def run(params, context)` function
- [ ] 3.2.4.3.2 Extract `step_count` from params
- [ ] 3.2.4.3.3 Check `context.state.path_memory` is not empty
  - Return `{:error, :no_path_memory}` if empty
- [ ] 3.2.4.3.4 Get current position from `context.state.position`
- [ ] 3.2.4.3.5 Find previous position in path_memory:
  - Reverse path_memory to get most recent first
  - Take first `step_count` entries
- [ ] 3.2.4.3.6 For each step:
  - Extract position from path_memory entry
  - Move to that position (via MoveAction or direct update)
  - Remove entry from path_memory
- [ ] 3.2.4.3.7 Check if new position equals nest
  - If so, set `current_state: :at_nest`
- [ ] 3.2.4.3.8 Update agent state with new position and path_memory
- [ ] 3.2.4.3.9 Return `{:ok, updated_state}`

### 3.2.4.4 Add Path Memory Validation

Ensure path_memory integrity.

- [ ] 3.2.4.4.1 Add validation that path positions are contiguous
- [ ] 3.2.4.4.2 Handle missing entries gracefully
- [ ] 3.2.4.4.3 Add fallback to direct navigation if path is broken

---

## 3.2.5 Extend Plane with Colony Food Tracking

Add total food collected tracking.

### 3.2.5.1 Add Colony Food Field to Plane

Track total food collected by the colony.

- [ ] 3.2.5.1.1 Open `lib/ant_colony/plane.ex`
- [ ] 3.2.5.1.2 Add `:total_food_collected` field to Plane struct
- [ ] 3.2.5.1.3 Set default to `0`
- [ ] 3.2.5.1.4 Document field in @moduledoc

### 3.2.5.2 Implement deposit_food API

Create API for depositing food at nest.

- [ ] 3.2.5.2.1 Define client function: `def deposit_food(position, level, ant_id)`
- [ ] 3.2.5.2.2 Implement as `GenServer.call(__MODULE__, {:deposit_food, position, level, ant_id})`
- [ ] 3.2.5.2.3 Add handle_call clause for `:deposit_food`
- [ ] 3.2.5.2.4 Verify position equals `state.nest_location`
- [ ] 3.2.5.2.5 Increment `total_food_collected` by level
- [ ] 3.2.5.2.6 Publish `{:food_collected, ant_id, level, new_total}` event
- [ ] 3.2.5.2.7 Return `{:reply, :ok, updated_state}`

### 3.2.5.3 Implement get_colony_stats API

Create API for querying colony statistics.

- [ ] 3.2.5.3.1 Define client function: `def get_colony_stats()`
- [ ] 3.2.5.3.2 Implement as `GenServer.call(__MODULE__, :get_colony_stats)`
- [ ] 3.2.5.3.3 Add handle_call clause for `:get_colony_stats`
- [ ] 3.2.5.3.4 Build stats map:
  ```elixir
  %{
    total_food_collected: state.total_food_collected,
    active_food_sources: count_active_sources(state.food_sources),
    total_ants: get_ant_count(),
    ants_with_food: count_ants_with_food()
  }
  ```
- [ ] 3.2.5.3.5 Return `{:reply, stats, state}`

---

## 3.2.6 Implement Ant State Machine

Manage ant behavioral states.

### 3.2.6.1 Define State Transitions

Document state machine rules.

- [ ] 3.2.6.1.1 Create `lib/ant_colony/agent/state_machine.ex`
- [ ] 3.2.6.1.2 Define state constants: `@at_nest`, `@searching`, `@returning_to_nest`, `@communicating`
- [ ] 3.2.6.1.3 Document valid transitions:
  - `:at_nest` → `:searching` (when ready to forage)
  - `:searching` → `:returning_to_nest` (when food picked up)
  - `:searching` → `:communicating` (when ant encountered)
  - `:returning_to_nest` → `:communicating` (optional, may skip)
  - `:returning_to_nest` → `:at_nest` (when nest reached)
  - `:communicating` → previous state (after communication)
- [ ] 3.2.6.1.4 Add transition validation function

### 3.2.6.2 Add State Transition Helper

Create helper for state changes.

- [ ] 3.2.6.2.1 Define `def transition_state(state, new_state)`
- [ ] 3.2.6.2.2 Validate transition is allowed
- [ ] 3.2.6.2.3 Publish `{:ant_state_changed, ant_id, old_state, new_state}` event
- [ ] 3.2.6.2.4 Return `{:ok, new_state}` or `{:error, :invalid_transition}`

### 3.2.6.3 Integrate State Machine with Actions

Update actions to use state machine.

- [ ] 3.2.6.3.1 Update `PickUpFoodAction` to transition to `:returning_to_nest`
- [ ] 3.2.6.3.2 Update `DropFoodAction` to transition to `:at_nest`
- [ ] 3.2.6.3.3 Update `MoveAction` to check state and behave appropriately
- [ ] 3.2.6.3.4 Add state-based action restrictions

---

## 3.2.7 UI Food Level and State Display

Update UI to show food levels and ant states.

### 3.2.7.1 Extend UI State for Colony Stats

Add colony statistics to UI.

- [ ] 3.2.7.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.2.7.1.2 Add `:total_food_collected` to UI struct (default: 0)
- [ ] 3.2.7.1.3 Add `:ants_with_food_count` to UI struct (default: 0)
- [ ] 3.2.7.1.4 Update init/1 to fetch initial stats from Plane

### 3.2.7.2 Handle Food Collection Events

Process food deposition events.

- [ ] 3.2.7.2.1 Add update clause for `{:food_collected, ant_id, level, new_total}`
- [ ] 3.2.7.2.2 Update `state.total_food_collected`
- [ ] 3.2.7.2.3 Update `state.ants_with_food_count` (decrement)
- [ ] 3.2.7.2.4 Return `{:noreply, updated_state}`

### 3.2.7.3 Handle Ant State Change Events

Process ant state transitions.

- [ ] 3.2.7.3.1 Add update clause for `{:ant_state_changed, ant_id, old_state, new_state}`
- [ ] 3.2.7.3.2 Update ant_positions with state information:
  - Change position tuple to `{x, y, carrying_food?}`
  - Set `carrying_food?` based on new_state
- [ ] 3.2.7.3.3 Update `state.ants_with_food_count` accordingly
- [ ] 3.2.7.3.4 Return `{:noreply, updated_state}`

### 3.2.7.4 Render Food Levels

Display food sources with level indicators.

- [ ] 3.2.7.4.1 In view/1, when drawing food sources:
  - Build character string: "F" + level (e.g., "F3")
  - If level is 1, just use "F" (no number)
- [ ] 3.2.7.4.2 Apply color coding:
  - Level 1: dark gray (low quality)
  - Level 2: yellow
  - Level 3: bright yellow
  - Level 4: orange
  - Level 5: red (high quality)
- [ ] 3.2.7.4.3 Handle depleted sources (quantity 0)
  - Draw faint "x" or empty space

### 3.2.7.5 Render Ant States

Display ants with different characters based on state.

- [ ] 3.2.7.5.1 In view/1, when drawing ants:
  - Check ant state from ant_positions
  - If carrying food (or state is `:returning_to_nest`): Draw "A"
  - If searching (or state is `:searching`): Draw "a"
- [ ] 3.2.7.5.2 Apply colors:
  - Searching "a": red
  - Returning "A": red + bold
- [ ] 3.2.7.5.3 Ensure ants draw over food when at same position

### 3.2.7.6 Update Status Bar

Add colony statistics to status display.

- [ ] 3.2.7.6.1 Modify status_bar function to show:
  - Total ants count
  - Ants with food count
  - Total food collected
- [ ] 3.2.7.6.2 Format: `"Ants: N | Carrying: M | Collected: T"`
- [ ] 3.2.7.6.3 Color-code the values for readability

---

## 3.2.8 Unit Tests for Foraging Logic

Test all foraging-related functionality.

### 3.2.8.1 Test Food Evaluation

Verify food quality assessment works.

- [ ] 3.2.8.1.1 Create `test/ant_colony/food_test.exs`
- [ ] 3.2.8.1.2 Add test: `test "should_pickup? returns correct boolean"` - threshold
- [ ] 3.2.8.1.3 Add test: `test "quality_category returns correct category"` - categorization
- [ ] 3.2.8.1.4 Add test: `test "pickup_probability returns correct curve"` - probability

### 3.2.8.2 Test PickUpFoodAction

Verify food pickup works correctly.

- [ ] 3.2.8.2.1 Create `test/ant_colony/actions/pick_up_food_action_test.exs`
- [ ] 3.2.8.2.2 Add test: `test "run picks up food when level > threshold"` - basic
- [ ] 3.2.8.2.3 Add test: `test "run ignores food when level <= threshold"` - threshold
- [ ] 3.2.8.2.4 Add test: `test "run picks up low quality food when forced"` - force
- [ ] 3.2.8.2.5 Add test: `test "run returns error when already carrying"` - duplicate
- [ ] 3.2.8.2.6 Add test: `test "run returns error when no food at position"` - empty
- [ ] 3.2.8.2.7 Add test: `run transitions state to returning_to_nest"` - state
- [ ] 3.2.8.2.8 Add test: `test "run publishes food_picked_up event"` - event

### 3.2.8.3 Test DropFoodAction

Verify food drop works correctly.

- [ ] 3.2.8.3.1 Create `test/ant_colony/actions/drop_food_action_test.exs`
- [ ] 3.2.8.3.2 Add test: `test "run drops food at nest"` - basic
- [ ] 3.2.8.3.3 Add test: `test "run returns error when not at nest"` - position check
- [ ] 3.2.8.3.4 Add test: `test "run returns error when not carrying"` - carrying check
- [ ] 3.2.8.3.5 Add test: `test "run resets has_food? flag"` - flag reset
- [ ] 3.2.8.3.6 Add test: `test "run transitions state to at_nest"` - state
- [ ] 3.2.8.3.7 Add test: `test "run clears path_memory"` - memory clear
- [ ] 3.2.8.3.8 Add test: `test "run publishes food_dropped_at_nest event"` - event

### 3.2.8.4 Test RetracePathAction

Verify path retracing works correctly.

- [ ] 3.2.8.4.1 Create `test/ant_colony/actions/retrace_path_action_test.exs`
- [ ] 3.2.8.4.2 Add test: `test "run moves back one step in path"` - single step
- [ ] 3.2.8.4.3 Add test: `test "run moves multiple steps when specified"` - multi-step
- [ ] 3.2.8.4.4 Add test: `test "run returns error when path_memory is empty"` - empty
- [ ] 3.2.8.4.5 Add test: `test "run removes visited positions from path"` - cleanup
- [ ] 3.2.8.4.6 Add test: `test "run detects when nest is reached"` - detection
- [ ] 3.2.8.4.7 Add test: `test "run handles broken path gracefully"` - fallback

### 3.2.8.5 Test State Machine

Verify state transitions work correctly.

- [ ] 3.2.8.5.1 Create `test/ant_colony/agent/state_machine_test.exs`
- [ ] 3.2.8.5.2 Add test: `test "valid transitions are allowed"` - valid
- [ ] 3.2.8.5.3 Add test: `test "invalid transitions are rejected"` - invalid
- [ ] 3.2.8.5.4 Add test: `test "all states have defined transitions"` - completeness
- [ ] 3.2.8.5.5 Add test: `test "transition_state publishes event"` - event

### 3.2.8.6 Test Colony Food Tracking

Verify Plane tracks colony food correctly.

- [ ] 3.2.8.6.1 Add test to plane tests: `test "deposit_food increments total_food_collected"` - increment
- [ ] 3.2.8.6.2 Add test: `test "deposit_food adds correct amount"` - amount
- [ ] 3.2.8.6.3 Add test: `test "get_colony_stats returns correct values"` - stats
- [ ] 3.2.8.6.4 Add test: `test "multiple deposits accumulate correctly"` - accumulation

### 3.2.8.7 Test UI Food Display

Verify UI displays food levels correctly.

- [ ] 3.2.8.7.1 Add test: `test "UI displays food levels correctly"` - levels
- [ ] 3.2.8.7.2 Add test: `test "UI applies correct colors for levels"` - colors
- [ ] 3.2.8.7.3 Add test: `test "UI shows ant states (a vs A)"` - states
- [ ] 3.2.8.7.4 Add test: `test "UI updates total food collected"` - total
- [ ] 3.2.8.7.5 Add test: `test "UI status bar shows correct stats"` - status

---

## 3.2.9 Phase 3.2 Integration Tests

End-to-end tests for foraging logic.

### 3.2.9.1 Complete Foraging Cycle Test

Verify full foraging workflow.

- [ ] 3.2.9.1.1 Create `test/ant_colony/integration/foraging_integration_test.exs`
- [ ] 3.2.9.1.2 Add test: `test "ant completes full foraging cycle"` - end-to-end
- [ ] 3.2.9.1.3 Add test: `test "ant ignores low quality food"` - threshold
- [ ] 3.2.9.1.4 Add test: `test "ant picks up high quality food"` - quality
- [ ] 3.2.9.1.5 Add test: `test "ant returns to nest via path_memory"` - retrace

### 3.2.9.2 Food Quality Decision Test

Verify food quality influences behavior.

- [ ] 3.2.9.2.1 Add test: `test "multiple ants prefer high quality food"` - preference
- [ ] 3.2.9.2.2 Add test: `test "ants eventually collect low quality food"` - fallback
- [ ] 3.2.9.2.3 Add test: `test "colony optimizes for high quality sources"` - optimization

### 3.2.9.3 State Machine Integration Test

Verify state machine works in simulation.

- [ ] 3.2.9.3.1 Add test: `test "ant transitions through all states"` - transitions
- [ ] 3.2.9.3.2 Add test: `test "state changes are visible in UI"` - UI
- [ ] 3.2.9.3.3 Add test: `test "invalid transitions are prevented"` - safety

### 3.2.9.4 Colony Statistics Test

Verify colony-wide metrics are accurate.

- [ ] 3.2.9.4.1 Add test: `test "total_food_collected matches deposits"` - accuracy
- [ ] 3.2.9.4.2 Add test: `test "ants_with_food_count is accurate"` - count
- [ ] 3.2.9.4.3 Add test: `test "stats update in real-time"` - updates
- [ ] 3.2.9.4.4 Add test: `test "UI displays correct colony stats"` - display

---

## Phase 3.2 Success Criteria

1. **Food Evaluation**: Quality assessment implemented ✅
2. **PickUpFoodAction**: Ants pick up food based on quality ✅
3. **DropFoodAction**: Food deposited at nest ✅
4. **RetracePathAction**: Path retracing via path_memory ✅
5. **State Machine**: Behavioral states work correctly ✅
6. **Colony Tracking**: Total food collected tracked ✅
7. **UI Display**: Food levels and ant states visible ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 3.2 Critical Files

**New Files:**
- `lib/ant_colony/food.ex` - Food evaluation helpers
- `lib/ant_colony/agent/state_machine.ex` - State machine definition
- `lib/ant_colony/actions/pick_up_food_action.ex` - Food pickup action
- `lib/ant_colony/actions/drop_food_action.ex` - Food drop action
- `lib/ant_colony/actions/retrace_path_action.ex` - Path retracing action
- `test/ant_colony/food_test.exs` - Food unit tests
- `test/ant_colony/agent/state_machine_test.exs` - State machine tests
- `test/ant_colony/actions/pick_up_food_action_test.exs` - Action tests
- `test/ant_colony/actions/drop_food_action_test.exs` - Action tests
- `test/ant_colony/actions/retrace_path_action_test.exs` - Action tests
- `test/ant_colony/integration/foraging_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/plane.ex` - Add total_food_collected, deposit_food API
- `lib/ant_colony/actions/sense_food_action.ex` - Add quality evaluation
- `lib/ant_colony/ui.ex` - Add colony stats, food levels, ant states

---

## Next Phase

Proceed to [Phase 3.3: Ant-to-Ant Communication](./03-ant-communication.md) to implement direct information exchange between ants.
