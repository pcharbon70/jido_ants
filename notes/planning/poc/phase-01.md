# Phase 1: Project Setup and Core Data Structures

This phase establishes the foundational project structure and core data types for the ant colony simulation. We create the Mix project, add dependencies, and define the fundamental data structures that will be used throughout the system.

---

## 1.1 Mix Project Setup

Create the Elixir Mix project with all required dependencies for Jido v2, Axon, and Bumblebee.

### 1.1.1 Create Mix Project
- [ ] **Task 1.1.1** Create initial Mix project structure.

- [ ] 1.1.1.1 Create `mix.exs` with project configuration:
  ```elixir
  defmodule JidoAnts.MixProject do
    use Mix.Project

    def project do
      [
        app: :jido_ants,
        version: "0.1.0",
        elixir: "~> 1.15",
        start_permanent: Mix.env() == :prod,
        deps: deps(),
        elixirc_paths: elixirc_paths(Mix.env())
      ]
    end

    def application do
      [
        extra_applications: [:logger]
      ]
    end

    defp deps do
      [
        {:jido, "~> 2.0"},
        {:axon, "~> 0.6"},
        {:bumblebee, "~> 0.1"},
        {:nx, "~> 0.6"},
        {:exla, "~> 0.6", only: :dev}
      ]
    end

    defp elixirc_paths(:test), do: ["lib", "test/support"]
    defp elixirc_paths(_), do: ["lib"]
  end
  ```
- [ ] 1.1.1.2 Create `lib/jido_ants.ex` main module with `@moduledoc`
- [ ] 1.1.1.3 Create `config/config.exs` with basic configuration
- [ ] 1.1.1.4 Create `test/test_helper.exs`
- [ ] 1.1.1.5 Run `mix deps.get` to fetch dependencies
- [ ] 1.1.1.6 Verify project compiles with `mix compile`

### 1.1.2 Configure Nx Backend
- [ ] **Task 1.1.2** Configure Nx backend for numerical operations.

- [ ] 1.2.1.1 Add Nx backend configuration to `config/config.exs`:
  ```elixir
  config :nx, default_backend: EXLA.Backend
  ```
- [ ] 1.2.1.2 Add fallback to BinaryBackend for environments without EXLA
- [ ] 1.2.1.3 Create `config/dev.exs` with development-specific settings
- [ ] 1.2.1.4 Create `config/test.exs` with test-specific settings
- [ ] 1.2.1.5 Create `config/prod.exs` with production-specific settings

**Unit Tests for Section 1.1:**
- Test Mix project compiles without errors
- Test all dependencies are fetched successfully
- Test Nx backend loads correctly
- Test application can be started with `mix run`

---

## 1.2 Position and Coordinate Types

Define the fundamental position type and utility functions for 2D grid coordinates.

### 1.2.1 Position Module
- [ ] **Task 1.2.1** Create the Position module with type definitions.

- [ ] 1.2.1.1 Create `lib/jido_ants/position.ex` with module documentation
- [ ] 1.2.1.2 Define `@type position() :: {non_neg_integer(), non_neg_integer()}`
- [ ] 1.2.1.3 Define `@type x() :: non_neg_integer()`
- [ ] 1.2.1.4 Define `@type y() :: non_neg_integer()`
- [ ] 1.2.1.5 Add typespecs for all public functions

### 1.2.2 Position Constructors
- [ ] **Task 1.2.2** Implement position creation functions.

- [ ] 1.2.2.1 Implement `new/2` accepting x and y coordinates:
  ```elixir
  @spec new(x(), y()) :: position()
  def new(x, y), do: {x, y}
  ```
- [ ] 1.2.2.2 Implement `origin/0` returning `{0, 0}`
- [ ] 1.2.2.3 Implement `random/2` accepting width and height bounds
- [ ] 1.2.2.4 Use `:rand.uniform/1` for random coordinate generation
- [ ] 1.2.2.5 Validate coordinates are non-negative

