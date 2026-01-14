# Phase 2.5: UI Integration

Integrate the UI module with the simulation supervision tree, create a mix task for starting the UI, and verify end-to-end functionality.

## Architecture

```
Application Supervision Tree
├── AntColony.Application
│   ├── Phoenix.PubSub (name: AntColony.PubSub)
│   ├── AntColony.Plane
│   ├── DynamicSupervisor (name: AgentSupervisor)
│   │   └── AntAgent children (dynamically spawned)
│   └── (Optional) AntColony.UI
│       └── Started via child spec or manual start
│
└── Mix.Task: ant_ui
    ├── Starts application if not running
    ├── Spawns initial ants (optional)
    └── Starts UI process
```

## Event Flow Integration

```
Simulation → PubSub → UI
     │            │        │
     │            │        └── init/1: Fetch initial state
     │            └── subscribe("ui_updates")
     └── publish events:
         ├── {:ant_moved, ant_id, old_pos, new_pos}
         ├── {:food_updated, pos, new_quantity}
         ├── {:ant_registered, ant_id, position}
         └── {:ant_unregistered, ant_id}
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Application | Add UI as optional child |
| Mix.Task.AntUI | Command-line task to start UI |
| UI.EventPublisher | Ensure events are published |
| Integration Tests | End-to-end verification |

---

## 2.5.1 Add UI to Supervision Tree

Integrate the UI module with the application supervision.

### 2.5.1.1 Evaluate UI Start Strategy

Determine whether UI starts automatically or manually.

- [ ] 2.5.1.1.1 Review requirements for auto-start vs manual start
- [ ] 2.5.1.1.2 Decide: UI starts only when explicitly requested (recommended)
- [ ] 2.5.1.1.3 Document start strategy in Application @moduledoc
- [ ] 2.5.1.1.4 Plan for both modes: conditional child spec

### 2.5.1.2 Add Conditional UI Child Spec

Configure UI as optional application child.

- [ ] 2.5.1.2.1 Open `lib/ant_colony/application.ex`
- [ ] 2.5.1.2.2 Add condition check for UI in children list
- [ ] 2.5.1.2.3 Use `Application.get_env(:ant_colony, :start_ui, false)` for config
- [ ] 2.5.1.2.4 Add UI child spec when enabled:
  ```elixir
  if start_ui? do
    {AntColony.UI, []}
  else
    []
  end
  ```
- [ ] 2.5.1.2.5 Document configuration option

### 2.5.1.3 Configure UI in config.exs

Set up UI configuration.

- [ ] 2.5.1.3.1 Open `config/config.exs`
- [ ] 2.5.1.3.2 Add `config :ant_colony, :start_ui, false` (default off)
- [ ] 2.5.1.3.3 Add `config :ant_colony, :ui_opts, []` for UI options
- [ ] 2.5.1.3.4 Document configuration in comments

---

## 2.5.2 Create Mix.Task for UI

Create a convenient way to start the simulation with UI.

### 2.5.2.1 Create Mix.Task File

Set up the mix task module.

- [ ] 2.5.2.1.1 Create `lib/mix/tasks/ant_ui.ex`
- [ ] 2.5.2.1.2 Add `defmodule Mix.Tasks.AntUi`
- [ ] 2.5.2.1.3 Add `use Mix.Task`
- [ ] 2.5.2.1.4 Add `@shortdoc "Start the ant colony simulation UI"`
- [ ] 2.5.2.1.5 Add `@moduledoc` with usage instructions

### 2.5.2.2 Implement run/1 Function

Implement the task execution logic.

- [ ] 2.5.2.2.1 Define `def run(args)`
- [ ] 2.5.2.2.2 Parse arguments (e.g., --ants, --help)
- [ ] 2.5.2.2.3 Ensure Application is started
- [ ] 2.5.2.2.4 Wait for Plane to be ready
- [ ] 2.5.2.2.5 Optionally spawn initial ants
- [ ] 2.5.2.2.6 Start UI process
- [ ] 2.5.2.2.7 Keep process alive until UI quits

### 2.5.2.3 Add Argument Parsing

Parse command-line options.

- [ ] 2.5.2.3.1 Parse `--ants N` for initial ant count
- [ ] 2.5.2.3.2 Parse `--help` for usage information
- [ ] 2.5.2.3.3 Parse `--verbose` for verbose output
- [ ] 2.5.2.3.4 Provide defaults for all options
- [ ] 2.5.2.3.5 Validate option values

### 2.5.2.4 Implement Help Output

Display usage information.

- [ ] 2.5.2.4.1 Define `defp print_help()`
- [ ] 2.5.2.4.2 Display usage: `mix ant_ui [options]`
- [ ] 2.5.2.4.3 Display available options with descriptions
- [ ] 2.5.2.4.4 Display example usage
- [ ] 2.5.2.4.5 Display keyboard controls (q to quit)

### 2.5.2.5 Add Ant Spawning Logic

Spawn initial ants for the simulation.

- [ ] 2.5.2.5.1 Define `defp spawn_ants(count)` helper
- [ ] 2.5.2.5.2 Validate count is positive
- [ ] 2.5.2.5.3 Call `AntColony.Agent.Manager.spawn_ants(count)`
- [ ] 2.5.2.5.4 Handle spawn errors gracefully
- [ ] 2.5.2.5.5 Log info message with spawn count

---

## 2.5.3 Ensure Event Publishing

Verify all simulation events are published to PubSub.

### 2.5.3.1 Review MoveAction Event Publishing

Verify MoveAction publishes ant_moved events.

- [ ] 2.5.3.1.1 Open `lib/ant_colony/actions/move_action.ex`
- [ ] 2.5.3.1.2 Verify `AntColony.Events.broadcast_ant_moved/3` is called
- [ ] 2.5.3.1.3 Verify event format matches UI expectations
- [ ] 2.5.3.1.4 Add or fix event publishing if missing

### 2.5.3.2 Review SenseFoodAction Event Publishing

Verify SenseFoodAction publishes food events.

- [ ] 2.5.3.2.1 Open `lib/ant_colony/actions/sense_food_action.ex`
- [ ] 2.5.3.2.2 Verify food_sensed events are published
- [ ] 2.5.3.2.3 Verify food_updated events are published
- [ ] 2.5.3.2.4 Add or fix event publishing if missing

### 2.5.3.3 Review AntAgent Lifecycle Events

Verify agent registration/unregistration events.

- [ ] 2.5.3.3.1 Open `lib/ant_colony/agent.ex`
- [ ] 2.5.3.3.2 Verify `ant_registered` event on init
- [ ] 2.5.3.3.3 Verify `ant_unregistered` event on terminate
- [ ] 2.5.3.3.4 Add or fix event publishing if missing

### 2.5.3.4 Verify PubSub Topic

Confirm UI subscribes to correct topic.

- [ ] 2.5.3.4.1 Verify UI subscribes to "ui_updates" topic
- [ ] 2.5.3.4.2 Verify events publish to "ui_updates" topic
- [ ] 2.5.3.4.3 Check for topic name consistency
- [ ] 2.5.3.4.4 Document topic name in Events module

---

## 2.5.4 Unit Tests for Mix.Task

Test the ant_ui mix task.

### 2.5.4.1 Test Task Starts

Verify the task starts correctly.

- [ ] 2.5.4.1.1 Create `test/mix/tasks/ant_ui_test.exs`
- [ ] 2.5.4.1.2 Add test: `test "run/1 starts the application"` - app start
- [ ] 2.5.4.1.3 Add test: `test "run/1 starts the UI"` - UI start
- [ ] 2.5.4.1.4 Add test: `test "run/1 handles default arguments"` - defaults

### 2.5.4.2 Test Argument Parsing

Verify command-line options are parsed correctly.

- [ ] 2.5.4.2.1 Add test: `test "parses --ants option"` - ant count
- [ ] 2.5.4.2.2 Add test: `test "parses --verbose option"` - verbose flag
- [ ] 2.5.4.2.3 Add test: `test "parses --help option"` - help display
- [ ] 2.5.4.2.4 Add test: `test "handles invalid arguments"` - error handling

### 2.5.4.3 Test Ant Spawning

Verify initial ants are spawned.

- [ ] 2.5.4.3.1 Add test: `test "spawns default number of ants"` - default
- [ ] 2.5.4.3.2 Add test: `test "spawns specified number of ants"` - custom count
- [ ] 2.5.4.3.3 Add test: `test "handles zero ant count"` - edge case
- [ ] 2.5.4.3.4 Add test: `test "handles invalid ant count"` - validation

---

## 2.5.5 Integration Tests for UI

End-to-end tests for the complete UI integration.

### 2.5.5.1 Full UI Lifecycle Test

Test starting and stopping the UI.

- [ ] 2.5.5.1.1 Create `test/ant_colony/integration/ui_integration_test.exs`
- [ ] 2.5.5.1.2 Add setup starting Application and Plane
- [ ] 2.5.5.1.3 Add test: `test "UI starts and connects to simulation"` - start
- [ ] 2.5.5.1.4 Add test: `test "UI stops cleanly on quit"` - stop
- [ ] 2.5.5.1.5 Add test: `test "UI can restart after quit"` - restart

### 2.5.5.2 Event Reception Test

Verify UI receives simulation events.

- [ ] 2.5.5.2.1 Add test: `test "UI receives ant_moved events"` - move events
- [ ] 2.5.5.2.2 Add test: `test "UI receives food_updated events"` - food events
- [ ] 2.5.5.2.3 Add test: `test "UI receives ant_registered events"` - registration
- [ ] 2.5.5.2.4 Add test: `test "UI receives ant_unregistered events"` - unregistration
- [ ] 2.5.5.2.5 Add test: `UI state updates match simulation state"` - accuracy

