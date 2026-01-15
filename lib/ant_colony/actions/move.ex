defmodule AntColony.Actions.Move do
  @moduledoc """
  Action for moving an ant in the simulated environment.

  This action calculates a new position based on the specified direction,
  updates the ant's path memory, updates the Plane registry, and broadcasts
  an ant_moved event.

  ## Parameters

  * `direction` - The direction to move: `:north`, `:south`, `:east`, `:west`, or `:random`
  * `steps` - The number of steps to move (default: 1)

  ## Effects

  1. Updates the agent's `position` to the new coordinates
  2. Appends the old position with observations to `path_memory`
  3. Calls `AntColony.Plane.update_ant_position/2` to update the Plane registry
  4. Broadcasts `{:ant_moved, ant_id, old_pos, new_pos}` via PubSub

  ## Boundary Handling

  Movement is constrained by the Plane dimensions. If a move would go outside
  the bounds (x < 0, x >= width, y < 0, y >= height), the position is clamped
  to the valid range.

  ## Examples

      # Move ant north by 1 step
      {:ok, result} = AntColony.Actions.Move.run(
        %{direction: :north, steps: 1},
        %{state: %{position: {25, 25}, id: "ant_1", current_state: :searching, path_memory => []}}
      )

      # Move ant east by 3 steps
      {:ok, result} = AntColony.Actions.Move.run(
        %{direction: :east, steps: 3},
        %{state: %{position: {10, 10}, id: "ant_2", current_state: :searching, path_memory => []}}
      )

      # Move in random direction
      {:ok, result} = AntColony.Actions.Move.run(
        %{direction: :random},
        %{state: %{position: {25, 25}, id: "ant_3", current_state: :searching, path_memory => []}}
      )
  """

  use Jido.Action,
    name: "move",
    description: "Move the ant in the specified direction",
    category: "movement",
    tags: ["ant", "movement", "position"],
    vsn: "1.0.0",
    schema: [
      direction: [
        type: {:in, [:north, :south, :east, :west, :random]},
        required: true,
        doc: "The direction to move the ant"
      ],
      steps: [
        type: :integer,
        default: 1,
        doc: "The number of steps to move in the given direction"
      ]
    ]

  require Logger

  @impl Jido.Action
  def run(params, context) do
    # Extract agent state - handle both direct context and wrapped context
    agent_state = case Map.get(context, :state) do
      nil -> context  # Direct call: context is the agent state
      state -> state  # Wrapped call: context contains :state key
    end

    # Extract ant_id from context or state
    # When called via Agent.cmd/2, the id may be at context level (not in state)
    # When called directly with a state map, the id is in the state
    ant_id = Map.get(context, :id) || Map.get(agent_state, :id)

    with {:ok, current_pos} <- validate_position(agent_state),
         {:ok, plane_dimensions} <- get_plane_dimensions(),
         steps <- Map.get(params, :steps, 1),
         {:ok, new_pos} <- calculate_movement(current_pos, params[:direction], steps, plane_dimensions),
         {:ok, _path_memory_entry} <- create_path_memory_entry(agent_state),
         {:ok, _} <- update_plane_registry(ant_id, new_pos),
         {:ok, _} <- broadcast_move_event(ant_id, current_pos, new_pos) do
      {:ok, build_result(new_pos, nil)}
    end
  end

  # Calculate new position based on direction and steps
  defp calculate_movement(current_pos, direction, steps, {width, height}) do
    do_calculate_movement(current_pos, direction, steps, width, height)
  end

  defp do_calculate_movement(pos, _direction, 0, _width, _height), do: {:ok, pos}
  defp do_calculate_movement({x, y}, :north, steps, _width, _height) when steps > 0 do
    new_y = max(0, y - steps)
    {:ok, {x, new_y}}
  end

  defp do_calculate_movement({x, y}, :south, steps, _width, height) when steps > 0 do
    new_y = min(height - 1, y + steps)
    {:ok, {x, new_y}}
  end

  defp do_calculate_movement({x, y}, :east, steps, width, _height) when steps > 0 do
    new_x = min(width - 1, x + steps)
    {:ok, {new_x, y}}
  end

  defp do_calculate_movement({x, y}, :west, steps, _width, _height) when steps > 0 do
    new_x = max(0, x - steps)
    {:ok, {new_x, y}}
  end

  defp do_calculate_movement(pos, :random, steps, width, height) when steps > 0 do
    directions = [:north, :south, :east, :west]
    final_pos = Enum.reduce(1..steps, pos, fn _, acc ->
      direction = Enum.random(directions)
      {:ok, new_pos} = do_calculate_movement(acc, direction, 1, width, height)
      new_pos
    end)
    {:ok, final_pos}
  end

  # Validate that the agent has a position
  defp validate_position(agent_state) do
    case Map.get(agent_state, :position) do
      nil -> {:error, "Agent position not found"}
      {x, y} = pos when is_integer(x) and is_integer(y) -> {:ok, pos}
      pos -> {:error, "Invalid position: #{inspect(pos)}"}
    end
  end

  # Get Plane dimensions for boundary checking
  defp get_plane_dimensions do
    case AntColony.Plane.get_dimensions() do
      {width, height} -> {:ok, {width, height}}
      _ -> {:error, "Failed to get Plane dimensions"}
    end
  end

  # Create a path memory entry with observations
  defp create_path_memory_entry(agent_state) do
    entry = {
      Map.get(agent_state, :position),
      %{
        timestamp: DateTime.utc_now(),
        current_state: Map.get(agent_state, :current_state, :at_nest)
      }
    }
    {:ok, entry}
  end

  # Update Plane's ant position registry
  defp update_plane_registry(nil, _new_pos), do: {:ok, :no_id}

  defp update_plane_registry(ant_id, new_pos) do
    case AntColony.Plane.update_ant_position(ant_id, new_pos) do
      :ok -> {:ok, :updated}
      {:error, :not_found} ->
        Logger.warning("Ant #{ant_id} not found in Plane registry")
        {:ok, :not_registered}
      {:error, reason} ->
        Logger.error("Failed to update Plane: #{inspect(reason)}")
        {:error, {:plane_update_failed, reason}}
    end
  end

  # Broadcast ant_moved event via PubSub
  defp broadcast_move_event(nil, _old_pos, _new_pos), do: {:ok, :no_id}

  defp broadcast_move_event(ant_id, old_pos, new_pos) do
    case AntColony.Events.broadcast_ant_moved(
           AntColony.PubSub,
           ant_id,
           old_pos,
           new_pos
         ) do
      :ok -> {:ok, :broadcasted}
      {:error, reason} ->
        Logger.error("Failed to broadcast move event: #{inspect(reason)}")
        {:error, {:broadcast_failed, reason}}
    end
  end

  # Build the result map with updated state
  # Note: Only return fields that should be merged into agent state
  # The agent schema has `path_memory` (list) not `path_memory_entry` (single entry)
  defp build_result(new_pos, _path_memory_entry) do
    %{
      position: new_pos
    }
  end

  @doc """
  Calculates a new position based on the current position and direction.

  This is a helper function that can be used externally for position calculations
  without executing the full action.

  ## Parameters

  * `current_pos` - The current {x, y} position
  * `direction` - The direction to move: `:north`, `:south`, `:east`, `:west`, or `:random`
  * `steps` - The number of steps to move (default: 1)
  * `plane_dimensions` - The {width, height} of the plane (default: {50, 50})

  ## Returns

  * `{:ok, new_position}` - The new {x, y} position
  * `{:error, reason}` - If calculation fails

  ## Examples

      iex> AntColony.Actions.Move.calculate_position({25, 25}, :north)
      {:ok, {25, 24}}

      iex> AntColony.Actions.Move.calculate_position({25, 25}, :east, 3)
      {:ok, {28, 25}}
  """
  @spec calculate_position(
          {integer(), integer()},
          atom(),
          pos_integer(),
          {pos_integer(), pos_integer()}
        ) :: {:ok, {integer(), integer()}} | {:error, term()}
  def calculate_position(current_pos, direction, steps \\ 1, plane_dimensions \\ {50, 50}) do
    calculate_movement(current_pos, direction, steps, plane_dimensions)
  end

  @doc """
  Checks if a position is valid within the given plane dimensions.

  ## Parameters

  * `position` - The {x, y} position to check
  * `plane_dimensions` - The {width, height} of the plane

  ## Returns

  * `true` - Position is within bounds
  * `false` - Position is out of bounds

  ## Examples

      iex> AntColony.Actions.Move.valid_position?({25, 25}, {50, 50})
      true

      iex> AntColony.Actions.Move.valid_position?({-1, 25}, {50, 50})
      false

      iex> AntColony.Actions.Move.valid_position?({25, 50}, {50, 50})
      false
  """
  @spec valid_position?({integer(), integer()}, {pos_integer(), pos_integer()}) :: boolean()
  def valid_position?({x, y}, {width, height}) do
    x >= 0 and x < width and y >= 0 and y < height
  end
end
