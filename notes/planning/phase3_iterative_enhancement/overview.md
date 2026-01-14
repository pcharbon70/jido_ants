# Phase 3: Iterative Enhancement - Overview

## Description

This document provides an overview of Phase 3: Iterative Enhancement. This phase represents the core development loop where specific features are added to the simulation in small, manageable cycles. Each cycle enhances both the simulation logic and the UI visualization to reflect the new capabilities.

## Goal

Implement the advanced features of the ant colony simulation through iterative development cycles. Each cycle adds a specific capability: pheromone-based communication, sophisticated foraging with food levels, direct ant-to-ant communication, machine learning integration, and polished UI controls.

## Architecture Overview

```
Phase 3 Iterative Enhancement
├── Cycle 3.1: Pheromone Logic
│   ├── Actions: LayPheromoneAction, SensePheromoneAction
│   ├── Plane: Pheromone storage, evaporation
│   └── UI: Pheromone visualization
│
├── Cycle 3.2: Food Levels and Foraging
│   ├── Actions: PickUpFoodAction, DropFoodAction, RetracePathAction
│   ├── Agent: State machine (searching, returning)
│   └── UI: Food level display, ant state indication
│
├── Cycle 3.3: Ant-to-Ant Communication
│   ├── Actions: CommunicateAction
│   ├── Plane: Proximity detection
│   └── UI: Communication event visualization
│
├── Cycle 3.4: Machine Learning Integration
│   ├── Actions: CollectLearningDataAction, UpdateModelAction
│   ├── Model: Axon neural network for path prediction
│   └── UI: Learning progress, model metrics
│
└── Cycle 3.5: UI Controls and Polish
    ├── Controls: Pause/resume, speed adjustment
    ├── UI: Status bar, quit confirmation
    └── Simulation: Command handling
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Pheromone System | Indirect communication for path reinforcement |
| Foraging Logic | Food level-based decision making |
| Communication System | Direct information exchange between ants |
| ML Integration | Adaptive search pattern learning |
| UI Controls | User interaction with simulation |

## Cycles in This Phase

| Cycle | Document | Description |
|-------|----------|-------------|
| 3.1 | [01-pheromone-logic.md](./01-pheromone-logic.md) | Implement pheromone laying, sensing, and evaporation |
| 3.2 | [02-food-levels-foraging.md](./02-food-levels-foraging.md) | Food levels, pickup/drop, path retracing |
| 3.3 | [03-ant-communication.md](./03-ant-communication.md) | Proximity detection and information sharing |
| 3.4 | [04-ml-integration.md](./04-ml-integration.md) | Axon-based learning for search patterns |
| 3.5 | [05-ui-controls-polish.md](./05-ui-controls-polish.md) | Pause, speed, status bar, refinement |

## Pheromone System Architecture (Cycle 3.1)

```
Pheromone Management
├── Plane State:
│   └── pheromones: %{{x, y} => %{type: atom(), level: float(), last_updated: DateTime}}
│
├── Pheromone Types:
│   ├── :food_trail - Laid by returning ants, intensity ∝ food quality
│   └── :exploration - Marks explored areas (optional)
│
├── Actions:
│   ├── LayPheromoneAction - Deposit pheromone at current position
│   └── SensePheromoneAction - Query pheromone levels in neighborhood
│
└── Evaporation:
    └── Periodic reduction: new_level = old_level * (1 - evaporation_rate)
```

## Foraging State Machine (Cycle 3.2)

```
AntAgent States
├── :at_nest
│   └── Transition to :searching when ready to forage
│
├── :searching
│   ├── Actions: MoveAction, SenseFoodAction, SensePheromoneAction
│   └── Transition to :returning_to_nest when food found (level > 2)
│
├── :returning_to_nest
│   ├── Actions: RetracePathAction, LayPheromoneAction
│   └── Transition to :at_nest when nest_position reached
│
└── :communicating
    ├── Actions: CommunicateAction
    └── Transition back to previous state after exchange
```

## Communication System (Cycle 3.3)

```
Ant-to-Ant Communication
├── Proximity Detection:
│   └── Plane checks if distance(ant1, ant2) <= 3
│
├── Information Exchange:
│   ├── known_food_sources: [%{position: {x, y}, level: 1-5, last_updated: DateTime}]
│   └── Rule: Higher nutrient level information overrides lower
│
└── Event Flow:
    └── Plane detects proximity → Sends signal → Ants exchange → Update known_food_sources
```

## Machine Learning Integration (Cycle 3.4)

```
ML Learning Pipeline
├── Data Collection:
│   ├── Foraging trip logs (path, time, energy, food quality)
│   └── Local environmental snapshots (pheromones, position, success)
│
├── Model (Axon):
│   ├── Input: [pheromone_level, gradient, distance_to_nest, visit_count, avg_food_quality]
│   ├── Output: Path quality score (0-1)
│   └── Architecture: Feedforward network with dense layers
│
└── Integration:
    ├── Trainer agent collects data and trains model
    └── Ants query model for movement decisions
```

## ACO Formula Reference

The probability of an ant moving from position i to j follows the ACO formula:

```
P(i→j) ∝ τ_ij^α * η_ij^β

Where:
- τ_ij = Pheromone level on edge (i, j)
- η_ij = Heuristic desirability (e.g., inverse distance to known food)
- α = Pheromone importance parameter
- β = Heuristic importance parameter
```

## Success Criteria for Phase 3

1. **Pheromones**: Laying, sensing, and evaporation working ✅
2. **Foraging**: Food levels influence ant behavior ✅
3. **Communication**: Ants share food source information ✅
4. **ML**: Model improves search patterns over time ✅
5. **UI**: All features visualized and controllable ✅
6. **Tests**: Unit and integration tests pass for all cycles ✅

## Dependencies on Phase 2

Phase 3 requires the following from Phase 2:
- Basic AntAgent with MoveAction
- Plane GenServer with food sources
- AntColony.UI with TermUI.Elm
- Phoenix.PubSub event system
- Canvas rendering for grid, nest, food, ants

## Dependencies on Phase 1

Phase 3 requires the following from Phase 1:
- Jido Agent framework configured
- Action system (MoveAction, SenseFoodAction)
- AntAgent schema with state fields
- Event broadcasting via AntColony.Events

## Key References

- `notes/research/development_cycles.md` - Phase 3 specification (lines 45-95)
- `notes/research/original_research.md` - Complete architecture, pheromone details, communication, ML
- `notes/research/terminal_ui.md` - UI enhancements and controls
- `notes/planning/phase1_foundational_simulation/*` - Phase 1 implementation
- `notes/planning/phase2_initial_ui_integration/*` - Phase 2 implementation

## Development Approach

Each cycle in Phase 3 follows this pattern:

1. **Simulation-First**: Implement the core simulation logic first
2. **Event Publishing**: Ensure all state changes publish events
3. **UI Integration**: Update UI to display new information
4. **Testing**: Write unit tests for each component
5. **Integration Tests**: Verify end-to-end functionality

This iterative approach ensures each feature is fully working before moving to the next, maintaining system stability and allowing for continuous validation.
