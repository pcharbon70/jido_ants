# Phase 2: Initial UI Integration - Overview

## Description

This document provides an overview of Phase 2: Initial UI Integration. This phase creates a terminal-based user interface using `term_ui` that visualizes the ant colony simulation in real-time.

## Goal

Get a visual representation of the simulation running in the terminal. The UI acts as an observer to the Phase 1 simulation, receiving events via Phoenix.PubSub and rendering them on a Canvas widget.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AntColonySimulation.Application                    │
│                    (Supervision Tree)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐     │
│   │ AntColony.PubSub│  │ AntColony.Plane │  │ AgentSupervisor│     │
│   │                 │  │                 │  │                │     │
│   │ Topic:          │  │ API:           │  │   AntAgents    │     │
│   │ "ui_updates"    │  │ get_full_state │  │                │     │
│   │                 │  │ _for_ui/0      │  │                │     │
│   └────────┬────────┘  └────────┬────────┘  └────────┬───────┘     │
│            │                    │                     │            │
│            └────────┬───────────┴─────────────────────┘            │
│                     ▼                                          │
│            ┌─────────────────┐                                 │
│            │ AntColony.UI    │                                 │
│            │  (TermUI.Elm)   │                                 │
│            │                 │                                 │
│            │ ┌─────────────┐ │                                 │
│            │ │   Canvas    │ │                                 │
│            │ │             │ │                                 │
│            │ │  N  a  F    │ │                                 │
│            │ │  a  a   F   │ │                                 │
│            │ │     F       │ │                                 │
│            │ └─────────────┘ │                                 │
│            └─────────────────┘                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| term_ui dependency | Terminal UI framework |
| AntColony.Plane.get_full_state_for_ui/0 | API to fetch world state for UI |
| AntColony.UI | TermUI.Elm module for visualization |
| Canvas Widget | Grid-based rendering of simulation |
| Mix.Task ant_ui | Optional UI starter task |

## Phases in This Stage

| Phase | Document | Description |
|-------|----------|-------------|
| 2.1 | [01-termui-dependencies.md](./01-termui-dependencies.md) | Add term_ui to mix.exs |
| 2.2 | [02-plane-ui-api.md](./02-plane-ui-api.md) | Add Plane UI state query API |
| 2.3 | [03-ui-module-structure.md](./03-ui-module-structure.md) | Create UI module with TermUI.Elm |
| 2.4 | [04-canvas-rendering.md](./04-canvas-rendering.md) | Implement Canvas drawing |
| 2.5 | [05-ui-integration.md](./05-ui-integration.md) | Integrate and test UI |

## Event Flow

```
Simulation ─────────────────────────────────────────> UI
                                                            │
                                                            ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  AntAgent    │  │    Plane      │  │   AntAgent    │
│               │  │               │  │               │
│ MoveAction   │  │ Food depleted │  │ SenseFood     │
│     │         │  │     │         │  │     │         │
│     ├─────────┴──┴─────┴─────────┴──┴─────┴─────────┤
│     │                                                 │
│     ▼                                                 │
│ AntColony.Events.broadcast_*()                       │
│     │                                                 │
│     ├───────────────────────> Phoenix.PubSub         │
│     │                         "ui_updates"            │
│     │                                                 │
│     └─────────────────────────────────────────────> │
│                                                         │
│                                             AntColony.UI │
│                                                     update/2
│                                                         │
│                                             ┌─────────┴────────┐
│                                             │ Update internal  │
│                                             │ UI state        │
│                                             └─────────────────┘
│                                                         │
│                                                         ▼
│                                                     view/1
│                                                         │
│                                             ┌─────────┴────────┐
│                                             │ Render Canvas    │
│                                             │ with updates     │
│                                             └─────────────────┘
```

## TermUI.Elm Architecture

The UI module uses the Elm Architecture pattern with three core functions:

### init/1
- Subscribes to Phoenix.PubSub "ui_updates" topic
- Fetches initial world state from Plane.get_full_state_for_ui/0
- Builds initial UI state struct
- Returns `{:ok, ui_state}`

### update/2
Handles incoming messages and updates UI state:

| Message | Action |
|---------|--------|
| `{:ant_moved, ant_id, old_pos, new_pos}` | Update ant_positions map |
| `{:food_updated, pos, new_quantity}` | Update food_sources list |
| `%TermUI.Event.Key{key: "q"}` | Return `[:quit]` command |
| `%TermUI.Event.Window{event: :resized}` | Handle resize (optional) |

### view/1
Renders the UI state as a widget tree:
- Creates `TermUI.Widget.Canvas` with grid dimensions
- Draws nest at nest_location
- Draws food sources at their positions
- Draws ants at their positions
- Returns widget tree for TermUI runtime to render

## Visual Elements

| Element | Character | Color | Description |
|---------|-----------|-------|-------------|
| Nest | "N" | White | Colony center location |
| Food | "F" | Yellow | Food source |
| Food (with level) | "F1"-"F5" | Yellow-Red | Food with nutrient level |
| Ant (searching) | "a" | Red | Ant without food |
| Ant (returning) | "A" | Red/Bold | Ant carrying food |

## Success Criteria for Phase 2

1. **term_ui Added**: Dependency installed and compiling
2. **Plane UI API**: get_full_state_for_ui/0 returns world state
3. **UI Module**: TermUI.Elm module created with init/update/view
4. **Canvas Rendering**: Grid, nest, food, ants visible
5. **Event Integration**: UI receives ant_moved and food_updated events
6. **Interactive**: Can quit with 'q' key
7. **Tests**: Unit and integration tests pass

## Dependencies on Phase 1

Phase 2 requires the following from Phase 1:
- Phoenix.PubSub configured and running
- Plane GenServer with world state
- AntAgent with MoveAction (publishes ant_moved)
- AntAgent with SenseFoodAction (publishes food_sensed)
- Event broadcasting via AntColony.Events

## Next Phase

After completing Phase 2, proceed to **Phase 3: Iterative Enhancement** cycles to add:
- Pheromone logic and visualization
- Food levels and foraging logic
- Ant-to-ant communication
- Machine learning integration
- UI controls and polish

## Key References

- `notes/research/development_cycles.md` - Phase 2 specification (lines 26-43)
- `notes/research/terminal_ui.md` - Complete TermUI architecture
- `notes/research/original_research.md` - Overall system architecture
- `notes/planning/phase1_foundational_simulation/*` - Phase 1 planning documents
