# Phase 2: The Plane Environment

This phase implements the Plane GenServer that manages the simulated environment. The Plane maintains the grid state, food sources, pheromone fields, and agent position tracking. It provides the interface through which ants interact with the world.

---

## 2.1 Plane GenServer

Create the Plane GenServer that manages the environment state and handles agent interactions.

### 2.1.1 PlaneServer Module Structure
- [ ] **Task 2.1.1** Create the PlaneServer GenServer module.

- [ ] 2.1.1.1 Create `lib/jido_ants/plane_server.ex` with module documentation
- [ ] 2.1.1.2 Add `use GenServer`
- [ ] 2.1.1.3 Define the server state:
  ```elixir
  @type state :: %{
    plane: Plane.t(),
    subscribers: [pid()]
  }
  ```
- [ ] 2.1.1.4 Implement `start_link/1` with options:
  ```elixir
  def start_link(opts) do
    {name_opts, plane_opts} = Keyword.split(opts, [:name])
    GenServer.start_link(__MODULE__, plane_opts, name_opts)
  end
  ```
- [ ] 2.1.1.5 Implement `via/1` for Registry naming support

### 2.1.2 Server Initialization
- [ ] **Task 2.1.2** Implement GenServer initialization.

- [ ] 2.1.2.1 Implement `init/1` callback:
  ```elixir
  def init(opts) do
    case Plane.new(opts) do
      {:ok, plane} ->
        schedule_evaporation()
        {:ok, %{plane: plane, subscribers: []}}
      {:error, reason} ->
        {:stop, reason}
    end
  end
  ```
- [ ] 2.1.2.2 Implement `schedule_evaporation/0` for periodic pheromone decay
- [ ] 2.1.2.3 Use `Process.send_after/3` for evaporation scheduling
- [ ] 2.1.2.4 Log plane initialization with dimensions

### 2.1.3 Plane State Access
- [ ] **Task 2.1.3** Implement synchronous state access calls.

- [ ] 2.1.3.1 Implement `get_plane/0` client function:
  ```elixir
  def get_plane(server \\ __MODULE__) do
    GenServer.call(server, :get_plane)
  end
  ```
- [ ] 2.1.3.2 Implement `handle_call(:get_plane, _, state)` returning plane
- [ ] 2.1.3.3 Implement `get_dimensions/0` returning width and height
- [ ] 2.1.3.4 Implement `get_nest_position/0` returning nest coordinates
- [ ] 2.1.3.5 Implement `get_food_sources/0` returning all food sources
- [ ] 2.1.3.6 Write unit tests for state access

**Unit Tests for Section 2.1:**
- Test PlaneServer starts with valid options
- Test PlaneServer stops with invalid options
- Test `get_plane/0` returns current plane state
- Test `get_dimensions/0` returns correct dimensions
- Test `get_nest_position/0` returns nest position
- Test `get_food_sources/0` returns all food sources
- Test evaporation is scheduled on init

---

## 2.2 Food Management

Implement food source management including spawning, depletion, and queries.

### 2.2.1 Food Source Registration
- [ ] **Task 2.2.1** Implement food source addition.

- [ ] 2.2.1.1 Implement `add_food_source/2` client function:
  ```elixir
  def add_food_source(server \\ __MODULE__, food_source) do
    GenServer.call(server, {:add_food_source, food_source})
  end
  ```
- [ ] 2.2.1.2 Implement `handle_call({:add_food_source, fs}, _, state)`:
  ```elixir
  def handle_call({:add_food_source, food_source}, _from, state) do
    case Plane.add_food_source(state.plane, food_source) do
      {:ok, new_plane} ->
        notify_subscribers(state.subscribers, {:food_added, food_source})
        {:reply, :ok, %{state | plane: new_plane}}
      error ->
        {:reply, error, state}
    end
  end
  ```
- [ ] 2.2.1.3 Validate food source position is in bounds
- [ ] 2.2.1.4 Validate food source doesn't overlap existing
- [ ] 2.2.1.5 Write unit tests for food source addition

### 2.2.2 Food Source Spawning
- [ ] **Task 2.2.2** Implement automatic food source spawning.

- [ ] 2.2.2.1 Implement `spawn_food_sources/2` with count and level options
- [ ] 2.2.2.2 Generate random positions avoiding nest area
- [ ] 2.2.2.3 Distribute food sources across the plane
- [ ] 2.2.2.4 Respect minimum distance between sources
- [ ] 2.2.2.5 Write unit tests for food spawning

