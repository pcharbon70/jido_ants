# Phase 8: Machine Learning Integration

This phase integrates machine learning capabilities using Axon and Bumblebee. The system collects foraging data, trains models to predict path quality, and uses these predictions to optimize ant search patterns. This moves beyond static ACO parameters toward adaptive, learned behavior.

---

## 8.1 Data Collection Setup

Implement the infrastructure for collecting foraging trip data.

### 8.1.1 Foraging Trip Schema
- [ ] **Task 8.1.1** Define the foraging trip data structure.

- [ ] 8.1.1.1 Create `lib/jido_ants/ml/foraging_trip.ex`
- [ ] 8.1.1.2 Define the trip schema:
  ```elixir
  defmodule JidoAnts.ML.ForagingTrip do
    defstruct [
      :ant_id,
      :start_time,
      :end_time,
      :path_taken,
      :food_found,
      :food_level,
      :path_length,
      :energy_consumed,
      :pheromones_encountered
    ]

    @type t :: %__MODULE__{
      ant_id: String.t(),
      start_time: DateTime.t(),
      end_time: DateTime.t(),
      path_taken: [Position.t()],
      food_found: boolean(),
      food_level: 1..5 | nil,
      path_length: non_neg_integer(),
      energy_consumed: non_neg_integer(),
      pheromones_encountered: %{Position.t() => float()}
    }
  end
  ```
- [ ] 8.1.1.3 Add typespec for trip record
- [ ] 8.1.1.4 Write unit tests for trip struct

### 8.1.2 DataCollector Module
- [ ] **Task 8.1.2** Create the data collection service.

- [ ] 8.1.2.1 Create `lib/jido_ants/ml/data_collector.ex` with module documentation
- [ ] 8.1.2.2 Add `use GenServer`
- [ ] 8.1.2.3 Define state:
  ```elixir
  @type state :: %{
    trips: [ForagingTrip.t()],
    max_trips: pos_integer(),
    export_path: String.t() | nil
  }
  ```
- [ ] 8.1.2.4 Implement `start_link/1` with options
- [ ] 8.1.2.5 Implement `init/1` initializing empty trip list

### 8.1.3 Trip Recording
- [ ] **Task 8.1.3** Implement trip recording API.

- [ ] 8.1.3.1 Implement `start_trip/2` recording trip start:
  ```elixir
  def start_trip(collector \\ __MODULE__, ant_id, initial_position) do
    GenServer.call(collector, {:start_trip, ant_id, initial_position})
  end
  ```
- [ ] 8.1.3.2 Implement `record_position/3` during trip
- [ ] 8.1.3.3 Implement `record_pheromones/3` for pheromone encounters
- [ ] 8.1.3.4 Implement `complete_trip/2` when ant returns:
  ```elixir
  def complete_trip(collector \\ __MODULE__, ant_id, result_map) do
    GenServer.call(collector, {:complete_trip, ant_id, result_map})
  end
  ```
- [ ] 8.1.3.5 Store completed trips in state
- [ ] 8.1.3.6 Enforce max_trips limit (rotate old trips)
- [ ] 8.1.3.7 Write unit tests for trip recording

### 8.1.4 Data Export
- [ ] **Task 8.1.4** Implement data export for training.

- [ ] 8.1.4.1 Implement `export_trips/1` returning all trip data
- [ ] 8.1.4.2 Implement `export_to_csv/2` writing to CSV file
- [ ] 8.1.4.3 Format trip data as Nx.Tensor for ML training
- [ ] 8.1.4.4 Implement `get_training_data/1` returning feature tensors
- [ ] 8.1.4.5 Implement `get_labels/1` returning target values
- [ ] 8.1.4.6 Write unit tests for data export

**Unit Tests for Section 8.1:**
- Test ForagingTrip struct created with valid fields
- Test DataCollector starts with empty state
- Test `start_trip/3` creates new trip record
- Test `record_position/3` updates trip path
- Test `complete_trip/2` finalizes trip
- Test `export_trips/1` returns all collected trips
- Test `get_training_data/1` returns Nx.Tensor
- Test `get_labels/1` returns target tensor

---

## 8.2 Axon Model Definition

Define the neural network model for path quality prediction.

### 8.2.1 PathQualityModel Module
- [ ] **Task 8.2.1** Create the Axon model definition.