### 2.5.5.3 Visual Verification Test

Verify the UI renders correctly.

- [ ] 2.5.5.3.1 Add test: `test "UI renders nest at correct position"` - nest
- [ ] 2.5.5.3.2 Add test: `test "UI renders all food sources"` - food
- [ ] 2.5.5.3.3 Add test: `test "UI renders all ants"` - ants
- [ ] 2.5.5.3.4 Add test: `UI updates display on simulation changes"` - updates

### 2.5.5.4 Multi-Agent Test

Verify UI handles multiple agents.

- [ ] 2.5.5.4.1 Add test: `test "UI displays 10 ants correctly"` - scale
- [ ] 2.5.5.4.2 Add test: `test "UI handles 100 ants"` - stress
- [ ] 2.5.5.4.3 Add test: `test "UI tracks concurrent ant movements"` - concurrency
- [ ] 2.5.5.4.4 Add test: `UI handles rapid events"` - performance

---

## 2.5.6 Phase 2.5 Integration Tests

Final integration tests for Phase 2 completion.

### 2.5.6.1 End-to-End Simulation Test

Test complete simulation with UI.

- [ ] 2.5.6.1.1 Create `test/ant_colony/integration/phase2_complete_test.exs`
- [ ] 2.5.6.1.2 Add test: `test "full simulation with UI works"` - complete flow
- [ ] 2.5.6.1.3 Add test: `test "ants move and UI updates"` - event flow
- [ ] 2.5.6.1.4 Add test: `test "food discovered and UI shows it"` - food discovery
- [ ] 2.5.6.1.5 Add test: `test "quit stops UI cleanly"` - clean shutdown

