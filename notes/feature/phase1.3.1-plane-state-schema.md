# Feature: Phase 1.3.1 - Define Plane State Schema

## Description
Implement section 1.3.1 of the Phase 1.3 Plane GenServer plan: Define Plane State Schema.

## Branch
`feature/phase1.3.1-plane-state-schema`

## Tasks from Plan

### 1.3.1.1 Create Plane.State Module
- [x] Create `lib/ant_colony/plane/state.ex`
- [x] Add `defmodule AntColony.Plane.State`
- [x] Add `@moduledoc` describing the state structure
- [x] Add custom Inspect implementation for cleaner output

### 1.3.1.2 Define State Struct
- [x] Add `defstruct` with fields: width, height, nest_location, food_sources, ant_positions
- [x] Add type specification for width: `@type width :: pos_integer()`
- [x] Add type specification for height: `@type height :: pos_integer()`
- [x] Add type specification for position: `@type position :: {non_neg_integer(), non_neg_integer()}`

### 1.3.1.3 Define Food Source Struct
- [x] Add `defmodule FoodSource` within `AntColony.Plane.State`
- [x] Add `defstruct` with fields: level (1-5), quantity (default 10)
- [x] Add type spec: `@type level :: 1..5`
- [x] Add type spec: `@type quantity :: pos_integer()`
- [x] Add type spec: `@type t :: %__MODULE__{...}`
- [x] Add `new/2` and `deplete/2` helper functions

### 1.3.1.4 Define Complete State Type Specification
- [x] Add type for food_sources map: `@type food_sources :: %{position() => FoodSource.t()}`
- [x] Add type for ant_positions map: `@type ant_positions :: %{String.t() => position()}`
- [x] Add complete state type: `@type t :: %__MODULE__{...}` with all fields

## Implementation Notes

- State struct defines the core data structure for the Plane GenServer
- FoodSource nested module defines food source properties
- Type specifications enable Dialyzer static analysis
- Custom Inspect implementation limits output to key fields for cleaner debugging
- FoodSource includes helper functions: new/2 and deplete/2

## Files Created

### Created
- `lib/ant_colony/plane/state.ex` - Plane state structures with FoodSource

## Verification

```
$ mix compile
Compiling 1 file (.ex)
Generated ant_colony app

$ mix test
Running ExUnit with seed: 276832, max_cases: 40
Excluding tags: [skip: true]
...................
Finished in 4.3 seconds (0.00s async, 4.3s sync)
1 doctest, 25 tests, 0 failures, 1 excluded
```

## Status

**Completed**
