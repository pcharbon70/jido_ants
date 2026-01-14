# Phase 1.3: Plane GenServer

Implement the Plane GenServer that manages the simulated environment including the grid, food sources, and ant positions. This serves as the central state management component for the simulation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AntColony.Plane                               │
│                          (GenServer)                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  State:                                                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • width: integer()              - Grid width              │    │
│  │  • height: integer()             - Grid height             │    │
│  │  • nest_location: {x, y}        - Nest position           │    │
│  │  • food_sources: map()          - %{{x,y} => food_info}   │    │
│  │  • ant_positions: map()         - %{ant_id => {x,y}}      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  API:                                                                │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • get_state/0                   - Returns full state      │    │
│  │  • get_dimensions/0              - Returns {width, height}│    │
│  │  • get_nest_location/0           - Returns nest position  │    │
│  │  • get_food_at/1                 - Returns food at pos    │    │
│  │  • set_food_sources/1            - Initialize food        │    │
│  │  • register_ant/2                - Register ant position  │    │
│  │  • unregister_ant/1              - Remove ant             │    │
│  │  • update_ant_position/2         - Update ant position    │    │
│  │  • get_nearby_ants/2             - Find ants in radius    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Plane | GenServer managing world state |
| AntColony.Plane.State | State struct with type specifications |
| Plane.FoodSource | Struct representing a food source |

---

## 1.3.1 Define Plane State Schema

Create the state structures for the Plane GenServer.

### 1.3.1.1 Create Plane.State Module

Create a dedicated module for Plane state structures.

- [ ] 1.3.1.1.1 Create `lib/ant_colony/plane/state.ex`
- [ ] 1.3.1.1.2 Add `defmodule AntColony.Plane.State`
- [ ] 1.3.1.1.3 Add `@moduledoc` describing the state structure
- [ ] 1.3.1.1.4 Add `@derive {Inspect, only: [...]}` to limit inspect output

### 1.3.1.2 Define State Struct

Define the main state struct with all fields.

- [ ] 1.3.1.2.1 Add `defstruct` with fields:
  - `:width` - default 50
  - `:height` - default 50
  - `:nest_location` - default `{25, 25}`
  - `:food_sources` - default `%{}`
  - `:ant_positions` - default `%{}`
- [ ] 1.3.1.2.2 Add type specification for `width`: `@type width :: pos_integer()`
- [ ] 1.3.1.2.3 Add type specification for `height`: `@type height :: pos_integer()`
- [ ] 1.3.1.2.4 Add type specification for position: `@type position :: {non_neg_integer(), non_neg_integer()}`

### 1.3.1.3 Define Food Source Struct

Define a struct for food source information.

- [ ] 1.3.1.3.1 Add `defmodule FoodSource` within `AntColony.Plane.State`
- [ ] 1.3.1.3.2 Add `defstruct` with fields:
  - `:level` - nutrient level 1-5, required
  - `:quantity` - available units, default 10
- [ ] 1.3.1.3.3 Add type spec: `@type level :: 1..5`
- [ ] 1.3.1.3.4 Add type spec: `@type quantity :: pos_integer()`
- [ ] 1.3.1.3.5 Add type spec: `@type t :: %__MODULE__{level: level(), quantity: quantity()}`

### 1.3.1.4 Define Complete State Type Specification

Add the complete type specification for the Plane state.

- [ ] 1.3.1.4.1 Add type for food_sources map: `@type food_sources :: %{position() => FoodSource.t()}`
- [ ] 1.3.1.4.2 Add type for ant_positions map: `@type ant_positions :: %{String.t() => position()}`
- [ ] 1.3.1.4.3 Add complete state type: `@type t :: %__MODULE__{...}` with all fields

---

## 1.3.2 Implement Plane GenServer

Implement the Plane as a GenServer with callback functions.

### 1.3.2.1 Create Plane GenServer Module

Create the main Plane GenServer module.

