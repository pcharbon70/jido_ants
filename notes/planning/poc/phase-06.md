# Phase 6: Pheromone System

This phase implements the pheromone-based communication system that enables stigmergic coordination. Ants lay pheromone trails while returning with food, other ants sense these trails and bias their movement toward stronger concentrations, and pheromones evaporate over time to prevent stagnation.

---

## 6.1 LayPheromoneAction

Implement the action that enables ants to deposit pheromones as they move.

### 6.1.1 LayPheromoneAction Module Structure
- [ ] **Task 6.1.1** Create the LayPheromoneAction module.

- [ ] 6.1.1.1 Create `lib/jido_ants/actions/lay_pheromone.ex` with module documentation
- [ ] 6.1.1.2 Add `use Jido.Action` with schema:
  ```elixir
  use Jido.Action,
    schema: [
      pheromone_type: [type: {:in, [:food_trail, :exploration]}, default: :food_trail],
      intensity: [type: :float, default: nil]  # nil means auto-calculate
    ]
  ```
- [ ] 6.1.1.3 Define `@descript "Lay a pheromone at the ant's current position"`
- [ ] 6.1.1.4 Implement `run/2` callback

### 6.1.2 Intensity Calculation
- [ ] **Task 6.1.2** Implement pheromone intensity calculation.

- [ ] 6.1.2.1 For :food_trail type, base intensity on carried_food_level:
  ```elixir
  defp calculate_intensity(:food_trail, %{carried_food_level: level}) do
    level * @intensity_multiplier  # e.g., 0.5
  end
  ```
- [ ] 6.1.2.2 For :exploration type, use fixed low intensity
- [ ] 6.1.2.3 Allow manual intensity override via action parameter
- [ ] 6.1.2.4 Validate intensity is positive
- [ ] 6.1.2.5 Write unit tests for intensity calculation

### 6.1.3 Pheromone Deposit
- [ ] **Task 6.1.3** Implement pheromone deposit logic.

- [ ] 6.1.3.1 Get agent position from context
- [ ] 6.1.3.2 Calculate or get intensity
- [ ] 6.1.3.3 Create Pheromone struct with type, intensity, timestamp
- [ ] 6.1.3.4 Call PlaneServer: `PlaneServer.lay_pheromone(position, pheromone)`
- [ ] 6.1.3.5 Handle reinforcement of existing pheromone (add intensities)
- [ ] 6.1.3.6 Emit signal: `{:pheromone_laid, ant_id, position, pheromone}`
- [ ] 6.1.3.7 Write unit tests for pheromone deposit

**Unit Tests for Section 6.1:**
- Test LayPheromoneAction calculates intensity from food_level
- Test LayPheromoneAction uses exploration intensity for :exploration type
- Test LayPheromoneAction allows manual intensity override
- Test LayPheromoneAction deposits pheromone at current position
- Test LayPheromoneAction reinforces existing pheromone
- Test LayPheromoneAction emits pheromone_laid signal
- Test LayPheromoneAction consumes minimal energy

---

## 6.2 Pheromone Evaporation

Implement periodic pheromone evaporation to prevent trail stagnation.

### 6.2.1 Evaporation Configuration
- [ ] **Task 6.2.1** Define evaporation parameters.

- [ ] 6.2.1.1 Define `@evaporation_rate 0.01` (1% per cycle)
- [ ] 6.2.1.2 Define `@evaporation_interval 1000` (milliseconds)
- [ ] 6.2.1.3 Define `@min_intensity 0.01` threshold for removal
- [ ] 6.2.1.4 Make parameters configurable via application environment
- [ ] 6.2.1.5 Write unit tests for configuration

### 6.2.2 Evaporation Logic
- [ ] **Task 6.2.2** Implement pheromone evaporation in PlaneServer.

- [ ] 6.2.2.1 Create `lib/jido_ants/plane/evaporator.ex` module
- [ ] 6.2.2.2 Implement `evaporate_pheromones/1`:
  ```elixir
  def evaporate_pheromones(%Plane{pheromones: pheromones} = plane) do
    evaporated =
      pheromones
      |> Enum.map(fn {pos, pher_map} ->
        {pos, evaporate_position(pher_map)}
      end)
      |> Enum.filter(fn {_pos, pher_map} ->
        not (pher_map == %{})  # Remove positions with no pheromones
      end)
      |> Map.new()

    %{plane | pheromones: evaporated}
  end
  ```