### 2.2.3 Food Queries and Pickup
- [ ] **Task 2.2.3** Implement food query and pickup operations.

- [ ] 2.2.3.1 Implement `sense_food/2` client function:
  ```elixir
  def sense_food(server \\ __MODULE__, position) do
    GenServer.call(server, {:sense_food, position})
  end
  ```
- [ ] 2.2.3.2 Implement `handle_call({:sense_food, pos}, _, state)` returning food at position
- [ ] 2.2.3.3 Implement `pick_up_food/2` for removing food unit:
  ```elixir
  def pick_up_food(server \\ __MODULE__, position) do
    GenServer.call(server, {:pick_up_food, position})
  end
  ```
- [ ] 2.2.3.4 Implement `handle_call({:pick_up_food, pos}, _, state)` updating food quantity
- [ ] 2.2.3.5 Remove food source from map when quantity reaches 0
- [ ] 2.2.3.6 Write unit tests for food queries and pickup

**Unit Tests for Section 2.2:**
- Test `add_food_source/2` adds food to plane
- Test `add_food_source/2` validates position bounds
- Test `add_food_source/2` prevents overlap
- Test `spawn_food_sources/2` distributes food across plane
- Test `sense_food/2` returns food at position
- Test `sense_food/2` returns nil for empty position
- Test `pick_up_food/2` reduces food quantity
- Test `pick_up_food/2` removes depleted food source
- Test subscribers notified of food changes

---

## 2.3 Grid Operations

Implement grid-based operations and agent position tracking.

### 2.3.1 Position Validation
- [ ] **Task 2.3.1** Implement position validation operations.

- [ ] 2.3.1.1 Implement `in_bounds?/2` client function:
  ```elixir
  def in_bounds?(server \\ __MODULE__, position) do
    GenServer.call(server, {:in_bounds, position})
  end
  ```
- [ ] 2.3.1.2 Implement `handle_call({:in_bounds, pos}, _, state)` using `Plane.in_bounds?/2`
- [ ] 2.3.1.3 Return `true` if position within plane dimensions
- [ ] 2.3.1.4 Return `false` if position outside bounds
- [ ] 2.3.1.5 Write unit tests for position validation

### 2.3.2 Ant Position Tracking
- [ ] **Task 2.3.2** Implement ant position registry.

- [ ] 2.3.2.1 Implement `register_ant/3` client function:
  ```elixir
  def register_ant(server \\ __MODULE__, ant_id, position) do
    GenServer.call(server, {:register_ant, ant_id, position})
  end
  ```
- [ ] 2.3.2.2 Implement `handle_call({:register_ant, id, pos}, _, state)`:
  ```elixir
  def handle_call({:register_ant, ant_id, position}, _from, state) do
    new_plane = Plane.register_ant(state.plane, ant_id, position)
    notify_subscribers(state.subscribers, {:ant_moved, ant_id, position})
    {:reply, :ok, %{state | plane: new_plane}}
  end
  ```
- [ ] 2.3.2.3 Implement `unregister_ant/2` for removing ant
- [ ] 2.3.2.4 Implement `get_ant_position/2` for looking up ant location
- [ ] 2.3.2.5 Implement `list_ant_positions/0` for all ant positions
- [ ] 2.3.2.6 Write unit tests for ant registration

### 2.3.3 Grid Queries
- [ ] **Task 2.3.3** Implement grid-based query functions.

- [ ] 2.3.3.1 Implement `get_neighbors/2` returning adjacent positions
- [ ] 2.3.3.2 Implement `get_valid_neighbors/2` returning in-bounds neighbors only
- [ ] 2.3.3.3 Implement `get_ants_nearby/3` returning ants within radius:
  ```elixir
  def get_ants_nearby(server \\ __MODULE__, position, radius) do
    GenServer.call(server, {:ants_nearby, position, radius})
  end
  ```
- [ ] 2.3.3.4 Use `Position.distance/2` to calculate proximity
- [ ] 2.3.3.5 Return list of `{ant_id, position, distance}` tuples
- [ ] 2.3.3.6 Write unit tests for grid queries

