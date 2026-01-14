# Phase 3.4: Generational Machine Learning Integration

Implement evolutionary machine learning where the colony improves its foraging strategies across generations. This cycle replaces individual ant learning with **generational evolution** - data is collected during a generation, models are trained, and the next generation spawns with evolved parameters. The ColonyIntelligenceAgent orchestrates the "Next Generation Protocol."

## Architecture

```
Generational ML Pipeline
├── Data Collection (During Generation):
│   ├── Events: {:food_delivered, ant_id, generation_id, food_level, trip_time, path_summary}
│   ├── Events: {:foraging_experience, path_data, outcome}
│   └── DataCollectorAgent aggregates all foraging data
│
├── Training (End of Generation):
│   ├── TrainerAgent uses Axon to train model on collected data
│   ├── Model predicts path quality based on environmental features
│   └── Training continues until convergence or max epochs
│
├── Generation Trigger Logic:
│   ├── Performance plateau detection
│   │   ├── Calculate food collection rate over sliding window
│   │   ├── Detect stagnation (rate change < threshold over N deliveries)
│   │   └── Trigger next generation when plateau confirmed
│   ├── Training completion confirmation
│   │   ├── Monitor TrainerAgent training status
│   │   └── Trigger when training epoch reaches target
│   └── Manual trigger (for debugging)
│
├── Next Generation Protocol:
│   ├── Evaluation:
│   │   ├── Rank all agents by performance metrics
│   │   │   ├── Food delivered (count and total quality)
│   │   │   ├── Trip efficiency (food quality / trip time)
│   │   │   └── Success rate (deliveries / attempts)
│   │   ├── Identify top N performers (elite selection)
│   │   ├── Calculate generation-level KPIs
│   │   └── Store in kpi_history for analysis
│   ├── Breeding (Evolution):
│   │   ├── Selection:
│   │   │   ├── Choose top 20% as elite (direct copy)
│   │   │   ├── Choose middle 60% for breeding
│   │   │   └── Discard bottom 20%
│   │   ├── Crossover:
│   │   │   ├── Combine parameters from two "parents"
│   │   │   ├── For neural networks: average weights
│   │   │   └── For ACO parameters: weighted average
│   │   └── Mutation:
│   │       ├── Introduce random parameter variations
│   │       ├── Mutation rate: 5-10% of parameters
│   │       └── Gaussian noise for continuous values
│   ├── Spawning:
│   │   ├── Terminate all current AntAgents
│   │   ├── Create new AntAgents with evolved parameters
│   │   ├── Set generation_id = current_generation_id + 1
│   │   ├── Deploy updated model from TrainerAgent
│   │   └── Broadcast {:generation_started, new_generation_id}
│   └── Reset:
│       ├── Clear generation-specific metrics
│       ├── Reset food_delivered_count to 0
│       ├── Initialize DataCollectorAgent for new generation
│       └── Start collecting data for next cycle
│
└── UI Display:
    ├── Training progress (epoch, loss, accuracy)
    ├── Generation transition notification
    ├── Historical KPI graph (sparkline across generations)
    └── Manual "trigger next generation" button
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| DataCollectorAgent | Aggregates foraging trip data for training |
| TrainerAgent | Uses Axon to train models per generation |
| ColonyIntelligenceAgent | Orchestrates generation protocol |
| BreedingActions | Selection, crossover, mutation of parameters |
| EvaluationActions | Rank agents and calculate KPIs |
| UI ML Display | Training progress and KPI visualization |

---

## 3.4.1 Define Generational ML Data Structures

Establish data structures for generational learning.

### 3.4.1.1 Define Foraging Record Structure

Create schema for foraging trip records.

- [ ] 3.4.1.1.1 Create `lib/ant_colony/ml/foraging_record.ex`
- [ ] 3.4.1.1.2 Add `defstruct` with fields:
  - `:ant_id` - ant identifier
  - `:generation_id` - generation identifier
  - `:path` - list of `{x, y}` positions
  - `:trip_time_ms` - duration of trip
  - `:energy_used` - energy expended
  - `:food_level` - food quality (1-5) if found
  - `:start_position` - starting coordinates
  - `:end_position` - ending coordinates
  - `:timestamp` - when trip completed
- [ ] 3.4.1.1.3 Add `@type` specification
- [ ] 3.4.1.1.4 Document struct in @moduledoc

### 3.4.1.2 Define Feature Vector Structure

Create schema for model input features.

- [ ] 3.4.1.2.1 Create `lib/ant_colony/ml/features.ex`
- [ ] 3.4.1.2.2 Define `@type feature_vector :: %{`
  - `pheromone_level: float(),`
  - `pheromone_gradient: {float(), float()},`
  - `distance_to_nest: float(),`
  - `visit_count: non_neg_integer(),`
  - `avg_food_quality: float(),`
  - `position: {non_neg_integer(), non_neg_integer()}`
  `}`
- [ ] 3.4.1.2.3 Define function `def to_tensor(features)` converts to Nx tensor
- [ ] 3.4.1.2.4 Define function `def from_tensor(tensor)` converts from tensor
- [ ] 3.4.1.2.5 Add normalization functions for each feature

### 3.4.1.3 Define Agent Parameters Structure

Create schema for evolvable agent parameters.

- [ ] 3.4.1.3.1 Create `lib/ant_colony/ml/agent_params.ex`
- [ ] 3.4.1.3.2 Add `defstruct` with fields:
  - `:aco_alpha` - pheromone importance (default: 1.0)
  - `:aco_beta` - heuristic importance (default: 2.0)
  - `:exploration_rate` - random exploration probability (default: 0.1)
  - `:pheromone_decay_rate` - evaporation rate (default: 0.05)
  - `:ml_weight` - influence of ML predictions (default: 0.5)
  - `:communication_radius` - proximity for sharing (default: 3)
- [ ] 3.4.1.3.3 Add `@type` specification
- [ ] 3.4.1.3.4 Add validation functions for parameter ranges
- [ ] 3.4.1.3.5 Document each parameter's effect on behavior

### 3.4.1.4 Define Generation Summary Structure

Create schema for generation-level KPIs.

- [ ] 3.4.1.4.1 Add to `lib/ant_colony/ml/generation_summary.ex`
- [ ] 3.4.1.4.2 Add `defstruct` with fields:
  - `:generation_id` - generation identifier
  - `:food_delivered_count` - total deliveries
  - `:total_food_quality` - sum of food levels
  - `:avg_trip_time` - average milliseconds per trip
  - `:avg_trip_efficiency` - avg(food_quality / trip_time)
  - `:success_rate` - deliveries / total trips
  - `:start_time` - generation start timestamp
  - `:end_time` - generation end timestamp
  - `:duration_ms` - generation duration
  - `:trained_model` - model state (if trained)
  - `:elite_agent_params` - list of best parameters
- [ ] 3.4.1.4.3 Add `@type` specification
- [ ] 3.4.1.4.4 Document struct in @moduledoc

---

## 3.4.2 Implement DataCollectorAgent

Create a Jido Agent to aggregate foraging data.

### 3.4.2.1 Create DataCollectorAgent Module

Set up the data collection agent.

- [ ] 3.4.2.1.1 Create `lib/ant_colony/agent/data_collector.ex`
- [ ] 3.4.2.1.2 Add `defmodule AntColony.Agent.DataCollector`
- [ ] 3.4.2.1.3 Add `use Jido.Agent` with appropriate options
- [ ] 3.4.2.1.4 Add comprehensive `@moduledoc`

### 3.4.2.2 Define DataCollector State

Define the collector's internal state.

- [ ] 3.4.2.2.1 Add State struct with fields:
  - `:foraging_records` - list of ForagingRecord
  - `:current_generation_id` - being tracked
  - `:record_count` - number of records
  - `:max_records` - limit (e.g., 10000)
- [ ] 3.4.2.2.2 Add `@type` specifications
- [ ] 3.4.2.2.3 Set default values

### 3.4.2.3 Subscribe to Foraging Events

Set up event subscriptions.

- [ ] 3.4.2.3.1 Subscribe to `{:food_delivered, ...}` events
- [ ] 3.4.2.3.2 Subscribe to `{:foraging_experience, ...}` events
- [ ] 3.4.2.3.3 Handle events in update/2 or handle_info
- [ ] 3.4.2.3.4 Filter by current_generation_id

### 3.4.2.4 Add Data Retrieval API

Create API for accessing collected data.

- [ ] 3.4.2.4.1 Define `def get_foraging_records(generation_id)` - returns list
- [ ] 3.4.2.4.2 Define `def get_training_data(generation_id)` - returns {features, labels}
- [ ] 3.4.2.4.3 Define `def clear_generation_data(generation_id)` - for reset
- [ ] 3.4.2.4.4 Define `def get_summary_stats(generation_id)` - KPIs

---

## 3.4.3 Implement TrainerAgent

Create a Jido Agent for Axon model training.

### 3.4.3.1 Create TrainerAgent Module

Set up the trainer agent.

- [ ] 3.4.3.1.1 Create `lib/ant_colony/agent/trainer.ex`
- [ ] 3.4.3.1.2 Add `defmodule AntColony.Agent.Trainer`
- [ ] 3.4.3.1.3 Add `use Jido.Agent` with appropriate options
- [ ] 3.4.3.1.4 Add comprehensive `@moduledoc`

### 3.4.3.2 Define TrainerAgent State

Define the trainer's internal state.

- [ ] 3.4.3.2.1 Add State struct with fields:
  - `:model_state` - current Axon model params
  - `:current_epoch` - training epoch
  - `:training_loss` - latest loss value
  - `:is_training` - boolean flag
  - `:target_epochs` - epochs per generation
  - `:generation_id` - current generation
- [ ] 3.4.3.2.2 Add `@type` specifications
- [ ] 3.4.3.2.3 Set default values

### 3.4.3.3 Implement Axon Model

Create the path prediction model.

- [ ] 3.4.3.3.1 Create `lib/ant_colony/ml/model.ex`
- [ ] 3.4.3.3.2 Define `def build_model(input_features)`
- [ ] 3.4.3.3.3 Implement architecture:
  ```elixir
  Axon.input("features", shape: {nil, 6})
  |> Axon.dense(32, activation: :relu)
  |> Axon.dropout(rate: 0.1)
  |> Axon.dense(16, activation: :relu)
  |> Axon.dense(1, activation: :sigmoid)
  ```
- [ ] 3.4.3.3.4 Add `def init_model()` - returns initial params
- [ ] 3.4.3.3.5 Add `def predict(model_state, features)` - inference
- [ ] 3.4.3.3.6 Add `def train(model_state, data)` - training loop

### 3.4.3.4 Implement Training Action

Create action to trigger model training.

- [ ] 3.4.3.4.1 Create `lib/ant_colony/actions/train_model_action.ex`
- [ ] 3.4.3.4.2 Add `use Jido.Action`
- [ ] 3.4.3.4.3 Define `run(params, context)`:
  - Fetch data from DataCollectorAgent
  - Call `Model.train(state.model_state, data)`
  - Update model_state in TrainerAgent
  - Return updated state

### 3.4.3.5 Add Training Status API

Create API for checking training status.

- [ ] 3.4.3.5.1 Define `def is_training()` - returns boolean
- [ ] 3.4.3.5.2 Define `def get_training_progress()` - returns {current, target} epochs
- [ ] 3.4.3.5.3 Define `def get_model_state()` - returns params and metrics
- [ ] 3.4.3.5.4 Define `def get_model_for_deployment()` - returns deployable params

---

## 3.4.4 Implement Generation Trigger Logic

Add refined trigger detection to ColonyIntelligenceAgent.

### 3.4.4.1 Implement Performance Plateau Detection

Detect when KPI growth stagnates.

- [ ] 3.4.4.1.1 Add to `lib/ant_colony/agent/colony_intelligence.ex`
- [ ] 3.4.4.1.2 Implement `def detect_plateau(state)` function:
  - Get last N food_delivered_count values (sliding window)
  - Calculate rate of change: (current - oldest) / oldest
  - Return `true` if rate < threshold (e.g., 0.05 = 5% growth)
- [ ] 3.4.4.1.3 Configure window size (e.g., 20 deliveries)
- [ ] 3.4.4.1.4 Add configurable plateau threshold

### 3.4.4.2 Add Training Completion Check

Monitor TrainerAgent status.

- [ ] 3.4.4.2.1 Implement `def training_complete?(state)` function
- [ ] 3.4.4.2.2 Call `TrainerAgent.get_training_progress()`
- [ ] 3.4.4.2.3 Return `true` if current_epoch >= target_epochs
- [ ] 3.4.4.2.4 Return `false` if training not started or in progress

### 3.4.4.3 Implement Manual Trigger Action

Add action for manual generation trigger (debugging).

- [ ] 3.4.4.3.1 Create `lib/ant_colony/actions/trigger_generation_action.ex`
- [ ] 3.4.4.3.2 Add `use Jido.Action`
- [ ] 3.4.4.3.3 Define `run(params, context)`:
  - Call `ColonyIntelligenceAgent.spawn_next_generation()`
  - Return `{:ok, %{triggered: true}}`
- [ ] 3.4.4.3.4 Add UI keybinding (e.g., 'g' to trigger)

### 3.4.4.4 Add Combined Trigger Check

Combine all trigger conditions.

- [ ] 3.4.4.4.1 Update `CheckGenerationTrigger` action
- [ ] 3.4.4.4.2 Implement `def should_trigger_next_generation?(state)`:
  - Check plateau detection
  - Check training completion
  - Check manual trigger flag
  - Return `true` if any condition met
- [ ] 3.4.4.4.3 Log which condition triggered
- [ ] 3.4.4.4.4 Include trigger reason in event

---

## 3.4.5 Implement Next Generation Protocol

Add evaluation, breeding, and spawning to ColonyIntelligenceAgent.

### 3.4.5.1 Implement Agent Evaluation

Rank agents by performance.

- [ ] 3.4.5.1.1 Add `def evaluate_generation(state)` function
- [ ] 3.4.5.1.2 Get all AntAgents and their performance:
  - Query each agent for food_delivered_count
  - Query each agent for total_trip_time
  - Calculate efficiency = food_quality / trip_time
- [ ] 3.4.5.1.3 Sort agents by efficiency (descending)
- [ ] 3.4.5.1.4 Return ranked list of `{ant_id, metrics}` tuples
- [ ] 3.4.5.1.5 Create GenerationSummary with KPIs

### 3.4.5.2 Implement Selection

Choose agents for breeding.

- [ ] 3.4.5.2.1 Add `def select_parents(ranked_agents)` function
- [ ] 3.4.5.2.2 Select top 20% as elite (direct copy)
- [ ] 3.4.5.2.3 Select middle 60% for breeding pool
- [ ] 3.4.5.2.4 Discard bottom 20%
- [ ] 3.4.5.2.5 Return `{elite, breeding_pool, discarded}`

### 3.4.5.3 Implement Crossover

Combine parameters from parents.

- [ ] 3.4.5.3.1 Add `def crossover_params(params1, params2)` function
- [ ] 3.4.5.3.2 For each parameter in AgentParams:
  - Numeric parameters: weighted average (alpha * p1 + (1-alpha) * p2)
  - Use random weight for each param
- [ ] 3.4.5.3.3 For neural network weights: average corresponding layers
- [ ] 3.4.5.3.4 Return new AgentParams struct

### 3.4.5.4 Implement Mutation

Introduce random variations.

- [ ] 3.4.5.4.1 Add `def mutate_params(params, mutation_rate)` function
- [ ] 3.4.5.4.2 For each parameter:
  - With probability mutation_rate: apply mutation
  - Numeric: add Gaussian noise (mean=0, std=0.1 * value)
  - Ensure params stay within valid ranges
- [ ] 3.4.5.4.3 For neural network: add noise to weights
- [ ] 3.4.5.4.4 Return mutated AgentParams

### 3.4.5.5 Implement Breeding Loop

Create next generation parameters.

- [ ] 3.4.5.5.1 Add `def breed_next_generation(elite, breeding_pool, target_count)` function
- [ ] 3.4.5.5.2 Start with elite (direct copy to next gen)
- [ ] 3.4.5.5.3 While count < target_count:
  - Select 2 parents from breeding_pool (weighted by fitness)
  - Call `crossover_params(parent1, parent2)`
  - Call `mutate_params(child, mutation_rate)`
  - Add child to next generation
- [ ] 3.4.5.5.4 Return list of AgentParams for next generation

### 3.4.5.6 Update SpawnNextGeneration Action

Integrate breeding into generation transition.

- [ ] 3.4.5.6.1 Modify `SpawnNextGeneration` action from Phase 1.9
- [ ] 3.4.5.6.2 Add breeding step before spawning:
  - Call `evaluate_generation(state)`
  - Call `breed_next_generation(elite, pool, ant_count)`
- [ ] 3.4.5.6.3 Spawn AntAgents with evolved params
- [ ] 3.4.5.6.4 Deploy trained model (if available)
- [ ] 3.4.5.6.5 Broadcast `{:generation_started, new_generation_id, evolved_params}`

---

## 3.4.6 UI ML Display

Add generational ML visualization to UI.

### 3.4.6.1 Extend UI State for ML Data

Add ML metrics to UI.

- [ ] 3.4.6.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.4.6.1.2 Add ML fields to UI struct:
  - `:model_epoch` - current training epoch
  - `:model_loss` - latest loss
  - `:kpi_history` - list of generation KPIs
  - `:training_progress` - {current, target} epochs
  - `:generation_transition` - notification flag
- [ ] 3.4.6.1.3 Set default values
- [ ] 3.4.6.1.4 Limit kpi_history size (e.g., 100 generations)

### 3.4.6.2 Handle ML Events

Process ML-related events.

- [ ] 3.4.6.2.1 Add update clause for `{:model_updated, model_state}`
- [ ] 3.4.6.2.2 Update UI ML fields from model_state
- [ ] 3.4.6.2.3 Add update clause for `{:training_progress, epoch, max}`
- [ ] 3.4.6.2.4 Add update clause for `{:generation_started, gen_id}`
- [ ] 3.4.6.2.5 Add update clause for `{:generation_ended, gen_id, metrics}`
- [ ] 3.4.6.2.6 Return `{:noreply, updated_state}`

### 3.4.6.3 Display Training Progress

Show training status in status bar.

- [ ] 3.4.6.3.1 Update status bar to include:
  - `"Training: #{current}/#{max} epochs"` when training
  - `"Loss: #{loss}"` when training complete
- [ ] 3.4.6.3.2 Use color coding for training status
- [ ] 3.4.6.3.3 Show spinner or progress bar during training

### 3.4.6.4 Add Historical KPI Graph

Display generation performance over time.

- [ ] 3.4.6.4.1 Create `draw_kpi_graph(canvas, kpi_history)` function
- [ ] 3.4.6.4.2 Extract food_delivered_count per generation
- [ ] 3.4.6.4.3 Normalize to fit available width
- [ ] 3.4.6.4.4 Draw sparkline using ASCII characters: `▁▂▃▄▅▆▇█`
- [ ] 3.4.6.4.5 Position at top or side of canvas
- [ ] 3.4.6.4.6 Handle empty history (show placeholder)

### 3.4.6.5 Add Generation Transition Indicator

Visual notification when generation changes.

- [ ] 3.4.6.5.1 Add `:generation_transition` flag to UI state
- [ ] 3.4.6.5.2 Set flag on `{:generation_started}` event
- [ ] 3.4.6.5.3 Display prominent message for 5 seconds
- [ ] 3.4.6.5.4 Format: `"=== GENERATION {gen_id} STARTED ==="`
- [ ] 3.4.6.5.5 Clear flag after display duration

### 3.4.6.6 Add Manual Trigger Button

Allow manual generation trigger via UI.

- [ ] 3.4.6.6.1 Add key binding: 'g' to trigger next generation
- [ ] 3.4.6.6.2 Add update clause for `%TermUI.Event.Key{key: "g"}`
- [ ] 3.4.6.6.3 Dispatch `TriggerGenerationAction` via Jido
- [ ] 3.4.6.6.4 Show feedback: "Manual generation trigger sent..."
- [ ] 3.4.6.6.5 Document in help text

---

## 3.4.7 Unit Tests for Generational ML

Test all generational ML functionality.

### 3.4.7.1 Test Data Structures

Verify ML data structures work correctly.

- [ ] 3.4.7.1.1 Create `test/ant_colony/ml/foraging_record_test.exs`
- [ ] 3.4.7.1.2 Add test: `test "ForagingRecord struct has correct fields"` - structure
- [ ] 3.4.7.1.3 Add test: `test "AgentParams validation works"` - validation
- [ ] 3.4.7.1.4 Add test: `test "GenerationSummary calculates KPIs correctly"` - KPIs

### 3.4.7.2 Test DataCollectorAgent

Verify data collection works.

- [ ] 3.4.7.2.1 Create `test/ant_colony/agent/data_collector_test.exs`
- [ ] 3.4.7.2.2 Add test: `test "subscribes to foraging events"` - subscription
- [ ] 3.4.7.2.3 Add test: `test "stores records by generation_id"` - filtering
- [ ] 3.4.7.2.4 Add test: `test "get_training_data returns correct format"` - format
- [ ] 3.4.7.2.5 Add test: `test "clear_generation_data removes records"` - cleanup

### 3.4.7.3 Test TrainerAgent

Verify training works.

- [ ] 3.4.7.3.1 Create `test/ant_colony/agent/trainer_test.exs`
- [ ] 3.4.7.3.2 Add test: `test "initializes with default model"` - init
- [ ] 3.4.7.3.3 Add test: `test "train updates model parameters"` - training
- [ ] 3.4.7.3.4 Add test: `test "predict returns valid scores"` - prediction
- [ ] 3.4.7.3.5 Add test: `test "is_training returns correct status"` - status

### 3.4.7.4 Test Generation Trigger Logic

Verify trigger detection works.

- [ ] 3.4.7.4.1 Add test: `test "detect_plateau returns true for stagnant KPIs"` - detection
- [ ] 3.4.7.4.2 Add test: `test "detect_plateau returns false for growing KPIs"` - growth
- [ ] 3.4.7.4.3 Add test: `test "training_complete returns true when epoch >= target"` - complete
- [ ] 3.4.7.4.4 Add test: `test "manual trigger action dispatches spawn"` - manual

### 3.4.7.5 Test Breeding Functions

Verify evolution works correctly.

- [ ] 3.4.7.5.1 Add test: `test "evaluation ranks agents correctly"` - ranking
- [ ] 3.4.7.5.2 Add test: `test "selection selects elite and breeding pool"` - selection
- [ ] 3.4.7.5.3 Add test: `test "crossover averages parent parameters"` - crossover
- [ ] 3.4.7.5.4 Add test: `test "mutation adds noise to parameters"` - mutation
- [ ] 3.4.7.5.5 Add test: `test "breeding creates target number of children"` - count
- [ ] 3.4.7.5.6 Add test: `test "evolved params stay within valid ranges"` - constraints

### 3.4.7.6 Test Next Generation Protocol

Verify complete generation transition.

- [ ] 3.4.7.6.1 Add test: `test "spawn_next_generation evaluates agents"` - evaluation
- [ ] 3.4.7.6.2 Add test: `test "spawn_next_generation breeds new params"` - breeding
- [ ] 3.4.7.6.3 Add test: `test "spawn_next_generation terminates old agents"` - cleanup
- [ ] 3.4.7.6.4 Add test: `test "spawn_next_generation spawns new agents"` - spawning
- [ ] 3.4.7.6.5 Add test: `test "spawn_next_generation increments generation_id"` - counter
- [ ] 3.4.7.6.6 Add test: `test "spawn_next_generation broadcasts events"` - events

### 3.4.7.7 Test UI ML Display

Verify UI shows ML information.

- [ ] 3.4.7.7.1 Add test: `test "UI receives model update events"` - events
- [ ] 3.4.7.7.2 Add test: `test "UI displays training progress"` - progress
- [ ] 3.4.7.7.3 Add test: `test "UI displays KPI graph"` - graph
- [ ] 3.4.7.7.4 Add test: `test "UI shows generation transition"` - transition
- [ ] 3.4.7.7.5 Add test: `test "manual trigger key sends action"` - trigger

---

## 3.4.8 Phase 3.4 Integration Tests

End-to-end tests for generational ML.

### 3.4.8.1 Complete Generation Lifecycle Test

Verify full generation transition.

- [ ] 3.4.8.1.1 Create `test/ant_colony/integration/generational_ml_integration_test.exs`
- [ ] 3.4.8.1.2 Add test: `test "complete generation cycle works"` - end-to-end
- [ ] 3.4.8.1.3 Add test: `test "generation improves over previous"` - improvement
- [ ] 3.4.8.1.4 Add test: `test "multiple generations cycle correctly"` - multi-gen

### 3.4.8.2 Breeding Effectiveness Test

Verify breeding produces better parameters.

- [ ] 3.4.8.2.1 Add test: `test "child params inherit from parents"` - inheritance
- [ ] 3.4.8.2.2 Add test: `test "mutation introduces beneficial variation"` - mutation
- [ ] 3.4.8.2.3 Add test: `test "evolution converges to better strategies"` - convergence
- [ ] 3.4.8.2.4 Add test: `test "breeding doesn't produce invalid params"` - validity

### 3.4.8.3 KPI Tracking Test

Verify KPIs are tracked correctly.

- [ ] 3.4.8.3.1 Add test: `test "KPIs calculated correctly per generation"` - calculation
- [ ] 3.4.8.3.2 Add test: `test "kpi_history stores all generations"` - storage
- [ ] 3.4.8.3.3 Add test: `test "plateau detection triggers generation"` - trigger
- [ ] 3.4.8.3.4 Add test: `test "KPI graph renders correctly"` - visualization

### 3.4.8.4 Model Deployment Test

Verify model is deployed to new generation.

- [ ] 3.4.8.4.1 Add test: `test "trained model deployed to next generation"` - deployment
- [ ] 3.4.8.4.2 Add test: `test "new agents use deployed model"` - usage
- [ ] 3.4.8.4.3 Add test: `test "model improves foraging efficiency"` - effectiveness

---

## Phase 3.4 Success Criteria

1. **Data Structures**: Foraging records, agent params, generation summary defined ✅
2. **DataCollectorAgent**: Aggregates trip data per generation ✅
3. **TrainerAgent**: Trains Axon model per generation ✅
4. **Generation Trigger**: Plateau detection and training completion work ✅
5. **Manual Trigger**: UI button triggers generation transition ✅
6. **Evaluation**: Agents ranked by performance metrics ✅
7. **Breeding**: Selection, crossover, mutation produce valid params ✅
8. **Next Generation Protocol**: Complete transition works end-to-end ✅
9. **UI Display**: Training progress, KPI graph, transitions visible ✅
10. **Tests**: All unit and integration tests pass ✅

## Phase 3.4 Critical Files

**New Files:**
- `lib/ant_colony/ml/foraging_record.ex` - Foraging trip data structure
- `lib/ant_colony/ml/features.ex` - Feature vector operations
- `lib/ant_colony/ml/agent_params.ex` - Evolvable agent parameters
- `lib/ant_colony/ml/generation_summary.ex` - Generation KPIs
- `lib/ant_colony/ml/model.ex` - Axon model definition
- `lib/ant_colony/agent/data_collector.ex` - Data collection Jido Agent
- `lib/ant_colony/agent/trainer.ex` - Training Jido Agent
- `lib/ant_colony/actions/train_model_action.ex` - Training action
- `lib/ant_colony/actions/trigger_generation_action.ex` - Manual trigger
- `test/ant_colony/ml/*` - ML unit tests
- `test/ant_colony/agent/*_test.exs` - Agent tests
- `test/ant_colony/integration/generational_ml_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/agent/colony_intelligence.ex` - Add breeding, trigger logic
- `lib/ant_colony/actions/spawn_next_generation.ex` - Integrate breeding
- `lib/ant_colony/ui.ex` - Add ML display and manual trigger

---

## Next Phase

Proceed to [Phase 3.5: UI Controls and Polish](./05-ui-controls-polish.md) to implement user controls, KPI visualization, and UI refinements.