- [ ] 6.2.2.3 Implement `evaporate_position/1` for single position
- [ ] 6.2.2.4 Apply decay: `new_intensity = intensity * (1 - evaporation_rate)`
- [ ] 6.2.2.5 Remove pheromones below `@min_intensity`
- [ ] 6.2.2.6 Return count of pheromones removed for logging
- [ ] 6.2.2.7 Write unit tests for evaporation logic

### 6.2.3 Scheduled Evaporation
- [ ] **Task 6.2.3** Integrate evaporation into PlaneServer.

- [ ] 6.2.3.1 Ensure PlaneServer schedules evaporation on init (from Phase 2)
- [ ] 6.2.3.2 Implement `handle_info(:evaporate, state)` handler:
  ```elixir
  def handle_info(:evaporate, state) do
    new_plane = Evaporator.evaporate_pheromones(state.plane)
    log_evaporation(state.plane, new_plane)
    schedule_evaporation()
    {:noreply, %{state | plane: new_plane}}
  end
  ```
- [ ] 6.2.3.3 Log evaporation statistics (count before, after, removed)
- [ ] 6.2.3.4 Reschedule next evaporation with `Process.send_after`
- [ ] 6.2.3.5 Write unit tests for scheduled evaporation

**Unit Tests for Section 6.2:**
- Test evaporation rate configured correctly
- Test evaporation interval configured correctly
- Test `evaporate_pheromones/1` reduces all pheromone intensities
- Test `evaporate_pheromones/1` removes pheromones below threshold
- Test `evaporate_pheromones/1` returns updated plane
- Test PlaneServer schedules evaporation on init
- Test PlaneServer reschedules after evaporation
- Test PlaneServer logs evaporation statistics

---

## 6.3 Pheromone-Based Movement Bias

Implement movement bias toward higher pheromone concentrations.

### 6.3.1 Pheromone-Guided Direction
- [ ] **Task 6.3.1** Calculate direction based on pheromone gradient.

- [ ] 6.3.1.1 Create `lib/jido_ants/navigation/pheromone_guidance.ex`
- [ ] 6.3.1.2 Implement `best_direction/3`:
  ```elixir
  @spec best_direction(Position.t(), %{Position.t() => map()}, [atom()]) :: atom() | nil
  def best_direction(current_pos, pheromones, pheromone_types \\ [:food_trail]) do
    current_pos
    |> Position.cardinal_neighbors()
    |> Enum.filter(fn pos -> Map.has_key?(pheromones, pos) end)
    |> Enum.map(fn pos ->
      intensity = total_pheromone_intensity(pheromones[pos], pheromone_types)
      direction = direction_to(current_pos, pos)
      {direction, intensity}
    end)
    |> Enum.max_by(fn {_dir, intensity} -> intensity end, fn -> nil end)
    |> case do
      {direction, _intensity} -> direction
      nil -> nil
    end
  end
  ```
- [ ] 6.3.1.3 Implement `direction_to/2` returning cardinal direction between positions
- [ ] 6.3.1.4 Implement `total_pheromone_intensity/2` summing intensities by type
- [ ] 6.3.1.5 Return nil if no pheromones in neighboring cells
- [ ] 6.3.1.6 Write unit tests for direction calculation

### 6.3.2 Probabilistic Movement
- [ ] **Task 6.3.2** Implement ACO-style probabilistic movement.

- [ ] 6.3.2.1 Implement `choose_direction/3` with pheromone influence:
  ```elixir
  @spec choose_direction(Position.t(), %{Position.t() => map()}, float()) :: atom()
  def choose_direction(current_pos, pheromones, exploration_rate \\ 0.1) do
    cond do
      :rand.uniform() < exploration_rate ->
        random_cardinal_direction()
      true ->
        best_direction(current_pos, pheromones) || random_cardinal_direction()
    end
  end
  ```
- [ ] 6.3.2.2 Use exploration_rate parameter (epsilon) for randomness
- [ ] 6.3.2.3 Return random direction when exploring
- [ ] 6.3.2.4 Return pheromone-guided direction when exploiting
- [ ] 6.3.2.5 Fall back to random if no pheromones detected
- [ ] 6.3.2.6 Write unit tests for probabilistic movement

### 6.3.3 Pheromone-Aware MoveAction
- [ ] **Task 6.3.3** Extend MoveAction with pheromone guidance.