### 1.2.3 Position Accessors
- [ ] **Task 1.2.3** Implement position accessor functions.

- [ ] 1.2.3.1 Implement `x/1` returning the x coordinate:
  ```elixir
  @spec x(position()) :: x()
  def x({x, _y}), do: x
  ```
- [ ] 1.2.3.2 Implement `y/1` returning the y coordinate:
  ```elixir
  @spec y(position()) :: y()
  def y({_x, y}), do: y
  ```
- [ ] 1.2.3.3 Implement `to_tuple/1` returning the position as tuple

### 1.2.4 Position Math
- [ ] **Task 1.2.4** Implement position arithmetic functions.

- [ ] 1.2.4.1 Implement `add/2` for adding two positions:
  ```elixir
  @spec add(position(), position()) :: position()
  def add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  ```
- [ ] 1.2.4.2 Implement `subtract/2` for subtracting positions
- [ ] 1.2.4.3 Implement `distance/2` calculating Euclidean distance:
  ```elixir
  @spec distance(position(), position()) :: float()
  def distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
  end
  ```
- [ ] 1.2.4.4 Implement `manhattan_distance/2` for grid-based distance
- [ ] 1.2.4.5 Implement `neighbors/1` returning 8 adjacent positions:
  ```elixir
  @spec neighbors(position()) :: [position()]
  def neighbors({x, y}) do
    for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0} do
      {x + dx, y + dy}
    end
  end
  ```
- [ ] 1.2.4.6 Implement `cardinal_neighbors/1` returning 4 adjacent positions (N, S, E, W)

### 1.2.5 Position Validation
- [ ] **Task 1.2.5** Implement position validation functions.

- [ ] 1.2.5.1 Implement `valid?/2` checking bounds:
  ```elixir
  @spec valid?(position(), {pos_integer(), pos_integer()}) :: boolean()
  def valid?({x, y}, {width, height}) do
    x >= 0 and x < width and y >= 0 and y < height
  end
  ```
- [ ] 1.2.5.2 Implement `clamp/2` to constrain position within bounds
- [ ] 1.2.5.3 Implement `equal?/2` for position equality comparison

**Unit Tests for Section 1.2:**
- Test `new/2` creates valid position
- Test `origin/0` returns `{0, 0}`
- Test `random/2` generates positions within bounds
- Test `x/1` and `y/1` return correct coordinates
- Test `add/2` adds positions correctly
- Test `subtract/2` subtracts positions correctly
- Test `distance/2` calculates Euclidean distance
- Test `manhattan_distance/2` calculates Manhattan distance
- Test `neighbors/1` returns 8 adjacent positions
- Test `cardinal_neighbors/1` returns 4 adjacent positions
- Test `valid?/2` checks bounds correctly
- Test `clamp/2` constrains position within bounds

---

## 1.3 Food Source Structs

Define the data structures for food sources on the plane.

### 1.3.1 FoodSource Module
- [ ] **Task 1.3.1** Create the FoodSource struct module.

- [ ] 1.3.1.1 Create `lib/jido_ants/food_source.ex` with module documentation
- [ ] 1.3.1.2 Define the struct:
  ```elixir
  defmodule JidoAnts.FoodSource do
    @type level :: 1..5

    defstruct [
      :position,
      :level,
      :quantity,
      :max_quantity
    ]

    @type t :: %__MODULE__{
      position: JidoAnts.Position.t(),
      level: level(),
      quantity: non_neg_integer(),
      max_quantity: pos_integer()
    }
  end
  ```
- [ ] 1.3.1.3 Add typespec for `level/0` as 1-5 range
- [ ] 1.3.1.4 Define `@enforce_keys [:position, :level, :max_quantity]`

### 1.3.2 FoodSource Creation
- [ ] **Task 1.3.2** Implement FoodSource constructors.

