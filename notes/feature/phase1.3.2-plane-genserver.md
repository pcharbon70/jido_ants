# Feature: Phase 1.3.2 - Implement Plane GenServer

## Description
Implement section 1.3.2 of the Phase 1.3 Plane GenServer plan: Implement Plane GenServer.

## Branch
`feature/phase1.3.2-plane-genserver`

## Tasks from Plan

### 1.3.2.1 Create Plane GenServer Module
- [x] Create `lib/ant_colony/plane.ex`
- [x] Add `defmodule AntColony.Plane`
- [x] Add `use GenServer`
- [x] Add `@moduledoc` describing the Plane's purpose

### 1.3.2.2 Implement init/1 Callback
- [x] Implement `init/1` with `opts` parameter
- [x] Extract width from opts, default to 50
- [x] Extract height from opts, default to 50
- [x] Calculate nest_location as `{div(width, 2), div(height, 2)}`
- [x] Return `{:ok, %AntColony.Plane.State{...}}`

### 1.3.2.3 Implement handle_call/3 for State Queries
- [x] Handle `:get_state` - return full state
- [x] Handle `:get_dimensions` - return `{state.width, state.height}`
- [x] Handle `:get_nest_location` - return `state.nest_location`
- [x] Handle `{:get_food_at, position}` - return food or nil
- [x] Handle `:get_ant_positions` - return ant_positions map
- [x] Handle {:get_ant_position, ant_id} - return position or error
- [x] Handle unknown requests with error response

### 1.3.2.4 Implement handle_call/3 for State Updates
- [x] Handle `{:set_food_sources, food_sources}` - replace food_sources map
- [x] Handle `{:register_ant, ant_id, position}` - add to ant_positions
- [x] Handle `{:unregister_ant, ant_id}` - remove from ant_positions
- [x] Handle `{:update_ant_position, ant_id, new_position}` - update position or error
- [x] Handle `{:deplete_food, position, amount}` - reduce food quantity
- [x] Return `{:reply, result, updated_state}` for each

### 1.3.2.5 Implement handle_info/2 for Async Messages
- [x] Handle `:print_state` - log state for debugging
- [x] Return `{:noreply, state}` for unhandled messages

## Implementation Notes

- Plane GenServer manages simulation environment state
- Uses AntColony.Plane.State struct from 1.3.1
- Client API functions wrap GenServer.call for clean API
- All state queries are synchronous via handle_call
- State updates modify state and return updated state
- Food depletion automatically removes food when quantity reaches 0

## Files Created

### Created
- `lib/ant_colony/plane.ex` - Plane GenServer with client API

## Verification

```
$ mix compile
Compiling 1 file (.ex)
Generated ant_colony app

$ mix test
Running ExUnit with seed: 54990, max_cases: 40
Excluding tags: [skip: true]
..................
Finished in 4.3 seconds (0.00s async, 0.09s sync)
1 doctest, 25 tests, 0 failures, 1 excluded
```

## Status

**Completed**
