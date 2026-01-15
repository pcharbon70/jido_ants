defmodule AntColony.Plane.State do
  @moduledoc """
  State structures for the Plane GenServer.

  This module defines the state structures used by the AntColony.Plane
  GenServer to manage the simulation environment.

  ## State Structure

  The Plane state contains:
  * `width` - Grid width (default: 50)
  * `height` - Grid height (default: 50)
  * `nest_location` - Position of the nest {x, y}
  * `food_sources` - Map of position to FoodSource
  * `ant_positions` - Map of ant_id to position

  ## Examples

      iex> state = %AntColony.Plane.State{}
      iex> state.width
      50
      iex> state.nest_location
      {25, 25}

      iex> food = %AntColony.Plane.State.FoodSource{level: 3}
      iex> food.quantity
      10
  """

  # Type definitions
  @type width :: pos_integer()
  @type height :: pos_integer()
  @type position :: {non_neg_integer(), non_neg_integer()}

  @type ant_id :: String.t()

  @type food_sources :: %{position() => FoodSource.t()}
  @type ant_positions :: %{ant_id() => position()}

  @type t :: %__MODULE__{
          width: width(),
          height: height(),
          nest_location: position(),
          food_sources: food_sources(),
          ant_positions: ant_positions()
        }

  @doc """
  Defines the Plane state struct with default values.

  ## Fields

  * `:width` - Grid width (default: 50)
  * `:height` - Grid height (default: 50)
  * `:nest_location` - Nest position (default: {25, 25})
  * `:food_sources` - Map of positions to FoodSource (default: %{})
  * `:ant_positions` - Map of ant IDs to positions (default: %{})
  """
  defstruct width: 50,
            height: 50,
            nest_location: {25, 25},
            food_sources: %{},
            ant_positions: %{}

  @doc false
  def inspect(%__MODULE__{} = state, opts) do
    computed_fields = [
      num_food_sources: map_size(state.food_sources),
      num_ants: map_size(state.ant_positions)
    ]

    base_fields = [
      width: state.width,
      height: state.height,
      nest_location: state.nest_location
    ]

    all_fields = Keyword.merge(base_fields, computed_fields)

    Inspect.Map.inspect(%__MODULE__{} |> Map.from_struct() |> Enum.into(all_fields), opts)
  end

  @doc """
  Nested module defining the FoodSource struct.

  Food sources have a nutrient level (1-5) and a quantity representing
  available units. Higher level food sources are more valuable to ants.
  """
  defmodule FoodSource do
    @moduledoc """
    Food source structure for the Plane.

    Represents a food source at a specific position on the Plane.
    Food sources have a nutrient level (1-5) and a quantity of available units.

    ## Fields

    * `:level` - Nutrient level 1-5 (5 being highest quality)
    * `:quantity` - Available units (default: 10)

    ## Examples

        iex> food = %AntColony.Plane.State.FoodSource{level: 5, quantity: 20}
        iex> food.level
        5
    """

    @type level :: 1..5
    @type quantity :: pos_integer()

    @type t :: %__MODULE__{
            level: level(),
            quantity: quantity()
          }

    @doc """
    Defines the FoodSource struct with default values.

    ## Fields

    * `:level` - Nutrient level 1-5 (required)
    * `:quantity` - Available units (default: 10)
    """
    defstruct level: 1,
              quantity: 10

    @doc """
    Creates a new FoodSource with the given level and optional quantity.

    ## Parameters

    * `level` - Nutrient level (1-5)
    * `quantity` - Available units (default: 10)

    ## Returns

    A `FoodSource.t()` struct.

    ## Examples

        iex> AntColony.Plane.State.FoodSource.new(5)
        %AntColony.Plane.State.FoodSource{level: 5, quantity: 10}

        iex> AntColony.Plane.State.FoodSource.new(3, 25)
        %AntColony.Plane.State.FoodSource{level: 3, quantity: 25}
    """
    @spec new(level(), quantity()) :: t()
    def new(level, quantity \\ 10) when level >= 1 and level <= 5 and quantity > 0 do
      %__MODULE__{level: level, quantity: quantity}
    end

    @doc """
    Depletes the food source by the given amount.

    Returns `{:ok, remaining_quantity}` if food remains,
    `{:error, :depleted}` if quantity reaches 0.

    ## Examples

        iex> food = AntColony.Plane.State.FoodSource.new(5, 10)
        iex> {:ok, 7} = AntColony.Plane.State.FoodSource.deplete(food, 3)
        iex> {:error, :depleted} = AntColony.Plane.State.FoodSource.deplete(%{food | quantity: 1}, 1)
    """
    @spec deplete(t(), pos_integer()) :: {:ok, t()} | {:error, :depleted}
    def deplete(%__MODULE__{quantity: qty} = food, amount) when amount < qty do
      {:ok, %{food | quantity: qty - amount}}
    end

    def deplete(%__MODULE__{quantity: amount}, amount) do
      {:error, :depleted}
    end
  end
end