### 2.5.6.2 Manual Test Instructions

Document manual testing steps.

- [ ] 2.5.6.2.1 Create `notes/planning/phase2_manual_test.md`
- [ ] 2.5.6.2.2 Document: Start with `mix ant_ui`
- [ ] 2.5.6.2.3 Document: Verify nest appears
- [ ] 2.5.6.2.4 Document: Spawn ants, verify they appear
- [ ] 2.5.6.2.5 Document: Verify movement is visible
- [ ] 2.5.6.2.6 Document: Press 'q' to quit

### 2.5.6.3 Performance Benchmarks

Establish baseline performance metrics.

- [ ] 2.5.6.3.1 Add test: `test "UI refresh rate is acceptable"` - FPS
- [ ] 2.5.6.3.2 Add test: `test "UI handles 1000 events/second"` - throughput
- [ ] 2.5.6.3.3 Add test: `test "memory usage is stable"` - memory
- [ ] 2.5.6.3.4 Document baseline metrics

---

## 2.5.7 Documentation and Examples

Add documentation for using the UI.

### 2.5.7.1 Update README.md

Document the UI functionality.

- [ ] 2.5.7.1.1 Open `README.md`
- [ ] 2.5.7.1.2 Add "Running the UI" section
- [ ] 2.5.7.1.3 Document `mix ant_ui` command
- [ ] 2.5.7.1.4 Document keyboard controls
- [ ] 2.5.7.1.5 Add screenshot or example output

