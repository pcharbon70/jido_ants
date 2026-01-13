# Phase 4: Movement and Sensing Actions

This phase implements the core actions that enable ants to navigate the plane and perceive their environment. The MoveAction handles position changes, SenseFoodAction detects food sources, and SensePheromoneAction reads pheromone intensities. These actions form the foundation of ant behavior.

---

## 4.1 MoveAction

Implement the action that enables ants to move around the plane.

### 4.1.1 MoveAction Module Structure
- [ ] **Task 4.1.1** Create the MoveAction module with Jido.Action behavior.

- [ ] 4.1.1.1 Create `lib/jido_ants/actions/move.ex` with module documentation
- [ ] 4.1.1.2 Add `use Jido.Action` with schema:
  ```elixir
  use Jido.Action,
    schema: [
      direction: [type: {:in, [:north, :south, :east, :west, :random]}, default: :random],
      steps: [type: :integer, default: 1]
    ]
  ```
- [ ] 4.1.1.3 Define `@descript "Move the ant in the specified direction"`
- [ ] 4.1.1.4 Implement `run/2` callback for action execution

### 4.1.2 Direction Calculation
- [ ] **Task 4.1.2** Implement direction to position delta conversion.

- [ ] 4.1.2.1 Implement `direction_to_delta/1` returning {dx, dy}:
  ```elixir
  @spec direction_to_delta(atom()) :: {integer(), integer()}
  def direction_to_delta(:north), do: {0, -1}
  def direction_to_delta(:south), do: {0, 1}
  def direction_to_delta(:east), do: {1, 0}
  def direction_to_delta(:west), do: {-1, 0}
  def direction_to_delta(:random), do: random_direction()
  ```
- [ ] 4.1.2.2 Implement `random_direction/0` for stochastic movement
- [ ] 4.1.2.3 Use `:rand.uniform/4` for random selection
- [ ] 4.1.2.4 Write unit tests for direction calculation

### 4.1.3 Position Update
- [ ] **Task 4.1.3** Implement position update logic.

- [ ] 4.1.3.1 Calculate new position from current position and direction
- [ ] 4.1.3.2 Validate new position is within plane bounds
- [ ] 4.1.3.3 Return `{:error, :out_of_bounds}` if position invalid
- [ ] 4.1.3.4 Update agent position on valid move
- [ ] 4.1.3.5 Append new position to path_memory
- [ ] 4.1.3.6 Consume energy for movement (1 unit per step)
- [ ] 4.1.3.7 Return `{:error, :exhausted}` if energy insufficient

### 4.1.4 Action Execution
- [ ] **Task 4.1.4** Implement the run/2 callback.

- [ ] 4.1.4.1 Extract agent state from context
- [ ] 4.1.4.2 Calculate delta from direction parameter
- [ ] 4.1.4.3 Calculate new position: `Position.add(agent.position, delta)`
- [ ] 4.1.4.4 Validate with PlaneServer: `PlaneServer.in_bounds?(new_pos)`
- [ ] 4.1.4.5 Update agent via `Agent.move_to/2`
- [ ] 4.1.4.6 Register new position with PlaneServer
- [ ] 4.1.4.7 Return `{:ok, %{agent | position: new_pos}, directives}`
- [ ] 4.1.4.8 Emit `Jido.Signal` with position update for proximity detection

**Unit Tests for Section 4.1:**
- Test `direction_to_delta/1` returns correct deltas
- Test `random_direction/0` returns valid direction
- Test MoveAction with :north moves y-1
- Test MoveAction with :south moves y+1
- Test MoveAction with :east moves x+1
- Test MoveAction with :west moves x-1
- Test MoveAction with :random picks valid direction
- Test MoveAction rejects out-of-bounds moves
- Test MoveAction updates path_memory
- Test MoveAction consumes energy
- Test MoveAction returns :exhausted when energy depleted
- Test MoveAction emits position update signal

---