**Unit Tests for Section 2.3:**
- Test `in_bounds?/2` validates positions correctly
- Test `register_ant/3` adds ant to registry
- Test `unregister_ant/2` removes ant from registry
- Test `get_ant_position/2` returns ant's position
- Test `list_ant_positions/0` returns all registered ants
- Test `get_valid_neighbors/2` filters out-of-bounds positions
- Test `get_ants_nearby/3` returns ants within radius
- Test `get_ants_nearby/3` excludes ants outside radius

---

## 2.4 Pheromone Field Management

Implement pheromone field operations including deposit, sensing, and evaporation.

### 2.4.1 Pheromone Deposit
- [ ] **Task 2.4.1** Implement pheromone deposit operations.

- [ ] 2.4.1.1 Implement `lay_pheromone/3` client function:
  ```elixir
  def lay_pheromone(server \\ __MODULE__, position, pheromone) do
    GenServer.call(server, {:lay_pheromone, position, pheromone})
  end
  ```
- [ ] 2.4.1.2 Implement `handle_call({:lay_pheromone, pos, pher}, _, state)`:
  ```elixir
  def handle_call({:lay_pheromone, position, pheromone}, _from, state) do
    new_plane = Plane.add_pheromone(state.plane, position, pheromone)
    notify_subscribers(state.subscribers, {:pheromone_laid, position, pheromone})
    {:reply, :ok, %{state | plane: new_plane}}
  end
  ```
- [ ] 2.4.1.3 Handle adding new pheromone to position
- [ ] 2.4.1.4 Handle reinforcing existing pheromone (add intensities)
- [ ] 2.4.1.5 Write unit tests for pheromone deposit

### 2.4.2 Pheromone Sensing
- [ ] **Task 2.4.2** Implement pheromone query operations.

- [ ] 2.4.2.1 Implement `sense_pheromones/2` client function:
  ```elixir
  def sense_pheromones(server \\ __MODULE__, position) do
    GenServer.call(server, {:sense_pheromones, position})
  end
  ```
- [ ] 2.4.2.2 Implement `handle_call({:sense_pheromones, pos}, _, state)` returning pheromone map
- [ ] 2.4.2.3 Return empty map if no pheromones at position
- [ ] 2.4.2.4 Implement `sense_pheromones_area/3` for multiple positions:
  ```elixir
  def sense_pheromones_area(server \\ __MODULE__, center, radius) do
    GenServer.call(server, {:sense_pheromones_area, center, radius})
  end
  ```
- [ ] 2.4.2.5 Write unit tests for pheromone sensing

### 2.4.3 Pheromone Evaporation
- [ ] **Task 2.4.3** Implement periodic pheromone evaporation.

- [ ] 2.4.3.1 Implement `handle_info(:evaporate, state)` for evaporation:
  ```elixir
  def handle_info(:evaporate, state) do
    new_plane = Plane.evaporate_pheromones(state.plane)
    schedule_evaporation()
    {:noreply, %{state | plane: new_plane}}
  end
  ```
- [ ] 2.4.3.2 Apply evaporation to all pheromones on the plane
- [ ] 2.4.3.3 Remove pheromones that fall below minimum intensity
- [ ] 2.4.3.4 Reschedule next evaporation cycle
- [ ] 2.4.3.5 Log evaporation statistics (count removed, remaining)
- [ ] 2.4.3.6 Write unit tests for pheromone evaporation

### 2.4.4 Subscription System
- [ ] **Task 2.4.4** Implement pub/sub for plane state changes.

- [ ] 2.4.4.1 Implement `subscribe/1` client function:
  ```elixir
  def subscribe(server \\ __MODULE__, subscriber \\ self()) do
    GenServer.call(server, {:subscribe, subscriber})
  end
  ```
- [ ] 2.4.4.2 Implement `handle_call({:subscribe, pid}, _, state)` adding subscriber
- [ ] 2.4.4.3 Implement `unsubscribe/1` for removing subscription
- [ ] 2.4.4.4 Implement `notify_subscribers/3` helper sending messages to all subscribers
- [ ] 2.4.4.5 Handle subscriber death (monitor and auto-remove)
- [ ] 2.4.4.6 Write unit tests for subscription system

