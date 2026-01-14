# Phase 3.1: Pheromone Logic

Implement the pheromone-based communication system that enables indirect, stigmergic communication between ants. This system allows ants to lay pheromone trails that influence the movement decisions of other ants, implementing the core Ant Colony Optimization (ACO) algorithm.

## Architecture

```
Pheromone System
├── Plane State:
│   └── pheromones: %{{x, y} => %{type: atom(), level: float(), last_updated: DateTime}}
│
├── Pheromone Types:
│   ├── :food_trail - Laid by returning ants carrying food
│   │   └── Intensity ∝ carried_food_level (1-5)
│   └── :exploration - Marks explored areas (optional)
│
├── Actions:
│   ├── AntColony.Actions.LayPheromoneAction
│   │   └── Deposits pheromone at ant's current position
│   └── AntColony.Actions.SensePheromoneAction
│       └── Queries pheromone levels in neighboring positions
│
├── Plane APIs:
│   ├── lay_pheromone(position, type, intensity)
│   ├── get_pheromone_levels(positions)
│   └── evaporate_pheromones()
│
└── Evaporation:
    └── new_level = old_level * (1 - evaporation_rate)
    └── evaporation_rate: 0.01 (1% per tick)
    └── min_threshold: 0.1 (removed if below)
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Plane pheromone state | Store pheromone data for each position |
| LayPheromoneAction | Deposit pheromone at current position |
| SensePheromoneAction | Query pheromone levels for movement decisions |
| Evaporation logic | Periodically reduce pheromone levels |
| UI visualization | Display pheromone intensity on canvas |

---

## 3.1.1 Define Pheromone Data Structures

Establish the data structures for representing pheromones in the system.

### 3.1.1.1 Define Pheromone Types

Create the pheromone type specification and atom definitions.

- [ ] 3.1.1.1.1 Create `lib/ant_colony/pheromone.ex` module
- [ ] 3.1.1.1.2 Define `@type pheromone_type :: :food_trail | :exploration`
- [ ] 3.1.1.1.3 Define `@type pheromone_level :: float()` (0.0 to 100.0)
- [ ] 3.1.1.1.4 Define `@type pheromone_record :: %__MODULE__{type: pheromone_type(), level: pheromone_level(), last_updated: DateTime.t()}`
- [ ] 3.1.1.1.5 Document each pheromone type and its purpose in @moduledoc

### 3.1.1.2 Define Pheromone Constants

Establish constants for pheromone system behavior.

- [ ] 3.1.1.2.1 Define `@evaporation_rate 0.01` (1% per evaporation cycle)
- [ ] 3.1.1.2.2 Define `@min_threshold 0.1` (minimum level before removal)
- [ ] 3.1.1.2.3 Define `@max_level 100.0` (maximum pheromone intensity)
- [ ] 3.1.1.2.4 Define `@base_deposit_intensity 10.0` (base amount deposited)
- [ ] 3.1.1.2.5 Define `@food_multiplier 5.0` (multiplier for food quality)

### 3.1.1.3 Create Pheromone Struct

Define the struct for individual pheromone records.

- [ ] 3.1.1.3.1 Add `defstruct` with fields:
  - `:type` - default `:food_trail`
  - `:level` - default `0.0`
  - `:last_updated` - default `DateTime.utc_now()`
- [ ] 3.1.1.3.2 Add `@enforce_keys` for `:type` and `:level`
- [ ] 3.1.1.3.3 Add `@type` specification for struct
- [ ] 3.1.1.3.4 Document struct fields

---

## 3.1.2 Extend Plane with Pheromone Storage

Add pheromone storage and management to the Plane GenServer.

### 3.1.2.1 Add Pheromone Field to Plane State

Extend Plane state to include pheromone data.

- [ ] 3.1.2.1.1 Open `lib/ant_colony/plane.ex`
- [ ] 3.1.2.1.2 Add `:pheromones` field to Plane struct
- [ ] 3.1.2.1.3 Set default to empty map: `%{{x, y} => %{type => level}}`
- [ ] 3.1.2.1.4 Document field in @moduledoc
- [ ] 3.1.2.1.5 Update init/1 to initialize empty pheromones map

### 3.1.2.2 Implement lay_pheromone API

Create API for depositing pheromones at a position.

- [ ] 3.1.2.2.1 Define client function: `def lay_pheromone(position, type, intensity)`
- [ ] 3.1.2.2.2 Implement as `GenServer.call(__MODULE__, {:lay_pheromone, position, type, intensity})`
- [ ] 3.1.2.2.3 Add handle_call clause for `:lay_pheromone`
- [ ] 3.1.2.2.4 Update pheromones map:
  ```elixir
  current_level = Map.get(state.pheromones, {x, y}, %{})
  updated = Map.put(current_level, type, min(current_level + intensity, @max_level))
  new_pheromones = Map.put(state.pheromones, {x, y}, updated)
  ```
- [ ] 3.1.2.2.5 Publish `{:pheromone_updated, position, type, new_level}` event to PubSub
- [ ] 3.1.2.2.6 Return `{:reply, :ok, %{state | pheromones: new_pheromones}}`

### 3.1.2.3 Implement get_pheromone_levels API

Create API for querying pheromone levels.

- [ ] 3.1.2.3.1 Define client function: `def get_pheromone_levels(positions)`
- [ ] 3.1.2.3.2 Implement as `GenServer.call(__MODULE__, {:get_pheromone_levels, positions})`
- [ ] 3.1.2.3.3 Add handle_call clause for `:get_pheromone_levels`
- [ ] 3.1.2.3.4 Build response map with pheromone data for each position
- [ ] 3.1.2.3.5 Return map of `%{position => %{type => level}}`
- [ ] 3.1.2.3.6 Return empty map for positions with no pheromones

### 3.1.2.4 Implement Pheromone Evaporation

Add periodic pheromone evaporation logic.

- [ ] 3.1.2.4.1 Define client function: `def evaporate_pheromones()`
- [ ] 3.1.2.4.2 Implement as `GenServer.call(__MODULE__, :evaporate_pheromones)`
- [ ] 3.1.2.4.3 Add handle_call clause for `:evaporate_pheromones`
- [ ] 3.1.2.4.4 Iterate over all pheromone entries:
  ```elixir
  new_level = level * (1 - @evaporation_rate)
  ```
- [ ] 3.1.2.4.5 Remove entries below `@min_threshold`
- [ ] 3.1.2.4.6 Update state with new pheromones map
- [ ] 3.1.2.4.7 Schedule next evaporation via `Process.send_after`

### 3.1.2.5 Set Up Evaporation Timer

Configure periodic evaporation in Plane init.

- [ ] 3.1.2.5.1 Add `:evaporation_interval_ms` to state (default 1000ms)
- [ ] 3.1.2.5.2 In init/1, schedule first evaporation:
  ```elixir
  Process.send_after(self(), :evaporate_pheromones, @evaporation_interval_ms)
  ```
- [ ] 3.1.2.5.3 Add handle_info for `:evaporate_pheromones`
- [ ] 3.1.2.5.4 Perform evaporation and reschedule next

---

## 3.1.3 Implement LayPheromoneAction

Create the Jido Action for ants to deposit pheromones.

### 3.1.3.1 Create LayPheromoneAction Module

Set up the action module structure.

- [ ] 3.1.3.1.1 Create `lib/ant_colony/actions/lay_pheromone_action.ex`
- [ ] 3.1.3.1.2 Add `defmodule AntColony.Actions.LayPheromoneAction`
- [ ] 3.1.3.1.3 Add `use Jido.Action`
- [ ] 3.1.3.1.4 Add comprehensive `@moduledoc`

### 3.1.3.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.1.3.2.1 Define `@param_schema` with fields:
  - `:type` - type: `:atom`, default: `:food_trail`, allowed: `[:food_trail, :exploration]`
  - `:intensity` - type: `:float`, default: `nil` (auto-calculated)
  - `:position` - type: `:tuple`, default: `nil` (uses current position)
- [ ] 3.1.3.2.2 Add validation for type field
- [ ] 3.1.3.2.3 Add validation for intensity range (0-100)

### 3.1.3.3 Implement run/2 Function

Execute the pheromone laying logic.

- [ ] 3.1.3.3.1 Define `def run(params, context)` function
- [ ] 3.1.3.3.2 Extract position from params or `context.state.position`
- [ ] 3.1.3.3.3 Extract type from params (default `:food_trail`)
- [ ] 3.1.3.3.4 Calculate intensity:
  - If params has intensity, use it
  - Else if `:food_trail` and ant has food: `carried_food_level * @food_multiplier + @base_deposit_intensity`
  - Else: `@base_deposit_intensity`
- [ ] 3.1.3.3.5 Call `Plane.lay_pheromone(position, type, intensity)`
- [ ] 3.1.3.3.6 Return `{:ok, context.state}` (no state change needed for ant)

---

## 3.1.4 Implement SensePheromoneAction

Create the Jido Action for ants to sense pheromones.

### 3.1.4.1 Create SensePheromoneAction Module

Set up the action module structure.

- [ ] 3.1.4.1.1 Create `lib/ant_colony/actions/sense_pheromone_action.ex`
- [ ] 3.1.4.1.2 Add `defmodule AntColony.Actions.SensePheromoneAction`
- [ ] 3.1.4.1.3 Add `use Jido.Action`
- [ ] 3.1.4.1.4 Add comprehensive `@moduledoc`

### 3.1.4.2 Define Action Schema

Specify the action's parameters.

- [ ] 3.1.4.2.1 Define `@param_schema` with fields:
  - `:positions` - type: `{:list, :tuple}`, default: `nil` (auto-neighbors)
  - `:types` - type: `{:list, :atom}`, default: `nil` (all types)
  - `:radius` - type: `:integer`, default: `1` (neighbor distance)
- [ ] 3.1.4.2.2 Add validation for positions list
- [ ] 3.1.4.2.3 Add validation for radius (1-3)

### 3.1.4.3 Implement run/2 Function

Execute the pheromone sensing logic.

- [ ] 3.1.4.3.1 Define `def run(params, context)` function
- [ ] 3.1.4.3.2 Extract position from `context.state.position`
- [ ] 3.1.4.3.3 Generate neighbor positions if not provided:
  ```elixir
  neighbors = for dx <- -radius..radius, dy <- -radius..radius,
    {dx, dy} != {0, 0},
    do: {x + dx, y + dy}
  ```
- [ ] 3.1.4.3.4 Filter out-of-bounds positions
- [ ] 3.1.4.3.5 Call `Plane.get_pheromone_levels(positions)`
- [ ] 3.1.4.3.6 Filter by types if specified
- [ ] 3.1.4.3.7 Store result in agent state as `:last_sensed_pheromones`
- [ ] 3.1.4.3.8 Return `{:ok, updated_state}`

### 3.1.4.4 Add Helper for Direction Selection

Create helper for ACO-based direction probability.

- [ ] 3.1.4.4.1 Define `def calculate_direction_probabilities(pheromone_data, options)`
- [ ] 3.1.4.4.2 Extract α (pheromone importance) from options (default 1.0)
- [ ] 3.1.4.4.3 Extract β (heuristic importance) from options (default 1.0)
- [ ] 3.1.4.4.4 Calculate for each direction: `P = τ^α * η^β`
- [ ] 3.1.4.4.5 Normalize probabilities to sum to 1.0
- [ ] 3.1.4.4.6 Return map of `%{direction => probability}`

---

## 3.1.5 Update MoveAction for Pheromone Influence

Enhance MoveAction to consider pheromone levels.

### 3.1.5.1 Integrate Pheromone Sensing

Add pheromone sensing to movement decisions.

- [ ] 3.1.5.1.1 Open `lib/ant_colony/actions/move_action.ex`
- [ ] 3.1.5.1.2 Add `:use_pheromones` option to param schema (default: `true`)
- [ ] 3.1.5.1.3 In run/2, if `:searching` state and `:use_pheromones`:
  - Call `SensePheromoneAction.run(%{radius: 1}, context)`
  - Use pheromone data to bias direction selection
- [ ] 3.1.5.1.4 Implement weighted random selection based on pheromone probabilities
- [ ] 3.1.5.1.5 Fallback to random selection if no pheromones detected

### 3.1.5.2 Integrate Pheromone Laying

Add pheromone laying during movement.

- [ ] 3.1.5.2.1 In run/2, after moving to new position:
- [ ] 3.1.5.2.2 If `:returning_to_nest` and `:has_food?`:
  - Call `LayPheromoneAction.run(%{type: :food_trail}, context)`
- [ ] 3.1.5.2.3 If `:searching` and exploration marking enabled:
  - Call `LayPheromoneAction.run(%{type: :exploration, intensity: 1.0}, context)`

---

## 3.1.6 UI Pheromone Visualization

Add pheromone display to the terminal UI.

### 3.1.6.1 Extend UI State for Pheromones

Add pheromone data to UI internal state.

- [ ] 3.1.6.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.1.6.1.2 Add `:pheromones` field to UI struct
- [ ] 3.1.6.1.3 Set default to empty map
- [ ] 3.1.6.1.4 Update init/1 to fetch initial pheromones from Plane
- [ ] 3.1.6.1.5 Add Plane API: `get_pheromones_for_ui/0`

### 3.1.6.2 Handle Pheromone Events

Process pheromone update events in UI.

- [ ] 3.1.6.2.1 Add update clause for `{:pheromone_updated, position, type, level}`
- [ ] 3.1.6.2.2 Update `state.pheromones` map with new level
- [ ] 3.1.6.2.3 Remove position if level is 0
- [ ] 3.1.6.2.4 Return `{:noreply, updated_state}`

### 3.1.6.3 Add Pheromone Toggle Control

Add keyboard toggle for pheromone display.

- [ ] 3.1.6.3.1 Add `:show_pheromones` boolean to UI state (default: `false`)
- [ ] 3.1.6.3.2 Add update clause for `%Event.Key{key: "p"}`:
  - Toggle `:show_pheromones`
  - Return `{:noreply, %{state | show_pheromones: not state.show_pheromones}}`
- [ ] 3.1.6.3.3 Display current toggle state in status bar

### 3.1.6.4 Render Pheromones on Canvas

Draw pheromone visualization.

- [ ] 3.1.6.4.1 In view/1, before drawing other elements:
  - Check if `state.show_pheromones` is true
- [ ] 3.1.6.4.2 Iterate over `state.pheromones` map
- [ ] 3.1.6.4.3 For each position with pheromone:
  - Calculate intensity-based character:
    - Level < 10: faint "·"
    - Level 10-30: "░"
    - Level 30-60: "▒"
    - Level 60-90: "▓"
    - Level > 90: "█"
  - Use color: `:food_trail` → green/cyan, `:exploration` → gray
  - Draw background character at position
- [ ] 3.1.6.4.4 Ensure other elements draw over pheromones (z-order)

### 3.1.6.5 Add Pheromone Legend

Display pheromone visualization guide.

- [ ] 3.1.6.5.1 Add legend to UI when `:show_pheromones` is true
- [ ] 3.1.6.5.2 Display: "Pheromones: [Low· ░▒▓█High]"
- [ ] 3.1.6.5.3 Display: "Press 'p' to toggle"
- [ ] 3.1.6.5.4 Position legend in corner of canvas

---

## 3.1.7 Unit Tests for Pheromone System

Test all pheromone-related functionality.

### 3.1.7.1 Test Pheromone Data Structures

Verify pheromone types and structs work correctly.

- [ ] 3.1.7.1.1 Create `test/ant_colony/pheromone_test.exs`
- [ ] 3.1.7.1.2 Add test: `test "pheromone struct has correct fields"` - structure
- [ ] 3.1.7.1.3 Add test: `test "pheromone types are valid"` - type checking
- [ ] 3.1.7.1.4 Add test: `test "pheromone constants are defined"` - constants
- [ ] 3.1.7.1.5 Add test: `test "pheromone level is within bounds"` - validation

### 3.1.7.2 Test Plane Pheromone APIs

Verify Plane pheromone storage and retrieval.

- [ ] 3.1.7.2.1 Create `test/ant_colony/plane_pheromone_test.exs`
- [ ] 3.1.7.2.2 Add test: `test "lay_pheromone adds pheromone to Plane"` - deposit
- [ ] 3.1.7.2.3 Add test: `test "lay_pheromone accumulates at same position"` - accumulation
- [ ] 3.1.7.2.4 Add test: `test "get_pheromone_levels returns correct data"` - query
- [ ] 3.1.7.2.5 Add test: `test "get_pheromone_levels handles empty positions"` - empty case
- [ ] 3.1.7.2.6 Add test: `test "pheromone capped at max_level"` - max cap
- [ ] 3.1.7.2.7 Add test: `test "evaporate_pheromones reduces levels"` - evaporation
- [ ] 3.1.7.2.8 Add test: `test "evaporation removes low levels"` - threshold

### 3.1.7.3 Test LayPheromoneAction

Verify the pheromone laying action works.

- [ ] 3.1.7.3.1 Create `test/ant_colony/actions/lay_pheromone_action_test.exs`
- [ ] 3.1.7.3.2 Add test: `test "run deposits pheromone at current position"` - basic
- [ ] 3.1.7.3.3 Add test: `test "run uses provided position"` - explicit position
- [ ] 3.1.7.3.4 Add test: `test "run calculates intensity from food level"` - auto intensity
- [ ] 3.1.7.3.5 Add test: `test "run uses provided intensity"` - explicit intensity
- [ ] 3.1.7.3.6 Add test: `test "run validates type parameter"` - validation
- [ ] 3.1.7.3.7 Add test: `test "run publishes pheromone_updated event"` - event

### 3.1.7.4 Test SensePheromoneAction

Verify the pheromone sensing action works.

- [ ] 3.1.7.4.1 Create `test/ant_colony/actions/sense_pheromone_action_test.exs`
- [ ] 3.1.7.4.2 Add test: `test "run returns pheromone data for neighbors"` - basic
- [ ] 3.1.7.4.3 Add test: `run filters by specified types"` - type filter
- [ ] 3.1.7.4.4 Add test: `test "run generates neighbor positions automatically"` - auto neighbors
- [ ] 3.1.7.4.5 Add test: `test "run handles out-of-bounds positions"` - bounds
- [ ] 3.1.7.4.6 Add test: `test "run stores result in agent state"` - state update
- [ ] 3.1.7.4.7 Add test: `test "calculate_direction_probabilities works"` - probabilities