- [ ] 8.2.1.1 Create `lib/jido_ants/ml/path_quality_model.ex`
- [ ] 8.2.1.2 Define input features:
  ```elixir
  @input_features [
    :current_x,
    :current_y,
    :pheromone_north,
    :pheromone_south,
    :pheromone_east,
    :pheromone_west,
    :distance_to_nest,
    :times_visited,
    :avg_food_quality_nearby
  ]
  ```
- [ ] 8.2.1.3 Define model architecture:
  ```elixir
  def model do
    Axon.input("input", shape: {nil, length(@input_features)})
    |> Axon.dense(16, activation: :relu)
    |> Axon.dense(8, activation: :relu)
    |> Axon.dense(1, activation: :sigmoid)
  end
  ```
- [ ] 8.2.1.4 Output: probability of finding food (0-1)
- [ ] 8.2.1.5 Add model documentation

### 8.2.2 Model Parameters
- [ ] **Task 8.2.2** Configure model hyperparameters.

- [ ] 8.2.2.1 Define `@learning_rate 0.001`
- [ ] 8.2.2.2 Define `@epochs 50`
- [ ] 8.2.2.3 Define `@batch_size 32`
- [ ] 8.2.2.4 Make parameters configurable
- [ ] 8.2.2.5 Add validation split ratio (e.g., 0.8)
- [ ] 8.2.2.6 Write unit tests for parameter configuration

### 8.2.3 Model Compilation
- [ ] **Task 8.2.3** Implement model compilation with Axon.

- [ ] 8.2.3.1 Implement `build_model/0` returning compiled model
- [ ] 8.2.3.2 Use `Axon.compile/3` with optimizer:
  ```elixir
  def build_model do
    model()
    |> Axon.compile(optimizer: Adam(learning_rate: @learning_rate))
  end
  ```
- [ ] 8.2.3.3 Initialize model with random weights
- [ ] 8.2.3.4 Return model state and parameters
- [ ] 8.2.3.5 Write unit tests for model compilation

**Unit Tests for Section 8.2:**
- Test model definition has correct input shape
- Test model has correct number of layers
- Test model output shape is correct
- Test `build_model/0` returns compiled model
- Test model parameters configurable
- Test model can be saved and loaded

---

## 8.3 Predictive Path Quality Model

Implement inference using the trained model for navigation decisions.

### 8.3.1 Feature Extraction
- [ ] **Task 8.3.1** Extract features from current state.

- [ ] 8.3.1.1 Implement `extract_features/2`:
  ```elixir
  @spec extract_features(Agent.t(), Plane.t()) :: Nx.Tensor.t()
  def extract_features(agent, plane) do
    position = agent.position
    nest = agent.nest_position

    [
      elem(position, 0),         # current_x
      elem(position, 1),         # current_y
      get_pheromone(plane, position, :north),
      get_pheromone(plane, position, :south),
      get_pheromone(plane, position, :east),
      get_pheromone(plane, position, :west),
      Position.distance(position, nest),
      count_visits(agent, position),
      avg_nearby_food_quality(plane, position)
    ]
    |> Nx.tensor()
    |> Nx.new_axis(0)
  end
  ```
- [ ] 8.3.1.2 Implement `get_pheromone/3` for direction-specific pheromone
- [ ] 8.3.1.3 Implement `count_visits/2` from path_memory
- [ ] 8.3.1.4 Implement `avg_nearby_food_quality/2` from plane data
- [ ] 8.3.1.5 Write unit tests for feature extraction

### 8.3.2 Model Inference
- [ ] **Task 8.3.2** Implement prediction using trained model.

- [ ] 8.3.2.1 Implement `predict_quality/3`:
  ```elixir
  @spec predict_quality(Agent.t(), Plane.t(), model_state()) :: float()
  def predict_quality(agent, plane, model_state) do
    features = extract_features(agent, plane)
    {prediction, _} = Axon.predict(model_state, features)
    prediction |> Nx.to_number()
  end
  ```
- [ ] 8.3.2.2 Return probability (0-1) of finding food
- [ ] 8.3.2.3 Handle missing/untrained model gracefully
- [ ] 8.3.2.4 Cache predictions for same position (performance)
- [ ] 8.3.2.5 Write unit tests for inference

### 8.3.3 Direction Selection with ML
- [ ] **Task 8.3.3** Integrate ML predictions into movement decisions.

