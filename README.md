# Jido Ants

A research and simulation project exploring ant colony intelligence using distributed autonomous agents in Elixir. The project implements emergent foraging behavior through individual agents following simple rules, enhanced with machine learning for adaptive pattern optimization.

## Project Overview

This project simulates an ant colony where each ant is an autonomous agent operating within a shared environment. The colony exhibits swarm intelligence through:

- **Stigmergic communication** via pheromone trails that reinforce successful foraging paths
- **Direct ant-to-ant communication** when agents encounter each other within a 3-unit radius
- **Machine learning integration** using Axon and Bumblebee for adaptive search pattern optimization
- **Terminal-based visualization** for real-time observation of emergent colony behaviors

## Goals

1. **Demonstrate Swarm Intelligence**: Show how complex collective behavior emerges from simple individual rules
2. **Explore Ant Colony Optimization (ACO)**: Implement classic ACO principles for path finding and resource allocation
3. **Integrate Machine Learning**: Enable the colony to learn and adapt its foraging strategies over time
4. **Provide Visualization**: Build a terminal UI for observing and debugging the simulation

## Technology Stack

| Component | Library | Purpose |
|-----------|---------|---------|
| **Agent Framework** | [Jido v2](https://github.com/agentjido/jido) | Autonomous agent framework with state machines, actions, and skills |
| **Language** | Elixir ~ 1.18 | Concurrent, fault-tolerant runtime (BEAM) |
| **Communication** | Phoenix.PubSub | Event-driven messaging between agents and UI |
| **ML / Neural Networks** | Axon | Custom neural network models for learning |
| **Pre-trained Models** | Bumblebee | Integration of pre-trained models (future) |
| **Numerical Computing** | Nx | Tensor operations backing ML components |
| **Terminal UI** | term_ui | Elm-Architecture-inspired terminal visualization |

## Architecture

### Core Components

#### AntAgent
Each ant is implemented as a Jido agent with:

**State Schema:**
- `id` - Unique identifier
- `position` - Current `{x, y}` coordinates
- `path_memory` - List of visited positions for retracing steps
- `has_food?` - Whether carrying food
- `current_state` - FSM state: `:at_nest`, `:searching`, `:returning_to_nest`, `:communicating`
- `known_food_sources` - Food locations discovered through exploration or communication
- `energy` - Optional energy level for work capacity modeling

**Actions:**
| Action | Description |
|--------|-------------|
| `MoveAction` | Navigate the grid based on pheromones, heuristics, or ML predictions |
| `SenseFoodAction` | Detect food at current position |
| `PickUpFoodAction` | Collect food if level > 2 |
| `DropFoodAction` | Deposit food at nest |
| `LayPheromoneAction` | Deposit pheromone trail (intensity proportional to food quality) |
| `SensePheromoneAction` | Detect pheromone levels in neighboring cells |
| `CommunicateAction` | Exchange food source information with nearby ants |
| `RetracePathAction` | Navigate back to nest using path memory |

#### Plane (Environment)
The Plane is a GenServer managing the shared world state:

- Grid dimensions and boundaries
- Nest location
- Food sources with levels 1-5 (nutrient quality) and quantities
- Pheromone fields with evaporation logic
- Proximity detection for ant-to-ant communication

#### Communication Mechanisms

**Pheromone Communication (Stigmergy):**
- Indirect, environment-mediated signaling
- Path reinforcement: `P(i→j) ∝ τ^α * η^β`
- Evaporation prevents stagnation and enables adaptation

**Direct Communication:**
- Ants within 3-unit radius exchange `known_food_sources`
- Higher nutrient level paths override lower quality information
- Enables rapid dissemination of valuable discoveries

#### Machine Learning Integration

**Data Collection:**
- Foraging trip logs: paths taken, time, energy, food quality
- Local environmental snapshots at decision points
- Communication events and outcomes

**Learning Tasks:**
- **Path Quality Prediction**: Neural network predicting food discovery likelihood
- **ACO Parameter Tuning**: Dynamic optimization of exploration vs. exploitation
- **Pattern Recognition**: Identifying spatial distributions of food sources

**Training:**
- Dedicated "trainer" agent collects data and trains Axon models
- Models distributed to agents via signals or centralized inference service

#### Terminal UI (AntColonyUI)

Built with `term_ui` using Elm Architecture:

```
init/1  →  Subscribe to PubSub, fetch initial world state
  ↓
update/2 → Handle simulation events and user input
  ↓
view/1  →  Render grid, ants, food, pheromones
```

**Features:**
- Canvas-based grid visualization
- Color-coded food levels and ant states
- Real-time updates via Phoenix.PubSub
- User controls: pause/resume, speed adjustment, quit

## Project Status

**Current Phase**: Research and Documentation

The project is in the planning/research phase. Comprehensive architecture documentation exists in `notes/research/`:

| Document | Content |
|----------|---------|
| `original_research.md` | Complete AntAgent schema, Plane design, ACO principles, ML integration |
| `terminal_ui.md` | TermUI architecture, event-driven simulation-to-UI communication |
| `development_cycles.md` | Iterative development workflow with simulation-first approach |
| `generative_ml.md` | Machine learning strategies and model architectures |
| `generative_cycles.md` | Multi-generational evolution and meta-learning protocols |

## Development Workflow

The project follows an iterative, simulation-first approach:

1. **Phase 1**: Foundational simulation skeleton (AntAgent, Plane, event publishing)
2. **Phase 2**: Initial UI integration (TermUI.Elm, Canvas visualization)
3. **Phase 3**: Iterative enhancement cycles:
   - Pheromone logic
   - Food levels and foraging behavior
   - Ant-to-ant communication
   - ML integration
   - UI controls and polish
4. **Phase 4**: Testing, debugging, and refinement

## Ant Colony Optimization (ACO) Formula

Path selection probability follows the classic ACO equation:

```
        τ_ij^α * η_ij^β
P(i→j) = ------------------
         Σ τ_il^α * η_il^β
          l∈allowed
```

Where:
- `τ` = pheromone level on the edge
- `η` = heuristic desirability (e.g., inverse distance)
- `α` = pheromone importance parameter
- `β` = heuristic importance parameter
- Evaporation rate `ρ` prevents premature convergence

## Running the Simulation

**Note**: Implementation is in progress. Refer to `notes/research/development_cycles.md` for the current development status.

```bash
# Start the simulation core
iex -S mix

# Start the terminal UI (planned)
mix ant_ui
```

## Future Directions

- Dynamic environments with regenerating food sources
- Predator-prey dynamics
- Multi-agent specialization (foragers, scouts, defenders)
- Advanced terrain with movement costs
- Reinforcement learning for individual ant policies
- Physical robot swarm translation

## References

- [Jido v2 Framework](https://github.com/agentjido/jido)
- [Ant Colony Optimization](https://en.wikipedia.org/wiki/Ant_colony_optimization_algorithms)
- [term_ui](https://github.com/pcharbon70/term_ui)
- [Axon & Bumblebee](https://github.com/elixir-nx/bumblebee)

## License

See [LICENSE](LICENSE) for details.