### 3.1.7.5 Test Pheromone Evaporation

Verify evaporation logic works correctly.

- [ ] 3.1.7.5.1 Add test: `test "evaporation reduces level by correct rate"` - rate
- [ ] 3.1.7.5.2 Add test: `test "evaporation scheduled periodically"` - scheduling
- [ ] 3.1.7.5.3 Add test: `test "multiple evaporations converge to zero"` - convergence
- [ ] 3.1.7.5.4 Add test: `test "evaporation doesn't affect other pheromones"` - isolation

### 3.1.7.6 Test UI Pheromone Visualization

Verify UI displays pheromones correctly.

- [ ] 3.1.7.6.1 Add test: `test "UI receives pheromone_updated events"` - event handling
- [ ] 3.1.7.6.2 Add test: `test "UI toggles show_pheromones on 'p' key"` - toggle
- [ ] 3.1.7.6.3 Add test: `test "UI renders pheromones when enabled"` - rendering
- [ ] 3.1.7.6.4 Add test: `test "UI doesn't render pheromones when disabled"` - disabled
- [ ] 3.1.7.6.5 Add test: `test "pheromone intensity maps to correct character"` - intensity mapping

---

## 3.1.8 Phase 3.1 Integration Tests

End-to-end tests for the pheromone system.