### 2.5.7.2 Create Examples Module

Provide example usage patterns.

- [ ] 2.5.7.2.1 Create `examples/ui_example.exs`
- [ ] 2.5.7.2.2 Show manual UI start
- [ ] 2.5.7.2.3 Show spawning ants
- [ ] 2.5.7.2.4 Show programmatic control
- [ ] 2.5.7.2.5 Add comments explaining each step

---

## Phase 2.5 Success Criteria

1. **Supervision**: UI integrates with Application ✅
2. **Mix.Task**: `mix ant_ui` starts UI with simulation ✅
3. **Event Publishing**: All events published correctly ✅
4. **Event Reception**: UI receives and displays events ✅
5. **Rendering**: All elements visible in UI ✅
6. **Quit**: 'q' key stops UI cleanly ✅
7. **Multi-Agent**: UI handles multiple ants ✅
8. **Tests**: All unit and integration tests pass ✅
9. **Documentation**: README updated with usage ✅

## Phase 2.5 Critical Files

**New Files:**
- `lib/mix/tasks/ant_ui.ex` - Mix task for starting UI
- `test/mix/tasks/ant_ui_test.exs` - Mix task tests
- `test/ant_colony/integration/ui_integration_test.exs` - UI integration tests
- `test/ant_colony/integration/phase2_complete_test.exs` - Phase 2 completion tests
- `examples/ui_example.exs` - Usage examples
- `notes/planning/phase2_manual_test.md` - Manual test instructions

**Modified Files:**
- `lib/ant_colony/application.ex` - Add UI child spec
- `lib/ant_colony/actions/move_action.ex` - Ensure event publishing
- `lib/ant_colony/actions/sense_food_action.ex` - Ensure event publishing
- `lib/ant_colony/agent.ex` - Ensure lifecycle events
- `config/config.exs` - UI configuration
- `README.md` - Documentation

---

## Phase 2 Complete!

All Phase 2: Initial UI Integration planning documents are now complete.

### Summary of Phase 2

1. **term_ui Dependencies** - Added term_ui and Nx packages
2. **Plane UI API** - Created get_full_state_for_ui/0 for UI state queries
3. **UI Module Structure** - Implemented TermUI.Elm module with init/update/view
4. **Canvas Rendering** - Implemented drawing functions for grid, nest, food, ants
5. **UI Integration** - Connected UI to simulation with Mix.Task

### Phase 2 Deliverables

- Terminal UI displaying real-time simulation
- Ants visible as "a" (searching) or "A" (returning with food)
- Nest visible as "N"
- Food sources visible as "F1"-"F5" with color coding
- Press 'q' to quit
- Mix task: `mix ant_ui [--ants N] [--verbose]`

### Next Phase

Proceed to **Phase 3: Iterative Enhancement** to add:
- Pheromone logic and visualization
- Enhanced food levels and foraging behavior
- Ant-to-ant communication
- Machine learning integration
- UI controls and polish

## Key References

- `notes/research/development_cycles.md` - Phase 2 specification (lines 26-43)
- `notes/research/terminal_ui.md` - Complete TermUI architecture
- `notes/research/original_research.md` - Overall system architecture
- `notes/planning/phase1_foundational_simulation/*` - Phase 1 implementation
