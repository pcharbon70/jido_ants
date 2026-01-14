# Phase 3.5: UI Controls and Polish

Implement user controls for interacting with the simulation and polish the visual presentation. This cycle adds pause/resume, speed adjustment, enhanced status displays, confirmation dialogs, manual generation trigger, and overall visual refinements.

## Architecture

```
UI Controls System
├── User Controls:
│   ├── Pause/Resume (SPACE)
│   ├── Speed Up (+) / Slow Down (-)
│   ├── Quit with Confirmation (q)
│   ├── Trigger Next Generation (G)
│   ├── Toggle Pheromones (p)
│   ├── Toggle Communications (c)
│   └── Reset Simulation (Ctrl+R)
│
├── Simulation Controller:
│   └── AntColony.Controller (GenServer)
│       ├── paused: boolean()
│       ├── speed_multiplier: float()
│       └── Handles UI commands
│
├── Enhanced UI Elements:
│   ├── Status Bar (bottom)
│   │   ├── Generation ID and progress
│   │   ├── Ant count, carrying count
│   │   ├── Total food collected
│   │   ├── Simulation time
│   │   ├── FPS indicator
│   │   ├── Speed: 1x, 2x, etc.
│   │   └── PAUSED indicator
│   ├── Info Panel (optional side panel)
│   │   ├── Legend
│   │   ├── Controls help
│   │   └── Selected ant info
│   └── Confirmation Dialog
│       ├── AlertDialog for quit
│       └── Yes/No buttons
│
└── Visual Polish:
    ├── Color scheme refinement
    ├── Character choices optimization
    └── Layout improvements
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Simulation Controller | Manage simulation state (pause, speed) |
| Pause/Resume Control | Stop/start simulation |
| Speed Control | Adjust simulation speed |
| Enhanced Status Bar | Comprehensive simulation info |
| Confirmation Dialog | Prevent accidental quit |
| Visual Refinements | Improved colors, characters, layout |

---

## 3.5.1 Create Simulation Controller

Implement a controller for simulation-wide state.

### 3.5.1.1 Create Controller Module

Set up the controller GenServer.

- [ ] 3.5.1.1.1 Create `lib/ant_colony/controller.ex`
- [ ] 3.5.1.1.2 Add `defmodule AntColony.Controller`
- [ ] 3.5.1.1.3 Add `use GenServer`
- [ ] 3.5.1.1.4 Add comprehensive `@moduledoc`

### 3.5.1.2 Define Controller State

Define the controller's internal state.

- [ ] 3.5.1.2.1 Add `defstruct` with fields:
  - `:paused` - boolean, default: `false`
  - `:speed_multiplier` - float, default: `1.0`
  - `:simulation_time` - integer, default: `0` (ticks)
  - `:start_time` - DateTime, default: `DateTime.utc_now()`
  - `:subscribers` - list of pids to notify on state changes
- [ ] 3.5.1.2.2 Add `@type` specifications

### 3.5.1.3 Implement init/1 Callback

Initialize the controller.

- [ ] 3.5.1.3.1 Define `def init(opts)` function
- [ ] 3.5.1.3.2 Subscribe to `"sim_commands"` PubSub topic
- [ ] 3.5.1.3.3 Initialize state with defaults
- [ ] 3.5.1.3.4 Start simulation ticker via `Process.send_after`
- [ ] 3.5.1.3.5 Return `{:ok, initial_state}`

### 3.5.1.4 Implement Pause/Resume API

Create API for pausing and resuming.

- [ ] 3.5.1.4.1 Define client function: `def pause()`
- [ ] 3.5.1.4.2 Implement as `GenServer.call(__MODULE__, :pause)`
- [ ] 3.5.1.4.3 Add handle_call for `:pause`
- [ ] 3.5.1.4.4 Set `paused: true` in state
- [ ] 3.5.1.4.5 Publish `{:simulation_paused}` event
- [ ] 3.5.1.4.6 Return `{:reply, :ok, updated_state}`

- [ ] 3.5.1.4.7 Define client function: `def resume()`
- [ ] 3.5.1.4.8 Implement as `GenServer.call(__MODULE__, :resume)`
- [ ] 3.5.1.4.9 Add handle_call for `:resume`
- [ ] 3.5.1.4.10 Set `paused: false` in state
- [ ] 3.5.1.4.11 Publish `{:simulation_resumed}` event
- [ ] 3.5.1.4.12 Return `{:reply, :ok, updated_state}`

- [ ] 3.5.1.4.13 Define client function: `def toggle_pause()`
- [ ] 3.5.1.4.14 Toggle current pause state
- [ ] 3.5.1.4.15 Return `{:ok, :paused | :resumed}`

### 3.5.1.5 Implement Speed Control API

Create API for adjusting simulation speed.

- [ ] 3.5.1.5.1 Define client function: `def set_speed(multiplier)`
- [ ] 3.5.1.5.2 Implement as `GenServer.call(__MODULE__, {:set_speed, multiplier})`
- [ ] 3.5.1.5.3 Add handle_call for `:set_speed`
- [ ] 3.5.1.5.4 Validate multiplier (0.1 to 10.0)
- [ ] 3.5.1.5.5 Update `speed_multiplier` in state
- [ ] 3.5.1.5.6 Publish `{:speed_changed, new_multiplier}` event
- [ ] 3.5.1.5.7 Return `{:reply, :ok, updated_state}`

- [ ] 3.5.1.5.8 Define client function: `def increase_speed()` and `def decrease_speed()`
- [ ] 3.5.1.5.9 Adjust by factor of 1.5 (clamp to 0.1-10.0)

### 3.5.1.6 Implement get_status API

Create API for querying controller state.

- [ ] 3.5.1.6.1 Define client function: `def get_status()`
- [ ] 3.5.1.6.2 Implement as `GenServer.call(__MODULE__, :get_status)`
- [ ] 3.5.1.6.3 Add handle_call for `:get_status`
- [ ] 3.5.1.6.4 Return status map:
  ```elixir
  %{
    paused: state.paused,
    speed_multiplier: state.speed_multiplier,
    simulation_time: state.simulation_time,
    uptime: DateTime.diff(DateTime.utc_now(), state.start_time)
  }
  ```

### 3.5.1.7 Implement Reset API

Create API for resetting the simulation.

- [ ] 3.5.1.7.1 Define client function: `def reset()`
- [ ] 3.5.1.7.2 Implement as `GenServer.call(__MODULE__, :reset)`
- [ ] 3.5.1.7.3 Add handle_call for `:reset`
- [ ] 3.5.1.7.4 Reset simulation_time to 0
- [ ] 3.5.1.7.5 Reset start_time to now
- [ ] 3.5.1.7.6 Publish `{:simulation_reset}` event
- [ ] 3.5.1.7.7 Return `{:reply, :ok, reset_state}`

---

## 3.5.2 Add Controller to Application

Integrate controller with supervision tree.

### 3.5.2.1 Add Controller Child Spec

Add controller to application children.

- [ ] 3.5.2.1.1 Open `lib/ant_colony/application.ex`
- [ ] 3.5.2.1.2 Add `{AntColony.Controller, []}` to children list
- [ ] 3.5.2.1.3 Ensure it starts after PubSub
- [ ] 3.5.2.1.4 Document controller in supervision comments

### 3.5.2.2 Connect Controller to Actions

Update actions to respect pause state.

- [ ] 3.5.2.2.1 Open `lib/ant_colony/actions/move_action.ex`
- [ ] 3.5.2.2.2 In run/2, check if controller is paused
- [ ] 3.5.2.2.3 If paused:
  - Return `{:ok, context.state}` without moving
  - Or return `{:error, :paused}`
- [ ] 3.5.2.2.4 Add `:ignore_pause` option for critical actions

### 3.5.2.3 Connect Speed to Timers

Adjust agent action timing based on speed.

- [ ] 3.5.2.3.1 Check controller's speed_multiplier before scheduling
- [ ] 3.5.2.3.2 Calculate adjusted delay: `base_delay / speed_multiplier`
- [ ] 3.5.2.3.3 Use Process.send_after with adjusted delay
- [ ] 3.5.2.3.4 Handle dynamic speed changes

---

## 3.5.3 Implement Pause/Resume Control

Add keyboard control for pause/resume.

### 3.5.3.1 Handle Space Key in UI

Process pause/resume keypress.

- [ ] 3.5.3.1.1 Open `lib/ant_colony/ui.ex`
- [ ] 3.5.3.1.2 Add update clause for `%Event.Key{key: " "}` (space)
- [ ] 3.5.3.1.3 Call `Controller.toggle_pause()`
- [ ] 3.5.3.1.4 Update UI state with pause status
- [ ] 3.5.3.1.5 Return `{:noreply, updated_state}`

### 3.5.3.2 Display Pause Indicator

Show PAUSED status when simulation is stopped.

- [ ] 3.5.3.2.1 Add `:paused` field to UI state
- [ ] 3.5.3.2.2 Update on `:simulation_paused` and `:simulation_resumed` events
- [ ] 3.5.3.2.3 In view/1, if paused:
  - Draw large "PAUSED" text centered on canvas
  - Use bright color (yellow or white)
  - Add transparent overlay if possible
- [ ] 3.5.3.2.4 Show in status bar when paused

### 3.5.3.3 Pause Agent Actions

Ensure agents respect pause state.

- [ ] 3.5.3.3.1 Add `handle_info` for `:simulation_paused` in Agent
- [ ] 3.5.3.3.2 Set internal paused flag
- [ ] 3.5.3.3.3 Skip action execution when paused
- [ ] 3.5.3.3.4 Resume on `:simulation_resumed`

---

## 3.5.4 Implement Speed Control

Add keyboard controls for simulation speed.

### 3.5.4.1 Handle Plus/Minus Keys

Process speed adjustment keypresses.

- [ ] 3.5.4.1.1 Add update clause for `%Event.Key{key: "+"}` or `=` key
- [ ] 3.5.4.1.2 Call `Controller.increase_speed()`
- [ ] 3.5.4.1.3 Update UI state with new speed
- [ ] 3.5.4.1.4 Return `{:noreply, updated_state}`

- [ ] 3.5.4.1.5 Add update clause for `%Event.Key{key: "-"}` or `_` key
- [ ] 3.5.4.1.6 Call `Controller.decrease_speed()`
- [ ] 3.5.4.1.7 Update UI state with new speed
- [ ] 3.5.4.1.8 Return `{:noreply, updated_state}`

### 3.5.4.2 Display Speed Indicator

Show current speed multiplier.

- [ ] 3.5.4.2.1 Add `:speed_multiplier` to UI state
- [ ] 3.5.4.2.2 Update on `:speed_changed` events
- [ ] 3.5.4.2.3 Display in status bar: `"Speed: #{multiplier}x"`
- [ ] 3.5.4.2.4 Use color coding:
  - 0.5x: blue (slow)
  - 1.0x: white (normal)
  - 2.0x+: yellow (fast)
  - 5.0x+: red (very fast)

---

## 3.5.5 Implement Manual Generation Trigger

Add keyboard control for manual generation transition (debugging).

### 3.5.5.1 Handle G Key for Generation Trigger

Process manual generation trigger keypress.

- [ ] 3.5.5.1.1 Add update clause for `%Event.Key{key: "G"}` or `"g"`
- [ ] 3.5.5.1.2 Call `ColonyIntelligenceAgent.spawn_next_generation()` via action dispatch
- [ ] 3.5.5.1.3 Show feedback: "Triggering next generation..."
- [ ] 3.5.5.1.4 Update UI state with `:generation_trigger_pending` flag
- [ ] 3.5.5.1.5 Return `{:noreply, updated_state}`

### 3.5.5.2 Display Generation Trigger Feedback

Show user feedback for manual trigger.

- [ ] 3.5.5.2.1 Add `:generation_trigger_pending` to UI state
- [ ] 3.5.5.2.2 Add `:generation_trigger_message` to UI state
- [ ] 3.5.5.2.3 When trigger pending:
  - Display message: "Forcing generation transition..."
  - Show for 2-3 seconds
  - Use bright color (yellow/cyan)
- [ ] 3.5.5.2.4 Clear pending flag when generation starts

### 3.5.5.3 Handle Trigger Errors

Gracefully handle trigger failures.

- [ ] 3.5.5.3.1 Add error handling for trigger action
- [ ] 3.5.5.3.2 On error, display: "Generation trigger failed: {reason}"
- [ ] 3.5.5.3.3 Use red color for error message
- [ ] 3.5.5.3.4 Clear error after display duration

---

## 3.5.6 Implement Enhanced Status Bar

Create comprehensive status display.

### 3.5.6.1 Design Status Bar Layout

Plan status bar sections.

- [ ] 3.5.6.1.1 Define sections left to right:
  1. Generation ID and progress
  2. Ant counts (total, carrying)
  3. Food collected
  4. Simulation time
  5. Speed
  6. Pause state
  7. FPS
- [ ] 3.5.6.1.2 Plan separators: `" | "`
- [ ] 3.5.6.1.3 Allocate minimum widths for each section

### 3.5.6.2 Implement Status Bar Widget

Create the status bar rendering.

- [ ] 3.5.6.2.1 Define `defp status_bar(state)` function
- [ ] 3.5.6.2.2 Build status string:
  ```elixir
  gen = "Gen: #{state.current_generation_id}(#{state.food_delivered_count}/#{state.generation_trigger_count})"
  ants = "Ants: #{total}(#{carrying})"
  food = "Food: #{total_collected}"
  time = format_time(state.simulation_time)
  speed = "Speed: #{state.speed_multiplier}x"
  pause = if state.paused, do: "[PAUSED]", else: ""
  fps = "FPS: #{state.fps || "?"}"
  ```
- [ ] 3.5.6.2.3 Combine with separators
- [ ] 3.5.6.2.4 Return `TermUI.Widget.text(status, style)`
- [ ] 3.5.6.2.5 Use background color for visibility

### 3.5.6.3 Add FPS Counter

Track and display frame rate.

- [ ] 3.5.6.3.1 Add `:last_frame_time` to UI state
- [ ] 3.5.6.3.2 Add `:fps` to UI state
- [ ] 3.5.6.3.3 In view/1, calculate FPS:
  - `now = System.monotonic_time(:millisecond)`
  - `delta = now - state.last_frame_time`
  - `fps = round(1000 / delta)`
- [ ] 3.5.6.3.4 Update state with new FPS
- [ ] 3.5.6.3.5 Display in status bar

### 3.5.6.4 Add Simulation Time Display

Format and display simulation time.

- [ ] 3.5.6.4.1 Get simulation_time from Controller
- [ ] 3.5.6.4.2 Format as MM:SS or HH:MM:SS
- [ ] 3.5.6.4.3 Display in status bar
- [ ] 3.5.6.4.4 Update periodically (not every frame)

### 3.5.6.5 Add Generation Info Display

Show generation ID and progress.

- [ ] 3.5.6.5.1 Add `:current_generation_id` to UI state
- [ ] 3.5.6.5.2 Add `:food_delivered_count` to UI state
- [ ] 3.5.6.5.3 Add `:generation_trigger_count` to UI state
- [ ] 3.5.6.5.4 Display in status bar: `"Gen: #{gen_id}(#{count}/#{trigger})"`
- [ ] 3.5.6.5.5 Update on generation events

### 3.5.6.6 Add ML Metrics Display

Show model training progress.

- [ ] 3.5.6.6.1 Add to status bar if ML is enabled
- [ ] 3.5.6.6.2 Display: `"ML: E#{epoch} L#{loss}"`
- [ ] 3.5.6.6.3 Use abbreviated format for space
- [ ] 3.5.6.6.4 Color-code based on loss (green=low, red=high)

---

## 3.5.7 Implement Quit Confirmation

Add dialog to prevent accidental exit.

### 3.5.7.1 Add Confirm Dialog State

Track quit confirmation state.

- [ ] 3.5.7.1.1 Add `:show_quit_confirm` to UI state (default: `false`)
- [ ] 3.5.7.1.2 Add `:pending_quit_command` to store original quit intent

### 3.5.7.2 Handle Quit Key with Confirmation

Process quit key with confirmation step.

- [ ] 3.5.7.2.1 Modify update clause for `%Event.Key{key: "q"}`
- [ ] 3.5.7.2.2 If not `show_quit_confirm`:
  - Set `show_quit_confirm: true`
  - Return `{:noreply, updated_state}`
- [ ] 3.5.7.2.3 If already showing confirmation:
  - Return `{:noreply, state, [:quit]}`

### 3.5.7.3 Handle Confirmation Keys

Process yes/no for quit.

- [ ] 3.5.7.3.1 Add update for `%Event.Key{key: "y"}` when confirming
- [ ] 3.5.7.3.2 Return `{:noreply, state, [:quit]}`
- [ ] 3.5.7.3.3 Add update for `%Event.Key{key: "n"}` or `ESC`:
  - Set `show_quit_confirm: false`
  - Return `{:noreply, updated_state}`

### 3.5.7.4 Render Confirmation Dialog

Draw the quit confirmation dialog.

- [ ] 3.5.7.4.1 In view/1, if `show_quit_confirm`:
  - Create dialog using `TermUI.Widget.AlertDialog`
  - Title: "Quit?"
  - Message: "Are you sure you want to quit?"
  - Buttons: "[Y]es  [N]o"
  - Center on canvas
- [ ] 3.5.7.4.2 Draw over other UI elements
- [ ] 3.5.7.4.3 Use contrasting color scheme

---

## 3.5.8 Implement Visual Refinements

Polish colors, characters, and layout.

### 3.5.7.1 Refine Color Scheme

Establish consistent color palette.

- [ ] 3.5.7.1.1 Create `lib/ant_colony/ui/colors.ex`
- [ ] 3.5.7.1.2 Define color constants:
  - `@nest_color :white`
  - `@ant_searching_color :red`
  - `@ant_returning_color {:rgb, 255, 100, 100}` (bright red)
  - `@food_low_color :yellow`
  - `@food_high_color :red`
  - `@pheromone_low_color :dark_gray`
  - `@pheromone_high_color :green`
  - `@bg_color :black`
  - `@grid_color :dark_blue` (faint)
- [ ] 3.5.7.1.3 Document color choices

### 3.5.7.2 Optimize Character Choices

Select optimal characters for display.

- [ ] 3.5.7.2.1 Define character constants:
  - `@nest_char "N"`
  - `@ant_char "a"` / `@ant_with_food_char "A"`
  - `@food_chars %{"F1" => "•", "F2" => "•", "F3" => "◆", "F4" => "◆", "F5" => "★"}`
  - `@pheromone_chars [" ", "·", "░", "▒", "▓", "█"]`
- [ ] 3.5.7.2.2 Ensure characters render correctly in terminal
- [ ] 3.5.7.2.3 Test for unicode support

### 3.5.7.3 Add Grid Lines (Optional)

Draw subtle grid for reference.

- [ ] 3.5.7.3.1 Add `:show_grid` option to UI state
- [ ] 3.5.7.3.2 Toggle with `g` key
- [ ] 3.5.7.3.3 Draw dots or + at intervals (every 10 positions)
- [ ] 3.5.7.3.4 Use dim color

### 3.5.7.4 Improve Layout

Arrange UI elements for clarity.

- [ ] 3.5.7.4.1 Place status bar at bottom (full width)
- [ ] 3.5.7.4.2 Center main canvas
- [ ] 3.5.7.4.3 Add padding around canvas if terminal larger
- [ ] 3.5.7.4.4 Ensure minimum size requirements (80x24)

### 3.5.8.5 Add Help Screen

Display controls and legend.

- [ ] 3.5.8.5.1 Add `:show_help` to UI state
- [ ] 3.5.8.5.2 Toggle with `h` or `?` key
- [ ] 3.5.8.5.3 Render help overlay:
  ```
  Controls:
    SPACE - Pause/Resume
    +/-  - Speed Up/Down
    q    - Quit (with confirmation)
    G    - Trigger Next Generation (debug)
    p    - Toggle Pheromones
    c    - Toggle Communications
    g    - Toggle Grid
    h/?  - Show this help

  Legend:
    N - Nest
    F - Food (1-5 quality)
    a - Searching ant
    A - Ant with food
  ```
- [ ] 3.5.8.5.4 Center on canvas
- [ ] 3.5.8.5.5 Dismiss on any key

---

## 3.5.9 Add Optional Info Panel

Create side panel for additional information.

### 3.5.8.1 Design Info Panel Layout

Plan panel structure.

- [ ] 3.5.8.1.1 Position to right of main canvas
- [ ] 3.5.8.1.2 Width: 20-30 characters
- [ ] 3.5.8.1.3 Sections: Legend, Stats, Selected Ant

### 3.5.8.2 Implement Panel Rendering

Draw the info panel.

- [ ] 3.5.8.2.1 Define `defp info_panel(state)` function
- [ ] 3.5.8.2.2 Create vertical layout widget
- [ ] 3.5.8.2.3 Add sections with headers
- [ ] 3.5.8.2.4 Return panel widget

### 3.5.8.3 Add Ant Selection

Allow selecting individual ants.

- [ ] 3.5.8.3.1 Add `:selected_ant_id` to UI state
- [ ] 3.5.8.3.2 Handle mouse click on ant position (if supported)
- [ ] 3.5.8.3.3 Or use number keys to select by ID
- [ ] 3.5.8.3.4 Display selected ant info:
  - ID, Position, State
  - Has Food?, Food Level
  - Path Memory length
  - Known Food Sources count

---

## 3.5.9 Unit Tests for UI Controls

Test all control functionality.

### 3.5.9.1 Test Controller

Verify controller manages state correctly.

- [ ] 3.5.9.1.1 Create `test/ant_colony/controller_test.exs`
- [ ] 3.5.9.1.2 Add test: `test "pause stops simulation"` - pause
- [ ] 3.5.9.1.3 Add test: `test "resume starts simulation"` - resume
- [ ] 3.5.9.1.4 Add test: `test "toggle_pause flips state"` - toggle
- [ ] 3.5.9.1.5 Add test: `test "set_speed adjusts multiplier"` - speed
- [ ] 3.5.9.1.6 Add test: `test "get_status returns correct info"` - status
- [ ] 3.5.9.1.7 Add test: `test "reset clears simulation time"` - reset

### 3.5.9.2 Test UI Controls

Verify UI handles keypresses correctly.

- [ ] 3.5.9.2.1 Create `test/ant_colony/ui_controls_test.exs`
- [ ] 3.5.9.2.2 Add test: `test "SPACE key triggers pause"` - space
- [ ] 3.5.9.2.3 Add test: `test "+ key increases speed"` - plus
- [ ] 3.5.9.2.4 Add test: `test "- key decreases speed"` - minus
- [ ] 3.5.9.2.5 Add test: `test "q shows confirmation dialog"` - quit dialog
- [ ] 3.5.9.2.6 Add test: `test "y on dialog quits"` - confirm
- [ ] 3.5.9.2.7 Add test: `test "n on dialog cancels"` - cancel

### 3.5.9.3 Test Status Bar

Verify status bar displays correctly.

- [ ] 3.5.9.3.1 Add test: `test "status_bar returns valid widget"` - widget
- [ ] 3.5.9.3.2 Add test: `test "status_bar shows all sections"` - sections
- [ ] 3.5.9.3.3 Add test: `test "FPS counter calculates correctly"` - FPS
- [ ] 3.5.9.3.4 Add test: `test "pause indicator appears when paused"` - indicator

### 3.5.9.4 Test Visual Elements

Verify rendering works correctly.

- [ ] 3.5.9.4.1 Add test: `test "colors are defined"` - colors
- [ ] 3.5.9.4.2 Add test: `test "characters render correctly"` - characters
- [ ] 3.5.9.4.3 Add test: `test "help screen displays"` - help
- [ ] 3.5.9.4.4 Add test: `test "confirmation dialog renders"` - dialog

---

## 3.5.10 Phase 3.5 Integration Tests

End-to-end tests for UI controls.

### 3.5.10.1 Control Flow Test

Verify user controls work end-to-end.

- [ ] 3.5.10.1.1 Create `test/ant_colony/integration/ui_controls_integration_test.exs`
- [ ] 3.5.10.1.2 Add test: `test "user can pause and resume simulation"` - pause flow
- [ ] 3.5.10.1.3 Add test: `test "user can adjust speed during simulation"` - speed flow
- [ ] 3.5.10.1.4 Add test: `test "user can quit with confirmation"` - quit flow
- [ ] 3.5.10.1.5 Add test: `test "all toggles work correctly"` - toggles

### 3.5.10.2 Visual Fidelity Test

Verify UI displays correctly.

- [ ] 3.5.10.2.1 Add test: `test "UI renders without errors"` - rendering
- [ ] 3.5.10.2.2 Add test: `test "status bar updates in real-time"` - updates
- [ ] 3.5.10.2.3 Add test: `test "help screen shows correct info"` - help
- [ ] 3.5.10.2.4 Add test: `test "colors and characters display"` - visual

### 3.5.10.3 Performance Test

Verify controls don't degrade performance.

- [ ] 3.5.10.3.1 Add test: `test "pause doesn't leak memory"` - pause
- [ ] 3.5.10.3.2 Add test: `test "speed changes don't crash simulation"` - speed
- [ ] 3.5.10.3.3 Add test: `test "UI maintains acceptable FPS"` - FPS
- [ ] 3.5.10.3.4 Add test: `test "status bar doesn't slow rendering"` - status

---

## Phase 3.5 Success Criteria

1. **Controller**: Simulation controller implemented ✅
2. **Pause/Resume**: SPACE key stops/starts simulation ✅
3. **Speed Control**: +/- keys adjust speed ✅
4. **Status Bar**: Comprehensive info displayed ✅
5. **Quit Confirmation**: Dialog prevents accidental exit ✅
6. **Visual Polish**: Colors and characters refined ✅
7. **Help Screen**: Controls reference available ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 3.5 Critical Files

**New Files:**
- `lib/ant_colony/controller.ex` - Simulation controller
- `lib/ant_colony/ui/colors.ex` - Color definitions
- `test/ant_colony/controller_test.exs` - Controller tests
- `test/ant_colony/ui_controls_test.exs` - UI control tests
- `test/ant_colony/integration/ui_controls_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/application.ex` - Add controller to supervision
- `lib/ant_colony/actions/move_action.ex` - Respect pause state
- `lib/ant_colony/ui.ex` - Add all controls and enhancements

---

## Phase 3 Complete!

All Phase 3: Iterative Enhancement planning documents are now complete.

### Summary of Phase 3

1. **Pheromone Logic** - Indirect communication via digital pheromones
2. **Food Levels and Foraging** - Quality-based foraging with path retracing
3. **Ant-to-Ant Communication** - Direct information exchange
4. **ML Integration** - Axon-based learning for optimization
5. **UI Controls and Polish** - User interaction and visual refinement

### Phase 3 Deliverables

- Complete ACO pheromone system with evaporation
- Sophisticated foraging based on food quality
- Direct communication between nearby ants
- Neural network model for path prediction
- Interactive UI with pause, speed, and controls
- Comprehensive test coverage

### Next Phase

After completing Phase 3 implementation, proceed to **Phase 4: Testing, Debugging, and Refinement** to ensure system quality and performance.

## Key References

- `notes/research/development_cycles.md` - Phase 3 specification
- `notes/research/original_research.md` - Complete architecture details
- `notes/research/terminal_ui.md` - UI enhancements
- `notes/planning/phase1_foundational_simulation/*` - Phase 1 planning
- `notes/planning/phase2_initial_ui_integration/*` - Phase 2 planning
