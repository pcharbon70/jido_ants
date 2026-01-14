# Phase 4.5: UI Debugging Tools

Create debugging tools and techniques for inspecting and diagnosing the ant colony simulation through the UI. This cycle adds inspector panels, event visualization, REPL helpers, and interactive debugging features to make the system transparent and debuggable.

## Architecture

```
UI Debugging Infrastructure
├── UI State Inspector
│   ├── State Dump Panel
│   ├── State Diff Viewer
│   ├── Event History Buffer
│   └── State Replay Capability
│
├── Agent Inspector
│   ├── Agent Detail Panel
│   ├── Agent State Viewer
│   ├── Path Memory Visualization
│   ├── Known Sources Display
│   └── Agent Action History
│
├── Event Logger
│   ├── PubSub Event Capture
│   ├── Event Filtering
│   ├── Event Search
│   └── Event Export
│
├── Debug Mode UI
│   ├── Debug Overlay
│   ├── Performance Metrics Display
│   ├── Pheromone Heatmap Toggle
│   └── Communication Lines Toggle
│
├── REPL Helpers
│   ├── IEx Helper Functions
│   ├── Inspect Agents
│   ├── Inspect Plane
│   ├── Query Events
│   └── Manipulate State
│
└── External Tools Integration
    ├── :debugger Integration
    ├── :observer Integration
    └── Recon Integration
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| UI State Inspector | Inspect and debug UI state |
| Agent Inspector | View detailed agent information |
| Event Logger | Capture and display PubSub events |
| Debug Mode UI | Overlay debugging information on canvas |
| REPL Helpers | IEx functions for inspection |
| External Tools | Integration with BEAM debugging tools |

---

## 4.5.1 Create UI State Inspector

Implement tools for inspecting and debugging UI state.

### 4.5.1.1 Create State Dump Panel

Create a panel to display current UI state.

- [ ] 4.5.1.1.1 Create `lib/ant_colony/ui/inspector.ex`
- [ ] 4.5.1.1.2 Add `defmodule AntColony.UI.Inspector`
- [ ] 4.5.1.1.3 Define `StateDump` panel widget
- [ ] 4.5.1.1.4 Display all UI state fields
- [ ] 4.5.1.1.5 Format nested structures for readability
- [ ] 4.5.1.1.6 Handle large state (truncate lists, maps)

### 4.5.1.2 Create State Diff Viewer

Compare UI state across time steps.

- [ ] 4.5.1.2.1 Store previous state in inspector
- [ ] 4.5.1.2.2 Implement state diff algorithm
- [ ] 4.5.1.2.3 Display changes with visual indicators (+/-)
- [ ] 4.5.1.2.4 Highlight ant position changes
- [ ] 4.5.1.2.5 Highlight food quantity changes

### 4.5.1.3 Create Event History Buffer

Capture and display UI events.

- [ ] 4.5.1.3.1 Add event buffer to inspector state (ring buffer, limit: 100)
- [ ] 4.5.1.3.2 Log all `update/2` events with timestamps
- [ ] 4.5.1.3.3 Display event history panel
- [ ] 4.5.1.3.4 Format events for readability
- [ ] 4.5.1.3.5 Support scrolling through history

### 4.5.1.4 Implement State Replay

Allow stepping through UI state history.

- [ ] 4.5.1.4.1 Store UI state snapshots (configurable interval)
- [ ] 4.5.1.4.2 Add replay mode toggle
- [ ] 4.5.1.4.3 Implement step forward/backward controls
- [ ] 4.5.1.4.4 Display current replay index
- [ ] 4.5.1.4.5 Exit replay mode returns to live state

### 4.5.1.5 Unit Tests for UI State Inspector

Test the state inspector functionality.

- [ ] 4.5.1.5.1 Test state dump displays all fields
- [ ] 4.5.1.5.2 Test state diff identifies changes
- [ ] 4.5.1.5.3 Test event buffer limits to max size
- [ ] 4.5.1.5.4 Test event history preserves order
- [ ] 4.5.1.5.5 Test state replay navigation

---

## 4.5.2 Create Agent Inspector

Implement detailed agent inspection through the UI.

### 4.5.2.1 Create Agent Detail Panel

Create a panel showing detailed agent information.

- [ ] 4.5.2.1.1 Create `lib/ant_colony/ui/agent_inspector.ex`
- [ ] 4.5.1.1.2 Add `defmodule AntColony.UI.AgentInspector`
- [ ] 4.5.2.1.3 Define agent selection state (selected_ant_id)
- [ ] 4.5.2.1.4 Create detail panel widget
- [ ] 4.5.2.1.5 Display: id, position, state, energy, carrying

### 4.5.2.2 Display Agent State Details

Show comprehensive agent state.

- [ ] 4.5.2.2.1 Display current state (searching, foraging, returning)
- [ ] 4.5.2.2.2 Display energy level with visual gauge
- [ ] 4.5.2.2.3 Display carrying status and amount
- [ ] 4.5.2.2.4 Display path memory length and contents
- [ ] 4.5.2.2.5 Display known food sources count

### 4.5.2.3 Visualize Path Memory

Show the agent's path memory on the canvas.

- [ ] 4.5.2.3.1 Add toggle for path visualization
- [ ] 4.5.2.3.2 Draw path memory as connected line
- [ ] 4.5.2.3.3 Use distinct color for selected agent
- [ ] 4.5.2.3.4 Indicate direction with arrows
- [ ] 4.5.2.3.5 Fade older path positions

### 4.5.2.4 Display Known Sources

Show the agent's known food sources.

- [ ] 4.5.2.4.1 Create known sources list panel
- [ ] 4.5.2.4.2 Display position and last quantity
- [ ] 4.5.2.4.3 Show last update time
- [ ] 4.5.2.4.4 Highlight sources on canvas
- [ ] 4.5.2.4.5 Connect agent to sources with lines

### 4.5.2.5 Display Agent Action History

Show recent actions executed by the agent.

- [ ] 4.5.2.5.1 Add action history to agent state (limit: 20)
- [ ] 4.5.2.5.2 Log each action with result
- [ ] 4.5.2.5.3 Display action history panel
- [ ] 4.5.2.5.4 Show action name and outcome
- [ ] 4.5.2.5.5 Include timestamps

### 4.5.2.6 Implement Agent Selection

Allow selecting agents from the UI.

- [ ] 4.5.2.6.1 Add key handler for agent selection (e.g., "s" then ID)
- [ ] 4.5.2.6.2 Support clicking on ants (if mouse support available)
- [ ] 4.5.2.6.3 Add next/previous agent navigation (n/N keys)
- [ ] 4.5.2.6.4 Highlight selected ant on canvas
- [ ] 4.5.2.6.5 Add clear selection command (ESC)

### 4.5.2.7 Unit Tests for Agent Inspector

Test the agent inspector functionality.

- [ ] 4.5.2.7.1 Test agent detail panel shows correct data
- [ ] 4.5.2.7.2 Test path visualization draws correctly
- [ ] 4.5.2.7.3 Test known sources display
- [ ] 4.5.2.7.4 Test action history preserves order
- [ ] 4.5.2.7.5 Test agent selection state changes

---

## 4.5.3 Create Event Logger

Implement comprehensive event logging and visualization.

### 4.5.3.1 Create Event Capture Module

Capture all PubSub events.

- [ ] 4.5.3.1.1 Create `lib/ant_colony/ui/event_logger.ex`
- [ ] 4.5.3.1.2 Add `defmodule AntColony.UI.EventLogger`
- [ ] 4.5.3.1.3 Add `use GenServer`
- [ ] 4.5.3.1.4 Define event buffer state (ring buffer, limit: 1000)
- [ ] 4.5.3.1.5 Subscribe to all ant colony PubSub topics
- [ ] 4.5.3.1.6 Handle `handle_info` for Phoenix.PubSub messages

### 4.5.3.2 Implement Event Storage

Store events with metadata.

- [ ] 4.5.3.2.1 Define event struct:
  - `:id` - unique event ID
  - `:timestamp` - DateTime
  - `:topic` - PubSub topic
  - `:event_name` - Event name
  - `:data` - Event payload
- [ ] 4.5.3.2.2 Implement ring buffer storage
- [ ] 4.5.3.2.3 Add event counter for total received
- [ ] 4.5.3.2.4 Track events by type (counter per event)

### 4.5.3.3 Implement Event Query API

Create functions to query events.

- [ ] 4.5.3.3.1 Define `def get_events/0` - returns all buffered events
- [ ] 4.5.3.3.2 Define `def get_events_by_type/1` - filter by event name
- [ ] 4.5.3.3.3 Define `def get_events_for_ant/1` - filter by ant_id
- [ ] 4.5.3.3.4 Define `def get_events_since/1` - filter by DateTime
- [ ] 4.5.3.3.5 Define `def get_event_stats/0` - return event counts

### 4.5.3.4 Create Event Log Viewer UI

Display events in the UI.

- [ ] 4.5.3.4.1 Create event log viewer widget
- [ ] 4.5.3.4.2 Display events in scrollable list
- [ ] 4.5.3.4.3 Color-code events by type
- [ ] 4.5.3.4.4 Show event timestamps
- [ ] 4.5.3.4.5 Support event detail expansion

### 4.5.3.5 Implement Event Filtering

Filter events in the viewer.

- [ ] 4.5.3.5.1 Add filter by event type
- [ ] 4.5.3.5.2 Add filter by ant_id
- [ ] 4.5.3.5.3 Add filter by time range
- [ ] 4.5.3.5.4 Add text search across event data
- [ ] 4.5.3.5.5 Clear filter command

### 4.5.3.6 Implement Event Export

Export events for external analysis.

- [ ] 4.5.3.6.1 Define `def export_events/1` - export to file
- [ ] 4.5.3.6.2 Support JSON format
- [ ] 4.5.3.6.3 Support CSV format (for tabular events)
- [ ] 4.5.3.6.4 Add UI command for export
- [ ] 4.5.3.6.5 Confirm export before writing

### 4.5.3.7 Unit Tests for Event Logger

Test the event logger functionality.

- [ ] 4.5.3.7.1 Test event capture from PubSub
- [ ] 4.5.3.7.2 Test ring buffer eviction
- [ ] 4.5.3.7.3 Test `get_events_by_type/1` filtering
- [ ] 4.5.3.7.4 Test `get_events_for_ant/1` filtering
- [ ] 4.5.3.7.5 Test `get_events_since/1` filtering
- [ ] 4.5.3.7.6 Test event stats accuracy
- [ ] 4.5.3.7.7 Test event export to JSON
- [ ] 4.5.3.7.8 Test event export to CSV

---

## 4.5.4 Create Debug Mode UI

Add debug overlay and visualizations to the main UI.

### 4.5.4.1 Create Debug Overlay

Add an overlay showing debug information.

- [ ] 4.5.4.1.1 Add `debug_mode` flag to UI state
- [ ] 4.5.4.1.2 Add toggle command (F1 key)
- [ ] 4.5.4.1.3 Create overlay widget
- [ ] 4.5.4.1.4 Display FPS
- [ ] 4.5.4.1.5 Display memory usage
- [ ] 4.5.4.1.6 Display event queue length
- [ ] 4.5.4.1.7 Display active agent count

### 4.5.4.2 Add Pheromone Heatmap Toggle

Visualize pheromone levels on the canvas.

- [ ] 4.5.4.2.1 Add `show_pheromones` flag to UI state
- [ ] 4.5.4.2.2 Add toggle command (p key)
- [ ] 4.5.4.2.3 Draw pheromone levels as background colors
- [ ] 4.5.4.2.4 Use grayscale or heatmap colors
- [ ] 4.5.4.2.5 Map pheromone level to color intensity

### 4.5.4.3 Add Communication Lines Toggle

Visualize agent communication events.

- [ ] 4.5.4.3.1 Add `show_communications` flag to UI state
- [ ] 4.5.4.3.2 Add toggle command (c key)
- [ ] 4.5.4.3.3 Store recent communication events (limit: 50)
- [ ] 4.5.4.3.4 Draw lines between communicating agents
- [ ] 4.5.4.3.5 Fade lines over time

### 4.5.4.4 Add Position Coordinates Display

Show coordinates on the canvas.

- [ ] 4.5.4.4.1 Add `show_coordinates` flag to UI state
- [ ] 4.5.4.4.2 Add toggle command (x key)
- [ ] 4.5.4.4.3 Draw coordinates along edges
- [ ] 4.5.4.4.4 Or show on hover/cursor position

### 4.5.4.5 Add Performance Metrics Display

Show detailed performance metrics.

- [ ] 4.5.4.5.1 Add `show_metrics` flag to UI state
- [ ] 4.5.4.5.2 Add toggle command (m key)
- [ ] 4.5.4.5.3 Create metrics panel widget
- [ ] 4.5.4.5.4 Display action execution times
- [ ] 4.5.4.5.5 Display PubSub latency
- [ ] 4.5.4.5.6 Display GC statistics

### 4.5.4.6 Unit Tests for Debug Mode UI

Test the debug mode features.

- [ ] 4.5.4.6.1 Test debug mode toggle
- [ ] 4.5.4.6.2 Test pheromone heatmap rendering
- [ ] 4.5.4.6.3 Test communication lines rendering
- [ ] 4.5.4.6.4 Test coordinates display
- [ ] 4.5.4.6.5 Test metrics panel accuracy

---

## 4.5.5 Create REPL Helpers

Create IEx helper functions for interactive debugging.

### 4.5.5.1 Create Helper Module

Create a module of IEx helper functions.

- [ ] 4.5.5.1.1 Create `lib/ant_colony/observability/iex_helpers.ex`
- [ ] 4.5.5.1.2 Add `defmodule AntColony.Observability.IExHelpers`
- [ ] 4.5.5.1.3 Add comprehensive `@moduledoc` with usage examples

### 4.5.5.2 Implement Agent Inspection Helpers

Create functions to inspect agents.

- [ ] 4.5.5.2.1 Define `def inspect_agent(ant_id)` - returns agent state
- [ ] 4.5.5.2.2 Define `def list_agents()` - returns all agent IDs
- [ ] 4.5.5.2.3 Define `def find_agents_by_state(state)` - filter by state
- [ ] 4.5.5.2.4 Define `def find_agents_at_position(pos)` - filter by position
- [ ] 4.5.5.2.5 Define `def agent_action_history(ant_id)` - get action history

### 4.5.5.3 Implement Plane Inspection Helpers

Create functions to inspect the plane.

- [ ] 4.5.5.3.1 Define `def inspect_plane()` - returns plane state
- [ ] 4.5.5.3.2 Define `def food_sources()` - returns all food sources
- [ ] 4.5.5.3.3 Define `def pheromone_map()` - returns pheromone grid
- [ ] 4.5.5.3.4 Define `def agents_at_position(pos)` - list agents at position
- [ ] 4.5.5.3.5 Define `def plane_statistics()` - return plane stats

### 4.5.5.4 Implement Event Query Helpers

Create functions to query events.

- [ ] 4.5.5.4.1 Define `def recent_events(count \\ 20)` - get recent events
- [ ] 4.5.5.4.2 Define `def events_for_agent(ant_id)` - get agent events
- [ ] 4.5.5.4.3 Define `def subscribe_to_events()` - subscribe in IEx
- [ ] 4.5.5.4.4 Define `def watch_agent(ant_id)` - print agent events
- [ ] 4.5.5.4.5 Define `def event_counts()` - show event frequency

### 4.5.5.5 Implement State Manipulation Helpers

Create functions to manipulate simulation state.

- [ ] 4.5.5.5.1 Define `def pause_simulation()` - pause the simulation
- [ ] 4.5.5.5.2 Define `def resume_simulation()` - resume the simulation
- [ ] 4.5.5.5.3 Define `def set_speed_multiplier(n)` - adjust speed
- [ ] 4.5.5.5.4 Define `def spawn_ant_at(pos)` - create ant at position
- [ ] 4.5.5.5.5 Define `def add_food_at(pos, amount)` - add food
- [ ] 4.5.5.5.6 Define `def kill_agent(ant_id)` - remove an agent

### 4.5.5.6 Import Helpers in IEx Session

Make helpers available in `.iex.exs`.

- [ ] 4.5.5.6.1 Create or update `.iex.exs` in project root
- [ ] 4.5.5.6.2 Import `AntColony.Observability.IExHelpers`
- [ ] 4.5.5.6.3 Add aliases for common functions
- [ ] 4.5.5.6.4 Add custom prompt with simulation status
- [ ] 4.5.5.6.5 Document usage in comments

### 4.5.5.7 Unit Tests for REPL Helpers

Test the REPL helper functions.

- [ ] 4.5.5.7.1 Test `inspect_agent/1` returns correct state
- [ ] 4.5.5.7.2 Test `list_agents/0` returns all IDs
- [ ] 4.5.5.7.3 Test `find_agents_by_state/1` filters correctly
- [ ] 4.5.5.7.4 Test `inspect_plane/0` returns plane state
- [ ] 4.5.5.7.5 Test `recent_events/1` limits count
- [ ] 4.5.5.7.6 Test `pause_simulation/0` pauses simulation
- [ ] 4.5.5.7.7 Test `spawn_ant_at/1` creates agent

---

## 4.5.6 Integrate External Tools

Integrate with BEAM debugging and observability tools.

### 4.5.6.1 Configure :debugger Integration

Enable BEAM debugger for the simulation.

- [ ] 4.5.6.1.1 Add :debugger configuration to `config/dev.exs`
- [ ] 4.5.6.1.2 Add :int module configuration
- [ ] 4.5.6.1.3 Create helper: `def start_debugger()`
- [ ] 4.5.6.1.4 Create helper: `def debug_module(module)`
- [ ] 4.5.6.1.5 Document debugging workflow

### 4.5.6.2 Configure :observer Integration

Enable Erlang observer for the simulation.

- [ ] 4.5.6.1.1 Add :wx configuration to `config/dev.exs`
- [ ] 4.5.6.2.2 Create helper: `def start_observer()`
- [ ] 4.5.6.2.3 Document observer usage for ant colony
- [ ] 4.5.6.2.4 Create observer layout documentation

### 4.5.6.3 Integrate Recon

Add Recon for enhanced shell debugging.

- [ ] 4.5.6.3.1 Add `{:recon, "~> 2.5"}` to `mix.exs` deps (dev only)
- [ ] 4.5.6.3.2 Configure Recon in `.iex.exs`
- [ ] 4.5.6.3.3 Add Recon helpers to IExHelpers
- [ ] 4.5.6.3.4 Document Recon functions for ant colony

### 4.5.6.4 Create Debugging Guide

Document debugging workflows.

- [ ] 4.5.6.4.1 Create `docs/debugging_guide.md`
- [ ] 4.5.6.4.2 Document common debugging scenarios
- [ ] 4.5.6.4.3 Document using IEx helpers
- [ ] 4.5.6.4.4 Document using external tools
- [ ] 4.5.6.4.5 Add troubleshooting section

### 4.5.6.5 Unit Tests for External Tools Integration

Test external tool helpers.

- [ ] 4.5.6.5.1 Test `start_debugger/0` launches debugger
- [ ] 4.5.6.5.2 Test `debug_module/1` interprets module
- [ ] 4.5.6.5.3 Test `start_observer/0` launches observer

---

## 4.5 Phase 4.5 Integration Tests

### 4.5.1 UI Debugging Integration Tests

Test debugging UI integration with the simulation.

- [ ] 4.5.1.1 Verify state inspector updates with simulation
- [ ] 4.5.1.2 Verify agent inspector reflects agent state
- [ ] 4.5.1.3 Verify event logger captures all events
- [ ] 4.5.1.4 Verify debug mode overlay shows accurate metrics
- [ ] 4.5.1.5 Verify toggles work correctly

### 4.5.2 Interactive Debugging Tests

Test interactive debugging scenarios.

- [ ] 4.5.2.1 Verify agent selection works
- [ ] 4.5.2.2 Verify event filtering works
- [ ] 4.5.2.3 Verify state replay navigation works
- [ ] 4.5.2.4 Verify REPL helpers return correct data

## Phase 4.5 Success Criteria

1. **UI State Inspector**: View and diff UI state ✅
2. **Agent Inspector**: Select and inspect agents in detail ✅
3. **Event Logger**: Capture, filter, and export events ✅
4. **Debug Mode UI**: Toggle debug overlays and visualizations ✅
5. **REPL Helpers**: IEx functions for inspection and manipulation ✅
6. **External Tools**: Integration with :debugger, :observer, Recon ✅

## Phase 4.5 Critical Files

**New Files:**
- `lib/ant_colony/ui/inspector.ex`
- `lib/ant_colony/ui/agent_inspector.ex`
- `lib/ant_colony/ui/event_logger.ex`
- `lib/ant_colony/observability/iex_helpers.ex`
- `.iex.exs`

**Modified Files:**
- `lib/ant_colony/ui.ex` - Add debug mode, toggles
- `config/dev.exs` - External tool configuration
- `mix.exs` - Recon dependency (dev)

**Test Files:**
- `test/ant_colony/ui/inspector_test.exs`
- `test/ant_colony/ui/agent_inspector_test.exs`
- `test/ant_colony/ui/event_logger_test.exs`
- `test/ant_colony/observability/iex_helpers_test.exs`
- `test/ant_colony/ui/debug_mode_integration_test.exs`