- [ ] 1.3.2.1 Implement `new/1` accepting keyword options:
  ```elixir
  @spec new(keyword()) :: {:ok, t()} | {:error, term()}
  def new(opts) do
    with {:ok, position} <- validate_position(Keyword.get(opts, :position)),
         {:ok, level} <- validate_level(Keyword.get(opts, :level, 3)),
         {:ok, max_quantity} <- validate_max_quantity(Keyword.get(opts, :max_quantity, 10)) do
      {:ok, %__MODULE__{
        position: position,
        level: level,
        quantity: max_quantity,
        max_quantity: max_quantity
      }}
    end
  end
  ```
- [ ] 1.3.2.2 Implement `new!/1` that raises on invalid input
- [ ] 1.3.2.3 Validate position is a valid `JidoAnts.Position.t()`
- [ ] 1.3.2.4 Validate level is between 1 and 5
- [ ] 1.3.2.5 Validate max_quantity is positive integer

### 1.3.3 FoodSource Operations
- [ ] **Task 1.3.3** Implement FoodSource operations.

- [ ] 1.3.3.1 Implement `deplete/1` reducing quantity by 1:
  ```elixir
  @spec deplete(t()) :: {:ok, t()} | {:error, :depleted}
  def deplete(%__MODULE__{quantity: 0}), do: {:error, :depleted}
  def deplete(%__MODULE__{} = food) do
    {:ok, %__MODULE__{food | quantity: food.quantity - 1}}
  end
  ```
- [ ] 1.3.3.2 Implement `depleted?/1` checking if quantity is 0
- [ ] 1.3.3.3 Implement `remaining/1` returning current quantity
- [ ] 1.3.3.4 Implement `nutrient_value/1` returning level * quantity

**Unit Tests for Section 1.3:**
- Test `new/1` creates valid FoodSource
- Test `new/1` validates position
- Test `new/1` validates level range (1-5)
- Test `new/1` validates max_quantity is positive
- Test `new!/1` raises on invalid input
- Test `deplete/1` reduces quantity
- Test `deplete/1` returns error when depleted
- Test `depleted?/1` returns true when quantity is 0
- Test `remaining/1` returns current quantity
- Test `nutrient_value/1` calculates level * quantity

---

## 1.4 Pheromone Data Structures

Define the data structures for pheromone trails and fields.

### 1.4.1 Pheromone Module
- [ ] **Task 1.4.1** Create the Pheromone struct module.

- [ ] 1.4.1.1 Create `lib/jido_ants/pheromone.ex` with module documentation
- [ ] 1.4.1.2 Define pheromone types:
  ```elixir
  defmodule JidoAnts.Pheromone do
    @type type :: :food_trail | :exploration | :danger

    defstruct [:type, :intensity, :deposited_at]

    @type t :: %__MODULE__{
      type: type(),
      intensity: float(),
      deposited_at: DateTime.t()
    }
  end
  ```
- [ ] 1.4.1.3 Define `@intensity_decay_rate 0.01` for evaporation
- [ ] 1.4.1.4 Define `@min_intensity 0.01` threshold for removal

### 1.4.2 Pheromone Creation
- [ ] **Task 1.4.2** Implement Pheromone constructors.

- [ ] 1.4.2.1 Implement `new/2` accepting type and initial intensity:
  ```elixir
  @spec new(type(), float()) :: t()
  def new(type, intensity) when intensity > 0 do
    %__MODULE__{
      type: type,
      intensity: intensity,
      deposited_at: DateTime.utc_now()
    }
  end
  ```
- [ ] 1.4.2.2 Implement `food_trail/1` for food trail pheromones
- [ ] 1.4.2.3 Implement `exploration/1` for exploration markers
- [ ] 1.4.2.4 Validate intensity is positive
- [ ] 1.4.2.5 Validate type is one of allowed types

### 1.4.3 Pheromone Operations
- [ ] **Task 1.4.3** Implement Pheromone operations.

