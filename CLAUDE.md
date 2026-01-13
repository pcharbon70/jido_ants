# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **research repository** for designing an ant colony intelligence simulation using Elixir. The project is in the architectural research phase with comprehensive documentation but no implementation code yet.

The goal is to create a multi-agent simulation where:
- Individual ants are implemented as **Jido v2** agents (autonomous agent framework for Elixir)
- Ants operate on a 2D grid plane with food sources
- Communication occurs via **pheromone trails** (stigmergic) and **direct ant-to-ant exchange** (within 3-unit radius)
- Machine learning via **Axon** and **Bumblebee** enables ants to learn optimal foraging patterns

## Key Technologies

- **Elixir/OTP** - Primary language, chosen for concurrency and fault tolerance
- **Jido v2** - Agent framework for creating autonomous, stateful agents with composable actions
- **Axon** - Deep learning library for neural networks (built on Nx)
- **Bumblebee** - Pre-trained neural network models
- **Nx** - Numerical computing backend (Elixir's equivalent to NumPy)

## Architecture

### Agent Design (AntAgent)

Each ant is a Jido agent with:
- **State schema**: `id`, `position`, `nest_position`, `path_memory`, `current_state`, `has_food?`, `carried_food_level`, `known_food_sources`, `energy`
- **FSM states**: `:at_nest`, `:searching`, `:returning_to_nest`, `:communicating`
- **Actions**: `MoveAction`, `SenseFoodAction`, `PickUpFoodAction`, `DropFoodAction`, `LayPheromoneAction`, `SensePheromoneAction`, `RetracePathAction`, `CommunicateAction`
- **Skills** (modular groups): `ForagingSkill`, `NavigationSkill`, `SocialSkill`

### Environment (The Plane)

The simulated environment manages:
- Grid dimensions and boundaries
- Food sources (position, nutrient level 1-5, quantity)
- Pheromone fields with evaporation
- Agent proximity detection for communication

### Communication

1. **Pheromone-based**: Ants returning with food lay pheromone trails; intensity proportional to food quality
2. **Direct exchange**: When ants within 3-unit radius meet, they share known food sources; highest quality source is adopted by both

### Machine Learning Integration

Axon models will be used for:
- **Predictive Path Quality**: Predict likelihood of finding food based on pheromone levels, historical success rates, environmental features
- **Adaptive ACO Parameters**: Dynamically adjust α (pheromone importance), β (heuristic importance), ρ (evaporation rate) based on colony performance

## Project Structure (Planned)

```
jido_ants/
├── mix.exs          # Project dependencies
├── lib/
│   ├── ant_colony/
│   │   ├── plane.ex         # Environment GenServer
│   │   ├── agent/
│   │   │   └── ant.ex       # AntAgent definition
│   │   ├── actions/         # Individual action modules
│   │   └── skills/          # Reusable skill modules
├── notes/
│   └── research/
│       └── original_research.md  # Comprehensive architecture document
```

## Dependencies (mix.exs)

```elixir
defp deps do
  [
    {:jido, "~> 2.0"},      # Core agent framework
    {:axon, "~> 0.x"},      # Neural network construction
    {:bumblebee, "~> 0.x"}, # Pre-trained models
    {:nx, "~> 0.x"},        # Numerical computing backend
    # Optional: {:exla, "~> 0.x"}  # GPU acceleration for Nx
  ]
end
```

## Design Reference

The complete architectural specification is in `notes/research/original_research.md`. Key sections:
- Section 2.1: Ant Colony Optimization (ACO) principles
- Section 2.2: Jido v2 framework architecture
- Section 3.1: AntAgent state machine and actions
- Section 3.2: Environment (Plane) design
- Section 3.3: Communication mechanisms
- Section 3.4: ML integration with Axon/Bumblebee
- Section 4: Implementation workflow

## Development Notes

- Use **Jido.AgentServer** to run individual AntAgent instances
- Agents communicate via **Jido.Signal** with directives (`Emit`, `Schedule`, `Spawn`, `Stop`)
- The **Plane** can be implemented as either a GenServer or a Jido agent itself
- For proximity detection, consider spatial partitioning (PubSub topics by region) for scalability
