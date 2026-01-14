# Phase 2.2: Plane UI API

Add the `get_full_state_for_ui/0` API to the Plane GenServer. This provides the UI with a complete snapshot of the simulation world for initialization and rendering.

## Architecture

```
AntColony.Plane (GenServer)
├── Existing State:
│   ├── width: integer()
│   ├── height: integer()
│   ├── nest_location: {x, y}
│   ├── food_sources: %{{x, y} => %{level: 1-5, quantity: integer()}}
│   └── ant_positions: %{ant_id => {x, y}}
└── New API:
    └── get_full_state_for_ui/0
        └── Returns %{
               width: integer(),
               height: integer(),
               nest_location: {x, y},
               food_sources: [%{pos: {x, y}, level: 1-5, quantity: integer()}]
             }
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Plane.get_full_state_for_ui/0 | Client function to query world state |
| Plane.handle_call :get_full_state_for_ui | Server callback returning state map |

---

## 2.2.1 Implement get_full_state_for_ui Client Function

Add the client-side function for querying Plane state.

### 2.2.1.1 Define Client Function

Create the public API for UI to fetch world state.

- [ ] 2.2.1.1.1 Open `lib/ant_colony/plane.ex`
- [ ] 2.2.1.1.2 Locate the existing client functions section
- [ ] 2.2.1.1.3 Add `def get_full_state_for_ui()` function with no parameters
- [ ] 2.2.1.1.4 Implement body: `GenServer.call(__MODULE__, :get_full_state_for_ui)`
- [ ] 2.2.1.1.5 Add `@spec` defining return type: `@spec get_full_state_for_ui() :: map()`

### 2.2.1.2 Document the Function

Add documentation for the new API.

- [ ] 2.2.1.2.1 Add `@doc` attribute with function description
- [ ] 2.2.1.2.2 Document the return structure in @doc
- [ ] 2.2.1.2.3 Include example usage in @doc
- [ ] 2.2.1.2.4 Note: Used by UI for initial world state

---

## 2.2.2 Implement handle_call Callback

Add the server-side handler for the UI state query.

### 2.2.2.1 Add handle_call Clause

Implement the GenServer callback for handling the query.

- [ ] 2.2.2.1.1 Locate the `handle_call/3` section in Plane
- [ ] 2.2.2.1.2 Add new clause: `def handle_call(:get_full_state_for_ui, _from, state)`
- [ ] 2.2.2.1.3 Build response map with all required fields:
  ```elixir
  %{
    width: state.width,
    height: state.height,
    nest_location: state.nest_location,
    food_sources: Enum.map(state.food_sources, fn {{x, y}, food} ->
      %{pos: {x, y}, level: food.level, quantity: food.quantity}
    end)
  }
  ```
- [ ] 2.2.2.1.4 Return `{:reply, response_map, state}`

### 2.2.2.2 Transform Food Sources Map

Convert food sources map to list format for UI consumption.

- [ ] 2.2.2.2.1 Use `Enum.map/2` to iterate over state.food_sources
- [ ] 2.2.2.2.2 Transform keys `{x, y}` to `pos: {x, y}` in result map
- [ ] 2.2.2.2.3 Include `level` field from food source struct
- [ ] 2.2.2.2.4 Include `quantity` field from food source struct
- [ ] 2.2.2.2.5 Return empty list `[]` when no food sources exist

### 2.2.2.3 Validate Response Structure

Ensure the response matches expected UI format.

- [ ] 2.2.2.3.1 Include `width` field in response (integer)
- [ ] 2.2.2.3.2 Include `height` field in response (integer)
- [ ] 2.2.2.3.3 Include `nest_location` field in response ({x, y} tuple)
- [ ] 2.2.2.3.4 Include `food_sources` field in response (list of maps)
- [ ] 2.2.2.3.5 Exclude `ant_positions` from response (UI tracks via events)

---

## 2.2.3 Add Type Specifications

Define types for the UI state response.

### 2.2.3.1 Define UI Food Source Type

Create type spec for food source in UI format.

- [ ] 2.2.3.1.1 Add `@type ui_food_source :: %{pos: {integer(), integer()}, level: 1..5, quantity: pos_integer()}`
- [ ] 2.2.3.1.2 Export type for use in UI module
- [ ] 2.2.3.1.3 Document type in @moduledoc

### 2.2.3.2 Define UI State Response Type

Create type spec for the full state response.

- [ ] 2.2.3.2.1 Add `@type ui_state :: %{width: pos_integer(), height: pos_integer(), nest_location: {integer(), integer()}, food_sources: [ui_food_source()]}`
- [ ] 2.2.3.2.2 Use this type in get_full_state_for_ui/0 @spec
- [ ] 2.2.3.2.3 Export type for use in UI module

### 2.2.3.3 Update Existing Plane Types

Update Plane module types if needed.

- [ ] 2.2.3.3.1 Ensure existing types are compatible
- [ ] 2.2.3.3.2 Add new types to @typedoc if appropriate
- [ ] 2.2.3.3.3 Maintain consistency with Phase 1 Plane state types

---

## 2.2.4 Unit Tests for Plane UI API

Test the new get_full_state_for_ui/0 function.

### 2.2.4.1 Test Returns Correct Structure

Verify the response has all required fields.

- [ ] 2.2.4.1.1 Create or update `test/ant_colony/plane_test.exs`
- [ ] 2.2.4.1.2 Add test: `test "get_full_state_for_ui returns map"` - check is_map
- [ ] 2.2.4.1.3 Add test: `test "get_full_state_for_ui includes width"` - check key exists
- [ ] 2.2.4.1.4 Add test: `test "get_full_state_for_ui includes height"` - check key exists
- [ ] 2.2.4.1.5 Add test: `test "get_full_state_for_ui includes nest_location"` - check key exists
- [ ] 2.2.4.1.6 Add test: `test "get_full_state_for_ui includes food_sources"` - check key exists

### 2.2.4.2 Test Field Values Are Correct

Verify the values in the response match Plane state.

- [ ] 2.2.4.2.1 Add test: `test "get_full_state_for_ui returns correct width"` - value match
- [ ] 2.2.4.2.2 Add test: `test "get_full_state_for_ui returns correct height"` - value match
- [ ] 2.2.4.2.3 Add test: `test "get_full_state_for_ui returns correct nest_location"` - value match
- [ ] 2.2.4.2.4 Add test: `test "get_full_state_for_ui returns correct food count"` - list length

### 2.2.4.3 Test Food Sources List Format

Verify food sources are correctly formatted.

- [ ] 2.2.4.3.1 Add test: `test "food_sources use pos key"` - check structure
- [ ] 2.2.4.3.2 Add test: `test "food_sources include level"` - check field exists
- [ ] 2.2.4.3.3 Add test: `test "food_sources include quantity"` - check field exists
- [ ] 2.2.4.3.4 Add test: `test "empty food_sources returns empty list"` - empty case

### 2.2.4.4 Test Does Not Include Internal State

Verify ant_positions is excluded from response.

- [ ] 2.2.4.4.1 Add test: `test "get_full_state_for_ui excludes ant_positions"` - check not included
- [ ] 2.2.4.4.2 Add test: `test "get_full_state_for_ui excludes pheromones"` - if implemented
- [ ] 2.2.4.4.3 Add test: `test "get_full_state_for_ui is a snapshot"` - immutability

---

## 2.2.5 Phase 2.2 Integration Tests

End-to-end tests for Plane UI API.

### 2.2.5.1 UI Initialization Test

Test that UI can fetch initial state from Plane.

- [ ] 2.2.5.1.1 Create `test/ant_colony/integration/plane_ui_api_integration_test.exs`
- [ ] 2.2.5.1.2 Add setup starting Plane with known state
- [ ] 2.2.5.1.3 Add test: `test "UI can fetch initial state from Plane"` - call function
- [ ] 2.2.5.1.4 Add test: `test "fetched state matches Plane state"` - value equality
- [ ] 2.2.5.1.5 Add test: `test "fetched state is independent of Plane state"` - copy behavior

### 2.2.5.2 Multiple Queries Test

Test that multiple queries work correctly.

- [ ] 2.2.5.2.1 Add test: `test "multiple calls to get_full_state_for_ui work"` - sequential calls
- [ ] 2.2.5.2.2 Add test: `test "concurrent calls to get_full_state_for_ui work"` - concurrent calls
- [ ] 2.2.5.2.3 Add test: `test "state changes are reflected in subsequent calls"` - dynamic behavior

### 2.2.5.3 Empty World Test

Test behavior when Plane has minimal state.

- [ ] 2.2.5.3.1 Add test: `test "get_full_state_for_ui works with no food"` - empty food
- [ ] 2.2.5.3.2 Add test: `test "get_full_state_for_ui works with no ants"` - no ants registered
- [ ] 2.2.5.3.3 Add test: `test "get_full_state_for_ui works with default dimensions"` - default config

---

## Phase 2.2 Success Criteria

1. **Client Function**: get_full_state_for_ui/0 defined ✅
2. **Server Callback**: handle_call processes query ✅
3. **Response Format**: Returns map with all required fields ✅
4. **Food Sources**: Correctly formatted as list of maps ✅
5. **Type Specs**: Complete type specifications added ✅
6. **Tests**: All unit and integration tests pass ✅

## Phase 2.2 Critical Files

**New Files:**
- `test/ant_colony/integration/plane_ui_api_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/plane.ex` - Add get_full_state_for_ui/0 API
- `test/ant_colony/plane_test.exs` - Add UI API tests

---

## Next Phase

Proceed to [Phase 2.3: UI Module Structure](./03-ui-module-structure.md) to create the AntColonyUI module with TermUI.Elm.