### 3.1.8.1 Pheromone Trail Formation Test

Verify ants form pheromone trails to food.

- [ ] 3.1.8.1.1 Create `test/ant_colony/integration/pheromone_integration_test.exs`
- [ ] 3.1.8.1.2 Add test: `test "returning ant deposits pheromone trail"` - trail formation
- [ ] 3.1.8.1.3 Add test: `test "searching ant detects pheromone trail"` - detection
- [ ] 3.1.8.1.4 Add test: `test "pheromone trail influences ant movement"` - influence
- [ ] 3.1.8.1.5 Add test: `test "higher food level creates stronger trail"` - intensity

### 3.1.8.2 Evaporation Test

Verify evaporation creates dynamic trail behavior.

- [ ] 3.1.8.2.1 Add test: `test "unused trails evaporate over time"` - decay
- [ ] 3.1.8.2.2 Add test: `test "reused trails persist"` - persistence
- [ ] 3.1.8.2.3 Add test: `test "evaporation rate is configurable"` - configuration
- [ ] 3.1.8.2.4 Add test: `test "Plane schedules periodic evaporation"` - scheduling

### 3.1.8.3 ACO Behavior Test

Verify ACO algorithm emerges from pheromone system.

- [ ] 3.1.8.3.1 Add test: `test "ants converge on shortest path to food"` - convergence
- [ ] 3.1.8.3.2 Add test: `test "ants explore when no pheromones present"` - exploration
- [ ] 3.1.8.3.3 Add test: `test "ants exploit known pheromone trails"` - exploitation
- [ ] 3.1.8.3.4 Add test: `test "colony adapts when food source depletes"` - adaptation