- [ ] 6.3.3.1 Add `follow_pheromones` boolean parameter to MoveAction schema
- [ ] 6.3.3.2 When `follow_pheromones: true`, query pheromones before moving
- [ ] 6.3.3.3 Use `PheromoneGuidance.choose_direction/3` for direction selection
- [ ] 6.3.3.4 Override explicit direction when pheromones present
- [ ] 6.3.3.5 Emit telemetry event for pheromone-following decisions
- [ ] 6.3.3.6 Write unit tests for pheromone-aware movement

**Unit Tests for Section 6.3:**
- Test `best_direction/3` returns direction of strongest pheromone
- Test `best_direction/3` filters by pheromone_types
- Test `best_direction/3` returns nil when no pheromones nearby
- Test `choose_direction/3` explores with probability epsilon
- Test `choose_direction/3` follows pheromones when not exploring
- Test MoveAction with follow_pheromones: true uses pheromone guidance
- Test MoveAction overrides explicit direction with pheromone guidance

---

## 6.4 ACO Algorithm Integration

Integrate Ant Colony Optimization algorithm components into the simulation.

### 6.4.1 ACO Parameters
- [ ] **Task 6.4.1** Define ACO algorithm parameters.

- [ ] 6.4.1.1 Define `@alpha 1.0` (pheromone importance)
- [ ] 6.4.1.2 Define `@beta 2.0` (heuristic importance)
- [ ] 6.4.1.3 Define `@rho 0.01` (evaporation rate, same as @evaporation_rate)
- [ ] 6.4.1.4 Define `@q 100` (pheromone deposit constant)
- [ ] 6.4.1.5 Make parameters configurable via Application environment
- [ ] 6.4.1.6 Write unit tests for parameter configuration

### 6.4.2 ACO Probability Calculation
- [ ] **Task 6.4.2** Implement ACO transition probability formula.

- [ ] 6.4.2.1 Create `lib/jido_ants/aco.ex` module
- [ ] 6.4.2.2 Implement `transition_probability/5`:
  ```elixir
  @spec transition_probability(float(), float(), float(), float(), float()) :: float()
  def transition_probability(pheromone, heuristic, alpha, beta, sum) do
    numerator = :math.pow(pheromone, alpha) * :math.pow(heuristic, beta)
    numerator / sum
  end
  ```
- [ ] 6.4.2.3 Implement `calculate_probabilities/3` for all neighbors:
  ```elixir
  def calculate_probabilities(current_pos, pheromones, nest_pos) do
    neighbors = Position.cardinal_neighbors(current_pos)

    probabilities =
      neighbors
      |> Enum.map(fn pos ->
        tau = get_pheromone(pheromones, pos, :food_trail, 1.0)
        eta = calculate_heuristic(pos, nest_pos)
        {pos, tau, eta}
      end)
      |> calculate_normalized_probabilities()

    probabilities
  end
  ```
- [ ] 6.4.2.4 Implement `calculate_heuristic/2` (e.g., 1 / distance to nest)
- [ ] 6.4.2.5 Implement `get_pheromone/4` with default for missing
- [ ] 6.4.2.6 Implement `calculate_normalized_probabilities/1`
- [ ] 6.4.2.7 Write unit tests for probability calculation

### 6.4.3 Pheromone Deposit Formula
- [ ] **Task 6.4.3** Implement ACO pheromone deposit calculation.

- [ ] 6.4.3.1 Implement `deposit_amount/3`:
  ```elixir
  @spec deposit_amount(pos_integer(), float(), float()) :: float()
  def deposit_amount(path_length, food_quality, q \\ @q) do
    q / (path_length * (6 - food_quality))  # Higher quality = more pheromone
  end
  ```
- [ ] 6.4.3.2 Use path length from agent's path_memory
- [ ] 6.4.3.3 Use carried_food_level for quality
- [ ] 6.4.3.4 Shorter paths deposit more pheromone
- [ ] 6.4.3.5 Higher quality food deposits more pheromone
- [ ] 6.4.3.6 Write unit tests for deposit calculation

### 6.4.4 Navigation Skill
- [ ] **Task 6.4.4** Create NavigationSkill with ACO-based movement.

- [ ] 6.4.4.1 Create `lib/jido_ants/skills/navigation.ex`
- [ ] 6.4.4.2 Add `use Jido.Skill`
- [ ] 6.4.4.3 Include MoveAction with pheromone guidance
- [ ] 6.4.4.4 Include SensePheromoneAction
- [ ] 6.4.4.5 Include LayPheromoneAction for returning ants
- [ ] 6.4.4.6 Implement ACO probability-based direction selection
- [ ] 6.4.4.7 Write unit tests for NavigationSkill

