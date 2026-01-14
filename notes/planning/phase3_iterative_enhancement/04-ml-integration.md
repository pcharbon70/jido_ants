# Phase 3.4: Machine Learning Integration

Integrate machine learning capabilities using Axon to enable ants to learn and adapt their search patterns over time. This cycle adds a neural network model that predicts path quality based on environmental features, allowing the colony to optimize foraging beyond static ACO heuristics.

## Architecture

```
ML Learning Pipeline
├── Data Collection:
│   ├── Foraging trip logs
│   │   ├── Path: sequence of positions
│   │   ├── Time taken
│   │   ├── Energy expended
│   │   └── Food quality found
│   └── Local snapshots
│       ├── Pheromone levels
│       ├── Position features
│       └── Success outcome
│
├── Model (Axon):
│   ├── Input tensor: [pheromone_level, gradient, distance_to_nest, visit_count, avg_food_quality]
│   ├── Architecture:
│   │   Input(5) → Dense(32, relu) → Dense(16, relu) → Dense(1, sigmoid)
│   └── Output: Path quality score (0.0-1.0)
│
├── Trainer Agent:
│   ├── Collects data from returning ants
│   ├── Trains model periodically
│   └── Broadcasts updated model parameters
│
├── Actions:
│   ├── CollectLearningDataAction - Record trip data
│   ├── UpdateModelAction - Trigger model training
│   └── PredictPathQualityAction - Query model for decision
│
└── UI Display:
    ├── Learning epoch counter
    ├── Model accuracy/metrics
    └── Foraging efficiency chart
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Data Collection | Gather foraging trip and local environment data |
| Axon Model | Neural network for path quality prediction |
| Trainer Agent | Central coordinator for ML training |
| CollectLearningDataAction | Record data at nest |
| PredictPathQualityAction | Use model for movement decisions |
| UI ML Display | Show learning progress and metrics |

---

## 3.4.1 Define ML Data Structures

Establish the data structures for machine learning.

### 3.4.1.1 Define Training Record Structure

Create schema for foraging trip records.

- [ ] 3.4.1.1.1 Create `lib/ant_colony/ml/training_record.ex`
- [ ] 3.4.1.1.2 Add `defstruct` with fields:
  - `:ant_id` - ant identifier
  - `:path` - list of `{x, y}` positions
  - `:duration_ms` - time taken for trip
  - `:energy_used` - energy expended
  - `:food_found` - boolean
  - `:food_quality` - food level (1-5) if found
  - `:timestamp` - when trip completed
- [ ] 3.4.1.1.3 Add `@type` specification
- [ ] 3.4.1.1.4 Document struct in @moduledoc

### 3.4.1.2 Define Feature Vector Structure

Create schema for model input features.

- [ ] 3.4.1.2.1 Create `lib/ant_colony/ml/features.ex`
- [ ] 3.4.1.2.2 Define `@type feature_vector :: %{
  pheromone_level: float(),
  pheromone_gradient: float(),
  distance_to_nest: float(),
  visit_count: non_neg_integer(),
  avg_food_quality: float()
}`
- [ ] 3.4.1.2.3 Define function `def to_tensor(features)` converts to Nx tensor
- [ ] 3.4.1.2.4 Define function `def from_tensor(tensor)` converts from tensor
- [ ] 3.4.1.2.5 Add normalization functions

### 3.4.1.3 Define Model State Structure

Create schema for model parameters and metadata.

- [ ] 3.4.1.3.1 Create `lib/ant_colony/ml/model_state.ex`
- [ ] 3.4.1.3.2 Add `defstruct` with fields:
  - `:model_params` - Axon model parameters
  - `:epoch` - current training epoch
  - `:training_loss` - latest loss value
  - `:accuracy` - model accuracy metric
  - `:last_updated` - timestamp of last training
  - `:sample_count` - number of training samples
- [ ] 3.4.1.3.3 Add `@type` specification
- [ ] 3.4.1.3.4 Document struct in @moduledoc

### 3.4.1.4 Define ML Constants

Establish constants for ML configuration.

- [ ] 3.4.1.4.1 Create `lib/ant_colony/ml/config.ex`
- [ ] 3.4.1.4.2 Define `@training_interval 10` (trips between training)
- [ ] 3.4.1.4.3 Define `@batch_size 32` (training batch size)
- [ ] 3.4.1.4.4 Define `@learning_rate 0.001` (optimizer learning rate)
- [ ] 3.4.1.4.5 Define `@epochs_per_training 5` (epochs per update)
- [ ] 3.4.1.4.6 Define `@max_samples 1000` (max training samples to keep)
- [ ] 3.4.1.4.7 Document constants in @moduledoc

---

## 3.4.2 Implement Axon Model

Create the neural network model for path prediction.

### 3.4.2.1 Define Model Architecture

Create the Axon model structure.

- [ ] 3.4.2.1.1 Create `lib/ant_colony/ml/model.ex`
- [ ] 3.4.2.1.2 Define `def build_model(input_features)`
- [ ] 3.4.2.1.3 Implement architecture:
  ```elixir
  Axon.input("features", shape: {nil, 5})
  |> Axon.dense(32, activation: :relu)
  |> Axon.dropout(rate: 0.1)
  |> Axon.dense(16, activation: :relu)
  |> Axon.dense(1, activation: :sigmoid)
  ```
- [ ] 3.4.2.1.4 Document architecture choices in @moduledoc
- [ ] 3.4.2.1.5 Add input feature descriptions

### 3.4.2.2 Initialize Model Parameters

Create initial model state.

- [ ] 3.4.2.2.1 Define `def init_model()` function
- [ ] 3.4.2.2.2 Build model with `build_model(5)`
- [ ] 3.4.2.2.3 Initialize with `Axon.init()`
- [ ] 3.4.2.2.4 Create initial `%ModelState{}` with params
- [ ] 3.4.2.2.5 Return `{:ok, model_state}`

### 3.4.2.3 Add Prediction Function

Create inference function for the model.

- [ ] 3.4.2.3.1 Define `def predict(model_state, features)`
- [ ] 3.4.2.3.2 Convert features to tensor
- [ ] 3.4.2.3.3 Run model inference with `Axon.predict()`
- [ ] 3.4.2.3.4 Extract score from output tensor
- [ ] 3.4.2.3.5 Return float score (0.0-1.0)

### 3.4.2.4 Add Training Function

Create model training function.

- [ ] 3.4.2.4.1 Define `def train(model_state, training_data)`
- [ ] 3.4.2.4.2 Extract features and labels from training_data
- [ ] 3.4.2.4.3 Convert to batched tensors
- [ ] 3.4.2.4.4 Run training loop:
  ```elixir
  model
  |> Axen.Loop.trainer(model_state, :mean_squared_error, Axen.Optimizers.adam(@learning_rate))
  |> Axen.Loop.run(training_data, epochs: @epochs_per_training)
  ```
- [ ] 3.4.2.4.5 Extract updated params and metrics
- [ ] 3.4.2.4.6 Return updated `%ModelState{}`

---

## 3.4.3 Implement Trainer Agent

Create a GenServer to coordinate ML training.

### 3.4.3.1 Create Trainer Module

Set up the trainer GenServer.

- [ ] 3.4.3.1.1 Create `lib/ant_colony/ml/trainer.ex`
- [ ] 3.4.3.1.2 Add `defmodule AntColony.ML.Trainer`
- [ ] 3.4.3.1.3 Add `use GenServer`
- [ ] 3.4.3.1.4 Add comprehensive `@moduledoc`

### 3.4.3.2 Define Trainer State

Define the trainer's internal state.

- [ ] 3.4.3.2.1 Add `defstruct` with fields:
  - `:model_state` - current model parameters and metrics
  - `:training_data` - list of training records
  - `:pending_count` - records since last training
  - `:subscribers` - pids to notify on model updates
- [ ] 3.4.3.2.2 Set `@max_samples` limit
- [ ] 3.4.3.2.3 Add `@type` specifications

### 3.4.3.3 Implement init/1 Callback

Initialize the trainer.

- [ ] 3.4.3.3.1 Define `def init(opts)` function
- [ ] 3.4.3.3.2 Initialize empty training data list
- [ ] 3.4.3.3.3 Create initial model with `Model.init_model()`
- [ ] 3.4.3.3.4 Subscribe to `"ml_events"` PubSub topic
- [ ] 3.4.3.3.5 Return `{:ok, initial_state}`

### 3.4.3.4 Implement add_training_data API

Add new training data to the trainer.

- [ ] 3.4.3.4.1 Define client function: `def add_training_data(record)`
- [ ] 3.4.3.4.2 Implement as `GenServer.cast(__MODULE__, {:add_data, record})`
- [ ] 3.4.3.4.3 Add handle_cast for `:add_data`
- [ ] 3.4.3.4.4 Add record to training data list
- [ ] 3.4.3.4.5 Trim to `@max_samples` if exceeded (keep most recent)
- [ ] 3.4.3.4.6 Increment `pending_count`
- [ ] 3.4.3.4.7 If `pending_count >= @training_interval`:
  - Trigger training via `handle_info(:train_model)`
- [ ] 3.4.3.4.8 Return `{:noreply, updated_state}`

### 3.4.3.5 Implement Model Training

Execute the training process.

- [ ] 3.4.3.5.1 Add handle_info for `:train_model`
- [ ] 3.4.3.5.2 Check if enough data available (min 10 samples)
- [ ] 3.4.3.5.3 Prepare training data:
  - Convert records to feature tensors
  - Create labels (success score based on food quality/time)
- [ ] 3.4.3.5.4 Call `Model.train(state.model_state, prepared_data)`
- [ ] 3.4.3.5.5 Update `model_state` with new params
- [ ] 3.4.3.5.6 Reset `pending_count` to 0
- [ ] 3.4.3.5.7 Publish `{:model_updated, new_model_state}` to subscribers
- [ ] 3.4.3.5.8 Return `{:noreply, updated_state}`

### 3.4.3.6 Implement predict API

Create API for model prediction.

- [ ] 3.4.3.6.1 Define client function: `def predict(features)`
- [ ] 3.4.3.6.2 Implement as `GenServer.call(__MODULE__, {:predict, features})`
- [ ] 3.4.3.6.3 Add handle_call for `:predict`
- [ ] 3.4.3.6.4 Call `Model.predict(state.model_state, features)`
- [ ] 3.4.3.6.5 Return `{:reply, score, state}`

### 3.4.3.7 Implement get_model_state API

Create API for retrieving model metadata.

- [ ] 3.4.3.7.1 Define client function: `def get_model_state()`
- [ ] 3.4.3.7.2 Implement as `GenServer.call(__MODULE__, :get_model_state)`
- [ ] 3.4.3.7.3 Add handle_call for `:get_model_state`
- [ ] 3.4.3.7.4 Return map with epoch, loss, accuracy, sample_count
- [ ] 3.4.3.7.5 Return `{:reply, metadata, state}`

---

## 3.4.4 Implement CollectLearningDataAction

Create action to record foraging trip data.

### 3.4.4.1 Create CollectLearningDataAction Module

Set up the action module.

- [ ] 3.4.4.1.1 Create `lib/ant_colony/actions/collect_learning_data_action.ex`
- [ ] 3.4.4.1.2 Add `defmodule AntColony.Actions.CollectLearningDataAction`
- [ ] 3.4.4.1.3 Add `use Jido.Action`
- [ ] 3.4.4.1.4 Add comprehensive `@moduledoc`

### 3.4.4.2 Define Action Schema

Specify parameters.

- [ ] 3.4.4.2.1 Define `@param_schema` with fields:
  - `:trip_data` - type: `:map`, required: true
- [ ] 3.4.4.2.2 Add validation for trip_data structure

### 3.4.4.3 Implement run/2 Function

Execute data collection.

- [ ] 3.4.4.3.1 Define `def run(params, context)` function
- [ ] 3.4.4.3.2 Extract `trip_data` from params
- [ ] 3.4.4.3.3 Build `%TrainingRecord{}` from trip_data and agent state
- [ ] 3.4.4.3.4 Call `Trainer.add_training_data(record)`
- [ ] 3.4.4.3.5 Return `{:ok, context.state}`

---

## 3.4.5 Implement PredictPathQualityAction

Create action to use model for movement decisions.

### 3.4.5.1 Create PredictPathQualityAction Module

Set up the action module.

- [ ] 3.4.5.1.1 Create `lib/ant_colony/actions/predict_path_quality_action.ex`
- [ ] 3.4.5.1.2 Add `defmodule AntColony.Actions.PredictPathQualityAction`
- [ ] 3.4.5.1.3 Add `use Jido.Action`
- [ ] 3.4.5.1.4 Add comprehensive `@moduledoc`

### 3.4.5.2 Define Action Schema

Specify parameters.

- [ ] 3.4.5.2.1 Define `@param_schema` with fields:
  - `:positions` - type: `{:list, :tuple}`, required: true
  - `:current_position` - type: `:tuple`, default: `nil`
- [ ] 3.4.5.2.2 Add validation

### 3.4.5.3 Implement run/2 Function

Execute prediction.

- [ ] 3.4.5.3.1 Define `def run(params, context)` function
- [ ] 3.4.5.3.2 Extract positions and current position
- [ ] 3.4.5.3.3 For each position, build features:
  - Get pheromone level from Plane
  - Calculate pheromone gradient
  - Calculate distance to nest
  - Get visit count from historical data
  - Get avg food quality from historical data
- [ ] 3.4.5.3.4 Call `Trainer.predict(features)` for each position
- [ ] 3.4.5.3.5 Return `{:ok, %{predictions: predictions}, context.state}`

---

## 3.4.6 Integrate ML with Movement Decisions

Enhance MoveAction to use model predictions.

### 3.4.6.1 Add ML Influence Option

Extend MoveAction with ML option.

- [ ] 3.4.6.1.1 Open `lib/ant_colony/actions/move_action.ex`
- [ ] 3.4.6.1.2 Add `:use_ml` option to param schema (default: `true`)
- [ ] 3.4.6.1.3 In run/2, when deciding direction:

### 3.4.6.2 Combine ACO and ML Scores

Merge pheromone and ML predictions.

- [ ] 3.4.6.2.1 Get ACO probabilities from pheromones
- [ ] 3.4.6.2.2 Get ML scores from `PredictPathQualityAction`
- [ ] 3.4.6.2.3 Combine scores: `combined = aco_score * 0.5 + ml_score * 0.5`
- [ ] 3.4.6.2.4 Normalize combined probabilities
- [ ] 3.4.6.2.5 Select direction using weighted random

### 3.4.6.3 Add Model Update Notification

Notify ants of model updates.

- [ ] 3.4.6.3.1 Subscribe to `Trainer` model updates
- [ ] 3.4.6.3.2 On `:model_updated` event:
  - Update agent's cached prediction function
  - Log model improvement
- [ ] 3.4.6.3.3 Store model version in agent state

---

## 3.4.7 UI ML Display

Add ML progress visualization to UI.

### 3.4.7.1 Extend UI State for ML Data

Add ML metrics to UI.

- [ ] 3.4.7.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.4.7.1.2 Add ML fields to UI struct:
  - `:model_epoch` - current training epoch
  - `:model_accuracy` - latest accuracy
  - `:model_loss` - latest loss
  - `:sample_count` - training samples
- [ ] 3.4.7.1.3 Set default values

### 3.4.7.2 Handle Model Update Events

Process model update notifications.

- [ ] 3.4.7.2.1 Add update clause for `{:model_updated, model_state}`
- [ ] 3.4.7.2.2 Update UI ML fields from model_state
- [ ] 3.4.7.2.3 Return `{:noreply, updated_state}`

### 3.4.7.3 Display ML Metrics in Status Bar

Show training progress.

- [ ] 3.4.7.3.1 Update status_bar to include ML info:
  - `"Epoch: #{epoch} | Loss: #{loss} | Acc: #{accuracy}"`
- [ ] 3.4.7.3.2 Format to fit available space
- [ ] 3.4.7.3.3 Use color coding for metrics

### 3.4.7.4 Add Foraging Efficiency Chart (Optional)

Display sparkline of food collection over time.

- [ ] 3.4.7.4.1 Add `:efficiency_history` field to UI state
  - Type: list of `{timestamp, food_collected}`
  - Max length: 50
- [ ] 3.4.7.4.2 Update history when food collected
- [ ] 3.4.7.4.3 Render using `TermUI.Widget.Sparkline` or custom
- [ ] 3.4.7.4.4 Display in corner of UI

---

## 3.4.8 Unit Tests for ML Integration

Test all ML-related functionality.

### 3.4.8.1 Test Data Structures

Verify ML data structures work correctly.

- [ ] 3.4.8.1.1 Create `test/ant_colony/ml/training_record_test.exs`
- [ ] 3.4.8.1.2 Add test: `test "TrainingRecord struct has correct fields"` - structure
- [ ] 3.4.8.1.3 Add test: `test "feature vector conversion works"` - conversion
- [ ] 3.4.8.1.4 Add test: `test "normalization functions work"` - normalization

### 3.4.8.2 Test Axon Model

Verify model structure and inference.

- [ ] 3.4.8.2.1 Create `test/ant_colony/ml/model_test.exs`
- [ ] 3.4.8.2.2 Add test: `test "build_model creates valid architecture"` - build
- [ ] 3.4.8.2.3 Add test: `test "init_model initializes parameters"` - init
- [ ] 3.4.8.2.4 Add test: `test "predict returns score in valid range"` - prediction
- [ ] 3.4.8.2.5 Add test: `test "train updates model parameters"` - training

### 3.4.8.3 Test Trainer Agent

Verify trainer coordination works.

- [ ] 3.4.8.3.1 Create `test/ant_colony/ml/trainer_test.exs`
- [ ] 3.4.8.3.2 Add test: `test "trainer starts with initial model"` - start
- [ ] 3.4.8.3.3 Add test: `test "add_training_data stores records"` - storage
- [ ] 3.4.8.3.4 Add test: `test "triggers training after interval"` - trigger
- [ ] 3.4.8.3.5 Add test: `test "predict returns model score"` - prediction
- [ ] 3.4.8.3.6 Add test: `test "get_model_state returns metadata"` - metadata

### 3.4.8.4 Test CollectLearningDataAction

Verify data collection works.

- [ ] 3.4.8.4.1 Create `test/ant_colony/actions/collect_learning_data_action_test.exs`
- [ ] 3.4.8.4.2 Add test: `test "run creates training record"` - record creation
- [ ] 3.4.8.4.3 Add test: `test "run sends data to trainer"` - trainer call
- [ ] 3.4.8.4.4 Add test: `test "run validates trip_data"` - validation

### 3.4.8.5 Test PredictPathQualityAction

Verify prediction action works.

- [ ] 3.4.8.5.1 Create `test/ant_colony/actions/predict_path_quality_action_test.exs`
- [ ] 3.4.8.5.2 Add test: `test "run returns predictions for positions"` - predictions
- [ ] 3.4.8.5.3 Add test: `test "run builds correct feature vectors"` - features
- [ ] 3.4.8.5.4 Add test: `test "run handles missing trainer"` - error handling

### 3.4.8.6 Test ML Integration with Movement

Verify ML influences movement correctly.

- [ ] 3.4.8.6.1 Add test: `test "MoveAction uses ML when enabled"` - integration
- [ ] 3.4.8.6.2 Add test: `test "combined scores normalize correctly"` - combination
- [ ] 3.4.8.6.3 Add test: `test "ML scores improve with training"` - improvement

### 3.4.8.7 Test UI ML Display

Verify UI shows ML information.

- [ ] 3.4.8.7.1 Add test: `test "UI receives model update events"` - events
- [ ] 3.4.8.7.2 Add test: `test "UI displays ML metrics"` - display
- [ ] 3.4.8.7.3 Add test: `test "efficiency chart updates"` - chart

---

## 3.4.9 Phase 3.4 Integration Tests

End-to-end tests for ML integration.

### 3.4.9.1 Learning Cycle Test

Verify complete learning pipeline.

- [ ] 3.4.9.1.1 Create `test/ant_colony/integration/ml_integration_test.exs`
- [ ] 3.4.9.1.2 Add test: `test "complete learning cycle works"` - end-to-end
- [ ] 3.4.9.1.3 Add test: `test "model improves over time"` - improvement
- [ ] 3.4.9.1.4 Add test: `test "predictions influence ant movement"` - behavior

### 3.4.9.2 Model Performance Test

Verify model accuracy improves.

- [ ] 3.4.9.2.1 Add test: `test "model loss decreases with training"` - loss
- [ ] 3.4.9.2.2 Add test: `test "foraging efficiency improves"` - efficiency
- [ ] 3.4.9.2.3 Add test: `test "ants find food faster with ML"` - speed

### 3.4.9.3 ML vs ACO Comparison

Compare ML-enhanced vs baseline ACO.

- [ ] 3.4.9.3.1 Add test: `test "ML+ACO outperforms ACO alone"` - comparison
- [ ] 3.4.9.3.2 Add test: `test "colony adapts to environment changes"` - adaptation
- [ ] 3.4.9.3.3 Add test: `test "model doesn't overfit"` - generalization

---

## Phase 3.4 Success Criteria

1. **Data Structures**: Training records and features defined ✅
2. **Axon Model**: Path prediction model created ✅
3. **Trainer Agent**: Coordinates training and predictions ✅
4. **CollectLearningDataAction**: Records trip data ✅
5. **PredictPathQualityAction**: Returns model predictions ✅
6. **Movement Integration**: ML scores influence decisions ✅
7. **UI Display**: ML metrics visible ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 3.4 Critical Files

**New Files:**
- `lib/ant_colony/ml/training_record.ex` - Training data structure
- `lib/ant_colony/ml/features.ex` - Feature vector operations
- `lib/ant_colony/ml/model_state.ex` - Model metadata
- `lib/ant_colony/ml/config.ex` - ML configuration constants
- `lib/ant_colony/ml/model.ex` - Axon model definition
- `lib/ant_colony/ml/trainer.ex` - Trainer GenServer
- `lib/ant_colony/actions/collect_learning_data_action.ex` - Data collection
- `lib/ant_colony/actions/predict_path_quality_action.ex` - Prediction
- `test/ant_colony/ml/*` - ML unit tests
- `test/ant_colony/actions/*_test.exs` - Action tests
- `test/ant_colony/integration/ml_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/actions/move_action.ex` - Integrate ML predictions
- `lib/ant_colony/ui.ex` - Add ML display

---

## Next Phase

Proceed to [Phase 3.5: UI Controls and Polish](./05-ui-controls-polish.md) to implement user controls and UI refinements.
