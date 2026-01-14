# Phase 2.3: UI Module Structure

Create the AntColony.UI module using the TermUI.Elm architecture pattern. This module subscribes to simulation events and renders the visualization.

## Architecture

```
AntColony.UI (TermUI.Elm)
├── State:
│   ├── width: integer()
│   ├── height: integer()
│   ├── nest_location: {x, y}
│   ├── food_sources: [%{pos: {x, y}, level: 1-5, quantity: integer()}]
│   ├── ant_positions: %{ant_id => {x, y, carrying_food?}}
│   └── running: boolean()
│
├── init/1 (TermUI.Elm callback)
│   ├── Subscribe to Phoenix.PubSub "ui_updates" topic
│   ├── Fetch initial state from Plane.get_full_state_for_ui/0
│   └── Return {:ok, initial_ui_state}
│
├── update/2 (TermUI.Elm callback)
│   ├── Handle {:ant_moved, ant_id, old_pos, new_pos}
│   ├── Handle {:food_updated, pos, new_quantity}
│   ├── Handle {:ant_registered, ant_id, position}
│   ├── Handle {:ant_unregistered, ant_id}
│   ├── Handle %TermUI.Event.Key{key: "q"} -> [:quit]
│   └── Return {:noreply, updated_state} | {:noreply, state, commands}
│
└── view/1 (TermUI.Elm callback)
    ├── Create TermUI.Widget.Canvas
    ├── Draw grid background
    ├── Draw nest, food sources, ants
    └── Return widget tree
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.UI | Main UI module using TermUI.Elm |
| UI.State | Internal UI state struct |
| UI.init/1 | Initialize UI state and subscriptions |
| UI.update/2 | Handle events and update state |
| UI.view/1 | Render Canvas widget |

---

## 2.3.1 Create UI Module File

Set up the basic UI module structure.

### 2.3.1.1 Create UI Module File

Create the module file with TermUI.Elm behavior.

- [ ] 2.3.1.1.1 Create `lib/ant_colony/ui.ex`
- [ ] 2.3.1.1.2 Add `defmodule AntColony.UI`
- [ ] 2.3.1.1.3 Add `use TermUI.Elm` to adopt Elm architecture
- [ ] 2.3.1.1.4 Add `require Logger` for logging
- [ ] 2.3.1.1.5 Add comprehensive `@moduledoc` with usage example

### 2.3.1.2 Define State Struct

Define the UI state structure.

- [ ] 2.3.1.2.1 Add `defstruct` with fields:
  - `:width` - default 80
  - `:height` - default 24
  - `:nest_location` - default nil
  - `:food_sources` - default []
  - `:ant_positions` - default %{}
  - `:running` - default true
- [ ] 2.3.1.2.2 Add `@type` specification for state struct
- [ ] 2.3.1.2.3 Document each field in struct

### 2.3.1.3 Add Module Dependencies

Import required modules.

- [ ] 2.3.1.3.1 Add `alias AntColony.Plane`
- [ ] 2.3.1.3.2 Add `alias AntColony.PubSub`
- [ ] 2.3.1.3.3 Add `import TermUI.Widget, only: [canvas: 2]`
- [ ] 2.3.1.3.4 Verify TermUI.Elm exports required callbacks

---

## 2.3.2 Implement init/1 Callback

Initialize the UI with PubSub subscription and initial world state.

### 2.3.2.1 Define init/1 Function

Implement the TermUI.Elm init callback.

- [ ] 2.3.2.1.1 Define `def init(opts)` function
- [ ] 2.3.2.1.2 Extract any options from opts (e.g., auto_start)
- [ ] 2.3.2.1.3 Call `Plane.get_full_state_for_ui()` to fetch initial state
- [ ] 2.3.2.1.4 Build initial UI state struct from Plane response
- [ ] 2.3.2.1.5 Subscribe to Phoenix.PubSub topic "ui_updates"
- [ ] 2.3.2.1.6 Return `{:ok, ui_state}`

### 2.3.2.2 Subscribe to PubSub

Set up PubSub subscription for simulation events.

- [ ] 2.3.2.2.1 Call `Phoenix.PubSub.subscribe(AntColony.PubSub, "ui_updates")`
- [ ] 2.3.2.2.2 Store subscription reference if needed
- [ ] 2.3.2.2.3 Handle subscription errors gracefully
- [ ] 2.3.2.2.4 Document subscribed event types in @moduledoc

### 2.3.2.3 Build Initial UI State

Transform Plane state to UI state format.

- [ ] 2.3.2.3.1 Extract width from Plane response
- [ ] 2.3.2.3.2 Extract height from Plane response
- [ ] 2.3.2.3.3 Extract nest_location from Plane response
- [ ] 2.3.2.3.4 Extract food_sources from Plane response
- [ ] 2.3.2.3.5 Initialize ant_positions as empty map (populated via events)
- [ ] 2.3.2.3.6 Set running to true

---

## 2.3.3 Implement update/2 Callback

Handle incoming events and update UI state.

### 2.3.3.1 Handle ant_moved Events

Update ant positions on movement events.

- [ ] 2.3.3.1.1 Add clause: `def update({:ant_moved, ant_id, old_pos, new_pos}, state)`
- [ ] 2.3.3.1.2 Update `ant_positions` map with new position
- [ ] 2.3.3.1.3 Store position as `{x, y, carrying_food?}` tuple
- [ ] 2.3.3.1.4 Return `{:noreply, updated_state}`

### 2.3.3.2 Handle food_updated Events

Update food sources on food quantity changes.

- [ ] 2.3.3.2.1 Add clause: `def update({:food_updated, pos, new_quantity}, state)`
- [ ] 2.3.3.2.2 Find food source in food_sources list by position
- [ ] 2.3.3.2.3 Update quantity field (remove if 0)
- [ ] 2.3.3.2.4 Return `{:noreply, updated_state}`

### 2.3.3.3 Handle ant_registered Events

Track new ants joining the simulation.

- [ ] 2.3.3.3.1 Add clause: `def update({:ant_registered, ant_id, position}, state)`
- [ ] 2.3.3.3.2 Add new ant to ant_positions map
- [ ] 2.3.3.3.3 Initialize with carrying_food: false
- [ ] 2.3.3.3.4 Return `{:noreply, updated_state}`

### 2.3.3.4 Handle ant_unregistered Events

Remove ants that have left the simulation.

- [ ] 2.3.3.4.1 Add clause: `def update({:ant_unregistered, ant_id}, state)`
- [ ] 2.3.3.4.2 Remove ant from ant_positions map
- [ ] 2.3.3.4.3 Return `{:noreply, updated_state}`

### 2.3.3.5 Handle Keyboard Events

Enable quit functionality via keyboard.

- [ ] 2.3.3.5.1 Add clause: `def update(%TermUI.Event.Key{key: "q"}, state)`
- [ ] 2.3.3.5.2 Set running to false
- [ ] 2.3.3.5.3 Return `{:noreply, updated_state, [:quit]}`
- [ ] 2.3.3.5.4 Document quit key in help text

### 2.3.3.6 Handle Window Events

Handle terminal resize events (optional).

- [ ] 2.3.3.6.1 Add clause: `def update(%TermUI.Event.Window{event: :resized}, state)`
- [ ] 2.3.3.6.2 Update width and height from terminal size
- [ ] 2.3.3.6.3 Return `{:noreply, updated_state}`

### 2.3.3.7 Handle Unknown Events

Catch-all for unexpected messages.

- [ ] 2.3.3.7.1 Add catch-all clause: `def update(msg, state)`
- [ ] 2.3.3.7.2 Log unknown message with Logger.debug
- [ ] 2.3.3.7.3 Return `{:noreply, state}` unchanged

---

## 2.3.4 Implement view/1 Callback

Render the UI state as a widget tree.

### 2.3.4.1 Define view/1 Function

Implement the TermUI.Elm view callback.

- [ ] 2.3.4.1.1 Define `def view(state)` function
- [ ] 2.3.4.1.2 Create Canvas widget with dimensions from state
- [ ] 2.3.4.1.3 Call helper functions to draw elements
- [ ] 2.3.4.1.4 Return widget tree

### 2.3.4.2 Create Canvas Widget

Set up the canvas for rendering.

- [ ] 2.3.4.2.1 Call `TermUI.Widget.canvas(state.width, state.height)`
- [ ] 2.3.4.2.2 Store canvas reference for drawing operations
- [ ] 2.3.4.2.3 Configure canvas properties (color, attributes)
- [ ] 2.3.4.2.4 Return canvas as root widget

### 2.3.4.3 Draw Nest

Render the nest location.

- [ ] 2.3.4.3.1 Extract nest coordinates from state.nest_location
- [ ] 2.3.4.3.2 Draw "N" character at nest position
- [ ] 2.3.4.3.3 Apply white color attribute
- [ ] 2.3.4.3.4 Handle case where nest_location is nil

### 2.3.4.4 Draw Food Sources

Render all food sources.

- [ ] 2.3.4.4.1 Iterate over state.food_sources list
- [ ] 2.3.4.4.2 Extract position and level from each food source
- [ ] 2.3.4.4.3 Draw "F" or "F{level}" at food position
- [ ] 2.3.4.4.4 Apply yellow/red color based on level
- [ ] 2.3.4.4.5 Skip drawing if quantity is 0

### 2.3.4.5 Draw Ants

Render all ant positions.

- [ ] 2.3.4.5.1 Iterate over state.ant_positions map
- [ ] 2.3.4.5.2 Extract ant_id and position tuple
- [ ] 2.3.4.5.3 Draw "a" (no food) or "A" (with food) at position
- [ ] 2.3.4.5.4 Apply red color
- [ ] 2.3.4.5.5 Handle multiple ants at same position (optional)

---

## 2.3.5 Add Start/Stop Functions

Create lifecycle management functions for the UI.

### 2.3.5.1 Implement start_link/1

Start the UI process.

- [ ] 2.3.5.1.1 Define `def start_link(opts \\ [])`
- [ ] 2.3.5.1.2 Call `TermUI.start_link(__MODULE__, opts, name: __MODULE__)`
- [ ] 2.3.5.1.3 Return `{:ok, pid}` or `{:error, reason}`

### 2.3.5.2 Implement child_spec/1

Define child spec for supervision tree.

- [ ] 2.3.5.2.1 Define `def child_spec(opts)`
- [ ] 2.3.5.2.2 Build child spec map with id, start, restart
- [ ] 2.3.5.2.3 Set restart to :temporary (UI shouldn't restart automatically)
- [ ] 2.3.5.2.4 Return child spec

---

## 2.3.6 Unit Tests for UI Module

Test the UI module functionality.

### 2.3.6.1 Test init/1 Callback

Verify UI initializes correctly.

- [ ] 2.3.6.1.1 Create `test/ant_colony/ui_test.exs`
- [ ] 2.3.6.1.2 Add test: `test "init/1 subscribes to ui_updates topic"` - check subscription
- [ ] 2.3.6.1.3 Add test: `test "init/1 fetches state from Plane"` - verify Plane call
- [ ] 2.3.6.1.4 Add test: `test "init/1 builds correct initial state"` - state structure
- [ ] 2.3.6.1.5 Add test: `test "init/1 handles empty Plane state"` - edge case

### 2.3.6.2 Test update/2 Callback - ant_moved

Verify ant movement updates state.

- [ ] 2.3.6.2.1 Add test: `test "update/2 handles ant_moved event"` - position update
- [ ] 2.3.6.2.2 Add test: `test "update/2 updates ant_positions map"` - map modification
- [ ] 2.3.6.2.3 Add test: `test "update/2 tracks new ant"` - new ant_id
- [ ] 2.3.6.2.4 Add test: `test "update/2 preserves other ant positions"` - isolation

### 2.3.6.3 Test update/2 Callback - food_updated

Verify food updates work correctly.

- [ ] 2.3.6.3.1 Add test: `test "update/2 handles food_updated event"` - quantity update
- [ ] 2.3.6.3.2 Add test: `test "update/2 removes depleted food"` - quantity 0
- [ ] 2.3.6.3.3 Add test: `test "update/2 preserves other food sources"` - isolation

### 2.3.6.4 Test update/2 Callback - ant lifecycle

Verify ant registration/unregistration.

- [ ] 2.3.6.4.1 Add test: `test "update/2 handles ant_registered event"` - new ant
- [ ] 2.3.6.4.2 Add test: `test "update/2 handles ant_unregistered event"` - remove ant
- [ ] 2.3.6.4.3 Add test: `test "update/2 handles unknown ant_id"` - error handling

### 2.3.6.5 Test update/2 Callback - quit key

Verify quit functionality.

- [ ] 2.3.6.5.1 Add test: `test "update/2 returns :quit command for 'q' key"` - quit command
- [ ] 2.3.6.5.2 Add test: `test "update/2 sets running to false on quit"` - state update
- [ ] 2.3.6.5.3 Add test: `test "update/2 ignores other keys"` - filter

### 2.3.6.6 Test view/1 Callback

Verify rendering works.

- [ ] 2.3.6.6.1 Add test: `test "view/1 returns Canvas widget"` - widget type
- [ ] 2.3.6.6.2 Add test: `test "view/1 uses state dimensions"` - dimensions
- [ ] 2.3.6.6.3 Add test: `test "view/1 handles empty state"` - edge case
- [ ] 2.3.6.6.4 Add test: `test "view/1 renders nest"` - nest rendering

### 2.3.6.7 Test State Transformations

Verify state management.

- [ ] 2.3.6.7.1 Add test: `test "state is immutable across updates"` - immutability
- [ ] 2.3.6.7.2 Add test: `test "multiple updates accumulate correctly"` - accumulation
- [ ] 2.3.6.7.3 Add test: `test "state structure matches expected format"` - structure

---

## 2.3.7 Phase 2.3 Integration Tests

End-to-end tests for UI module.

### 2.3.7.1 UI Initialization Test

Test UI starts and connects to simulation.

- [ ] 2.3.7.1.1 Create `test/ant_colony/integration/ui_module_integration_test.exs`
- [ ] 2.3.7.1.2 Add setup starting Application with Plane
- [ ] 2.3.7.1.3 Add test: `test "UI module starts successfully"` - start_link
- [ ] 2.3.7.1.4 Add test: `test "UI subscribes to PubSub topic"` - subscription verification
- [ ] 2.3.7.1.5 Add test: `test "UI fetches initial Plane state"` - Plane interaction

### 2.3.7.2 Event Flow Test

Test UI receives simulation events.

- [ ] 2.3.7.2.1 Add test: `test "UI receives ant_moved events"` - event reception
- [ ] 2.3.7.2.2 Add test: `test "UI state updates on events"` - state changes
- [ ] 2.3.7.2.3 Add test: `test "UI handles multiple event types"` - mixed events
- [ ] 2.3.7.2.4 Add test: `test "UI doesn't crash on malformed events"` - fault tolerance

### 2.3.7.3 Rendering Test

Test UI renders correctly.

- [ ] 2.3.7.3.1 Add test: `test "view/1 generates valid widget tree"` - widget validation
- [ ] 2.3.7.3.2 Add test: `test "UI renders nest at correct position"` - position accuracy
- [ ] 2.3.7.3.3 Add test: `test "UI renders all food sources"` - completeness
- [ ] 2.3.7.3.4 Add test: `test "UI renders all ants"` - ant rendering

### 2.3.7.4 UI Lifecycle Test

Test UI start/stop behavior.

- [ ] 2.3.7.4.1 Add test: `test "UI stops cleanly on quit"` - graceful shutdown
- [ ] 2.3.7.4.2 Add test: `test "UI unsubscribes on stop"` - cleanup
- [ ] 2.3.7.4.3 Add test: `test "UI can restart after stop"` - restart

---

## Phase 2.3 Success Criteria

1. **UI Module**: TermUI.Elm module compiles ✅
2. **init/1**: Subscribes to PubSub, fetches Plane state ✅
3. **update/2**: Handles all event types correctly ✅
4. **view/1**: Returns valid Canvas widget tree ✅
5. **Quit**: 'q' key triggers quit command ✅
6. **State**: UI state structure matches design ✅
7. **Tests**: All unit and integration tests pass ✅

## Phase 2.3 Critical Files

**New Files:**
- `lib/ant_colony/ui.ex` - Main UI module
- `test/ant_colony/ui_test.exs` - UI unit tests
- `test/ant_colony/integration/ui_module_integration_test.exs` - Integration tests

**Modified Files:**
- None

---

## Next Phase

Proceed to [Phase 2.4: Canvas Rendering](./04-canvas-rendering.md) to implement detailed Canvas drawing operations.
