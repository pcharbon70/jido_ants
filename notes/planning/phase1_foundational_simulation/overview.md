# Phase 1 Foundational Simulation: Overview

## Description

This document provides an overview of Phase 1: Foundational Simulation Skeleton. This phase establishes the minimal viable simulation that can be observed and tested before integrating the terminal UI.

## Goal

Create a very basic, working simulation that can be "observed" even without a graphical UI. The simulation components (Plane, AntAgents) will publish events that can be consumed by a simple console observer or, in the next phase, by the terminal UI.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    AntColony.Application                        │
│                    (Supervision Tree)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │ AntColony.PubSub│  │ AntColony.Plane │  │ AgentSupervisor│  │
│  │ (Phoenix.PubSub)│  │   (GenServer)   │  │  (Dynamic)      │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬───────┘  │
│           │                    │                     │          │
│           │                    │                     │          │
│           ▼                    ▼                     ▼          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   AntAgent Instances                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐               │  │
│  │  │  Ant 1   │  │  Ant 2   │  │  Ant 3   │  ...          │  │
│  │  │ (Jido)   │  │ (Jido)   │  │ (Jido)   │               │  │
│  │  └──────────┘  └──────────┘  └──────────┘               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                AntColony.Observer (Optional)             │  │
│  │                Subscribes to PubSub events               │  │
│  │                Prints to console for debugging           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Phases in This Stage

| Phase | Document | Description |
|-------|----------|-------------|
| 1.1 | [01-project-setup.md](./01-project-setup.md) | Initialize Elixir project with dependencies |
| 1.2 | [02-pubsub-configuration.md](./02-pubsub-configuration.md) | Configure Phoenix.PubSub for events |
| 1.3 | [03-plane-genserver.md](./03-plane-genserver.md) | Implement Plane environment GenServer |
| 1.4 | [04-antagent-schema.md](./04-antagent-schema.md) | Define AntAgent schema with Jido |
| 1.5 | [05-move-action.md](./05-move-action.md) | Implement MoveAction with event publishing |
| 1.6 | [06-sense-food-action.md](./06-sense-food-action.md) | Implement SenseFoodAction |
| 1.7 | [07-supervision-tree.md](./07-supervision-tree.md) | Set up application supervision tree |
| 1.8 | [08-console-observer.md](./08-console-observer.md) | Create console observer for testing |

## Component Relationships

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Event Flow                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   AntAgent                      Plane                    Observer    │
│      │                            │                          │       │
│      │ MoveAction                 │                          │       │
│      ├───────────────────────────>│ register_ant()           │       │
│      │                            │                          │       │
│      │ MoveAction                 │                          │       │
│      ├───────────────────────────>│ update_ant_position()    │       │
│      │                            │                          │       │
│      │ MoveAction                 │                          │       │
│      │  ┌─────────────────────────────────────────────────┐   │       │
│      │  │ Publish: {:ant_moved, ant_id, old_pos, new_pos} │──┼──>│       │
│      │  │            via Phoenix.PubSub                    │   │       │
│      │  └─────────────────────────────────────────────────┘   │       │
│      │                            │                          │       │
│      │ SenseFoodAction             │                          │       │
│      ├───────────────────────────>│ get_food_at(position)    │       │
│      │<───────────────────────────│ food_details             │       │
│      │                            │                          │       │
│      │ SenseFoodAction             │                          │       │
│      │  ┌─────────────────────────────────────────────────┐   │       │
│      │  │ Publish: {:food_sensed, ant_id, pos, food}      │──┼──>│       │
│      │  │            via Phoenix.PubSub                    │   │       │
│      │  └─────────────────────────────────────────────────┘   │       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Success Criteria for Phase 1

1. **Project Setup**: Elixir project compiles with all dependencies
2. **PubSub**: Event publishing and subscription works
3. **Plane**: GenServer manages world state (food, positions)
4. **AntAgent**: Jido agents can be created and execute actions
5. **MoveAction**: Ants can move and publish events
6. **SenseFoodAction**: Ants can detect food at their position
7. **Supervision**: All processes run under supervision tree
8. **Observer**: Console output shows simulation events

## Next Phase

After completing Phase 1, proceed to **Phase 2: Initial UI Integration** to create the terminal UI that visualizes the simulation.

## Dependencies Between Phases

```
1.1 Project Setup
    │
    ├─────────────> 1.2 PubSub Configuration
    │                   │
    │                   ├─────────────> 1.4 AntAgent Schema ───────┐
    │                   │                                          │
    │                   └─────────────> 1.3 Plane GenServer ──────┤
    │                                                               │
    └───────────────────────────────────────────────────────────────┤
                                                                    │
                                    1.5 MoveAction <───────────────┘
                                    │
                                    ├─────────────> 1.7 Supervision Tree
                                    │                   │
                                    └─────> 1.6 SenseFood Action ────┘
                                                        │
                                                        │
                                              1.8 Console Observer
```

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Phoenix.PubSub for events | Decouples simulation from UI/observers |
| Plane as GenServer | Centralized state management for world |
| Jido.Agent for ants | Framework provides state machine and actions |
| Console observer first | Test events before building UI |
| DynamicSupervisor for ants | Agents can be spawned/stopped dynamically |