## 4.2 SenseFoodAction

Implement the action that enables ants to detect food in their current position.

### 4.2.1 SenseFoodAction Module Structure
- [ ] **Task 4.2.1** Create the SenseFoodAction module.

- [ ] 4.2.1.1 Create `lib/jido_ants/actions/sense_food.ex` with module documentation
- [ ] 4.2.1.2 Add `use Jido.Action` with empty schema (senses current position)
- [ ] 4.2.1.3 Define `@descript "Sense for food at the ant's current position"`
- [ ] 4.2.1.4 Implement `run/2` callback

### 4.2.2 Food Sensing Logic
- [ ] **Task 4.2.2** Implement food detection from PlaneServer.

- [ ] 4.2.2.1 Get agent position from context
- [ ] 4.2.2.2 Query PlaneServer: `PlaneServer.sense_food(position)`
- [ ] 4.2.2.3 Handle food found case: return food level
- [ ] 4.2.2.4 Handle no food case: return nil
- [ ] 4.2.2.5 Update path_memory observation with food data
- [ ] 4.2.2.6 Return `{:ok, updated_agent, directives}`

### 4.2.3 Observation Recording
- [ ] **Task 4.2.3** Record food observations in path memory.

- [ ] 4.2.3.1 Update current path_memory entry with food_found: true/false
- [ ] 4.2.3.2 Record food_level if food found
- [ ] 4.2.3.3 Use `Agent.record_observation/3` helper
- [ ] 4.2.3.4 Maintain observation structure for later ML training
- [ ] 4.2.3.5 Write unit tests for observation recording

**Unit Tests for Section 4.2:**
- Test SenseFoodAction returns food level when present
- Test SenseFoodAction returns nil when no food
- Test SenseFoodAction updates path_memory with food_found: true
- Test SenseFoodAction records food_level
- Test SenseFoodAction updates last path_memory entry
- Test SenseFoodAction consumes minimal energy

---

## 4.3 SensePheromoneAction

Implement the action that enables ants to detect pheromone levels in their environment.

### 4.3.1 SensePheromoneAction Module Structure
- [ ] **Task 4.3.1** Create the SensePheromoneAction module.

- [ ] 4.3.1.1 Create `lib/jido_ants/actions/sense_pheromone.ex` with module documentation
- [ ] 4.3.1.2 Add `use Jido.Action` with schema:
  ```elixir
  use Jido.Action,
    schema: [
      radius: [type: :integer, default: 0],
      pheromone_types: [type: {:list, :atom}, default: [:food_trail]]
    ]
  ```
- [ ] 4.3.1.3 Define `@descript "Sense pheromone levels in the environment"`
- [ ] 4.3.1.4 Implement `run/2` callback

### 4.3.2 Pheromone Sensing Logic
- [ ] **Task 4.3.2** Implement pheromone detection from PlaneServer.

- [ ] 4.3.2.1 Get agent position from context
- [ ] 4.3.2.2 If radius is 0, sense only current position
- [ ] 4.3.2.3 If radius > 0, sense all positions within radius
- [ ] 4.3.2.4 Query PlaneServer: `PlaneServer.sense_pheromones_area(center, radius)`
- [ ] 4.3.2.5 Filter results by pheromone_types parameter
- [ ] 4.3.2.6 Return map of `{position => %{type => intensity}}`

### 4.3.3 Pheromone Data Processing
- [ ] **Task 4.3.3** Process and return pheromone data.

- [ ] 4.3.3.1 Structure return value for action result
- [ ] 4.3.3.2 Include position, pheromone types, and intensities
- [ ] 4.3.3.3 Update path_memory observation with pheromone data
- [ ] 4.3.3.4 Calculate pheromone gradient (direction of increasing intensity)
- [ ] 4.3.3.5 Return gradient information for movement decisions
- [ ] 4.3.3.6 Write unit tests for pheromone processing

