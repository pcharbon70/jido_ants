# Ant Colony Simulation: A Distributed Foraging Architecture

This plan details the implementation of an ant colony intelligence simulation using the Jido v2 autonomous agent framework within the Elixir ecosystem. Individual Jido agents model autonomous ants with internal state machines governing behavior (searching, foraging, returning, communicating). A pheromone-inspired communication system enables local knowledge sharing when ants encounter each other within proximity. Machine learning integration via Axon and Bumblebee enables ants to learn and adapt search patterns over time.

## Overview

The simulation models emergent foraging behavior in ant colonies through individual agents following simple rules. Each ant operates autonomously with its own state, while collective intelligence emerges through pheromone trails and direct communication. The system demonstrates swarm intelligence principles, distributed optimization, and adaptive agent behaviors in a complex, dynamic environment.

**Key Deliverables:**
- `JidoAnts.Plane` - Simulated 2D grid environment with food sources and pheromone fields
- `JidoAnts.Agent.Ant` - Individual ant agents with FSM-based behavior
- `JidoAnts.Actions` - Movement, sensing, foraging, and communication actions
- `JidoAnts.Skills` - Modular behavior groups (Foraging, Navigation, Social)
- Pheromone-based indirect communication system
- Direct ant-to-ant communication within proximity radius
- Machine learning models for adaptive path optimization

## Phase Documents

- [Phase 1: Project Setup and Core Data Structures](phase-01.md) - Mix project, position types, food structs, pheromone structures, plane definition
- [Phase 2: The Plane Environment](phase-02.md) - Plane GenServer, food management, grid operations, pheromone fields
- [Phase 3: Ant Agent Foundation](phase-03.md) - AntAgent struct, FSM states, state management, agent lifecycle
- [Phase 4: Movement and Sensing Actions](phase-04.md) - MoveAction, SenseFoodAction, SensePheromoneAction, path memory
- [Phase 5: Foraging Actions](phase-05.md) - PickUpFoodAction, DropFoodAction, RetracePathAction, food transport
- [Phase 6: Pheromone System](phase-06.md) - LayPheromoneAction, evaporation, movement bias, ACO integration
- [Phase 7: Ant Communication](phase-07.md) - Proximity detection, CommunicateAction, signaling, information exchange
- [Phase 8: Machine Learning Integration](phase-08.md) - Data collection, Axon models, predictive path quality, training

## Architecture Overview

```
JidoAnts.Application (:one_for_one)
├── JidoAnts.Plane (GenServer - Environment)
│   ├── Grid state (dimensions, bounds)
│   ├── Food sources (position, level, quantity)
│   ├── Pheromone fields (type, intensity)
│   └── Agent position registry
│
├── JidoAnts.Agent.Supervisor (DynamicSupervisor)
│   │
│   └── JidoAnts.Agent.Ant (Jido.AgentServer)
│       ├── FSM Strategy (:at_nest, :searching, :returning_to_nest, :communicating)
│       ├── ForagingSkill (PickUpFoodAction, DropFoodAction, RetracePathAction)
│       ├── NavigationSkill (MoveAction, SensePheromoneAction)
│       └── SocialSkill (CommunicateAction)
│
└── JidoAnts.ColonyIntelligence (GenServer - ML Coordinator)
    ├── Data collection (foraging trip logs)
    ├── Axon model (path quality predictor)
    └── Training pipeline
```

## Data Structures

### Position

```elixir
@type position :: {non_neg_integer(), non_neg_integer()}
```

A coordinate pair `{x, y}` on the 2D grid plane.

### Food Source

```elixir
defmodule JidoAnts.FoodSource do
  @type t :: %__MODULE__{
    position: position(),
    level: 1..5,           # Nutrient quality
    quantity: non_neg_integer(),
    max_quantity: pos_integer()
  }
end
```

### Pheromone

```elixir
defmodule JidoAnts.Pheromone do
  @type type :: :food_trail | :exploration | :danger

  @type t :: %__MODULE__{
    type: type(),
    intensity: float(),
    deposited_at: DateTime.t()
  }
end
```