**Unit Tests for Section 6.4:**
- Test ACO parameters configurable
- Test `transition_probability/5` calculates correctly
- Test `calculate_probabilities/3` returns valid distribution
- Test probabilities sum to 1.0
- Test `deposit_amount/3` inversely proportional to path length
- Test `deposit_amount/3` proportional to food quality
- Test NavigationSkill includes ACO actions
- Test NavigationSkill uses ACO for movement decisions

---

## 6.5 Phase 6 Integration Tests

Comprehensive integration tests verifying all Phase 6 components work together correctly.

### 6.5.1 Pheromone Trail Integration
- [ ] **Task 6.5.1** Test pheromone trail formation and following.

- [ ] 6.5.1.1 Create `test/jido_ants/integration/pheromone_phase6_test.exs`
- [ ] 6.5.1.2 Test: Ant with food returns → lays pheromone trail
- [ ] 6.5.1.3 Test: Second ant senses pheromone → follows trail
- [ ] 6.5.1.4 Test: Multiple ants reinforce trail → stronger signal
- [ ] 6.5.1.5 Test: Trail evaporates over time → signal weakens
- [ ] 6.5.1.6 Write all trail integration tests

### 6.5.2 ACO Convergence Integration
- [ ] **Task 6.5.2** Test ACO algorithm convergence.

- [ ] 6.5.2.1 Test: Multiple ants find same food → shortest path emerges
- [ ] 6.5.2.2 Test: Colony converges on optimal foraging route
- [ ] 6.5.2.3 Test: Exploration continues despite convergence
- [ ] 6.5.2.4 Test: New food source discovered → new trail forms
- [ ] 6.5.2.5 Write all convergence integration tests

### 6.5.3 Evaporation Dynamics Integration
- [ ] **Task 6.5.3** Test evaporation effects on colony behavior.

- [ ] 6.5.3.1 Test: Food source depleted → trail evaporates → ants stop following
- [ ] 6.5.3.2 Test: Shorter path found → old trail evaporates → new trail dominates
- [ ] 6.5.3.3 Test: Evaporation rate affects trail persistence
- [ ] 6.5.3.4 Test: Minimum intensity threshold removes old trails
- [ ] 6.5.3.5 Write all evaporation integration tests

**Integration Tests for Section 6.5:**
- Pheromone trails form and are followed correctly
- ACO algorithm converges on optimal paths
- Evaporation prevents stagnation
- Colony adapts to changing conditions

---

## Success Criteria

1. **LayPheromoneAction**: Ants deposit pheromones based on food quality
2. **Evaporation**: Pheromones decay over time and are removed
3. **Movement Bias**: Ants prefer movement toward higher pheromone concentrations
4. **ACO Parameters**: Alpha, beta, rho, Q properly configured
5. **Probability Calculation**: Transition probabilities follow ACO formula
6. **Pheromone Deposit**: Amount based on path length and food quality
7. **NavigationSkill**: ACO-based actions grouped in skill
8. **Convergence**: Colony converges on shortest foraging paths
9. **Test Coverage**: Minimum 80% coverage for phase 6 code
10. **Integration Tests**: All Phase 6 components work together (Section 6.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/actions/lay_pheromone.ex`
- `lib/jido_ants/plane/evaporator.ex`
- `lib/jido_ants/navigation/pheromone_guidance.ex`
- `lib/jido_ants/aco.ex`
- `lib/jido_ants/skills/navigation.ex`
- `test/jido_ants/actions/lay_pheromone_test.exs`
- `test/jido_ants/plane/evaporator_test.exs`
- `test/jido_ants/navigation/pheromone_guidance_test.exs`
- `test/jido_ants/aco_test.exs`
- `test/jido_ants/skills/navigation_test.exs`
- `test/jido_ants/integration/pheromone_phase6_test.exs`

**Modified Files:**
- `lib/jido_ants/plane_server.ex` - Add evaporation handler
- `lib/jido_ants/actions/move.ex` - Add pheromone guidance option
- `lib/jido_ants/agent/fsm_strategy.ex` - Add pheromone-aware transitions

---

## Dependencies

- **Depends on Phase 1**: Pheromone types, Position
- **Depends on Phase 2**: PlaneServer for pheromone storage
- **Depends on Phase 3**: AntAgent for laying behavior
- **Depends on Phase 4**: Movement for pheromone-guided navigation
- **Depends on Phase 5**: Foraging for pheromone laying triggers
- **Phase 7 depends on this**: Communication can inform about pheromone trails
- **Phase 8 depends on this**: ML can optimize ACO parameters