- [ ] 1.4.3.1 Implement `evaporate/1` reducing intensity:
  ```elixir
  @spec evaporate(t()) :: {:ok, t()} | {:error, :dissipated}
  def evaporate(%__MODULE__{intensity: intensity} = pheromone) do
    new_intensity = intensity * (1 - @intensity_decay_rate)
    if new_intensity < @min_intensity do
      {:error, :dissipated}
    else
      {:ok, %__MODULE__{pheromone | intensity: new_intensity}}
    end
  end
  ```
- [ ] 1.4.3.2 Implement `add_intensity/2` for reinforcement
- [ ] 1.4.3.3 Implement `age/1` returning time since deposition
- [ ] 1.4.3.4 Implement `dissipated?/1` checking if below threshold

**Unit Tests for Section 1.4:**
- Test `new/2` creates valid Pheromone
- Test `new/2` validates positive intensity
- Test `food_trail/1` creates :food_trail pheromone
- Test `exploration/1` creates :exploration pheromone
- Test `evaporate/1` reduces intensity
- Test `evaporate/1` returns :dissipated when below threshold
- Test `add_intensity/2` increases intensity
- Test `age/1` returns correct time elapsed
- Test `dissipated?/1` returns true for old pheromones

---

## 1.5 Plane Struct Definition

Define the core Plane struct that represents the simulation environment.

### 1.5.1 Plane Module
- [ ] **Task 1.5.1** Create the Plane struct module.

- [ ] 1.5.1.1 Create `lib/jido_ants/plane.ex` with module documentation
- [ ] 1.5.1.2 Define the Plane struct:
  ```elixir
  defmodule JidoAnts.Plane do
    alias JidoAnts.{Position, FoodSource, Pheromone}

    defstruct [
      :width,
      :height,
      :food_sources,
      :pheromones,
      :ant_positions,
      :nest_position
    ]

    @type t :: %__MODULE__{
      width: pos_integer(),
      height: pos_integer(),
      food_sources: %{Position.t() => FoodSource.t()},
      pheromones: %{Position.t() => %{Pheromone.type() => Pheromone.t()}},
      ant_positions: %{String.t() => Position.t()},
      nest_position: Position.t()
    }
  end
  ```
- [ ] 1.5.1.3 Define default dimensions `@default_width 100`
- [ ] 1.5.1.4 Define default dimensions `@default_height 100`

### 1.5.2 Plane Creation
- [ ] **Task 1.5.2** Implement Plane constructors.

- [ ] 1.5.2.1 Implement `new/1` accepting keyword options:
  ```elixir
  @spec new(keyword()) :: {:ok, t()} | {:error, term()}
  def new(opts) do
    width = Keyword.get(opts, :width, @default_width)
    height = Keyword.get(opts, :height, @default_height)
    nest_position = Keyword.get(opts, :nest_position, {div(width, 2), div(height, 2)})

    with true <- width > 0,
         true <- height > 0,
         true <- Position.valid?(nest_position, {width, height}) do
      {:ok, %__MODULE__{
        width: width,
        height: height,
        food_sources: %{},
        pheromones: %{},
        ant_positions: %{},
        nest_position: nest_position
      }}
    else
      _ -> {:error, :invalid_dimensions}
    end
  end
  ```
- [ ] 1.5.2.2 Implement `new!/1` that raises on invalid input
- [ ] 1.5.2.3 Validate width and height are positive
- [ ] 1.5.2.4 Validate nest_position is within bounds

### 1.5.3 Plane Queries
- [ ] **Task 1.5.3** Implement Plane query functions.

- [ ] 1.5.3.1 Implement `has_food?/2` checking position for food
- [ ] 1.5.3.2 Implement `get_food/2` returning food at position
- [ ] 1.5.3.3 Implement `get_pheromones/2` returning pheromones at position
- [ ] 1.5.3.4 Implement `get_ant_position/2` returning ant's position
- [ ] 1.5.3.5 Implement `ants_at/2` returning list of ant IDs at position
- [ ] 1.5.3.6 Implement `in_bounds?/2` checking if position is valid