### 4.3.4 Gradient Calculation
- [ ] **Task 4.3.4** Implement pheromone gradient calculation.

- [ ] 4.3.4.1 Implement `calculate_gradient/2`:
  ```elixir
  @spec calculate_gradient(Position.t(), %{Position.t() => map()}) :: {:atom(), float()} | nil
  def calculate_gradient(current_pos, pheromones) do
    neighbors = Position.neighbors(current_pos)
    # Find neighbor with highest pheromone intensity
    # Return direction to that neighbor
  end
  ```
- [ ] 4.3.4.2 Compare pheromone levels at neighboring positions
- [ ] 4.3.4.3 Return direction of strongest pheromone signal
- [ ] 4.3.4.4 Return nil if no pheromones detected
- [ ] 4.3.4.5 Write unit tests for gradient calculation

**Unit Tests for Section 4.3:**
- Test SensePheromoneAction returns pheromones at current position
- Test SensePheromoneAction with radius senses multiple positions
- Test SensePheromoneAction filters by pheromone_types
- Test SensePheromoneAction updates path_memory
- Test `calculate_gradient/2` returns direction of strongest pheromone
- Test `calculate_gradient/2` returns nil when no pheromones
- Test `calculate_gradient/2` handles multiple pheromone types
- Test SensePheromoneAction consumes minimal energy

---

## 4.4 Path Memory Management

Implement utilities for managing and utilizing the ant's path memory.

### 4.4.1 Path Memory Queries
- [ ] **Task 4.4.1** Implement path memory query functions.

- [ ] 4.4.1.1 Implement `current_path_entry/1` returning most recent observation
- [ ] 4.4.1.2 Implement `path_contains_food?/1` checking if food found on path
- [ ] 4.4.1.3 Implement `positions_visited/1` returning list of positions
- [ ] 4.4.1.4 Implement `path_length/1` returning number of positions
- [ ] 4.4.1.5 Implement `has_visited?/2` checking if position was visited
- [ ] 4.4.1.6 Write unit tests for path queries

### 4.4.2 Path Memory Updates
- [ ] **Task 4.4.2** Implement path memory update helpers.

- [ ] 4.4.2.1 Implement `update_observation/3` modifying current entry:
  ```elixir
  @spec update_observation(Agent.t(), atom(), term()) :: Agent.t()
  def update_observation(%Agent{path_memory: memory} = agent, key, value) do
    {pos, obs} = List.last(memory)
    updated_obs = Map.put(obs, key, value)
    updated_memory = List.replace_at(memory, -1, {pos, updated_obs})
    %{agent | path_memory: updated_memory}
  end
  ```
- [ ] 4.4.2.2 Implement `append_observation/3` adding new observation
- [ ] 4.4.2.3 Implement `merge_observation/3` merging map into current observation
- [ ] 4.4.2.4 Write unit tests for observation updates

### 4.4.3 Return Path Calculation
- [ ] **Task 4.4.3** Implement return path calculation.

- [ ] 4.4.3.1 Implement `calculate_return_path/1`:
  ```elixir
  @spec calculate_return_path(Agent.t()) :: [Position.t()]
  def calculate_return_path(%Agent{path_memory: memory}) do
    memory
    |> Enum.map(fn {pos, _obs} -> pos end)
    |> Enum.reverse()
    |> Enum.drop(1)  # Drop current position (will be added during moves)
  end
  ```
- [ ] 4.4.3.2 Handle empty path_memory case
- [ ] 4.4.3.3 Exclude duplicate consecutive positions
- [ ] 4.4.3.4 Return list of positions from current to nest
- [ ] 4.4.3.5 Write unit tests for return path calculation

**Unit Tests for Section 4.4:**
- Test `current_path_entry/1` returns most recent observation
- Test `path_contains_food?/1` detects food on path
- Test `positions_visited/1` returns all positions
- Test `path_length/1` returns correct count
- Test `has_visited?/2` checks for position in memory
- Test `update_observation/3` modifies current entry
- Test `append_observation/3` adds new observation
- Test `merge_observation/3` merges into current observation
- Test `calculate_return_path/1` returns path to nest
- Test `calculate_return_path/1` handles empty memory