### Ant State

```elixir
defmodule JidoAnts.Agent.Ant do
  @type state :: :at_nest | :searching | :returning_to_nest | :communicating

  @type t :: %__MODULE__{
    id: String.t(),
    position: position(),
    nest_position: position(),
    path_memory: [position_entry()],
    current_state: state(),
    has_food?: boolean(),
    carried_food_level: 1..5,
    known_food_sources: [food_source_info()],
    energy: non_neg_integer()
  }

  @type position_entry :: {position(), observation()}
  @type observation :: %{
    food_found: boolean(),
    food_level: 1..5,
    pheromone_sensed: map()
  }
end
```

### Plane State

```elixir
defmodule JidoAnts.Plane do
  @type t :: %__MODULE__{
    width: pos_integer(),
    height: pos_integer(),
    food_sources: %{position() => FoodSource.t()},
    pheromones: %{position() => %{Pheromone.type() => Pheromone.t()}},
    ant_positions: %{ant_id() => position()},
    nest_position: position()
  }
end
```

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Agent framework | Jido v2 | Provides autonomous agents with composable actions, state management, and directive-based side effects |
| Language | Elixir | BEAM concurrency enables thousands of lightweight ant processes, fault tolerance for robust multi-agent systems |
| Grid representation | 2D discrete coordinates | Simplifies movement and sensing, matches ACO graph-based approach |
| Pheromone storage | Centralized in Plane | Simpler implementation, enables global evaporation, sufficient for moderate ant counts |
| Communication range | 3-unit radius | Balances information propagation with localization, creates interesting clustering dynamics |
| FSM states | 4 behavioral states | Covers full foraging lifecycle: at nest, searching, returning, communicating |
| ML library | Axon | Native Elixir deep learning, integrates with Nx for numerical computing |
| Food quality levels | 1-5 scale | Provides gradient for decision-making, maps to pheromone intensity |
| Energy system | Optional per-ant energy | Adds realism, can be toggled for different simulation complexity |
| Path memory | List of visited positions | Enables retracing, supports exploration tracking |

## Current State Analysis

### What Already Exists

| Component | Status | Location |
|-----------|--------|----------|
| Research document | Complete | `notes/research/original_research.md` |
| Mix project | Not created | N/A |
| Jido v2 dependency | Not added | N/A |
| Any implementation code | None | N/A |

### Gaps to Fill

| Component | Gap | Phase |
|-----------|-----|-------|
| Mix project setup | No project file | Phase 1 |
| Core data types | Not defined | Phase 1 |
| Plane environment | Not implemented | Phase 2 |
| Ant agents | Not implemented | Phase 3 |
| Movement actions | Not implemented | Phase 4 |
| Foraging actions | Not implemented | Phase 5 |
| Pheromone system | Not implemented | Phase 6 |
| Communication | Not implemented | Phase 7 |
| ML integration | Not implemented | Phase 8 |

## Success Criteria

1. **Project Structure**: Mix project with Jido v2, Axon, Bumblebee dependencies
2. **Plane Environment**: Functional 2D grid with food sources and pheromone fields
3. **Ant Agents**: Jido agents with FSM-based behavioral states
4. **Movement**: Ants navigate grid with path memory
5. **Foraging**: Ants find, pick up, and return food to nest
6. **Pheromones**: Digital pheromone trails with evaporation
7. **Communication**: Ants exchange food source information within proximity
8. **ACO Integration**: Pheromone-based path reinforcement and probabilistic movement
9. **ML Models**: Axon models for path quality prediction
10. **Test Coverage**: Minimum 80% coverage for implementation code
11. **Emergent Behavior**: Colony converges on optimal foraging paths

## Critical Files

**New Files (Phase 1):**
- `mix.exs` - Project configuration and dependencies
- `lib/jido_ants.ex` - Main application module
- `lib/jido_ants/plane.ex` - Plane struct definition
- `lib/jido_ants/position.ex` - Position type and utilities
- `lib/jido_ants/food_source.ex` - Food source struct
- `lib/jido_ants/pheromone.ex` - Pheromone struct
- `test/jido_ants/position_test.exs`
- `test/jido_ants/food_source_test.exs`
- `test/jido_ants/pheromone_test.exs`

