defmodule AntColony.Events do
  @moduledoc """
  Event definitions and constants for the ant colony simulation.

  This module provides:
  - Topic constants for PubSub communication
  - Type specifications for simulation events
  - Accessor functions for topic names

  ## Topics

  * `:simulation` - Events related to ant behavior and simulation state
  * `:ui_updates` - Events for UI updates (reserved for Phase 2)

  ## Event Types

  Events are represented as tuples with the first element being the event type atom.

  ### Examples

      iex> AntColony.Events.simulation_topic()
      "simulation"

      iex> AntColony.Events.ui_updates_topic()
      "ui_updates"
  """

  @type position :: {integer(), integer()}

  @type ant_id :: String.t()

  @type ant_state :: :at_nest | :searching | :returning_to_nest

  @type ant_moved :: {:ant_moved, ant_id(), position(), position()}

  @type food_sensed :: {:food_sensed, ant_id(), position(), map()}

  @type ant_state_changed :: {:ant_state_changed, ant_id(), ant_state(), ant_state()}

  @type ant_registered :: {:ant_registered, ant_id(), position()}

  @type ant_unregistered :: {:ant_unregistered, ant_id()}

  # Topic constants
  @topic_simulation "simulation"
  @topic_ui_updates "ui_updates"

  @doc """
  Returns the simulation topic name.

  ## Examples

      iex> AntColony.Events.simulation_topic()
      "simulation"
  """
  @spec simulation_topic() :: String.t()
  def simulation_topic, do: @topic_simulation

  @doc """
  Returns the UI updates topic name.

  ## Examples

      iex> AntColony.Events.ui_updates_topic()
      "ui_updates"
  """
  @spec ui_updates_topic() :: String.t()
  def ui_updates_topic, do: @topic_ui_updates

  # Broadcast Functions

  @doc """
  Broadcasts an ant_moved event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `old_pos` - The previous position {x, y}
  * `new_pos` - The new position {x, y}

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_moved(AntColony.PubSub, "ant_1", {0, 0}, {1, 1})
  """
  @spec broadcast_ant_moved(atom(), ant_id(), position(), position()) :: :ok | {:error, term()}
  def broadcast_ant_moved(pubsub_name, ant_id, old_pos, new_pos) do
    event = {:ant_moved, ant_id, old_pos, new_pos}
    Phoenix.PubSub.broadcast(pubsub_name, @topic_simulation, event)
  end

  @doc """
  Broadcasts a food_sensed event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `position` - The position where food was sensed {x, y}
  * `food_details` - A map containing food details (amount, type, etc.)

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_food_sensed(AntColony.PubSub, "ant_1", {5, 5}, %{amount: 10})
  """
  @spec broadcast_food_sensed(atom(), ant_id(), position(), map()) :: :ok | {:error, term()}
  def broadcast_food_sensed(pubsub_name, ant_id, position, food_details) do
    event = {:food_sensed, ant_id, position, food_details}
    Phoenix.PubSub.broadcast(pubsub_name, @topic_simulation, event)
  end

  @doc """
  Broadcasts an ant_state_changed event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `old_state` - The previous state atom
  * `new_state` - The new state atom

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_state_changed(
        AntColony.PubSub,
        "ant_1",
        :at_nest,
        :searching
      )
  """
  @spec broadcast_ant_state_changed(atom(), ant_id(), ant_state(), ant_state()) ::
          :ok | {:error, term()}
  def broadcast_ant_state_changed(pubsub_name, ant_id, old_state, new_state) do
    event = {:ant_state_changed, ant_id, old_state, new_state}
    Phoenix.PubSub.broadcast(pubsub_name, @topic_simulation, event)
  end

  @doc """
  Broadcasts an ant_registered event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `position` - The initial position {x, y}

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_registered(AntColony.PubSub, "ant_1", {0, 0})
  """
  @spec broadcast_ant_registered(atom(), ant_id(), position()) :: :ok | {:error, term()}
  def broadcast_ant_registered(pubsub_name, ant_id, position) do
    event = {:ant_registered, ant_id, position}
    Phoenix.PubSub.broadcast(pubsub_name, @topic_simulation, event)
  end

  @doc """
  Broadcasts an ant_unregistered event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_unregistered(AntColony.PubSub, "ant_1")
  """
  @spec broadcast_ant_unregistered(atom(), ant_id()) :: :ok | {:error, term()}
  def broadcast_ant_unregistered(pubsub_name, ant_id) do
    event = {:ant_unregistered, ant_id}
    Phoenix.PubSub.broadcast(pubsub_name, @topic_simulation, event)
  end

  # Subscribe Functions

  @doc """
  Subscribes the calling process to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process

  ## Returns

  * `:ok` - Successfully subscribed

  ## Examples

      AntColony.Events.subscribe_to_simulation(AntColony.PubSub)
  """
  @spec subscribe_to_simulation(atom()) :: :ok
  def subscribe_to_simulation(pubsub_name) do
    Phoenix.PubSub.subscribe(pubsub_name, @topic_simulation)
  end

  @doc """
  Subscribes the calling process to the UI updates topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process

  ## Returns

  * `:ok` - Successfully subscribed

  ## Examples

      AntColony.Events.subscribe_to_ui_updates(AntColony.PubSub)
  """
  @spec subscribe_to_ui_updates(atom()) :: :ok
  def subscribe_to_ui_updates(pubsub_name) do
    Phoenix.PubSub.subscribe(pubsub_name, @topic_ui_updates)
  end

  # Validation Functions

  @doc """
  Validates that the given value is a valid position tuple.

  A valid position is a tuple of two integers {x, y}.

  ## Returns

  * `true` - Valid position
  * `false` - Invalid position

  ## Examples

      iex> AntColony.Events.valid_position?({1, 2})
      true

      iex> AntColony.Events.valid_position?({1, "a"})
      false
  """
  @spec valid_position?(term()) :: boolean()
  def valid_position?({x, y}) when is_integer(x) and is_integer(y), do: true
  def valid_position?(_), do: false

  @doc """
  Validates that the given value is a valid ant ID.

  A valid ant ID is a non-empty binary string.

  ## Returns

  * `true` - Valid ant ID
  * `false` - Invalid ant ID

  ## Examples

      iex> AntColony.Events.valid_ant_id?("ant_1")
      true

      iex> AntColony.Events.valid_ant_id?("")
      false
  """
  @spec valid_ant_id?(term()) :: boolean()
  def valid_ant_id?(id) when is_binary(id), do: byte_size(id) > 0
  def valid_ant_id?(_), do: false

  @doc """
  Validates that the given value is a valid ant state.

  Valid states are: `:at_nest`, `:searching`, `:returning_to_nest`

  ## Returns

  * `true` - Valid ant state
  * `false` - Invalid ant state

  ## Examples

      iex> AntColony.Events.valid_ant_state?(:searching)
      true

      iex> AntColony.Events.valid_ant_state?(:invalid)
      false
  """
  @spec valid_ant_state?(term()) :: boolean()
  def valid_ant_state?(:at_nest), do: true
  def valid_ant_state?(:searching), do: true
  def valid_ant_state?(:returning_to_nest), do: true
  def valid_ant_state?(_), do: false
end