- [ ] 1.3.2.1.1 Create `lib/ant_colony/plane.ex`
- [ ] 1.3.2.1.2 Add `defmodule AntColony.Plane`
- [ ] 1.3.2.1.3 Add `use GenServer`
- [ ] 1.3.2.1.4 Add `@moduledoc` describing the Plane's purpose
- [ ] 1.3.2.1.5 Add `@behaviour GenServer` (implicit from use)

### 1.3.2.2 Implement init/1 Callback

Initialize the Plane GenServer with default state.

- [ ] 1.3.2.2.1 Implement `init/1` with `opts` parameter
- [ ] 1.3.2.2.2 Extract width from opts, default to 50
- [ ] 1.3.2.2.3 Extract height from opts, default to 50
- [ ] 1.3.2.2.4 Calculate nest_location as `{div(width, 2), div(height, 2)}`
- [ ] 1.3.2.2.5 Return `{:ok, %AntColony.Plane.State{...}}`

### 1.3.2.3 Implement handle_call/3 for State Queries

Add synchronous query handlers.

- [ ] 1.3.2.3.1 Handle `:get_state` - return full state
- [ ] 1.3.2.3.2 Handle `:get_dimensions` - return `{state.width, state.height}`
- [ ] 1.3.2.3.3 Handle `:get_nest_location` - return `state.nest_location`
- [ ] 1.3.2.3.4 Handle `{:get_food_at, position}` - return food or nil
- [ ] 1.3.2.3.5 Handle `:get_ant_positions` - return ant_positions map
- [ ] 1.3.2.3.6 Handle unknown requests with `{:noreply, state}`

### 1.3.2.4 Implement handle_call/3 for State Updates

Add synchronous update handlers.

- [ ] 1.3.2.4.1 Handle `{:set_food_sources, food_sources}` - replace food_sources map
- [ ] 1.3.2.4.2 Handle `{:register_ant, ant_id, position}` - add to ant_positions
- [ ] 1.3.2.4.3 Handle `{:unregister_ant, ant_id}` - remove from ant_positions
- [ ] 1.3.2.4.4 Handle `{:update_ant_position, ant_id, new_position}` - update position
- [ ] 1.3.2.4.5 Handle `{:deplete_food, position, amount}` - reduce food quantity
- [ ] 1.3.2.4.6 Return `{:reply, result, updated_state}` for each

### 1.3.2.5 Implement handle_info/2 for Async Messages

Add any asynchronous message handlers if needed.

- [ ] 1.3.2.5.1 Handle `:print_state` - log state for debugging
- [ ] 1.3.2.5.2 Return `{:noreply, state}` for unhandled messages

---

## 1.3.3 Add Food Source Management

Implement client functions for managing food sources.

### 1.3.3.1 Implement get_state/0

Client function to retrieve full Plane state.

- [ ] 1.3.3.1.1 Define `def get_state()` with no parameters
- [ ] 1.3.3.1.2 Call `GenServer.call(__MODULE__, :get_state)`
- [ ] 1.3.3.1.3 Return the state struct

### 1.3.3.2 Implement get_dimensions/0

Client function to get grid dimensions.

- [ ] 1.3.3.2.1 Define `def get_dimensions()`
- [ ] 1.3.3.2.2 Call `GenServer.call(__MODULE__, :get_dimensions)`
- [ ] 1.3.3.2.3 Return `{width, height}` tuple

### 1.3.3.3 Implement get_food_at/1

Client function to query food at a specific position.

- [ ] 1.3.3.3.1 Define `def get_food_at(position)`
- [ ] 1.3.3.3.2 Call `GenServer.call(__MODULE__, {:get_food_at, position})`
- [ ] 1.3.3.3.3 Return `FoodSource.t() | nil`

### 1.3.3.4 Implement set_food_sources/1

Client function to initialize food sources on the Plane.

