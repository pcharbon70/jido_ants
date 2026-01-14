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
end