**Unit Tests for Section 1.5:**
- Test `new/1` creates valid Plane
- Test `new/1` uses default dimensions when not specified
- Test `new/1` places nest at center when not specified
- Test `new/1` validates dimensions are positive
- Test `new/1` validates nest_position is in bounds
- Test `has_food?/2` returns false for empty plane
- Test `get_food/2` returns nil for empty position
- Test `get_pheromones/2` returns empty map for no pheromones
- Test `in_bounds?/2` checks bounds correctly

---

## 1.6 Phase 1 Integration Tests

Comprehensive integration tests verifying all Phase 1 components work together correctly.

### 1.6.1 Core Types Integration
- [ ] **Task 1.6.1** Test integration of core data types.

- [ ] 1.6.1.1 Create `test/jido_ants/integration/data_types_phase1_test.exs`
- [ ] 1.6.1.2 Test: Create Plane → add FoodSource → verify position contains food
- [ ] 1.6.1.3 Test: Create Plane → add Pheromone → verify pheromone accessible
- [ ] 1.6.1.4 Test: Position arithmetic → add to food position → verify new position
- [ ] ] 1.6.1.5 Test: Distance calculations between food source and nest
- [ ] 1.6.1.6 Test: Deplete food source → verify quantity decreases
- [ ] 1.6.1.7 Test: Evaporate pheromone → verify intensity decreases
- [ ] 1.6.1.8 Write all integration tests

### 1.6.2 Boundary Validation Integration
- [ ] **Task 1.6.2** Test boundary validation across components.

- [ ] 1.6.2.1 Test: Create Plane with food at edge → verify in_bounds? works
- [ ] 1.6.2.2 Test: Position neighbors at boundary → verify only valid positions returned
- [ ] 1.6.2.3 Test: Clamp position to plane bounds → verify position within bounds
- [ ] 1.6.2.4 Test: Distance from corner to opposite corner
- [ ] 1.6.2.5 Write all boundary validation tests

**Integration Tests for Section 1.6:**
- Core types integrate correctly
- Boundary validation consistent across components
- Food source lifecycle works as expected
- Pheromone lifecycle works as expected

---

## Success Criteria

1. **Mix Project**: Project compiles with all dependencies (Jido v2, Axon, Bumblebee, Nx)
2. **Position Module**: Position type with constructors, accessors, math, and validation
3. **FoodSource Module**: FoodSource struct with creation, depletion, and query functions
4. **Pheromone Module**: Pheromone struct with creation, evaporation, and operations
5. **Plane Module**: Plane struct representing the simulation environment
6. **Type Specs**: All public functions have proper typespecs
7. **Nx Backend**: Configured for numerical operations
8. **Test Coverage**: Minimum 80% coverage for phase 1 code
9. **Integration Tests**: All Phase 1 components work together correctly (Section 1.6)

---

## Critical Files

**New Files:**
- `mix.exs`
- `lib/jido_ants.ex`
- `lib/jido_ants/position.ex`
- `lib/jido_ants/food_source.ex`
- `lib/jido_ants/pheromone.ex`
- `lib/jido_ants/plane.ex`
- `config/config.exs`
- `config/dev.exs`
- `config/test.exs`
- `config/prod.exs`
- `test/test_helper.exs`
- `test/jido_ants/position_test.exs`
- `test/jido_ants/food_source_test.exs`
- `test/jido_ants/pheromone_test.exs`
- `test/jido_ants/plane_test.exs`
- `test/jido_ants/integration/data_types_phase1_test.exs`

---

## Dependencies

- This phase has no dependencies on other phases
- Phase 2 depends on this phase (Plane Server uses Plane struct)
- Phase 3 depends on this phase (AntAgent uses Position types)