- [ ] 1.3.3.4.1 Define `def set_food_sources(food_sources)`
- [ ] 1.3.3.4.2 Validate food_sources is a map
- [ ] 1.3.3.4.3 Call `GenServer.call(__MODULE__, {:set_food_sources, food_sources})`
- [ ] 1.3.3.4.4 Return `:ok`

### 1.3.3.5 Implement deplete_food/2

Client function to reduce food quantity at a position.

- [ ] 1.3.3.5.1 Define `def deplete_food(position, amount \\ 1)`
- [ ] 1.3.3.5.2 Call `GenServer.call(__MODULE__, {:deplete_food, position, amount})`
- [ ] 1.3.3.5.3 Return `{:ok, remaining_quantity} | {:error, :no_food}`

---

## 1.3.4 Add Ant Position Registry

Implement client functions for managing ant positions.

### 1.3.4.1 Implement register_ant/2

Register an ant's position with the Plane.

- [ ] 1.3.4.1.1 Define `def register_ant(ant_id, position)`
- [ ] 1.3.4.1.2 Validate ant_id is a string
- [ ] 1.3.4.1.3 Validate position is a tuple
- [ ] 1.3.4.1.4 Call `GenServer.call(__MODULE__, {:register_ant, ant_id, position})`
- [ ] 1.3.4.1.5 Return `:ok | {:error, reason}`

### 1.3.4.2 Implement unregister_ant/1

Remove an ant from the Plane's registry.

- [ ] 1.3.4.2.1 Define `def unregister_ant(ant_id)`
- [ ] 1.3.4.2.2 Call `GenServer.call(__MODULE__, {:unregister_ant, ant_id})`
- [ ] 1.3.4.2.3 Return `:ok | {:error, :not_found}`

### 1.3.4.3 Implement update_ant_position/2

Update an existing ant's position.

- [ ] 1.3.4.3.1 Define `def update_ant_position(ant_id, new_position)`
- [ ] 1.3.4.3.2 Call `GenServer.call(__MODULE__, {:update_ant_position, ant_id, new_position})`
- [ ] 1.3.4.3.3 Return `:ok | {:error, :not_found}`

### 1.3.4.4 Implement get_nearby_ants/2

Find all ants within a given radius of a position.

- [ ] 1.3.4.4.1 Define `def get_nearby_ants(position, radius)`
- [ ] 1.3.4.4.2 Call `GenServer.call(__MODULE__, :get_ant_positions)` to get all positions
- [ ] 1.3.4.4.3 Filter for ants within Euclidean distance of radius
- [ ] 1.3.4.4.4 Return list of `{ant_id, position}` tuples
- [ ] 1.3.4.4.5 Exclude the querying ant if ant_id is provided

### 1.3.4.5 Implement get_ant_position/1

Get a specific ant's current position.

- [ ] 1.3.4.5.1 Define `def get_ant_position(ant_id)`
- [ ] 1.3.4.5.2 Call `GenServer.call(__MODULE__, {:get_ant_position, ant_id})`
- [ ] 1.3.4.5.3 Return `{:ok, position} | {:error, :not_found}`

---

## 1.3.5 Unit Tests for Plane State

Test the Plane state structure creation and validation.

### 1.3.5.1 Test State Struct Creation

Verify the state struct can be created with defaults.

- [ ] 1.3.5.1.1 Create `test/ant_colony/plane/state_test.exs`
- [ ] 1.3.5.1.2 Add test: `test "creates state with default values"` - check %AntColony.Plane.State{}
- [ ] 1.3.5.1.3 Add test: `test "default width is 50"` - assert state.width == 50
- [ ] 1.3.5.1.4 Add test: `test "default height is 50"` - assert state.height == 50
- [ ] 1.3.5.1.5 Add test: `test "default nest_location is center"` - assert {25, 25}
- [ ] 1.3.5.1.6 Add test: `test "default food_sources is empty map"` - assert %{}
- [ ] 1.3.5.1.7 Add test: `test "default ant_positions is empty map"` - assert %{}