**Unit Tests for Section 2.4:**
- Test `lay_pheromone/3` adds pheromone to position
- Test `lay_pheromone/3` reinforces existing pheromone
- Test `sense_pheromones/2` returns pheromones at position
- Test `sense_pheromones_area/3` returns pheromones in area
- Test evaporation reduces pheromone intensity
- Test evaporation removes dissipated pheromones
- Test evaporation reschedules automatically
- Test `subscribe/1` adds subscriber
- Test subscribers receive notifications
- Test `unsubscribe/1` removes subscriber

---

## 2.5 Phase 2 Integration Tests

Comprehensive integration tests verifying all Phase 2 components work together correctly.

### 2.5.1 Plane Lifecycle Integration
- [ ] **Task 2.5.1** Test complete PlaneServer lifecycle.

- [ ] 2.5.1.1 Create `test/jido_ants/integration/plane_phase2_test.exs`
- [ ] 2.5.1.2 Test: Start PlaneServer → verify plane state → add food → verify food exists
- [ ] 2.5.1.3 Test: Add multiple food sources → verify all accessible
- [ ] 2.5.1.4 Test: Pick up food until depleted → verify food removed
- [ ] 2.5.1.5 Test: Stop and restart PlaneServer → verify state reset
- [ ] 2.5.1.6 Write all lifecycle integration tests

### 2.5.2 Food System Integration
- [ ] **Task 2.5.2** Test food management end-to-end.

- [ ] 2.5.2.1 Test: Spawn food sources → verify distribution
- [ ] 2.5.2.2 Test: Ant picks up food → verify quantity decreased
- [ ] 2.5.2.3 Test: Ant picks up last food unit → verify source removed
- [ ] 2.5.2.4 Test: Multiple ants pick up from same source → verify concurrent access
- [ ] 2.5.2.5 Write all food system integration tests

### 2.5.3 Pheromone System Integration
- [ ] **Task 2.5.3** Test pheromone operations end-to-end.

- [ ] 2.5.3.1 Test: Lay pheromone trail → sense pheromones → verify trail detected
- [ ] 2.5.3.2 Test: Multiple ants lay pheromone → verify reinforcement
- [ ] 2.5.3.3 Test: Wait for evaporation cycle → verify intensity reduced
- [ ] 2.5.3.4 Test: Many evaporation cycles → verify pheromones removed
- [ ] 2.5.3.5 Write all pheromone integration tests

### 2.5.4 Subscription Integration
- [ ] **Task 2.5.4** Test pub/sub notification system.

- [ ] 2.5.4.1 Test: Subscribe to plane → trigger event → verify notification received
- [ ] 2.5.4.2 Test: Multiple subscribers → all receive notifications
- [ ] 2.5.4.3 Test: Subscriber crashes → verify auto-removed
- [ ] 2.5.4.4 Test: Unsubscribe → verify no further notifications
- [ ] 2.5.4.5 Write all subscription integration tests

**Integration Tests for Section 2.5:**
- PlaneServer lifecycle works correctly
- Food management operations integrate properly
- Pheromone system functions as designed
- Subscription system notifies correctly

---

## Success Criteria

1. **PlaneServer GenServer**: Functional environment manager with state operations
2. **Food Management**: Food sources can be added, queried, and depleted
3. **Position Tracking**: Ant positions registered and queryable
4. **Pheromone Fields**: Pheromones deposited, sensed, and evaporated
5. **Subscription System**: Plane state changes notify subscribers
6. **Evaporation**: Periodic pheromone decay removes old trails
7. **Concurrency**: Multiple ants can interact with plane simultaneously
8. **Test Coverage**: Minimum 80% coverage for phase 2 code
9. **Integration Tests**: All Phase 2 components work together (Section 2.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/plane_server.ex`
- `lib/jido_ants/plane/add_food_source.ex` (Plane helper)
- `lib/jido_ants/plane/add_pheromone.ex` (Plane helper)
- `lib/jido_ants/plane/evaporate_pheromones.ex` (Plane helper)
- `test/jido_ants/plane_server_test.exs`
- `test/jido_ants/integration/plane_phase2_test.exs`

**Modified Files:**
- `lib/jido_ants/plane.ex` - Add server-related helper functions

---

## Dependencies

- **Depends on Phase 1**: Plane struct, Position, FoodSource, Pheromone types
- **Phase 3 depends on this**: AntAgent needs PlaneServer for environment interaction
- **Phase 6 depends on this**: Pheromone system extends PlaneServer pheromone operations
