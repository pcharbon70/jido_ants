# Phase 4.3: Property-Based Tests

Implement property-based tests using StreamData to generate random inputs and verify system invariants hold true. Property-based testing finds edge cases that example-based tests might miss.

## Architecture

```
Property-Based Testing with StreamData
├── Generators
│   ├── position_generator() -> {x, y}
│   ├── ant_state_generator() -> AntAgent.t()
│   ├── food_source_generator() -> FoodSource.t()
│   ├── pheromone_generator() -> Pheromone.t()
│   ├── path_generator() -> [{x, y}]
│   └── generation_state_generator() -> GenerationState.t() (NEW)
│
├── Invariants
│   ├── Ant State Invariants
│   │   ├── Position within bounds
│   │   ├── Path memory includes current position
│   │   ├── Energy non-negative
│   │   ├── Known sources have valid positions
│   │   └── generation_id matches current generation (NEW)
│   ├── Plane State Invariants
│   │   ├── Food quantity non-negative
│   │   ├── Pheromone levels 0-100
│   │   ├── Nest position within bounds
│   │   └── Registered ants have valid positions
│   ├── UI State Invariants
│   │   ├── Width/height positive
│   │   └── Positions consistent with state
│   └── Generational Invariants (NEW)
│       ├── Generation IDs strictly increasing
│       ├── KPIs remain within valid ranges
│       ├── Breeding preserves parameter constraints
│       └── Agent generation_id consistency
│
├── Properties
│   ├── Action Properties
│   │   ├── MoveAction: position changes by 1 unit
│   │   ├── PickUpFoodAction: has_food becomes true
│   │   └── DropFoodAction: has_food becomes false
│   ├── Simulation Properties
│   │   ├── Food conservation: total food constant or increasing
│   │   ├── Ant conservation: ants only removed explicitly
│   │   └── Position continuity: moves are adjacent
│   ├── ML Properties
│   │   ├── Predictions in range [0, 1]
│   │   └── Training decreases loss
│   └── Generational Properties (NEW)
│       ├── Generation transition produces valid state
│       ├── KPIs are monotonic or bounded
│       └── Breeding produces valid parameters
│
└── Test Execution
    ├── Check 100 generations
    ├── Shrink to minimal counterexample
    └── Report failed seeds
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| StreamData Generators | Produce random valid test data |
| Invariant Tests | Verify state properties always hold |
| Property Tests | Verify behavioral properties |
| Generational Invariant Tests (NEW) | Verify generation properties always hold |
| Shrinking | Find minimal failing examples |

---

## 4.3.1 Add StreamData Dependency

Add property-based testing library.

### 4.3.1.1 Add StreamData to Dependencies

Configure StreamData in project.

- [ ] 4.3.1.1.1 Open `mix.exs`
- [ ] 4.3.1.1.2 Add `{:stream_data, "~> 0.5", only: [:test, :dev]}` to deps
- [ ] 4.3.1.1.3 Run `mix deps.get` to fetch
- [ ] 4.3.1.1.4 Verify compilation succeeds

### 4.3.1.2 Configure StreamData

Set up StreamData configuration.

- [ ] 4.3.1.2.1 Open `test/test_helper.ex`
- [ ] 4.3.1.2.2 Add `Application.put_env(:stream_data, :max_runs, 100)`
- [ ] 4.3.1.2.3 Add `Application.put_env(:stream_data, :max_shrinking_steps, 20)`
- [ ] 4.3.1.2.4 Configure to print seed on failure

---

## 4.3.2 Create Data Generators

Build generators for all domain types.

### 4.3.2.1 Create Generators Module

Set up the generators module.

- [ ] 4.3.2.1.1 Create `test/support/generators.ex`
- [ ] 4.3.2.1.2 Add `defmodule AntColony.Generators`
- [ ] 4.3.2.1.3 Add `use StreamData`
- [ ] 4.3.2.1.4 Add `import StreamData`
- [ ] 4.3.2.1.5 Add comprehensive `@moduledoc`

### 4.3.2.2 Generate Position

Create generator for valid positions.

- [ ] 4.3.2.2.1 Define `def position_generator(opts \\ [])`
- [ ] 4.3.2.2.2 Extract width, height from opts (default 100, 100)
- [ ] 4.3.2.2.3 Implement: `gen all({integer(0, width), integer(0, height)})`
- [ ] 4.3.2.2.4 Return generator

### 4.3.2.3 Generate Ant State

Create generator for valid agent states.

- [ ] 4.3.2.3.1 Define `def ant_state_generator(opts \\ [])`
- [ ] 4.3.2.3.2 Generate id: `map(atom(:ant_id), &"ant_#{&1}")`
- [ ] 4.3.2.3.3 Generate position: call `position_generator(opts)`
- [ ] 4.3.2.3.4 Generate nest_position: `position_generator(opts)`
- [ ] 4.3.2.3.5 Generate current_state from `[:at_nest, :searching, :returning_to_nest, :communicating]`
- [ ] 4.3.2.3.6 Generate has_food?: `boolean()`
- [ ] 4.3.2.3.7 Generate carried_food_level: `integer(1, 5)` when has_food
- [ ] 4.3.2.3.8 Generate path_memory: `list_of(position_generator(opts), min_length: 0)`
- [ ] 4.3.2.3.9 Generate known_food_sources: `list_of(food_source_generator())`
- [ ] 4.3.2.3.10 Generate energy: `integer(0, 100)`
- [ ] 4.3.2.3.11 Return fixed struct

### 4.3.2.4 Generate Food Source

Create generator for valid food sources.

- [ ] 4.3.2.4.1 Define `def food_source_generator(opts \\ [])`
- [ ] 4.3.2.4.2 Generate position: `position_generator(opts)`
- [ ] 4.3.2.4.3 Generate level: `integer(1, 5)`
- [ ] 4.3.2.4.4 Generate quantity: `integer(1, 100)`
- [ ] 4.3.2.4.5 Return map with keys: `:position, :level, :quantity`

### 4.3.2.5 Generate Pheromone

Create generator for valid pheromone records.

- [ ] 4.3.2.5.1 Define `def pheromone_generator(opts \\ [])`
- [ ] 4.3.2.5.2 Generate type: `one_of([:food_trail, :exploration])`
- [ ] 4.3.2.5.3 Generate level: `float(min: 0.0, max: 100.0)`
- [ ] 4.3.2.5.4 Generate last_updated: generate recent datetime
- [ ] 4.3.2.5.5 Return map with keys

### 4.3.2.6 Generate Plane State

Create generator for valid Plane states.

- [ ] 4.3.2.6.1 Define `def plane_state_generator(opts \\ [])`
- [ ] 4.3.2.6.2 Generate width, height: `integer(10, 100)`
- [ ] 4.3.2.6.3 Generate nest_position within bounds
- [ ] 4.3.2.6.4 Generate food_sources: `list_of(food_source_generator(opts))`
- [ ] 4.3.2.6.5 Generate pheromones: `map_of(position_generator(opts), pheromone_generator())`
- [ ] 4.3.2.6.6 Generate ant_positions: `map_of(ant_id_generator(), position_generator(opts))`
- [ ] 4.3.2.6.7 Return fixed struct

### 4.3.2.7 Generate Action Parameters

Create generators for action parameters.

- [ ] 4.3.2.7.1 Define `def move_params_generator()`
- [ ] 4.3.2.7.2 Define `def pickup_params_generator()`
- [ ] 4.3.2.7.3 Define `def communication_params_generator()`
- [ ] 4.3.2.7.4 Return appropriate generators

### 4.3.2.8 Generate Generation State (NEW)

Create generator for valid generation states.

- [ ] 4.3.2.8.1 Define `def generation_state_generator(opts \\ [])`
- [ ] 4.3.2.8.2 Generate generation_id: `positive_integer()`
- [ ] 4.3.2.8.3 Generate start_time: recent datetime
- [ ] 4.3.2.8.4 Generate kpis: kpi_map_generator()
- [ ] 4.3.2.8.5 Generate agent_params: parameter_map_generator()
- [ ] 4.3.2.8.6 Return fixed struct with all generation fields

### 4.3.2.9 Generate KPI Map (NEW)

Create generator for KPI maps.

- [ ] 4.3.2.9.1 Define `def kpi_map_generator(opts \\ [])`
- [ ] 4.3.2.9.2 Generate food_collected: `non_negative_integer()`
- [ ] 4.3.2.9.3 Generate trip_efficiency: `float(min: 0.0, max: 10.0)`
- [ ] 4.3.2.9.4 Generate success_rate: `float(min: 0.0, max: 1.0)`
- [ ] 4.3.2.9.5 Return map with KPI keys

### 4.3.2.10 Generate Parameter Map (NEW)

Create generator for agent parameter maps.

- [ ] 4.3.2.10.1 Define `def parameter_map_generator(opts \\ [])`
- [ ] 4.3.2.10.2 Generate exploration_bias: `float(min: 0.0, max: 1.0)`
- [ ] 4.3.2.10.3 Generate pheromone_sensitivity: `float(min: 0.0, max: 2.0)`
- [ ] 4.3.2.10.4 Generate communication_willingness: `float(min: 0.0, max: 1.0)`
- [ ] 4.3.2.10.5 Generate food_quality_threshold: `integer(1, 5)`
- [ ] 4.3.2.10.6 Return map with parameter keys

---

## 4.3.3 Ant State Invariant Tests

Verify ant state properties always hold.

### 4.3.3.1 Create Ant State Property Tests

Create test file for ant invariants.

- [ ] 4.3.3.1.1 Create `test/ant_colony/agent_properties_test.exs`
- [ ] 4.3.3.1.2 Add `use ExUnit.Case`
- [ ] 4.3.3.1.3 Add `use StreamData`
- [ ] 4.3.3.1.4 Add `import AntColony.Generators`

### 4.3.3.2 Test Position Within Bounds

Verify positions are always valid.

- [ ] 4.3.3.2.1 Add `@tag :property` to module
- [ ] 4.3.3.2.2 Test `property "ant position is within plane bounds"`
  - Generator: `ant_state_generator(width: 10, height: 10)`
  - Check: `state.position.x >= 0 and state.position.x < width`
  - Check: `state.position.y >= 0 and state.position.y < height`

### 4.3.3.3 Test Path Memory Invariant

Verify path memory includes current position.

- [ ] 4.3.3.3.1 Test `property "path_memory includes current position when not at nest"`
  - Generator: `ant_state_generator()`
  - Precondition: `state.current_state != :at_nest`
  - Check: `state.position in state.path_memory`

### 4.3.3.4 Test Food Consistency

Verify food state consistency.

- [ ] 4.3.3.4.1 Test `property "carried_food_level implies has_food?"`
  - Generator: `ant_state_generator()`
  - Check: `!state.has_food? or state.carried_food_level != nil`
- [ ] 4.3.3.4.2 Test `property "has_food? implies carried_food_level >= 1"`
  - Check: `!state.has_food? or state.carried_food_level >= 1`

### 4.3.3.5 Test Energy Non-Negative

Verify energy never goes below zero.

- [ ] 4.3.3.5.1 Test `property "energy is always non-negative"`
  - Generator: `ant_state_generator()`
  - Check: `state.energy >= 0`

### 4.3.3.6 Test Known Food Sources Valid

Verify known food sources have valid data.

- [ ] 4.3.3.6.1 Test `property "known_food_sources have valid positions"`
  - Generator: `ant_state_generator()`
  - Check: `Enum.all?(state.known_food_sources, fn fs -> is_valid_position(fs.position) end)`
- [ ] 4.3.3.6.2 Test `property "known_food_sources have valid levels"`
  - Check: `Enum.all?(state.known_food_sources, fn fs -> fs.level in 1..5 end)`

### 4.3.3.7 Test Generation ID Valid (NEW)

Verify generation_id is valid and consistent.

- [ ] 4.3.3.7.1 Test `property "generation_id is positive integer"`
  - Generator: `ant_state_generator()`
  - Check: `state.generation_id > 0`
- [ ] 4.3.3.7.2 Test `property "generation_id matches colony current generation"`
  - Generator: `ant_state_generator()` with current_generation context
  - Check: `state.generation_id == current_generation_id`

---

## 4.3.4 Plane State Invariant Tests

Verify Plane state properties always hold.

### 4.3.4.1 Create Plane State Property Tests

Create test file for Plane invariants.

- [ ] 4.3.4.1.1 Create `test/ant_colony/plane_properties_test.exs`
- [ ] 4.3.4.1.2 Add `use ExUnit.Case`
- [ ] 4.3.4.1.3 Add `use StreamData`
- [ ] 4.3.4.1.4 Add `import AntColony.Generators`

### 4.3.4.2 Test Food Quantity Non-Negative

Verify food quantities are valid.

- [ ] 4.3.4.2.1 Add `@tag :property` to module
- [ ] 4.3.4.2.2 Test `property "food quantities are non-negative"`
  - Generator: `plane_state_generator()`
  - Check: `Enum.all?(state.food_sources, fn fs -> fs.quantity >= 0 end)`

### 4.3.4.3 Test Pheromone Level Range

Verify pheromone levels are in valid range.

- [ ] 4.3.4.3.1 Test `property "pheromone levels are 0-100"`
  - Generator: `plane_state_generator()`
  - Check: `Enum.all?(state.pheromones, fn {_, phero_map} ->`
    `Enum.all?(phero_map, fn {_, level} -> level >= 0 and level <= 100 end) end)`

### 4.3.4.4 Test Nest Position Valid

Verify nest is within bounds.

- [ ] 4.3.4.4.1 Test `property "nest_position is within bounds"`
  - Generator: `plane_state_generator()`
  - Check: `state.nest_location.x >= 0 and state.nest_location.x < state.width`
  - Check: `state.nest_location.y >= 0 and state.nest_location.y < state.height`

### 4.3.4.5 Test Registered Ants Valid

Verify registered ants have valid positions.

- [ ] 4.3.4.5.1 Test `property "registered ant positions are within bounds"`
  - Generator: `plane_state_generator()`
  - Check: `Enum.all?(state.ant_positions, fn {_, {x, y}} ->`
    `x >= 0 and x < state.width and y >= 0 and y < state.height end)`

---

## 4.3.5 Action Property Tests

Verify actions maintain invariants.

### 4.3.5.1 Create Action Property Tests

Create test file for action properties.

- [ ] 4.3.5.1.1 Create `test/ant_colony/actions/properties_test.exs`
- [ ] 4.3.5.1.2 Add `use ExUnit.Case`
- [ ] 4.3.5.1.3 Add `use StreamData`
- [ ] 4.3.5.1.4 Add `import AntColony.Generators`

### 4.3.5.2 Test MoveAction Position Change

Verify moves change position by 1.

- [ ] 4.3.5.2.1 Add `@tag :property` to module
- [ ] 4.3.5.2.2 Test `property "MoveAction changes position by at most 1 unit"`
  - Generator: `{ant_state_generator(), move_params_generator()}`
  - Run MoveAction
  - Calculate distance: `abs(new_x - old_x) + abs(new_y - old_y)`
  - Check: `distance <= 1`

### 4.3.5.3 Test PickUpFoodAction State Change

Verify pickup changes state correctly.

- [ ] 4.3.5.3.1 Test `property "PickUpFoodAction sets has_food? to true on success"`
  - Generator: `{ant_state_generator(has_food?: false), pickup_params_generator()}`
  - Setup: food at ant position
  - Run PickUpFoodAction
  - Check: `new_state.has_food? == true`

### 4.3.5.4 Test DropFoodAction State Change

Verify drop resets food state.

- [ ] 4.3.5.4.1 Test `property "DropFoodAction resets has_food? and carried_food_level"`
  - Generator: `{ant_state_generator(has_food?: true), drop_params_generator()}`
  - Setup: ant at nest
  - Run DropFoodAction
  - Check: `new_state.has_food? == false`
  - Check: `new_state.carried_food_level == nil`

### 4.3.5.5 Test RetracePathAction Path Continuity

Verify retracing follows valid path.

- [ ] 4.3.5.5.1 Test `property "RetracePathAction reverses path_memory"`
  - Generator: `{ant_state_generator() with path_memory, retrace_params_generator()}`
  - Run RetracePathAction with step_count: 1
  - Check: `new_position in old_state.path_memory`

---

## 4.3.6 Simulation Property Tests

Verify simulation-level properties.

### 4.3.6.1 Create Simulation Property Tests

Create test file for simulation properties.

- [ ] 4.3.6.1.1 Create `test/ant_colony/simulation_properties_test.exs`
- [ ] 4.3.6.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.3.6.1.3 Add `use StreamData`
- [ ] 4.3.6.1.4 Add `import AntColony.Generators`

### 4.3.6.2 Test Food Conservation

Verify total food is conserved.

- [ ] 4.3.6.2.1 Add `@tag :property` to module
- [ ] 4.3.6.2.2 Test `property "total food is conserved (plane + ants + collected)"`
  - Setup: start Application with Plane
  - Generator: `list_of(ant_state_generator())`
  - Calculate initial: `food_in_plane + food_with_ants + collected`
  - Perform pickup/drop operations
  - Calculate final: `food_in_plane + food_with_ants + collected`
  - Check: `initial == final`

### 4.3.6.3 Test Ant Count Conservation

Verify ants only removed explicitly.

- [ ] 4.3.6.3.1 Test `property "ant count only changes via spawn/stop"`
  - Setup: start Application with known ants
  - Get initial count
  - Run simulation (no spawn/stop)
  - Get final count
  - Check: `initial == final`

### 4.3.6.4 Test Position Continuity

Verify moves are to adjacent positions.

- [ ] 4.3.6.4.1 Test `property "ant moves are always to adjacent positions"`
  - Setup: start Application, spawn ant
  - Record position
  - Execute move
  - Record new position
  - Check: `manhattan_distance(old, new) == 1`

---

## 4.3.7 ML Property Tests

Verify ML properties.

### 4.3.7.1 Create ML Property Tests

Create test file for ML properties.

- [ ] 4.3.7.1.1 Create `test/ant_colony/ml/properties_test.exs`
- [ ] 4.3.7.1.2 Add `use ExUnit.Case`
- [ ] 4.3.7.1.3 Add `use StreamData`
- [ ] 4.3.7.1.4 Add `import AntColony.Generators`

### 4.3.7.2 Test Prediction Range

Verify predictions are in valid range.

- [ ] 4.3.7.2.1 Add `@tag :property` to module
- [ ] 4.3.7.2.2 Test `property "model predictions are in [0, 1]"`
  - Setup: start Trainer
  - Generator: `list_of(feature_generator())`
  - Call `Trainer.predict(features)`
  - Check: `score >= 0.0 and score <= 1.0`

### 4.3.7.3 Test Training Convergence

Verify training improves model.

- [ ] 4.3.7.3.1 Test `property "training loss decreases or stays same"`
  - Setup: start Trainer with initial model
  - Get initial loss
  - Run training iteration
  - Get new loss
  - Check: `new_loss <= initial_loss`

---

## 4.3.8 UI State Invariant Tests

Verify UI state properties.

### 4.3.8.1 Create UI Property Tests

Create test file for UI invariants.

- [ ] 4.3.8.1.1 Create `test/ant_colony/ui_properties_test.exs`
- [ ] 4.3.8.1.2 Add `use ExUnit.Case`
- [ ] 4.3.8.1.3 Add `use StreamData`
- [ ] 4.3.8.1.4 Add `import AntColony.Generators`

### 4.3.8.2 Test Dimensions Positive

Verify UI dimensions are valid.

- [ ] 4.3.8.2.1 Add `@tag :property` to module
- [ ] 4.3.8.2.2 Test `property "width and height are positive"`
  - Generator: `ui_state_generator()`
  - Check: `state.width > 0 and state.height > 0`

### 4.3.8.3 Test Ant Positions Consistent

Verify UI ant positions match ant state.

- [ ] 4.3.8.3.1 Test `property "ant_positions are within bounds"`
  - Generator: `ui_state_generator()`
  - Check: all ant positions within width/height

---

## 4.3.9 Generational Invariant Tests (NEW)

Verify generation-level properties always hold.

### 4.3.9.1 Create Generational Property Tests

Create test file for generational invariants.

- [ ] 4.3.9.1.1 Create `test/ant_colony/generational_properties_test.exs`
- [ ] 4.3.9.1.2 Add `use ExUnit.Case`
- [ ] 4.3.9.1.3 Add `use StreamData`
- [ ] 4.3.9.1.4 Add `import AntColony.Generators`

### 4.3.9.2 Test Generation IDs Strictly Increasing

Verify generation IDs always increase.

- [ ] 4.3.9.2.1 Add `@tag :property` to module
- [ ] 4.3.9.2.2 Test `property "generation_ids are strictly increasing over time"`
  - Setup: track generation transitions
  - Generator: `list_of(generation_transition_generator())`
  - Check: each transition increments generation_id by 1
- [ ] 4.3.9.2.3 Test `property "generation_id never decreases"`
  - Generator: `generation_state_generator()`
  - Check: `new_generation_id >= previous_generation_id`

### 4.3.9.3 Test KPI Ranges Valid

Verify KPIs remain within valid ranges.

- [ ] 4.3.9.3.1 Test `property "food_collection_rate is non-negative"`
  - Generator: `kpi_map_generator()`
  - Check: `kpi.food_collection_rate >= 0`
- [ ] 4.3.9.3.2 Test `property "trip_efficiency is bounded"`
  - Generator: `kpi_map_generator()`
  - Check: `kpi.trip_efficiency >= 0.0 and kpi.trip_efficiency <= 10.0`
- [ ] 4.3.9.3.3 Test `property "success_rate is in [0, 1]"`
  - Generator: `kpi_map_generator()`
  - Check: `kpi.success_rate >= 0.0 and kpi.success_rate <= 1.0`

### 4.3.9.4 Test Breeding Preserves Constraints

Verify breeding produces valid parameters.

- [ ] 4.3.9.4.1 Test `property "breeding produces valid exploration_bias"`
  - Generator: `list_of(parameter_map_generator())` as parents
  - Run breeding
  - Check: all offspring `exploration_bias in 0.0..1.0`
- [ ] 4.3.9.4.2 Test `property "breeding produces valid pheromone_sensitivity"`
  - Generator: `list_of(parameter_map_generator())` as parents
  - Run breeding
  - Check: all offspring `pheromone_sensitivity in 0.0..2.0`
- [ ] 4.3.9.4.3 Test `property "breeding produces valid food_quality_threshold"`
  - Generator: `list_of(parameter_map_generator())` as parents
  - Run breeding
  - Check: all offspring `food_quality_threshold in 1..5`

### 4.3.9.5 Test Agent Generation ID Consistency

Verify all ants in a generation have matching generation_id.

- [ ] 4.3.9.5.1 Test `property "all agents in generation have same generation_id"`
  - Generator: `list_of(ant_state_generator())`
  - Precondition: all ants spawned in same generation
  - Check: `Enum.all?(ants, fn a -> a.generation_id == generation_id end)`
- [ ] 4.3.9.5.2 Test `property "agent generation_id matches colony generation_id"`
  - Setup: Application with ColonyIntelligenceAgent
  - Generator: `ant_state_generator()`
  - Check: `ant.generation_id == colony.current_generation_id`

### 4.3.9.6 Test Generation Transition Properties

Verify generation transitions produce valid state.

- [ ] 4.3.9.6.1 Test `property "generation_transition preserves valid state"`
  - Setup: valid generation state
  - Run transition
  - Check: new state has valid generation_id
  - Check: new state has empty metrics (reset)
- [ ] 4.3.9.6.2 Test `property "KPI history preserved across transitions"`
  - Setup: generation with KPIs
  - Run transition
  - Check: previous generation KPIs in history
  - Check: KPIs indexed by generation_id

---

## 4.3.10 Test Execution and Reporting

Configure property test execution.

### 4.3.10.1 Configure Test Tags

Organize property tests.

- [ ] 4.3.10.1.1 Add `@tag :property` to all property test modules
- [ ] 4.3.10.1.2 Add `@tag :slow` to slow property tests
- [ ] 4.3.10.1.3 Configure `mix test` to exclude `:slow` by default

### 4.3.10.2 Add Seed Reporting

Report failing seeds for reproducibility.

- [ ] 4.3.10.2.1 Configure `Application.put_env(:stream_data, :seed_on_failure, true)`
- [ ] 4.3.10.2.2 Add task to re-run specific seed:
  ```elixir
  defp property_seed(seed) do
    System.put_env("STREAM_DATA_SEED", seed)
    Mix.Task.run("test", ["--only", "property"])
  end
  ```

---

## 4.3.11 Phase 4.3 Integration Tests

End-to-end tests for property-based testing.

### 4.3.11.1 Test Infrastructure Validation

Verify property test framework works.

- [ ] 4.3.11.1.1 Create `test/phase4/property_tests_infrastructure_test.exs`
- [ ] 4.3.11.1.2 Add test: `test "StreamData is available"`
- [ ] 4.3.11.1.3 Add test: `test "all generators produce valid data"`
- [ ] 4.3.11.1.4 Add test: `test "property tests run successfully"`
- [ ] 4.3.11.1.5 Add test: `test "shrinking finds minimal counterexample"`

---

## Phase 4.3 Success Criteria

1. **StreamData**: Dependency added and configured ✅
2. **Generators**: All domain types have generators ✅
3. **Ant Invariants**: All state properties tested ✅
4. **Plane Invariants**: All environment properties tested ✅
5. **Action Properties**: Action behaviors tested ✅
6. **Simulation Properties**: System-level properties tested ✅
7. **ML Properties**: Model properties tested ✅
8. **Generational Invariants**: Generation IDs, KPIs, breeding tested ✅
9. **Tests**: All property tests pass ✅

## Phase 4.3 Critical Files

**New Files:**
- `test/support/generators.ex` - StreamData generators
- `test/ant_colony/agent_properties_test.exs` - Ant invariant tests
- `test/ant_colony/plane_properties_test.exs` - Plane invariant tests
- `test/ant_colony/actions/properties_test.exs` - Action property tests
- `test/ant_colony/simulation_properties_test.exs` - Simulation property tests
- `test/ant_colony/ml/properties_test.exs` - ML property tests
- `test/ant_colony/ui_properties_test.exs` - UI invariant tests
- `test/ant_colony/generational_properties_test.exs` - Generational invariants (NEW)
- `test/phase4/property_tests_infrastructure_test.exs` - Infrastructure tests

**Modified Files:**
- `mix.exs` - Add StreamData dependency
- `test/test_helper.ex` - Configure StreamData

---

## Next Phase

Proceed to [Phase 4.4: Observability and Logging](./04-observability-logging.md) to add logging and telemetry.