### 1.3.5.2 Test FoodSource Struct Creation

Verify FoodSource struct creation.

- [ ] 1.3.5.2.1 Add test: `test "creates FoodSource with level and quantity"` - custom values
- [ ] 1.3.5.2.2 Add test: `test "default quantity is 10"` - check default
- [ ] 1.3.5.2.3 Add test: `test "level must be between 1 and 5"` - test boundary values
- [ ] 1.3.5.2.4 Add test: `test "quantity must be positive"` - test validation

### 1.3.5.3 Test Type Specifications

Verify type specs are correct.

- [ ] 1.3.5.3.1 Add test: `test "position type accepts valid tuples"` - check `{0, 0}`, `{100, 100}`
- [ ] 1.3.5.3.2 Add test: `test "food_sources map type is correct"` - check map structure
- [ ] 1.3.5.3.3 Add test: `test "ant_positions map type is correct"` - check map structure

---

## 1.3.6 Unit Tests for Plane GenServer

Test the Plane GenServer callback functions and client API.

### 1.3.6.1 Test Plane Initialization

Verify Plane starts with correct initial state.

- [ ] 1.3.6.1.1 Create `test/ant_colony/plane_test.exs`
- [ ] 1.3.6.1.2 Add setup block: `setup :start_plane`
- [ ] 1.3.6.1.3 Add test: `test "plane starts with default dimensions"` - check 50x50
- [ ] 1.3.6.1.4 Add test: `test "plane starts with custom dimensions"` - pass opts
- [ ] 1.3.6.1.5 Add test: `test "nest is at center of grid"` - verify position
- [ ] 1.3.6.1.6 Add test: `test "plane starts with no food sources"` - check empty
- [ ] 1.3.6.1.7 Add test: `test "plane starts with no ants registered"` - check empty

### 1.3.6.2 Test State Query Functions

Verify client functions retrieve state correctly.

- [ ] 1.3.6.2.1 Add test: `test "get_state/0 returns full state"` - check all fields
- [ ] 1.3.6.2.2 Add test: `test "get_dimensions/0 returns width and height"` - check tuple
- [ ] 1.3.6.2.3 Add test: `test "get_nest_location/0 returns nest position"` - check position
- [ ] 1.3.6.2.4 Add test: `test "get_food_at/1 returns food source"` - with food
- [ ] 1.3.6.2.5 Add test: `test "get_food_at/1 returns nil when no food"` - empty position

### 1.3.6.3 Test Food Source Management

Verify food sources can be managed correctly.

- [ ] 1.3.6.3.1 Add test: `test "set_food_sources/1 adds food to plane"` - add one source
- [ ] 1.3.6.3.2 Add test: `test "set_food_sources/1 replaces existing food"` - replace all
- [ ] 1.3.6.3.3 Add test: `test "deplete_food/2 reduces quantity"` - check decrement
- [ ] 1.3.6.3.4 Add test: `test "deplete_food/2 removes food when quantity reaches 0"` - deletion
- [ ] 1.3.6.3.5 Add test: `test "deplete_food/2 returns error when no food"` - error case

### 1.3.6.4 Test Ant Position Registry

Verify ant positions can be registered and managed.

- [ ] 1.3.6.4.1 Add test: `test "register_ant/2 adds ant to registry"` - check registered
- [ ] 1.3.6.4.2 Add test: `test "register_ant/2 replaces existing ant position"` - update
- [ ] 1.3.6.4.3 Add test: `test "unregister_ant/1 removes ant from registry"` - check removed
- [ ] 1.3.6.4.4 Add test: `test "unregister_ant/1 returns error for unknown ant"` - error case
- [ ] 1.3.6.4.5 Add test: `test "update_ant_position/2 updates ant position"` - check new position
- [ ] 1.3.6.4.6 Add test: `test "get_ant_position/1 returns ant position"` - check result
- [ ] 1.3.6.4.7 Add test: `test "get_ant_position/1 returns error for unknown ant"` - error case

