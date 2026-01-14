defmodule AntColony.Events do
  @moduledoc """
  Event definitions and constants for the ant colony simulation.

  This module provides:
  - Topic constants for PubSub communication
  - Type specifications for simulation events
  - Accessor functions for topic names
  - Broadcast helper functions with error handling
  - Subscribe helper functions
  - Validation functions for event data

  ## Topics

  * `:simulation` - Events related to ant behavior and simulation state
  * `:ui_updates` - Events for UI updates (reserved for Phase 2)

  ## Event Metadata

  Broadcast functions accept an optional keyword list of metadata that is
  automatically included with a timestamp. Events are broadcast as:

      {event_type, event_data, %{timestamp: DateTime.t(), user_metadata: map()}}

  ### Examples

      iex> AntColony.Events.simulation_topic()
      "simulation"

      iex> AntColony.Events.ui_updates_topic()
      "ui_updates"

      # Broadcast with metadata
      AntColony.Events.broadcast_ant_moved(
        AntColony.PubSub,
        "ant_1",
        {0, 0},
        {1, 1},
        source: "sensor"
      )
  """

  require Logger

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

  # Metadata Helper Functions

  @doc """
  Returns the current UTC timestamp as a DateTime.

  ## Examples

      iex> timestamp = AntColony.Events.get_timestamp()
      iex> timestamp.__struct__ == DateTime
      true
  """
  @spec get_timestamp() :: DateTime.t()
  def get_timestamp, do: DateTime.utc_now()

  # Broadcast Functions

  @doc """
  Broadcasts an ant_moved event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `old_pos` - The previous position {x, y}
  * `new_pos` - The new position {x, y}
  * `opts` - Optional keyword list for metadata (e.g., `source: "sensor"`)

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Metadata

  The event includes an automatic timestamp. Any additional options
  passed in `opts` are included in the metadata map.

  ## Examples

      # Basic broadcast
      AntColony.Events.broadcast_ant_moved(AntColony.PubSub, "ant_1", {0, 0}, {1, 1})

      # With custom metadata
      AntColony.Events.broadcast_ant_moved(
        AntColony.PubSub,
        "ant_1",
        {0, 0},
        {1, 1},
        source: "sensor",
        reason: "foraging"
      )
  """
  @spec broadcast_ant_moved(atom(), ant_id(), position(), position(), keyword()) ::
          :ok | {:error, term()}
  def broadcast_ant_moved(pubsub_name, ant_id, old_pos, new_pos, opts \\ []) do
    event_data = {:ant_moved, ant_id, old_pos, new_pos}
    metadata = build_metadata(opts)
    event = {:ant_moved, event_data, metadata}

    do_broadcast(pubsub_name, @topic_simulation, event, :ant_moved)
  end

  @doc """
  Broadcasts a food_sensed event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `position` - The position where food was sensed {x, y}
  * `food_details` - A map containing food details (amount, type, etc.)
  * `opts` - Optional keyword list for metadata

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_food_sensed(AntColony.PubSub, "ant_1", {5, 5}, %{amount: 10})
  """
  @spec broadcast_food_sensed(atom(), ant_id(), position(), map(), keyword()) ::
          :ok | {:error, term()}
  def broadcast_food_sensed(pubsub_name, ant_id, position, food_details, opts \\ []) do
    event_data = {:food_sensed, ant_id, position, food_details}
    metadata = build_metadata(opts)
    event = {:food_sensed, event_data, metadata}

    do_broadcast(pubsub_name, @topic_simulation, event, :food_sensed)
  end

  @doc """
  Broadcasts an ant_state_changed event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `old_state` - The previous state atom
  * `new_state` - The new state atom
  * `opts` - Optional keyword list for metadata

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
  @spec broadcast_ant_state_changed(atom(), ant_id(), ant_state(), ant_state(), keyword()) ::
          :ok | {:error, term()}
  def broadcast_ant_state_changed(pubsub_name, ant_id, old_state, new_state, opts \\ []) do
    event_data = {:ant_state_changed, ant_id, old_state, new_state}
    metadata = build_metadata(opts)
    event = {:ant_state_changed, event_data, metadata}

    do_broadcast(pubsub_name, @topic_simulation, event, :ant_state_changed)
  end

  @doc """
  Broadcasts an ant_registered event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `position` - The initial position {x, y}
  * `opts` - Optional keyword list for metadata

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_registered(AntColony.PubSub, "ant_1", {0, 0})
  """
  @spec broadcast_ant_registered(atom(), ant_id(), position(), keyword()) ::
          :ok | {:error, term()}
  def broadcast_ant_registered(pubsub_name, ant_id, position, opts \\ []) do
    event_data = {:ant_registered, ant_id, position}
    metadata = build_metadata(opts)
    event = {:ant_registered, event_data, metadata}

    do_broadcast(pubsub_name, @topic_simulation, event, :ant_registered)
  end

  @doc """
  Broadcasts an ant_unregistered event to the simulation topic.

  ## Parameters

  * `pubsub_name` - The name of the PubSub process
  * `ant_id` - The unique identifier of the ant
  * `opts` - Optional keyword list for metadata

  ## Returns

  * `:ok` - Successfully broadcast
  * `{:error, reason}` - Broadcast failed

  ## Examples

      AntColony.Events.broadcast_ant_unregistered(AntColony.PubSub, "ant_1")
  """
  @spec broadcast_ant_unregistered(atom(), ant_id(), keyword()) :: :ok | {:error, term()}
  def broadcast_ant_unregistered(pubsub_name, ant_id, opts \\ []) do
    event_data = {:ant_unregistered, ant_id}
    metadata = build_metadata(opts)
    event = {:ant_unregistered, event_data, metadata}

    do_broadcast(pubsub_name, @topic_simulation, event, :ant_unregistered)
  end

  # Private Helper Functions

  @doc false
  @spec build_metadata(keyword()) :: %{timestamp: DateTime.t(), user_metadata: map() | nil}
  defp build_metadata(opts) when is_list(opts) do
    base_metadata = %{
      timestamp: get_timestamp()
    }

    if opts == [] do
      base_metadata
    else
      Map.put(base_metadata, :user_metadata, Map.new(opts))
    end
  end

  @doc false
  @spec do_broadcast(atom(), String.t(), term(), atom()) :: :ok | {:error, term()}
  defp do_broadcast(pubsub_name, topic, event, event_type) do
    try do
      Phoenix.PubSub.broadcast(pubsub_name, topic, event)
    rescue
      e ->
        Logger.error(
          "Failed to broadcast #{event_type} event: #{Exception.message(e)}\n#{Exception.format_stacktrace()}"
        )

        {:error, {:broadcast_failed, Exception.message(e)}}
    end
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