---

## 4.5 Phase 4 Integration Tests

Comprehensive integration tests verifying all Phase 4 components work together correctly.

### 4.5.1 Movement Integration
- [ ] **Task 4.5.1** Test movement actions with full agent lifecycle.

- [ ] 4.5.1.1 Create `test/jido_ants/integration/actions_phase4_test.exs`
- [ ] 4.5.1.2 Test: Agent at nest → MoveAction north → verify position changed
- [ ] 4.5.1.3 Test: Agent moves to boundary → MoveAction toward boundary → rejected
- [ ] 4.5.1.4 Test: Agent moves multiple steps → verify path_memory accumulates
- [ ] 4.5.1.5 Test: Agent exhausts energy → MoveAction fails
- [ ] 4.5.1.6 Write all movement integration tests

### 4.5.2 Sensing Integration
- [ ] **Task 4.5.2** Test sensing actions with environment.

- [ ] 4.5.2.1 Test: Agent senses food → SenseFoodAction returns food level
- [ ] 4.5.2.2 Test: Agent senses empty area → SenseFoodAction returns nil
- [ ] 4.5.2.3 Test: Agent senses pheromones → SensePheromoneAction returns data
- [ ] 4.5.2.4 Test: Agent senses with radius → receives multiple positions
- [ ] 4.5.2.5 Test: Pheromone gradient calculated correctly
- [ ] 4.5.2.6 Write all sensing integration tests

### 4.5.3 Combined Action Sequences
- [ ] **Task 4.5.3** Test sequences of movement and sensing actions.

- [ ] 4.5.3.1 Test: Move → Sense → Move → Sense sequence
- [ ] 4.5.3.2 Test: Follow pheromone gradient using SensePheromoneAction
- [ ] 4.5.3.3 Test: Search pattern with MoveAction and SenseFoodAction
- [ ] 4.5.3.4 Test: Path memory accumulates correctly through action sequence
- [ ] 4.5.3.5 Write all sequence integration tests

**Integration Tests for Section 4.5:**
- Movement actions work with PlaneServer
- Sensing actions retrieve correct environmental data
- Action sequences maintain agent state correctly
- Path memory builds through movements

---

## Success Criteria

1. **MoveAction**: Ants can move in cardinal directions with bounds checking
2. **SenseFoodAction**: Ants detect food at current position
3. **SensePheromoneAction**: Ants sense pheromones with optional radius
4. **Path Memory**: Agent state tracks movement history
5. **Energy Consumption**: Actions consume energy appropriately
6. **Signal Emission**: Position updates emitted for proximity detection
7. **Gradient Calculation**: Pheromone gradient computed for navigation
8. **Test Coverage**: Minimum 80% coverage for phase 4 code
9. **Integration Tests**: All Phase 4 components work together (Section 4.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/actions/move.ex`
- `lib/jido_ants/actions/sense_food.ex`
- `lib/jido_ants/actions/sense_pheromone.ex`
- `lib/jido_ants/actions/path_memory.ex` (helpers)
- `test/jido_ants/actions/move_test.exs`
- `test/jido_ants/actions/sense_food_test.exs`
- `test/jido_ants/actions/sense_pheromone_test.exs`
- `test/jido_ants/integration/actions_phase4_test.exs`

**Modified Files:**
- `lib/jido_ants/agent/ant.ex` - Add path memory helper functions

---

## Dependencies

- **Depends on Phase 1**: Position types for movement
- **Depends on Phase 2**: PlaneServer for environment queries
- **Depends on Phase 3**: AntAgent for state management
- **Phase 5 depends on this**: Foraging uses movement and sensing
- **Phase 6 depends on this**: Pheromone following uses sensing