### 1.3.6.5 Test Nearby Ants Detection

Verify proximity detection works correctly.

- [ ] 1.3.6.5.1 Add test: `test "get_nearby_ants/2 finds ants within radius"` - basic case
- [ ] 1.3.6.5.2 Add test: `test "get_nearby_ants/2 excludes ants outside radius"` - boundary
- [ ] 1.3.6.5.3 Add test: `test "get_nearby_ants/2 returns empty when no ants nearby"` - isolation
- [ ] 1.3.6.5.4 Add test: `test "get_nearby_ants/3 excludes specified ant_id"` - self-exclusion
- [ ] 1.3.6.5.5 Add test: `test "get_nearby_ants/2 uses Euclidean distance"` - diagonal distance

### 1.3.6.6 Test Concurrent Access

Verify Plane handles concurrent requests correctly.

- [ ] 1.3.6.6.1 Add test: `test "concurrent ant registrations succeed"` - 10 concurrent tasks
- [ ] 1.3.6.6.2 Add test: "concurrent position updates succeed"` - 10 concurrent updates
- [ ] 1.3.6.6.3 Add test: `test "concurrent queries return consistent state"` - read consistency

---

## 1.3.7 Phase 1.3 Integration Tests

End-to-end tests for Plane functionality.

### 1.3.7.1 Plane Lifecycle Test

Test complete Plane lifecycle from start to stop.

- [ ] 1.3.7.1.1 Create `test/ant_colony/integration/plane_integration_test.exs`
- [ ] 1.3.7.1.2 Add test: `test "plane starts and stops cleanly"` - full lifecycle
- [ ] 1.3.7.1.3 Add test: `test "plane state persists across calls"` - state retention
- [ ] 1.3.7.1.4 Add test: `test "plane can be restarted"` - stop/start sequence

### 1.3.7.2 Multi-Ant Simulation Test

Test Plane with multiple ants interacting.

- [ ] 1.3.7.2.1 Add test: `test "multiple ants can register simultaneously"` - 5 ants
- [ ] 1.3.7.2.2 Add test: `test "ants can move independently"` - concurrent moves
- [ ] 1.3.7.2.3 Add test: `test "nearby ants are detected correctly"` - proximity with 10 ants
- [ ] 1.3.7.2.4 Add test: `test "ants can unregister independently"` - selective removal

### 1.3.7.3 Food Interaction Test

Test food source interactions with multiple ants.

- [ ] 1.3.7.3.1 Add test: `test "multiple food sources exist independently"` - 3 sources
- [ ] 1.3.7.3.2 Add test: `test "ants can deplete food independently"` - concurrent deplete
- [ ] 1.3.7.3.3 Add test: `test "food is removed when depleted"` - zero quantity
- [ ] 1.3.7.3.4 Add test: `test "food state is consistent across queries"` - consistency check

---

## Phase 1.3 Success Criteria

1. **Plane Module**: GenServer module compiles and starts ✅
2. **State Structure**: State struct with all fields defined ✅
3. **Food Management**: Food sources can be added, queried, depleted ✅
4. **Ant Registry**: Ants can be registered, unregistered, updated ✅
5. **Proximity Detection**: Nearby ants can be found ✅
6. **Concurrency**: Handles concurrent access correctly ✅
7. **Tests**: All unit and integration tests pass ✅

## Phase 1.3 Critical Files

**New Files:**
- `lib/ant_colony/plane.ex` - Plane GenServer module
- `lib/ant_colony/plane/state.ex` - Plane state structures
- `test/ant_colony/plane_test.exs` - Plane unit tests
- `test/ant_colony/plane/state_test.exs` - State structure tests
- `test/ant_colony/integration/plane_integration_test.exs` - Integration tests

**Modified Files:**
- None

---

## Next Phase

Proceed to [Phase 1.4: AntAgent Schema](./04-antagent-schema.md) to define the Jido Agent for individual ants.
