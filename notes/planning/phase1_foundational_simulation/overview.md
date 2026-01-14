# Phase 1 Foundational Simulation: Overview

## Description

This document provides an overview of Phase 1: Foundational Simulation Skeleton. This phase establishes the minimal viable simulation with generational management that can be observed and tested before integrating the terminal UI.

## Goal

Create a basic, working simulation with generational intelligence. The simulation components (ColonyIntelligenceAgent, Plane, AntAgents) will publish events that can be consumed by a simple console observer or, in the next phase, by the terminal UI. The ColonyIntelligenceAgent manages generations, tracks KPIs, and spawns new generations of AntAgents.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AntColony.Application                            │
│                      (Supervision Tree)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐ │
│  │AntColony.PubSub  │  │AntColony.Plane   │  │ ColonyIntelligence  │ │
│  │(Phoenix.PubSub)  │  │  (GenServer)     │  │     Agent          │ │
│  └────────┬─────────┘  └────────┬─────────┘  │      (Jido)         │ │
│           │                     │              └──────────┬─────────┘ │
│           │                     │                         │           │
│           │                     │                         ▼           │
│           │                     │              ┌─────────────────────┐│
│           │                     │              │ AgentSupervisor     ││
│           │                     │              │    (Dynamic)        ││
│           │                     │              └──────────┬─────────┘│
│           │                     │                         │           │
│           ▼                     ▼                         ▼           │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                      AntAgent Instances                         │  │
│  │   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │  │
│  │   │  Ant 1   │  │  Ant 2   │  │  Ant 3   │  │  Ant 4   │...  │  │
│  │   │ (Jido)   │  │ (Jido)   │  │ (Jido)   │  │ (Jido)   │     │  │
│  │   │ gen_id=1 │  │ gen_id=1 │  │ gen_id=1 │  │ gen_id=1 │     │  │
│  │   └──────────┘  └──────────┘  └──────────┘  └──────────┘     │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                AntColony.Observer (Optional)                     │  │
│  │                Subscribes to PubSub events                       │  │
│  │                Prints to console for debugging                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Generational Concept

The simulation is organized into **generations** - discrete epochs where ants forage and the colony learns. When a generation ends (based on food delivery count, performance plateau, or other triggers), the ColonyIntelligenceAgent:

1. Evaluates the current generation's performance
2. Breeds the next generation (selection, crossover, mutation)
3. Spawns new AntAgents with evolved parameters
4. Increments the generation counter

This enables **meta-learning** - the colony evolves its strategies across generations, not just within an ant's lifetime.

## Phases in This Stage

| Phase | Document | Description |
|-------|----------|-------------|
| 1.1 | [01-project-setup.md](./01-project-setup.md) | Initialize Elixir project with dependencies |
| 1.2 | [02-pubsub-configuration.md](./02-pubsub-configuration.md) | Configure Phoenix.PubSub for events |
| 1.3 | [03-plane-genserver.md](./03-plane-genserver.md) | Implement Plane environment GenServer |
| 1.4 | [04-antagent-schema.md](./04-antagent-schema.md) | Define AntAgent schema with Jido (includes generation_id) |
| 1.5 | [05-move-action.md](./05-move-action.md) | Implement MoveAction with event publishing |
| 1.6 | [06-sense-food-action.md](./06-sense-food-action.md) | Implement SenseFoodAction |
| 1.7 | [07-supervision-tree.md](./07-supervision-tree.md) | Set up application supervision tree with ColonyIntelligenceAgent |
| 1.8 | [08-console-observer.md](./08-console-observer.md) | Create console observer for testing |
| 1.9 | [09-colony-intelligence-agent.md](./09-colony-intelligence-agent.md) | Implement ColonyIntelligenceAgent for generational management |

## Component Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Event Flow                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   AntAgent              Plane          ColonyIntelligenceAgent    Observer  │
│      │                    │                    │                      │      │
│      │ MoveAction         │                    │                      │      │
│      ├───────────────────>│ register_ant(gen_id)│                      │      │
│      │                    │<───────────────────┼ spawn_agent()         │      │
│      │                    │                    │                      │      │
│      │ MoveAction         │                    │                      │      │
│      ├───────────────────>│ update_ant_position()│                    │      │
│      │                    │                    │                      │      │
│      │ MoveAction         │                    │                      │      │
│      │  ┌───────────────────────────────────────────────────────┐   │      │
│      │  │ Publish: {:ant_moved, ant_id, gen_id, old_pos, new_pos}│──┼──>│      │
│      │  │               via Phoenix.PubSub                        │   │      │
│      │  └───────────────────────────────────────────────────────┘   │      │
│      │                    │                    │                      │      │
│      │ SenseFoodAction   │                    │                      │      │
│      ├───────────────────>│ get_food_at(pos)   │                      │      │
│      │<───────────────────│ food_details        │                      │      │
│      │                    │                    │                      │      │
│      │ Food Delivered     │                    │                      │      │
│      │  ┌───────────────────────────────────────────────────────┐   │      │
│      │  │ Publish: {:food_delivered, ant_id, gen_id, qty, time}  │──┼──>│      │
│      │  │               via Phoenix.PubSub                        │   │      │
│      │  └───────────────────┬───────────────────────────────────┘   │      │
│      │                      ▼                                       │      │
│      │              ┌─────────────────┐                             │      │
│      │              │ KPI Tracking    │                             │      │
│      │              │ - Count++       │                             │      │
│      │              │ - Calc rate     │                             │      │
│      │              └─────────────────┘                             │      │
│                        │                                           │      │
│                        │ Count >= Threshold?                        │      │
│                        ▼                                             │      │
│                 ┌─────────────────┐                                  │      │
│                 │ Trigger Next     │                                  │      │
│                 │ Generation       │                                  │      │
│                 └─────────────────┘                                  │      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Success Criteria for Phase 1

1. **Project Setup**: Elixir project compiles with all dependencies
2. **PubSub**: Event publishing and subscription works
3. **Plane**: GenServer manages world state (food, positions)
4. **AntAgent**: Jido agents can be created and execute actions
5. **AntAgent Schema**: Includes `generation_id` field
6. **MoveAction**: Ants can move and publish events (with generation_id)
7. **SenseFoodAction**: Ants can detect food at their position
8. **ColonyIntelligenceAgent**: Manages generations, tracks KPIs, spawns new generations
9. **Supervision**: All processes run under supervision tree
10. **Observer**: Console output shows simulation events

## Next Phase

After completing Phase 1, proceed to **Phase 2: Initial UI Integration** to create the terminal UI that visualizes the simulation and displays generation information.

## Dependencies Between Phases

```
1.1 Project Setup
    │
    ├─────────────> 1.2 PubSub Configuration
    │                   │
    │                   ├─────────────> 1.4 AntAgent Schema ───────┐
    │                   │              (add generation_id)        │
    │                   ├─────────────> 1.3 Plane GenServer ──────┤
    │                   │                                          │
    │                   └─────────────> 1.9 ColonyIntelligence ───┤
    │                                   Agent (NEW)                │
    │                                                               │
    └───────────────────────────────────────────────────────────────┤
                                                                    │
                                    1.5 MoveAction <───────────────┘
                                    │ (include gen_id in events)
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
| Jido.Agent for ants & ColonyIntelligence | Framework provides state machine and actions |
| ColonyIntelligenceAgent spawns AntAgents | Enables generational management and evolution |
| Count-based generation trigger (Phase 1) | Simple to implement; will evolve to plateau detection |
| Console observer first | Test events before building UI |
| DynamicSupervisor for ants | Agents can be spawned/stopped dynamically between generations |
