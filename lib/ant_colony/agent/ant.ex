defmodule AntColony.Agent.Ant do
  @moduledoc """
  An individual ant agent in the ant colony simulation.

  This agent uses the Jido.Agent framework to model ant behavior including
  foraging, communication, and state machine-based decision making.

  ## Agent Schema

  The agent maintains the following state:

  * `id` - Unique identifier (required, auto-generated if not provided)
  * `generation_id` - Generation identifier for KPI tracking and breeding (required)
  * `position` - Current {x, y} coordinates (required)
  * `nest_position` - Known nest location {x, y} (required)
  * `path_memory` - List of visited positions with observations (default: [])
  * `current_state` - FSM state: :at_nest, :searching, :returning_to_nest, :communicating
  * `previous_state` - Previous FSM state (for transitions)
  * `has_food?` - Whether the ant is carrying food (default: false)
  * `carried_food_level` - Food quality level 1-5 when carrying (optional)
  * `known_food_sources` - List of discovered food sources (default: [])
  * `energy` - Current energy level (default: 100)
  * `max_energy` - Maximum energy capacity (default: 100)
  * `age` - Simulation ticks since creation (default: 0)

  ## FSM States

  The agent uses a finite state machine for behavior control:

  * `:at_nest` - Ant is at the nest, ready to leave for foraging
  * `:searching` - Ant is actively exploring for food
  * `:returning_to_nest` - Ant has found food and is returning (Phase 2)
  * `:communicating` - Ant is exchanging information with nearby ants (Phase 2)

  ## State Transitions (Phase 1)

  * `:at_nest` → `:searching` - Ant leaves nest to explore
  * `:searching` → `:at_nest` - Ant returns to nest without food

  ## Usage

      # Create a new ant (with default position at nest)
      ant = AntColony.Agent.Ant.new(
        id: "ant_1",
        generation_id: 1,
        position: {25, 25},
        nest_position: {25, 25}
      )

      # Run the ant via AgentServer
      {:ok, pid} = Jido.AgentServer.start_link(
        agent: ant,
        agent_module: AntColony.Agent.Ant,
        jido: AntColony.Jido
      )

      # Execute commands
      {:ok, agent} = Jido.AgentServer.state(pid)
      {:ok, _result} = Jido.AgentServer.cmd(pid, SomeAction)

  ## Generation ID

  The `generation_id` field is used for tracking KPIs across ant generations.
  It is set by the ColonyIntelligenceAgent when spawning ants and is used
  to measure performance across different breeding generations.
  """

  use Jido.Agent,
    name: "ant",
    description: "An individual ant agent in the colony simulation",
    category: "ant",
    tags: ["forager", "colony"],
    vsn: "1.0.0",
    strategy: {Jido.Agent.Strategy.FSM,
      initial_state: :at_nest,
      auto_transition: false,
      transitions: %{
        at_nest: [:searching],
        searching: [:at_nest]
      }
    },
    schema: [
      # Core identity fields (required)
      id: [type: :string, required: false],
      generation_id: [type: :pos_integer, required: true],
      position: [type: {:tuple, [:non_neg_integer, :non_neg_integer]}, required: true],
      nest_position: [type: {:tuple, [:non_neg_integer, :non_neg_integer]}, required: true],

      # Movement and memory
      path_memory: [type: {:list, :any}, default: []],

      # State machine fields
      current_state: [type: :atom, default: :at_nest],
      previous_state: [type: :atom, required: false],

      # Food-related fields
      has_food?: [type: :boolean, default: false],
      carried_food_level: [type: :integer, required: false],
      known_food_sources: [type: {:list, :any}, default: []],

      # Optional fields
      energy: [type: :integer, default: 100],
      max_energy: [type: :integer, default: 100],
      age: [type: :integer, default: 0]
    ]

  @doc """
  Returns signal routes for this agent.

  Maps incoming signals to action modules for execution.
  Currently empty - will be populated in later phases as actions are defined.
  """
  def signal_routes, do: []

  # Type definitions
  @type position :: {non_neg_integer(), non_neg_integer()}

  @doc """
  Transitions the agent to a new FSM state.

  Returns `{:ok, agent}` if transition is valid, `{:error, reason}` otherwise.
  """
  @spec transition_to_state(Jido.Agent.t(), atom()) :: {:ok, Jido.Agent.t()} | {:error, term()}
  def transition_to_state(%Jido.Agent{} = agent, new_state) do
    current = Map.get(agent.state, :current_state, :at_nest)

    transitions = %{
      at_nest: [:searching],
      searching: [:at_nest]
    }

    allowed = Map.get(transitions, current, [])

    if new_state in allowed do
      new_agent =
        agent
        |> Map.update!(:state, fn state ->
          state
          |> Map.put(:previous_state, current)
          |> Map.put(:current_state, new_state)
        end)

      {:ok, new_agent}
    else
      {:error, {:invalid_transition, from: current, to: new_state, allowed: allowed}}
    end
  end

  @doc """
  Returns the current FSM state of the agent.
  """
  @spec current_state(Jido.Agent.t()) :: atom()
  def current_state(%Jido.Agent{state: state}), do: Map.get(state, :current_state, :at_nest)

  @doc """
  Returns the previous FSM state of the agent, if any.
  """
  @spec previous_state(Jido.Agent.t()) :: atom() | nil
  def previous_state(%Jido.Agent{state: state}), do: Map.get(state, :previous_state)

  @doc """
  Checks if the ant is currently carrying food.
  """
  @spec has_food?(Jido.Agent.t()) :: boolean()
  def has_food?(%Jido.Agent{state: state}), do: Map.get(state, :has_food?, false)

  @doc """
  Returns the ant's current position.
  """
  @spec position(Jido.Agent.t()) :: {non_neg_integer(), non_neg_integer()}
  def position(%Jido.Agent{state: state}), do: Map.get(state, :position)

  @doc """
  Returns the ant's nest position.
  """
  @spec nest_position(Jido.Agent.t()) :: {non_neg_integer(), non_neg_integer()}
  def nest_position(%Jido.Agent{state: state}), do: Map.get(state, :nest_position)

  @doc """
  Returns the ant's current energy level.
  """
  @spec energy(Jido.Agent.t()) :: integer()
  def energy(%Jido.Agent{state: state}), do: Map.get(state, :energy, 100)

  @doc """
  Returns the ant's generation ID.
  """
  @spec generation_id(Jido.Agent.t()) :: pos_integer()
  def generation_id(%Jido.Agent{state: state}), do: Map.get(state, :generation_id)

  @doc """
  Returns the ant's age in simulation ticks.
  """
  @spec age(Jido.Agent.t()) :: integer()
  def age(%Jido.Agent{state: state}), do: Map.get(state, :age, 0)

  @doc """
  Checks if the ant is at the nest.
  """
  @spec at_nest?(Jido.Agent.t()) :: boolean()
  def at_nest?(%Jido.Agent{} = agent), do: position(agent) == nest_position(agent)

  @doc """
  Returns known food sources discovered by this ant.
  """
  @spec known_food_sources(Jido.Agent.t()) :: [map()]
  def known_food_sources(%Jido.Agent{state: state}) do
    Map.get(state, :known_food_sources, [])
  end

  @doc """
  Returns the path memory - list of visited positions with observations.
  """
  @spec path_memory(Jido.Agent.t()) :: [{position(), map()}]
  def path_memory(%Jido.Agent{state: state}) do
    Map.get(state, :path_memory, [])
  end

  @doc """
  Adds a food source to the ant's known food sources.

  Returns `{:ok, agent}` if added, `{:error, :already_known}` if already known.
  """
  @spec add_known_food_source(Jido.Agent.t(), position(), pos_integer(), DateTime.t()) ::
          {:ok, Jido.Agent.t()} | {:error, :already_known}
  def add_known_food_source(%Jido.Agent{} = agent, position, level, timestamp) do
    known = Map.get(agent.state, :known_food_sources, [])

    if Enum.any?(known, fn fs -> Map.get(fs, :position) == position end) do
      {:error, :already_known}
    else
      food_source = %{
        position: position,
        level: level,
        last_updated: timestamp
      }

      new_known = known ++ [food_source]
      {:ok, %{agent | state: Map.put(agent.state, :known_food_sources, new_known)}}
    end
  end

  @doc """
  Adds a position entry to the ant's path memory.
  """
  @spec remember_position(Jido.Agent.t(), position(), map()) :: Jido.Agent.t()
  def remember_position(%Jido.Agent{} = agent, position, observations \\ %{}) do
    path_memory = Map.get(agent.state, :path_memory, [])
    entry = {position, observations}
    new_path_memory = path_memory ++ [entry]
    %{agent | state: Map.put(agent.state, :path_memory, new_path_memory)}
  end

  @doc """
  Decrements the ant's energy by the given amount.
  Energy cannot go below 0.
  """
  @spec consume_energy(Jido.Agent.t(), pos_integer()) :: Jido.Agent.t()
  def consume_energy(%Jido.Agent{} = agent, amount) when amount > 0 do
    current_energy = Map.get(agent.state, :energy, 100)
    new_energy = max(0, current_energy - amount)
    %{agent | state: Map.put(agent.state, :energy, new_energy)}
  end

  @doc """
  Checks if the ant has enough energy to perform an action.
  """
  @spec has_energy?(Jido.Agent.t(), pos_integer()) :: boolean()
  def has_energy?(%Jido.Agent{} = agent, amount) do
    Map.get(agent.state, :energy, 100) >= amount
  end

  @doc """
  Increments the ant's age by one tick.
  """
  @spec increment_age(Jido.Agent.t()) :: Jido.Agent.t()
  def increment_age(%Jido.Agent{} = agent) do
    current_age = Map.get(agent.state, :age, 0)
    %{agent | state: Map.put(agent.state, :age, current_age + 1)}
  end

  @doc """
  Updates the ant's position.
  """
  @spec update_position(Jido.Agent.t(), position()) :: Jido.Agent.t()
  def update_position(%Jido.Agent{} = agent, new_position) do
    %{agent | state: Map.put(agent.state, :position, new_position)}
  end

  @doc """
  Picks up food at the ant's current position.

  Returns `{:ok, agent}` if successful, `{:error, :already_has_food}` if already carrying.
  """
  @spec pick_up_food(Jido.Agent.t(), pos_integer()) :: {:ok, Jido.Agent.t()} | {:error, :already_has_food}
  def pick_up_food(%Jido.Agent{} = agent, level) do
    if Map.get(agent.state, :has_food?, false) do
      {:error, :already_has_food}
    else
      new_state =
        agent.state
        |> Map.put(:has_food?, true)
        |> Map.put(:carried_food_level, level)

      {:ok, %{agent | state: new_state}}
    end
  end

  @doc """
  Drops food at the ant's current position.

  Returns `{:ok, agent, level}` if successful, `{:error, :no_food}` if not carrying.
  """
  @spec drop_food(Jido.Agent.t()) :: {:ok, Jido.Agent.t(), pos_integer()} | {:error, :no_food}
  def drop_food(%Jido.Agent{} = agent) do
    if Map.get(agent.state, :has_food?, false) do
      level = Map.get(agent.state, :carried_food_level)
      new_state = agent.state |> Map.put(:has_food?, false) |> Map.delete(:carried_food_level)
      {:ok, %{agent | state: new_state}, level}
    else
      {:error, :no_food}
    end
  end
end
