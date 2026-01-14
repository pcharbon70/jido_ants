# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **research and documentation project** for simulating ant colony intelligence using distributed foraging architecture with Jido v2. The project is in the planning/research phase—no implementation code exists yet.

**Technology Stack:**
- **Language:** Elixir
- **Agent Framework:** Jido v2 (autonomous agent framework)
- **Machine Learning:** Axon (neural networks) and Bumblebee (pre-trained models)
- **UI:** Terminal UI using `term_ui` library (Elm Architecture-inspired)
- **Communication:** Phoenix.PubSub for event-driven architecture

## Project Status

**Current Phase:** Research and documentation. No `mix.exs`, no source code, no build system exists.

**Research Documents:**
- `notes/research/original_research.md` - Comprehensive architecture paper covering AntAgent schema, Plane environment, pheromone communication, ML integration
- `notes/research/terminal_ui.md` - Terminal UI architecture using term_ui with Elm pattern (init/update/view cycle)
- `notes/research/development_cycles.md` - Iterative development workflow guidance

## Planned Architecture

### Core Components

**AntAgent (Jido Agent)**
- State schema: `id`, `position`, `path_memory`, `has_food?`, `current_state`, `known_food_sources`, `energy`
- FSM states: `:at_nest`, `:searching`, `:returning_to_nest`, `:communicating`
- Actions: `MoveAction`, `SenseFoodAction`, `PickUpFoodAction`, `DropFoodAction`, `LayPheromoneAction`, `CommunicateAction`, `RetracePathAction`
- Skills: Modular groupings like `ForagingSkill`, `NavigationSkill`, `SocialSkill`

**Plane (Environment GenServer)**
- Manages grid dimensions, nest location, food sources (with levels 1-5), pheromone fields
- Handles proximity detection for ant-to-ant communication (3-square radius)
- Publishes events via Phoenix.PubSub for UI updates
- Manages pheromone evaporation via periodic tasks

**Communication Mechanisms**
- **Pheromones:** Indirect stigmergic communication laid by returning ants, intensity proportional to food quality
- **Direct Exchange:** Ants within 3-unit radius share `known_food_sources`, higher nutrient paths override lower ones

**Terminal UI (AntColonyUI)**
- Implements `TermUI.Elm` behaviour with `init/1`, `update/2`, `view/1` cycle
- Subscribes to Phoenix.PubSub topic `"ui_updates"` for simulation events
- Uses `TermUI.Widget.Canvas` for grid-based visualization
- Events: `{:ant_moved, ant_id, old_pos, new_pos}`, `{:food_updated, pos, new_quantity}`

## Development Workflow

**When implementation begins**, follow the iterative approach from `notes/research/development_cycles.md`:

1. **Phase 1:** Foundational simulation skeleton (AntAgent with basic MoveAction, Plane GenServer, event publishing via PubSub)
2. **Phase 2:** Initial UI integration (TermUI.Elm module, Canvas grid visualization)
3. **Phase 3:** Iterative enhancement cycles (pheromones, foraging logic, communication, ML integration)
4. **Phase 4:** Testing and debugging (unit tests, integration tests, UI debugging)

**Key Principle:** Within each iteration, implement simulation changes before or in tandem with UI changes. The simulation must publish events immediately upon state changes (e.g., ant movement must broadcast `{:ant_moved, ...}` right away).

## Machine Learning Integration (Planned)

- **Axon** for custom neural networks (path quality prediction, ACO parameter tuning)
- **Bumblebee** for pre-trained models (if complex sensory inputs are added later)
- Training occurs in dedicated "trainer" agent; models distributed to ants via signals
- Data collected from foraging trips: paths taken, time, energy expended, food quality found

## Event-Driven Communication

All simulation-to-UI communication uses Phoenix.PubSub:
- Topic: `"ui_updates"` (configurable)
- Published by: `AntAgent` actions (movement) and `Plane` (food updates, world initialization)
- Consumed by: `AntColonyUI` module which subscribes on initialization

UI-to-simulation commands (pause/resume, speed control) flow via GenServer calls or PubSub command events.

## Ant Colony Optimization (ACO) Principles

Path selection probability uses classic ACO formula:
```
P(i→j) ∝ τ_ij^α * η_ij^β
```
- τ = pheromone level
- η = heuristic desirability
- α, β = relative importance parameters
- Evaporation rate ρ prevents stagnation

## Implementation Notes

When code is added:
- Use `Jido.AgentServer` to run individual AntAgent instances
- Use `Jido.Signal.Emit` directive for side effects in actions
- Use Zoi or NimbleOptions for schema validation
- Pheromone intensity = `carried_food_level * constant`
- Food levels 1-5; ants only pick up if level > 2