- [ ] 8.3.3.1 Implement `ml_choose_direction/3`:
  ```elixir
  @spec ml_choose_direction(Agent.t(), Plane.t(), model_state()) :: atom()
  def ml_choose_direction(agent, plane, model_state) do
    [:north, :south, :east, :west]
    |> Enum.map(fn direction ->
      simulated_pos = simulate_move(agent.position, direction)
      quality = predict_quality(%{agent | position: simulated_pos}, plane, model_state)
      {direction, quality}
    end)
    |> Enum.max_by(fn {_dir, quality} -> quality end)
    |> elem(0)
  end
  ```
- [ ] 8.3.3.2 Evaluate quality for each cardinal direction
- [ ] 8.3.3.3 Return direction with highest predicted quality
- [ ] 8.3.3.4 Fall back to random if model unavailable
- [ ] 8.3.3.5 Write unit tests for ML direction selection

**Unit Tests for Section 8.3:**
- Test `extract_features/2` returns correct feature tensor
- Test feature tensor has correct shape
- Test `predict_quality/3` returns probability
- Test `predict_quality/3` handles missing model
- Test `ml_choose_direction/3` returns best direction
- Test `ml_choose_direction/3` falls back without model

---

## 8.4 Model Training Integration

Implement the training pipeline and model updates.

### 8.4.1 Trainer Module
- [ ] **Task 8.4.1** Create the model training service.

- [ ] 8.4.1.1 Create `lib/jido_ants/ml/trainer.ex` with module documentation
- [ ] 8.4.1.2 Add `use GenServer`
- [ ] 8.4.1.3 Define state:
  ```elixir
  @type state :: %{
    model: model_state() | nil,
    model_version: non_neg_integer(),
    training_schedule: :continuous | :batch | :manual
  }
  ```
- [ ] 8.4.1.4 Implement `start_link/1` with options
- [ ] 8.4.1.5 Implement `init/1` starting with nil model

### 8.4.2 Training Execution
- [ ] **Task 8.4.2** Implement model training logic.

- [ ] 8.4.2.1 Implement `train_model/2`:
  ```elixir
  def train_model(trainer \\ __MODULE__, data_collector) do
    GenServer.call(trainer, {:train, data_collector})
  end
  ```
- [ ] 8.4.2.2 Get training data from DataCollector
- [ ] 8.4.2.3 Split into train and validation sets
- [ ] 8.4.2.4 Run training loop with Axon:
  ```elixir
  model = PathQualityModel.model()

  trained_model =
    model
    |> Axon.train(
      :binary_cross_entropy,
      Adam(learning_rate: @learning_rate),
      data,
      epochs: @epochs,
      validation_data: validation_data
    )
  ```
- [ ] 8.4.2.5 Return trained model state
- [ ] 8.4.2.6 Update model version on successful training
- [ ] 8.4.2.7 Write unit tests for training

### 8.4.3 Model Distribution
- [ ] **Task 8.4.3** Distribute trained model to ants.

- [ ] 8.4.3.1 Implement `broadcast_model/1`:
  ```elixir
  def broadcast_model(trainer \\ __MODULE__) do
    GenServer.call(trainer, :broadcast_model)
  end
  ```
- [ ] 8.4.3.2 Emit signal with serialized model parameters
- [ ] 8.4.3.3 Signal format: `{:model_update, version, parameters}`
- [ ] 8.4.3.4 Ant agents subscribe to model updates
- [ ] 8.4.3.5 Handle update failures gracefully
- [ ] 8.4.3.6 Write unit tests for model distribution

### 8.4.4 ColonyIntelligence GenServer
- [ ] **Task 8.4.4** Create the ML coordinator GenServer.

- [ ] 8.4.4.1 Create `lib/jido_ants/colony_intelligence.ex`
- [ ] 8.4.4.2 Add `use GenServer`
- [ ] 8.4.4.3 Aggregate data from DataCollector and Trainer
- [ ] 8.4.4.4 Schedule periodic training runs
- [ ] 8.4.4.5 Track model performance metrics
- [ ] 8.4.4.6 Implement `get_model/0` for current model
- [ ] 8.4.4.7 Write unit tests for coordinator

