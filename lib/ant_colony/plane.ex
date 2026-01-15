defmodule AntColony.Plane do
  @moduledoc """
  The Plane GenServer manages the simulated environment.

  The Plane maintains the state of the simulation including:
  * Grid dimensions (width, height)
  * Nest location
  * Food sources with their levels and quantities
  * Ant positions on the grid

  ## Client API

  The Plane provides both client API functions (called by other processes)
  and GenServer callbacks (handle_call, handle_info for message processing).

  ## State Queries

      {:ok, state} = AntColony.Plane.get_state()
      {width, height} = AntColony.Plane.get_dimensions()
      {x, y} = AntColony.Plane.get_nest_location()

  ## State Updates

      :ok = AntColony.Plane.set_food_sources(%{{5, 5} => %FoodSource{level: 3}})
      :ok = AntColony.Plane.register_ant("ant_1", {25, 25})
      :ok = AntColony.Plane.update_ant_position("ant_1", {26, 26})

  ## Examples

      # Start the Plane with default dimensions (50x50)
      {:ok, pid} = AntColony.Plane.start_link()

      # Start with custom dimensions
      {:ok, pid} = AntColony.Plane.start_link(width: 100, height: 100)

      # Query the state
      {:ok, state} = AntColony.Plane.get_state()
  """

  use GenServer
  require Logger

  alias AntColony.Plane.State

  @doc """
  Starts the Plane GenServer.

  ## Options

  * `:width` - Grid width (default: 50)
  * `:height` - Grid height (default: 50)

  ## Returns

  * `{:ok, pid}` - Successfully started
  * `{:error, reason}` - Failed to start

  ## Examples

      {:ok, pid} = AntColony.Plane.start_link()
      {:ok, pid} = AntColony.Plane.start_link(width: 100, height: 100)
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    {width, opts} = Keyword.pop(opts, :width, 50)
    {height, opts} = Keyword.pop(opts, :height, 50)

    GenServer.start_link(__MODULE__, {width, height}, opts)
  end

  @doc """
  Stops the Plane GenServer.

  ## Examples

      :ok = AntColony.Plane.stop()
  """
  @spec stop() :: :ok
  def stop do
    if Process.whereis(__MODULE__) do
      GenServer.stop(__MODULE__)
    else
      :ok
    end
  end

  # Client API - State Queries

  @doc """
  Returns the full Plane state.

  ## Examples

      {:ok, state} = AntColony.Plane.get_state()
  """
  @spec get_state() :: {:ok, State.t()}
  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc """
  Returns the grid dimensions.

  ## Examples

      {width, height} = AntColony.Plane.get_dimensions()
  """
  @spec get_dimensions() :: {State.width(), State.height()}
  def get_dimensions do
    GenServer.call(__MODULE__, :get_dimensions)
  end

  @doc """
  Returns the nest location.

  ## Examples

      {x, y} = AntColony.Plane.get_nest_location()
  """
  @spec get_nest_location() :: State.position()
  def get_nest_location do
    GenServer.call(__MODULE__, :get_nest_location)
  end

  @doc """
  Returns the food source at a given position.

  ## Examples

      food = AntColony.Plane.get_food_at({5, 5})
      food = AntColony.Plane.get_food_at({99, 99})  # => nil
  """
  @spec get_food_at(State.position()) :: State.FoodSource.t() | nil
  def get_food_at(position) do
    GenServer.call(__MODULE__, {:get_food_at, position})
  end

  @doc """
  Returns all ant positions.

  ## Examples

      positions = AntColony.Plane.get_ant_positions()
      # => %{"ant_1" => {25, 25}, "ant_2" => {26, 26}}
  """
  @spec get_ant_positions() :: State.ant_positions()
  def get_ant_positions do
    GenServer.call(__MODULE__, :get_ant_positions)
  end

  @doc """
  Returns a specific ant's position.

  ## Examples

      {:ok, {x, y}} = AntColony.Plane.get_ant_position("ant_1")
      {:error, :not_found} = AntColony.Plane.get_ant_position("unknown")
  """
  @spec get_ant_position(String.t()) :: {:ok, State.position()} | {:error, :not_found}
  def get_ant_position(ant_id) do
    GenServer.call(__MODULE__, {:get_ant_position, ant_id})
  end

  # Client API - State Updates

  @doc """
  Sets the food sources on the Plane.

  Replaces all existing food sources with the provided map.

  ## Examples

      :ok = AntColony.Plane.set_food_sources(%{{5, 5} => %FoodSource{level: 3}})
  """
  @spec set_food_sources(State.food_sources()) :: :ok
  def set_food_sources(food_sources) when is_map(food_sources) do
    GenServer.call(__MODULE__, {:set_food_sources, food_sources})
  end

  @doc """
  Registers an ant at a specific position.

  ## Examples

      :ok = AntColony.Plane.register_ant("ant_1", {25, 25})
  """
  @spec register_ant(String.t(), State.position()) :: :ok
  def register_ant(ant_id, position) when is_binary(ant_id) and is_tuple(position) do
    GenServer.call(__MODULE__, {:register_ant, ant_id, position})
  end

  @doc """
  Unregisters an ant from the Plane.

  ## Examples

      :ok = AntColony.Plane.unregister_ant("ant_1")
  """
  @spec unregister_ant(String.t()) :: :ok
  def unregister_ant(ant_id) when is_binary(ant_id) do
    GenServer.call(__MODULE__, {:unregister_ant, ant_id})
  end

  @doc """
  Updates an ant's position.

  ## Examples

      :ok = AntColony.Plane.update_ant_position("ant_1", {26, 26})
  """
  @spec update_ant_position(String.t(), State.position()) :: :ok
  def update_ant_position(ant_id, new_position) when is_binary(ant_id) and is_tuple(new_position) do
    GenServer.call(__MODULE__, {:update_ant_position, ant_id, new_position})
  end

  @doc """
  Depletes food at a given position by the specified amount.

  ## Examples

      {:ok, remaining} = AntColony.Plane.deplete_food({5, 5}, 3)
      {:error, :no_food} = AntColony.Plane.deplete_food({99, 99}, 1)
  """
  @spec deplete_food(State.position(), pos_integer()) :: {:ok, pos_integer()} | {:error, :no_food}
  def deplete_food(position, amount \\ 1) when is_tuple(position) and is_integer(amount) and amount > 0 do
    GenServer.call(__MODULE__, {:deplete_food, position, amount})
  end

  @doc """
  Finds all ants within a given radius of a position.

  Uses Euclidean distance for proximity calculation. Optionally excludes
  a specific ant_id (useful for ant-to-ant communication to exclude self).

  ## Parameters

  * `position` - Center position {x, y}
  * `radius` - Search radius
  * `opts` - Optional keyword list:
    * `exclude_ant_id` - Ant ID to exclude from results

  ## Returns

  List of `{ant_id, position}` tuples within the radius.

  ## Examples

      # Find all ants within 3 units of position {10, 10}
      nearby = AntColony.Plane.get_nearby_ants({10, 10}, 3)
      # => [{"ant_1", {11, 10}}, {"ant_2", {10, 12}}]

      # Find nearby ants excluding self
      nearby = AntColony.Plane.get_nearby_ants({10, 10}, 3, exclude_ant_id: "ant_1")
  """
  @spec get_nearby_ants(State.position(), number(), keyword()) :: [{String.t(), State.position()}]
  def get_nearby_ants(position, radius, opts \\ []) when is_tuple(position) and is_number(radius) and radius >= 0 do
    exclude_ant_id = Keyword.get(opts, :exclude_ant_id)

    GenServer.call(__MODULE__, {:get_nearby_ants, position, radius, exclude_ant_id})
  end

  # Private Helper Functions

  @doc false
  @spec distance_squared(State.position(), State.position()) :: number()
  defp distance_squared({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    dx * dx + dy * dy
  end

  # GenServer Callbacks

  @impl true
  def init({width, height}) when is_integer(width) and width > 0 and is_integer(height) and height > 0 do
    state = %State{
      width: width,
      height: height,
      nest_location: {div(width, 2), div(height, 2)}
    }

    Logger.info("Plane started: #{width}x#{height}, nest at #{inspect(state.nest_location)}")
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @impl true
  def handle_call(:get_dimensions, _from, state) do
    {:reply, {state.width, state.height}, state}
  end

  @impl true
  def handle_call(:get_nest_location, _from, state) do
    {:reply, state.nest_location, state}
  end

  @impl true
  def handle_call({:get_food_at, position}, _from, state) do
    food = Map.get(state.food_sources, position)
    {:reply, food, state}
  end

  @impl true
  def handle_call(:get_ant_positions, _from, state) do
    {:reply, state.ant_positions, state}
  end

  @impl true
  def handle_call({:get_ant_position, ant_id}, _from, state) do
    case Map.get(state.ant_positions, ant_id) do
      nil -> {:reply, {:error, :not_found}, state}
      position -> {:reply, {:ok, position}, state}
    end
  end

  @impl true
  def handle_call({:set_food_sources, food_sources}, _from, state) do
    {:reply, :ok, %{state | food_sources: food_sources}}
  end

  @impl true
  def handle_call({:register_ant, ant_id, position}, _from, state) do
    new_positions = Map.put(state.ant_positions, ant_id, position)
    {:reply, :ok, %{state | ant_positions: new_positions}}
  end

  @impl true
  def handle_call({:unregister_ant, ant_id}, _from, state) do
    new_positions = Map.delete(state.ant_positions, ant_id)
    {:reply, :ok, %{state | ant_positions: new_positions}}
  end

  @impl true
  def handle_call({:update_ant_position, ant_id, new_position}, _from, state) do
    if Map.has_key?(state.ant_positions, ant_id) do
      new_positions = Map.put(state.ant_positions, ant_id, new_position)
      {:reply, :ok, %{state | ant_positions: new_positions}}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_call({:deplete_food, position, amount}, _from, state) do
    case Map.get(state.food_sources, position) do
      nil ->
        {:reply, {:error, :no_food}, state}

      food ->
        case State.FoodSource.deplete(food, amount) do
          {:ok, updated_food} ->
            new_sources = Map.put(state.food_sources, position, updated_food)
            {:reply, {:ok, updated_food.quantity}, %{state | food_sources: new_sources}}

          {:error, :depleted} ->
            # Remove food source when depleted
            new_sources = Map.delete(state.food_sources, position)
            {:reply, {:ok, 0}, %{state | food_sources: new_sources}}
        end
    end
  end

  @impl true
  def handle_call({:get_nearby_ants, position, radius, exclude_ant_id}, _from, state) do
    nearby =
      state.ant_positions
      |> Enum.filter(fn {ant_id, _ant_pos} ->
        ant_id != exclude_ant_id
      end)
      |> Enum.filter(fn {_ant_id, ant_pos} ->
        distance_squared(position, ant_pos) <= radius * radius
      end)
      |> Enum.to_list()

    {:reply, nearby, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.warning("Unexpected handle_call: #{inspect(msg)}")
    {:reply, {:error, :unknown_request}, state}
  end

  @impl true
  def handle_info(:print_state, state) do
    Logger.info("Plane state: #{inspect(state, limit: :infinity)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("Unexpected handle_info: #{inspect(msg)}")
    {:noreply, state}
  end
end