### 3.1.8.4 UI Pheromone Visualization Test

Verify UI correctly displays pheromone system.

- [ ] 3.1.8.4.1 Add test: `test "UI visualizes pheromone trails"` - trail display
- [ ] 3.1.8.4.2 Add test: `test "UI updates display on evaporation"` - dynamic
- [ ] 3.1.8.4.3 Add test: `test "pheromone toggle works during simulation"` - toggle
- [ ] 3.1.8.4.4 Add test: `test "legend displays correct information"` - legend

---

## Phase 3.1 Success Criteria

1. **Pheromone Types**: :food_trail and :exploration defined ✅
2. **Plane Storage**: Pheromones stored per position ✅
3. **LayPheromoneAction**: Deposits pheromones correctly ✅
4. **SensePheromoneAction**: Queries pheromone levels ✅
5. **Evaporation**: Periodic reduction implemented ✅
6. **MoveAction Integration**: Movement influenced by pheromones ✅
7. **UI Visualization**: Pheromones toggleable and visible ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 3.1 Critical Files

**New Files:**
- `lib/ant_colony/pheromone.ex` - Pheromone types and constants
- `lib/ant_colony/actions/lay_pheromone_action.ex` - Pheromone laying action
- `lib/ant_colony/actions/sense_pheromone_action.ex` - Pheromone sensing action
- `test/ant_colony/pheromone_test.exs` - Pheromone unit tests
- `test/ant_colony/plane_pheromone_test.exs` - Plane pheromone tests
- `test/ant_colony/actions/lay_pheromone_action_test.exs` - Action tests
- `test/ant_colony/actions/sense_pheromone_action_test.exs` - Action tests
- `test/ant_colony/integration/pheromone_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/plane.ex` - Add pheromones field and APIs
- `lib/ant_colony/actions/move_action.ex` - Integrate pheromone influence
- `lib/ant_colony/ui.ex` - Add pheromone visualization

---

## Next Phase

Proceed to [Phase 3.2: Food Levels and Foraging Logic](./02-food-levels-foraging.md) to implement food level-based foraging behavior.
