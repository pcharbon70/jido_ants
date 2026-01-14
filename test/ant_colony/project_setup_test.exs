defmodule AntColony.ProjectSetupTest do
  @moduledoc """
  Unit tests verifying the project setup is correct and functional.

  These tests ensure the project structure, dependencies, and configuration
  are properly set up as defined in Phase 1.1 of the project plan.
  """
  use ExUnit.Case

  @moduletag :project_setup

  describe "1.1.5.1 Project Compilation" do
    test "project compiles successfully" do
      # If we're running tests, compilation has already succeeded
      # This test serves as documentation that compilation works
      assert true
    end

    test "application module exists" do
      assert Code.ensure_loaded?(AntColony.Application)
      assert function_exported?(AntColony.Application, :start, 2)
    end

    test "jido dependency is available" do
      # Jido should be available as a dependency
      assert {:module, Jido.Agent} == Code.ensure_loaded(Jido.Agent)
    end

    test "pubsub dependency is available" do
      # Phoenix.PubSub should be available as a dependency
      assert {:module, Phoenix.PubSub} == Code.ensure_loaded(Phoenix.PubSub)
    end
  end

  describe "1.1.5.2 Directory Structure" do
    test "actions directory exists" do
      assert File.dir?("lib/ant_colony/actions")
    end

    test "agent directory exists" do
      assert File.dir?("lib/ant_colony/agent")
    end

    test "plane directory exists" do
      assert File.dir?("lib/ant_colony/plane")
    end

    test "test actions directory exists" do
      assert File.dir?("test/ant_colony/actions")
    end

    test "test agent directory exists" do
      assert File.dir?("test/ant_colony/agent")
    end

    test "test plane directory exists" do
      assert File.dir?("test/ant_colony/plane")
    end

    test "test support directory exists" do
      assert File.dir?("test/support")
    end
  end

  describe "1.1.5.3 Application Configuration" do
    test "application name is ant_colony" do
      assert :ant_colony == Application.app_dir(:ant_colony) |> Path.basename() |> String.to_atom()
    end

    test "mix project has correct app name" do
      assert :ant_colony == Mix.Project.config()[:app]
    end

    test "application module is correct" do
      # Application.get_application returns the app atom, not the module
      assert :ant_colony == Application.get_application(AntColony.Application)
      # Verify the application module implements the Application behavior
      assert function_exported?(AntColony.Application, :start, 2)
    end

    test "test configuration is set" do
      # Verify the plane_size config from test_helper.exs is set
      assert {20, 20} == Application.get_env(:ant_colony, :plane_size)
    end
  end
end
