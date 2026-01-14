defmodule AntColony.Application do
  @moduledoc """
  Application module for the ant_colony OTP application.

  Configures and starts the supervision tree for the simulation.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Phoenix.PubSub for event-driven communication
      {Phoenix.PubSub, name: AntColony.PubSub}
    ]

    opts = [strategy: :one_for_one, name: AntColony.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
