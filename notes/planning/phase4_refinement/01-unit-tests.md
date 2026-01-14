# Phase 4.1: Unit Tests

Implement comprehensive unit tests for all individual components of the ant colony simulation. Unit tests verify that each module, function, and action works correctly in isolation.

## Architecture

```
Unit Test Coverage
├── Actions (test/ant_colony/actions/*_test.exs)
│   ├── MoveAction
│   ├── SenseFoodAction
│   ├── PickUpFoodAction
│   ├── DropFoodAction
│   ├── LayPheromoneAction
│   ├── SensePheromoneAction
│   ├── RetracePathAction
│   ├── CommunicateAction
│   └── CollectLearningDataAction
│
├── Core Modules (test/ant_colony/*_test.exs)
│   ├── Plane
│   ├── Agent
│   ├── Agent.StateMachine
│   ├── Controller
│   ├── Pheromone
│   └── ColonyIntelligenceAgent (NEW)
│
├── ML Modules (test/ant_colony/ml/*_test.exs)
│   ├── Model
│   ├── Trainer
│   ├── TrainingRecord
│   └── Features
│
├── Generational Modules (test/ant_colony/generational/*_test.exs) (NEW)
│   ├── DataCollectorAgent
│   ├── TrainerAgent
│   ├── Breeding
│   └── GenerationSupervisor
│
└── UI (test/ant_colony/ui_test.exs)
    ├── init/1
    ├── update/2
    └── view/1
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Action Tests | Verify each Jido Action produces correct state transitions |
| Module Tests | Verify Plane, Agent, and other core modules |
| ColonyIntelligenceAgent Tests (NEW) | Verify KPI tracking, trigger logic, evaluation, breeding |
| DataCollectorAgent Tests (NEW) | Verify foraging data aggregation |
| TrainerAgent Tests (NEW) | Verify Axon model training per generation |
| Breeding Tests (NEW) | Verify selection, crossover, mutation algorithms |
| ML Tests | Verify machine learning components |
| UI Tests | Verify TermUI.Elm callbacks |

---

## 4.1.1 Test Infrastructure Setup

Set up the testing framework and shared utilities.

### 4.1.1.1 Configure Test Helper

Create test helper module with shared utilities.

- [ ] 4.1.1.1.1 Create `test/test_helper.ex`
- [ ] 4.1.1.1.2 Configure ExUnit with `ExUnit.start()`
- [ ] 4.1.1.1.3 Add `Application.put_env(:jido, :disable_telemetry, true)` to disable telemetry during tests
- [ ] 4.1.1.1.4 Configure `exclude` tags: `[skip: true, focus: true]`
- [ ] 4.1.1.1.5 Add `@moduletag :capture_log` for log capture in failing tests

### 4.1.1.2 Create Test Data Generators

Build helper functions for generating test data.

- [ ] 4.1.1.2.1 Create `test/support/data_generators.ex`
- [ ] 4.1.1.2.2 Define `def valid_ant_state(opts \\ [])`
- [ ] 4.1.1.2.3 Define `def valid_plane_state(opts \\ [])`
- [ ] 4.1.1.2.4 Define `def valid_food_source(opts \\ [])`
- [ ] 4.1.1.2.5 Define `def valid_pheromone(opts \\ [])`

### 4.1.1.3 Create Test Assertions

Add custom assertions for common checks.

- [ ] 4.1.1.3.1 Define `def assert_position(state, {x, y})`
- [ ] 4.1.1.3.2 Define `def assert_state(state, expected_state)`
- [ ] 4.1.1.3.3 Define `def assert_directives(directives, expected_types)`
- [ ] 4.1.1.3.4 Define `def assert_event_published(event_name, payload)`

### 4.1.1.4 Setup Test Fixtures

Create common test scenarios.

- [ ] 4.1.1.4.1 Create `test/support/fixtures.ex`
- [ ] 4.1.1.4.2 Define `def simple_plane()` - 10x10 with nest and one food
- [ ] 4.1.1.4.3 Define `def empty_plane()` - plane with no food
- [ ] 4.1.1.4.4 Define `def populated_plane()` - multiple food sources
- [ ] 4.1.1.4.5 Define `def ant_at_nest()` - ant positioned at nest

### 4.1.1.5 Configure Test Coverage

Set up coverage reporting.

- [ ] 4.1.1.5.1 Add `:test_coverage` to deps in mix.exs
- [ ] 4.1.1.5.2 Configure coverage settings:
  ```elixir
  def project do
    [
      test_coverage: [threshold: 80],
      preferred_cli_env: [
        coverage: ["test", "--cover"],
        "coveralls.html": ["test", "--cover"]
      ]
    ]
  end
  ```
- [ ] 4.1.1.5.3 Add `ignore` paths for generated files
- [ ] 4.1.1.5.4 Set minimum coverage target to 80%

---

## 4.1.2 Unit Tests for Actions

Test all Jido Actions produce correct state transitions and directives.

### 4.1.2.1 Test MoveAction

Verify movement action works correctly.

- [ ] 4.1.2.1.1 Create `test/ant_colony/actions/move_action_test.exs`
- [ ] 4.1.2.1.2 Describe "MoveAction context setup"
- [ ] 4.1.2.1.3 Test `test "run/2 updates position when direction is valid"`
  - Setup: ant at {5, 5}, facing north
  - Action: move north
  - Assert: new position is {5, 4}
  - Assert: path_memory updated
- [ ] 4.1.2.1.4 Test `test "run/2 returns error for invalid position"`
  - Setup: ant at {0, 0}
  - Action: move north (out of bounds)
  - Assert: returns `{:error, :out_of_bounds}`
- [ ] 4.1.2.1.5 Test `test "run/2 publishes ant_moved event"`
  - Setup: valid move
  - Assert: Phoenix.PubSub broadcast called
- [ ] 4.1.2.1.6 Test `test "run/2 handles diagonal movement"`
  - Test diagonal directions
- [ ] 4.1.2.1.7 Test `test "run/2 respects plane boundaries"`
  - Test at all four corners
- [ ] 4.1.2.1.8 Test `test "run/2 considers pheromones when enabled"`
  - Mock pheromone sensing
  - Verify direction influenced

### 4.1.2.2 Test SenseFoodAction

Verify food sensing works correctly.

- [ ] 4.1.2.2.1 Create `test/ant_colony/actions/sense_food_action_test.exs`
- [ ] 4.1.2.2.2 Test `test "run/2 detects food at current position"`
  - Setup: plane with food at {5, 5}, ant at {5, 5}
  - Assert: returns food details
- [ ] 4.1.2.2.3 Test `test "run/2 returns nil when no food present"`
  - Setup: ant at empty position
  - Assert: returns no food
- [ ] 4.1.2.2.4 Test `test "run/2 evaluates food quality when enabled"`
  - Test quality evaluation logic
- [ ] 4.1.2.2.5 Test `test "run/2 handles plane errors gracefully"`

### 4.1.2.3 Test PickUpFoodAction

Verify food pickup works correctly.

- [ ] 4.1.2.3.1 Create `test/ant_colony/actions/pick_up_food_action_test.exs`
- [ ] 4.1.2.3.2 Test `test "run/2 picks up food when quality > threshold"`
- [ ] 4.1.2.3.3 Test `test "run/2 ignores low quality food"`
- [ ] 4.1.2.3.4 Test `test "run/2 picks up when force is true"`
- [ ] 4.1.2.3.5 Test `test "run/2 returns error when already carrying"`
- [ ] 4.1.2.3.6 Test `test "run/2 transitions state to returning_to_nest"`
- [ ] 4.1.2.3.7 Test `test "run/2 publishes food_picked_up event"`

### 4.1.2.4 Test DropFoodAction

Verify food drop works correctly.

- [ ] 4.1.2.4.1 Create `test/ant_colony/actions/drop_food_action_test.exs`
- [ ] 4.1.2.4.2 Test `test "run/2 drops food at nest"`
- [ ] 4.1.2.4.3 Test `test "run/2 returns error when not at nest"`
- [ ] 4.1.2.4.4 Test `test "run/2 returns error when not carrying"`
- [ ] 4.1.2.4.5 Test `test "run/2 transitions state to at_nest"`
- [ ] 4.1.2.4.6 Test `test "run/2 clears path_memory"`

### 4.1.2.5 Test LayPheromoneAction

Verify pheromone laying works correctly.

- [ ] 4.1.2.5.1 Create `test/ant_colony/actions/lay_pheromone_action_test.exs`
- [ ] 4.1.2.5.2 Test `test "run/2 deposits pheromone at current position"`
- [ ] 4.1.2.5.3 Test `test "run/2 calculates intensity from food level"`
- [ ] 4.1.2.5.4 Test `test "run/2 uses provided intensity"`
- [ ] 4.1.2.5.5 Test `test "run/2 caps intensity at maximum"`
- [ ] 4.1.2.5.6 Test `test "run/2 publishes pheromone_updated event"`

### 4.1.2.6 Test SensePheromoneAction

Verify pheromone sensing works correctly.

- [ ] 4.1.2.6.1 Create `test/ant_colony/actions/sense_pheromone_action_test.exs`
- [ ] 4.1.2.6.2 Test `test "run/2 returns pheromone data for neighbors"`
- [ ] 4.1.2.6.3 Test `test "run/2 filters by specified types"`
- [ ] 4.1.2.6.4 Test `test "run/2 generates neighbors automatically"`
- [ ] 4.1.2.6.5 Test `test "run/2 filters out-of-bounds positions"`
- [ ] 4.1.2.6.6 Test `test "run/2 stores result in agent state"`
- [ ] 4.1.2.6.7 Test `test "calculate_direction_probabilities works"`

### 4.1.2.7 Test RetracePathAction

Verify path retracing works correctly.

- [ ] 4.1.2.7.1 Create `test/ant_colony/actions/retrace_path_action_test.exs`
- [ ] 4.1.2.7.2 Test `test "run/2 moves back one step"`
- [ ] 4.1.2.7.3 Test `test "run/2 moves multiple steps"`
- [ ] 4.1.2.7.4 Test `test "run/2 returns error when path_memory empty"`
- [ ] 4.1.2.7.5 Test `test "run/2 removes visited positions"`
- [ ] 4.1.2.7.6 Test `test "run/2 detects nest reached"`

### 4.1.2.8 Test CommunicateAction

Verify communication action works correctly.

- [ ] 4.1.2.8.1 Create `test/ant_colony/actions/communicate_action_test.exs`
- [ ] 4.1.2.8.2 Test `test "run/2 shares known_food_sources"`
- [ ] 4.1.2.8.3 Test `test "run/2 receives sources from other ant"`
- [ ] 4.1.2.8.4 Test `test "run/2 merges sources correctly"`
- [ ] 4.1.2.8.5 Test `test "run/2 handles timeout"`
- [ ] 4.1.2.8.6 Test `test "run/2 publishes communication events"`

### 4.1.2.9 Test ML Actions

Verify ML-related actions work correctly.

- [ ] 4.1.2.9.1 Create `test/ant_colony/actions/collect_learning_data_action_test.exs`
- [ ] 4.1.2.9.2 Test `test "run/2 creates training record"`
- [ ] 4.1.2.9.3 Test `test "run/2 sends data to trainer"`

- [ ] 4.1.2.9.4 Create `test/ant_colony/actions/predict_path_quality_action_test.exs`
- [ ] 4.1.2.9.5 Test `test "run/2 returns predictions"`
- [ ] 4.1.2.9.6 Test `test "run/2 builds correct features"`
- [ ] 4.1.2.9.7 Test `test "run/2 handles missing trainer"`

---

## 4.1.3 Unit Tests for Core Modules

Test Plane, Agent, and other core modules.

### 4.1.3.1 Test Plane Module

Verify Plane GenServer works correctly.

- [ ] 4.1.3.1.1 Create `test/ant_colony/plane_test.exs`
- [ ] 4.1.3.1.2 Describe "Plane context setup"
- [ ] 4.1.3.1.3 Test `test "start_link/1 initializes plane with defaults"`
- [ ] 4.1.3.1.4 Test `test "handle_call :get_full_state_for_ui returns correct data"`
- [ ] 4.1.3.1.5 Test `test "register_ant adds ant to ant_positions"`
- [ ] 4.1.3.1.6 Test `test "unregister_ant removes ant from ant_positions"`
- [ ] 4.1.3.1.7 Test `test "pick_up_food decrements food quantity"`
- [ ] 4.1.3.1.8 Test `test "pick_up_food returns error when no food"`
- [ ] 4.1.3.1.9 Test `test "deposit_food increments total_food_collected"`
- [ ] 4.1.3.1.10 Test `test "lay_pheromone adds pheromone at position"`
- [ ] 4.1.3.1.11 Test `test "get_pheromone_levels returns correct data"`
- [ ] 4.1.3.1.12 Test `test "evaporate_pheromones reduces levels"`
- [ ] 4.1.3.1.13 Test `test "evaporation removes low levels"`
- [ ] 4.1.3.1.14 Test `test "check_proximity finds nearby ants"`
- [ ] 4.1.3.1.15 Test `test "check_proximity respects cooldowns"`

### 4.1.3.2 Test Agent Module

Verify AntAgent works correctly.

- [ ] 4.1.3.2.1 Create `test/ant_colony/agent_test.exs`
- [ ] 4.1.3.2.2 Describe "Agent context setup"
- [ ] 4.1.3.2.3 Test `test "init/1 creates agent with valid schema"`
- [ ] 4.1.3.2.4 Test `test "child_spec/1 returns correct child spec"`
- [ ] 4.1.3.2.5 Test `test "handle_call :get_state returns agent state"`
- [ ] 4.1.3.2.6 Test `test "handle_info :ant_encounter triggers communication"`
- [ ] 4.1.3.2.7 Test `test "handle_info :simulation_paused pauses agent"`
- [ ] 4.1.3.2.8 Test `test "handle_info :simulation_resumed resumes agent"`

### 4.1.3.3 Test StateMachine Module

Verify state transitions work correctly.

- [ ] 4.1.3.3.1 Create `test/ant_colony/agent/state_machine_test.exs`
- [ ] 4.1.3.3.2 Test `test "valid transitions are allowed"`
- [ ] 4.1.3.3.3 Test `test "invalid transitions are rejected"`
- [ ] 4.1.3.3.4 Test `test "all states have defined transitions"`
- [ ] 4.1.3.3.5 Test `test "transition_state publishes event"`

### 4.1.3.4 Test Controller Module

Verify simulation controller works correctly.

- [ ] 4.1.3.4.1 Create `test/ant_colony/controller_test.exs`
- [ ] 4.1.3.4.2 Test `test "init/1 starts controller with defaults"`
- [ ] 4.1.3.4.3 Test `test "pause sets paused to true"`
- [ ] 4.1.3.4.4 Test `test "resume sets paused to false"`
- [ ] 4.1.3.4.5 Test `test "toggle_pause flips state"`
- [ ] 4.1.3.4.6 Test `test "set_speed adjusts multiplier"`
- [ ] 4.1.3.4.7 Test `test "set_speed validates range (0.1-10.0)"`
- [ ] 4.1.3.4.8 Test `test "get_status returns correct metadata"`
- [ ] 4.1.3.4.9 Test `test "reset clears simulation time"`

### 4.1.3.5 Test Pheromone Module

Verify pheromone utilities work correctly.

- [ ] 4.1.3.5.1 Create `test/ant_colony/pheromone_test.exs`
- [ ] 4.1.3.5.2 Test `test "distance calculates Euclidean distance"`
- [ ] 4.1.3.5.3 Test `test "within_radius? returns correct boolean"`
- [ ] 4.1.3.5.4 Test `test "evap_rate applies correct evaporation"`

### 4.1.3.6 Test ColonyIntelligenceAgent (NEW)

Verify generational management and KPI tracking.

- [ ] 4.1.3.6.1 Create `test/ant_colony/colony_intelligence_agent_test.exs`
- [ ] 4.1.3.6.2 Test `test "init/1 starts with generation_id 1"`
- [ ] 4.1.3.6.3 Test `test "current_generation_id returns correct generation"`
- [ ] 4.1.3.6.4 Test `test "register_agent increments agent count"`
- [ ] 4.1.3.6.5 Test `test "unregister_agent decrements agent count"`

### 4.1.3.7 Test KPI Calculation (NEW)

Verify KPI metrics are calculated correctly.

- [ ] 4.1.3.7.1 Test `test "calculate_food_collection_rate returns correct value"`
  - Setup: 100 food collected over 60 seconds
  - Assert: rate ≈ 1.67 food/second
- [ ] 4.1.3.7.2 Test `test "calculate_trip_efficiency returns correct value"`
  - Setup: 50 trips, total distance 500
  - Assert: efficiency = 0.1 food/unit
- [ ] 4.1.3.7.3 Test `test "calculate_success_rate returns correct value"`
  - Setup: 40 successful trips, 10 failed
  - Assert: success rate = 80%
- [ ] 4.1.3.7.4 Test `test "KPIs are reset on generation transition"`

### 4.1.3.8 Test Generation Trigger Logic (NEW)

Verify generation transition triggers work correctly.

- [ ] 4.1.3.8.1 Test `test "trigger_after_food_delivered fires at threshold"`
  - Setup: threshold = 50, count = 49
  - Send food_delivered event
  - Assert: generation triggered
- [ ] 4.1.3.8.2 Test `test "plateau_detection_fires_after_stagnation"`
  - Setup: KPIs unchanged for N deliveries
  - Assert: plateau detected
- [ ] 4.1.3.8.3 Test `test "manual_trigger_fires_generation_transition"`
  - Call `trigger_generation()`
  - Assert: generation_id incremented

### 4.1.3.9 Test Evaluation and Ranking (NEW)

Verify agent evaluation produces valid rankings.

- [ ] 4.1.3.9.1 Test `test "evaluate_agents returns ranked list"`
  - Setup: agents with varying performance
  - Call `evaluate_agents()`
  - Assert: list sorted by performance descending
- [ ] 4.1.3.9.2 Test `test "identify_fittest_returns_top_percentage"`
  - Setup: 100 agents, top 20%
  - Call `identify_fittest(0.2)`
  - Assert: returns 20 best agents

### 4.1.3.10 Test Breeding Algorithms (NEW)

Verify selection, crossover, and mutation produce valid parameters.

- [ ] 4.1.3.10.1 Test `test "selection chooses top performers"`
  - Setup: ranked agents
  - Call `select_parents(ranked, count)`
  - Assert: only top performers selected
- [ ] 4.1.3.10.2 Test `test "crossover_combines_parent_parameters"`
  - Setup: two parent parameter maps
  - Call `crossover(parent1, parent2)`
  - Assert: child has mix of both parameters
- [ ] 4.1.3.10.3 Test `test "mutation_introduces_random_variations"`
  - Setup: parameter map
  - Call `mutate(params, rate)`
  - Assert: some parameters changed slightly
- [ ] 4.1.3.10.4 Test `test "breeding_preserves_parameter_constraints"`
  - Setup: parameters with min/max constraints
  - Call `breed(parents)`
  - Assert: all children within valid ranges

### 4.1.3.11 Test Next Generation Protocol (NEW)

Verify the full generation lifecycle.

- [ ] 4.1.3.11.1 Test `test "next_generation_protocol_runs_full_cycle"`
  - Setup: agents with performance data
  - Call `next_generation()`
  - Assert: evaluation → breeding → spawning → reset
- [ ] 4.1.3.11.2 Test `test "spawning_creates_new_generation_with_evolved_params"`
  - Setup: evolved parameters
  - Call `spawn_new_generation(params)`
  - Assert: new agents have evolved params, generation_id incremented

---

## 4.1.4 Unit Tests for ML Components

Test machine learning modules.

### 4.1.4.1 Test Model Module

Verify Axon model works correctly.

- [ ] 4.1.4.1.1 Create `test/ant_colony/ml/model_test.exs`
- [ ] 4.1.4.1.2 Test `test "build_model creates valid architecture"`
- [ ] 4.1.4.1.3 Test `test "init_model initializes parameters"`
- [ ] 4.1.4.1.4 Test `test "predict returns score in valid range (0-1)"`
- [ ] 4.1.4.1.5 Test `test "train updates model parameters"`
- [ ] 4.1.4.1.6 Test `test "train decreases loss over time"`

### 4.1.4.2 Test Trainer Module

Verify trainer coordinates ML correctly.

- [ ] 4.1.4.2.1 Create `test/ant_colony/ml/trainer_test.exs`
- [ ] 4.1.4.2.2 Test `test "init/1 starts with initial model"`
- [ ] 4.1.4.2.3 Test `test "add_training_data stores records"`
- [ ] 4.1.4.2.4 Test `test "add_training_data trims to max_samples"`
- [ ] 4.1.4.2.5 Test `test "triggers training after interval"`
- [ ] 4.1.4.2.6 Test `test "predict returns model score"`
- [ ] 4.1.4.2.7 Test `test "get_model_state returns metadata"`

### 4.1.4.3 Test TrainingRecord Module

Verify training data structures.

- [ ] 4.1.4.3.1 Create `test/ant_colony/ml/training_record_test.exs`
- [ ] 4.1.4.3.2 Test `test "struct has correct fields"`
- [ ] 4.1.4.3.3 Test `test "from_trip_data creates valid record"`

### 4.1.4.4 Test Features Module

Verify feature engineering.

- [ ] 4.1.4.4.1 Create `test/ant_colony/ml/features_test.exs`
- [ ] 4.1.4.4.2 Test `test "to_tensor converts features to tensor"`
- [ ] 4.1.4.4.3 Test `test "normalization scales values correctly"`
- [ ] 4.1.4.4.4 Test `test "from_tensor converts tensor to features"`

---

## 4.1.5 Unit Tests for Generational Modules (NEW)

Test generational ML components.

### 4.1.5.1 Test DataCollectorAgent (NEW)

Verify foraging data aggregation.

- [ ] 4.1.5.1.1 Create `test/ant_colony/generational/data_collector_agent_test.exs`
- [ ] 4.1.5.1.2 Test `test "init/1 starts with empty data buffer"`
- [ ] 4.1.5.1.3 Test `test "collect_foraging_data stores trip data"`
- [ ] 4.1.5.1.4 Test `test "collect_foraging_data links to generation_id"`
- [ ] 4.1.5.1.5 Test `test "get_aggregated_data returns summary statistics"`
- [ ] 4.1.5.1.6 Test `test "clear_generation_data removes data for generation"`
- [ ] 4.1.5.1.7 Test `test "data buffer respects max_samples limit"`

### 4.1.5.2 Test TrainerAgent (NEW)

Verify Axon model training per generation.

- [ ] 4.1.5.2.1 Create `test/ant_colony/generational/trainer_agent_test.exs`
- [ ] 4.1.5.2.2 Test `test "init/1 starts with initial model"`
- [ ] 4.1.5.2.3 Test `test "train_generation creates new model version"`
- [ ] 4.1.5.2.4 Test `test "train_generation emits training_complete event"`
- [ ] 4.1.5.2.5 Test `test "get_model_for_generation returns correct model"`
- [ ] 4.1.5.2.6 Test `test "training preserves model lineage"`
- [ ] 4.1.5.2.7 Test `test "training handles insufficient data gracefully"`

### 4.1.5.3 Test Breeding Module (NEW)

Verify selection, crossover, and mutation algorithms.

- [ ] 4.1.5.3.1 Create `test/ant_colony/generational/breeding_test.exs`
- [ ] 4.1.5.3.2 Test `test "select_tournament returns winners"`
- [ ] 4.1.5.3.3 Test `test "select_roulette selects by fitness probability"`
- [ ] 4.1.5.3.4 Test `test "crossover_single_point combines parents"`
- [ ] 4.1.5.3.5 Test `test "crossover_uniform mixes parameters"`
- [ ] 4.1.5.3.6 Test `test "mutate_gaussian adds random noise"`
- [ ] 4.1.5.3.7 Test `test "mutate_uniform randomizes parameters"`
- [ ] 4.1.5.3.8 Test `test "breed_cycle produces valid offspring"`
- [ ] 4.1.5.3.9 Test `test "offspring_respect_parameter_bounds"`

### 4.1.5.4 Test GenerationSupervisor (NEW)

Verify generation lifecycle supervision.

- [ ] 4.1.5.4.1 Create `test/ant_colony/generational/generation_supervisor_test.exs`
- [ ] 4.1.5.4.2 Test `test "init/1 starts initial generation"`
- [ ] 4.1.5.4.3 Test `test "advance_generation triggers full lifecycle"`
- [ ] 4.1.5.4.4 Test `test "handle_info handles generation trigger"`
- [ ] 4.1.5.4.5 Test `test "spawn_generation creates new agents"`
- [ ] 4.1.5.4.6 Test `test "terminate_generation shuts down agents cleanly"`

---

## 4.1.6 Unit Tests for UI Components

Test TermUI.Elm callbacks.

### 4.1.6.1 Test UI Module

Verify UI Elm architecture works correctly.

- [ ] 4.1.6.1.1 Create `test/ant_colony/ui_test.exs`
- [ ] 4.1.6.1.2 Describe "UI context setup"
- [ ] 4.1.6.1.3 Test `test "init/1 subscribes to ui_updates topic"`
- [ ] 4.1.6.1.4 Test `test "init/1 fetches initial state from Plane"`
- [ ] 4.1.6.1.5 Test `test "init/1 builds correct initial UI state"`
- [ ] 4.1.6.1.6 Test `test "update/2 handles ant_moved event"`
- [ ] 4.1.6.1.7 Test `test "update/2 handles food_updated event"`
- [ ] 4.1.6.1.8 Test `test "update/2 handles pheromone_updated event"`
- [ ] 4.1.6.1.9 Test `test "update/2 handles communication events"`
- [ ] 4.1.6.1.10 Test `test "update/2 handles model_updated event"`
- [ ] 4.1.6.1.11 Test `test "update/2 handles pause/resume events"`
- [ ] 4.1.6.1.12 Test `test "update/2 handles quit key"`
- [ ] 4.1.6.1.13 Test `test "update/2 handles quit confirmation"`
- [ ] 4.1.6.1.14 Test `test "view/1 returns valid Canvas widget"`
- [ ] 4.1.6.1.15 Test `test "view/1 draws nest at correct position"`
- [ ] 4.1.6.1.16 Test `test "view/1 draws food sources correctly"`
- [ ] 4.1.6.1.17 Test `test "view/1 draws ants at positions"`
- [ ] 4.1.6.1.18 Test `test "view/1 handles empty state"`

---

## 4.1.7 Test Mocks and Fixtures

Create test doubles for external dependencies.

### 4.1.7.1 Create Plane Mock

Mock Plane GenServer for action tests.

- [ ] 4.1.7.1.1 Create `test/mocks/plane_mock.ex`
- [ ] 4.1.7.1.2 Define `def start_link()` for mock
- [ ] 4.1.7.1.3 Implement mock responses for:
  - `:get_position`
  - `:pick_up_food`
  - `:lay_pheromone`
  - `:get_pheromone_levels`
- [ ] 4.1.7.1.4 Store calls in agent process for assertion

### 4.1.7.2 Create PubSub Mock

Mock Phoenix.PubSub for isolation.

- [ ] 4.1.7.2.1 Create `test/mocks/pubsub_mock.ex`
- [ ] 4.1.7.2.2 Track published events
- [ ] 4.1.7.2.3 Define `def get_published_events()` helper
- [ ] 4.1.7.2.4 Define `def clear_published_events()` helper

### 4.1.7.3 Create ML Mock

Mock ML trainer for tests.

- [ ] 4.1.7.3.1 Create `test/mocks/ml_mock.ex`
- [ ] 4.1.7.3.2 Mock `predict/1` to return fixed scores
- [ ] 4.1.7.3.3 Mock `add_training_data/1`
- [ ] 4.1.7.3.4 Allow configuration via process dictionary

---

## 4.1.8 Test Configuration

Configure test environment and settings.

### 4.1.8.1 Configure Test Environment

Set up config for test environment.

- [ ] 4.1.8.1.1 Open `config/test.exs`
- [ ] 4.1.8.1.2 Configure `config :ant_colony, :enable_ui, false`
- [ ] 4.1.8.1.3 Configure `config :ant_colony, :log_level, :warn`
- [ ] 4.1.8.1.4 Configure `config :ant_colony, :plane_dimensions, {10, 10}`
- [ ] 4.1.8.1.5 Configure any test-specific timeouts

### 4.1.8.2 Add Test Watcher Configuration

Enable automatic test running during development.

- [ ] 4.1.8.2.1 Create `test/test.watch.exs` if using mix_test.watch
- [ ] 4.1.8.2.2 Configure watch patterns for lib/ and test/
- [ ] 4.1.8.2.3 Configure clear command

---

## 4.1.9 Phase 4.1 Integration Tests

End-to-end tests for unit test infrastructure.

### 4.1.9.1 Test Framework Validation

Verify testing infrastructure works.

- [ ] 4.1.9.1.1 Create `test/phase4/unit_tests_infrastructure_test.exs`
- [ ] 4.1.9.1.2 Add test: `test "test helper loads successfully"`
- [ ] 4.1.9.1.3 Add test: `test "data generators produce valid data"`
- [ ] 4.1.9.1.4 Add test: `test "fixtures create expected state"`
- [ ] 4.1.9.1.5 Add test: `test "mocks work correctly"`

### 4.1.9.2 Coverage Validation

Verify coverage meets targets.

- [ ] 4.1.9.2.1 Add test: `test "unit tests achieve 80% coverage"`
- [ ] 4.1.9.2.2 Add test: `test "all actions have unit tests"`
- [ ] 4.1.9.2.3 Add test: `test "all core modules have unit tests"`

### 4.1.9.3 Test Execution Performance

Verify tests run efficiently.

- [ ] 4.1.9.3.1 Add test: `test "unit test suite completes in reasonable time"`
- [ ] 4.1.9.3.2 Add test: `test "no tests have race conditions"`
- [ ] 4.1.9.3.3 Add test: `test "tests are deterministic"`

---

## Phase 4.1 Success Criteria

1. **Test Infrastructure**: Helpers, fixtures, mocks in place ✅
2. **Action Tests**: All actions have comprehensive unit tests ✅
3. **Module Tests**: Core modules fully tested ✅
4. **ColonyIntelligenceAgent Tests**: KPI, trigger, evaluation, breeding ✅
5. **DataCollectorAgent Tests**: Foraging data aggregation ✅
6. **TrainerAgent Tests**: Model training per generation ✅
7. **Breeding Tests**: Selection, crossover, mutation ✅
8. **ML Tests**: ML components tested ✅
9. **UI Tests**: UI callbacks tested ✅
10. **Coverage**: 80%+ coverage achieved ✅
11. **Performance**: Test suite runs in < 30 seconds ✅

## Phase 4.1 Critical Files

**New Files:**
- `test/test_helper.ex` - Test configuration
- `test/support/data_generators.ex` - Test data helpers
- `test/support/fixtures.ex` - Common test scenarios
- `test/support/assertions.ex` - Custom assertions
- `test/mocks/plane_mock.ex` - Plane mock
- `test/mocks/pubsub_mock.ex` - PubSub mock
- `test/mocks/ml_mock.ex` - ML mock
- `test/ant_colony/actions/*_test.exs` - Action tests
- `test/ant_colony/*_test.exs` - Module tests
- `test/ant_colony/colony_intelligence_agent_test.exs` - ColonyIntelligence tests (NEW)
- `test/ant_colony/generational/*_test.exs` - Generational modules tests (NEW)
- `test/ant_colony/ml/*_test.exs` - ML tests
- `test/ant_colony/ui_test.exs` - UI tests
- `test/phase4/unit_tests_infrastructure_test.exs` - Infrastructure tests

**Modified Files:**
- `config/test.exs` - Test configuration
- `mix.exs` - Add test coverage dependencies

---

## Next Phase

Proceed to [Phase 4.2: Integration Tests](./02-integration-tests.md) to test interactions between components.