**New Files (Phase 2):**
- `lib/jido_ants/plane_server.ex` - Plane GenServer
- `test/jido_ants/plane_server_test.exs`
- `test/jido_ants/integration/plane_phase2_test.exs`

**New Files (Phase 3):**
- `lib/jido_ants/agent/ant.ex` - Ant agent module
- `lib/jido_ants/agent/supervisor.ex` - Agent supervisor
- `lib/jido_ants/agent/fsm_strategy.ex` - FSM execution strategy
- `test/jido_ants/agent/ant_test.exs`
- `test/jido_ants/integration/agent_phase3_test.exs`

**New Files (Phase 4):**
- `lib/jido_ants/actions/move.ex` - MoveAction
- `lib/jido_ants/actions/sense_food.ex` - SenseFoodAction
- `lib/jido_ants/actions/sense_pheromone.ex` - SensePheromoneAction
- `test/jido_ants/actions/move_test.exs`
- `test/jido_ants/actions/sense_food_test.exs`
- `test/jido_ants/actions/sense_pheromone_test.exs`
- `test/jido_ants/integration/actions_phase4_test.exs`

**New Files (Phase 5):**
- `lib/jido_ants/actions/pick_up_food.ex` - PickUpFoodAction
- `lib/jido_ants/actions/drop_food.ex` - DropFoodAction
- `lib/jido_ants/actions/retrace_path.ex` - RetracePathAction
- `test/jido_ants/actions/pick_up_food_test.exs`
- `test/jido_ants/actions/drop_food_test.exs`
- `test/jido_ants/actions/retrace_path_test.exs`
- `test/jido_ants/integration/foraging_phase5_test.exs`

**New Files (Phase 6):**
- `lib/jido_ants/actions/lay_pheromone.ex` - LayPheromoneAction
- `lib/jido_ants/plane/pheromone_manager.ex` - Pheromone field management
- `lib/jido_ants/aco.ex` - ACO algorithm implementation
- `test/jido_ants/actions/lay_pheromone_test.exs`
- `test/jido_ants/plane/pheromone_manager_test.exs`
- `test/jido_ants/integration/pheromone_phase6_test.exs`

**New Files (Phase 7):**
- `lib/jido_ants/actions/communicate.ex` - CommunicateAction
- `lib/jido_ants/plane/proximity_detector.ex` - Proximity detection service
- `lib/jido_ants/skills/social.ex` - Social skill
- `test/jido_ants/actions/communicate_test.exs`
- `test/jido_ants/plane/proximity_detector_test.exs`
- `test/jido_ants/integration/communication_phase7_test.exs`

**New Files (Phase 8):**
- `lib/jido_ants/colony_intelligence.ex` - ML coordinator
- `lib/jido_ants/ml/data_collector.ex` - Foraging data collection
- `lib/jido_ants/ml/path_quality_model.ex` - Axon model definition
- `lib/jido_ants/ml/trainer.ex` - Model training
- `test/jido_ants/colony_intelligence_test.exs`
- `test/jido_ants/ml/data_collector_test.exs`
- `test/jido_ants/ml/integration/ml_phase8_test.exs`

**New Files (Cross-Cutting):**
- `lib/jido_ants/skills/foraging.ex` - Foraging skill
- `lib/jido_ants/skills/navigation.ex` - Navigation skill
- `lib/jido_ants/application.ex` - Application supervisor
- `config/config.exs` - Application configuration

## Provides Foundation For

- **Swarm Intelligence Research**: Platform for studying emergent behavior in multi-agent systems
- **ACO Variants**: Test bed for ant colony optimization algorithm variations
- **Distributed AI**: Demonstration of distributed decision-making with local communication
- **Robotics Swarms**: Simulation foundation for physical robot swarm control
- **Educational Tool**: Teaching platform for agent-based modeling and Elixir/BEAM
- **ML in Agents**: Reference implementation for ML-integrated autonomous agents