**Unit Tests for Section 8.4:**
- Test Trainer starts without initial model
- Test `train_model/2` trains from collected data
- Test training updates model state
- Test model version increments on training
- Test `broadcast_model/1` emits update signal
- Test ColonyIntelligence coordinates training
- Test ColonyIntelligence tracks metrics

---

## 8.5 Phase 8 Integration Tests

Comprehensive integration tests verifying all Phase 8 components work together correctly.

### 8.5.1 Data Collection Integration
- [ ] **Task 8.5.1** Test end-to-end data collection.

- [ ] 8.5.1.1 Create `test/jido_ants/ml/integration/ml_phase8_test.exs`
- [ ] 8.5.1.2 Test: Ant completes foraging trip → DataCollector records trip
- [ ] 8.5.1.3 Test: Multiple trips → all recorded correctly
- [ ] 8.5.1.4 Test: Max trips limit → oldest trips removed
- [ ] 8.5.1.5 Test: Export data → returns training tensors
- [ ] 8.5.1.6 Write all data collection integration tests

### 8.5.2 Training Integration
- [ ] **Task 8.5.2** Test model training pipeline.

- [ ] 8.5.2.1 Test: Collect data → train model → model updated
- [ ] 8.5.2.2 Test: Training improves predictions on validation set
- [ ] 7.5.2.3 Test: Model version increments after training
- [ ] 8.5.2.4 Test: Model broadcast to ants
- [ ] 8.5.2.5 Test: Training handles edge cases (empty data, single trip)
- [ ] 8.5.2.6 Write all training integration tests

### 8.5.3 ML-Guided Foraging Integration
- [ ] **Task 8.5.3** Test ants using ML for navigation.

- [ ] 8.5.3.1 Test: Ant with trained model → uses ML predictions
- [ ] 8.5.3.2 Test: Ant without model → falls back to ACO
- [ ] 8.5.3.3 Test: ML-trained ants find food faster than ACO-only
- [ ] 8.5.3.4 Test: Model update during simulation → ants adapt
- [ ] 8.5.3.5 Test: ML + ACO combination works correctly
- [ ] 8.5.3.6 Write all ML-guided foraging integration tests

**Integration Tests for Section 8.5:**
- Data collection captures foraging data
- Training pipeline produces valid models
- ML predictions improve foraging efficiency
- Model updates propagate to ants
- ML and ACO work together effectively

---

## Success Criteria

1. **Data Collection**: Foraging trips recorded with all relevant features
2. **Model Definition**: Axon model defined with correct architecture
3. **Feature Extraction**: Features extracted from agent/plane state
4. **Model Inference**: Predictions made using trained model
5. **Training Pipeline**: Models trained from collected data
6. **Model Distribution**: Trained models broadcast to ants
7. **ML Navigation**: Ants use predictions for movement decisions
8. **ColonyIntelligence**: Coordinator manages ML lifecycle
9. **Improved Efficiency**: ML-guided ants outperform ACO-only
10. **Test Coverage**: Minimum 80% coverage for phase 8 code
11. **Integration Tests**: All Phase 8 components work together (Section 8.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/ml/foraging_trip.ex`
- `lib/jido_ants/ml/data_collector.ex`
- `lib/jido_ants/ml/path_quality_model.ex`
- `lib/jido_ants/ml/trainer.ex`
- `lib/jido_ants/ml/inference.ex`
- `lib/jido_ants/colony_intelligence.ex`
- `test/jido_ants/ml/foraging_trip_test.exs`
- `test/jido_ants/ml/data_collector_test.exs`
- `test/jido_ants/ml/path_quality_model_test.exs`
- `test/jido_ants/ml/trainer_test.exs`
- `test/jido_ants/ml/inference_test.exs`
- `test/jido_ants/colony_intelligence_test.exs`
- `test/jido_ants/ml/integration/ml_phase8_test.exs`

**Modified Files:**
- `lib/jido_ants/agent/ant.ex` - Add ML model state
- `lib/jido_ants/actions/move.ex` - Add ML-guided option
- `lib/jido_ants/application.ex` - Add ML supervisor

---

## Dependencies

- **Depends on Phase 1**: Core data structures for ML features
- **Depends on Phase 2**: PlaneServer for environment data
- **Depends on Phase 3**: AntAgent for prediction context
- **Depends on Phase 4**: Actions use ML for decisions
- **Depends on Phase 5**: Foraging generates training data
- **Depends on Phase 6**: ACO provides baseline for ML improvement
