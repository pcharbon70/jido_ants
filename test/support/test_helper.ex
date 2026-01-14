defmodule AntColony.TestHelper do
  @moduledoc """
  Helper module for common test utilities.

  Provides functions to start and stop the Plane GenServer
  during tests, ensuring proper setup and teardown.
  """

  @doc """
  Starts the Plane GenServer for testing.

  Returns `{:ok, pid}` on success or raises if startup fails.
  """
  def start_plane do
    # Plane will be implemented in Phase 1.3
    # For now, this is a placeholder that will be used
    # once the Plane module exists
    {:ok, nil}
  end

  @doc """
  Stops the Plane GenServer after testing.

  Returns `:ok` on success.
  """
  def stop_plane do
    # Plane will be implemented in Phase 1.3
    # For now, this is a placeholder that will be used
    # once the Plane module exists
    :ok
  end
end
