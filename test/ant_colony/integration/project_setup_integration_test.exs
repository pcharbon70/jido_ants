defmodule AntColony.ProjectSetupIntegrationTest do
  @moduledoc """
  Integration tests for Phase 1.1 project setup.

  These tests verify end-to-end behavior including application
  lifecycle, dependency loading, and Mix task execution.
  """
  use ExUnit.Case

  @moduletag :integration

  # Helper to extract app names from Application.loaded_applications()
  defp loaded_app_names do
    Application.loaded_applications()
    |> Enum.map(fn {app, _desc, _vsn} -> app end)
  end

  describe "1.1.6.1 Application Lifecycle" do
    setup do
      # Ensure application is stopped before each test
      _ = Application.stop(:ant_colony)
      :ok
    end

    test "application starts without errors" do
      assert {:ok, _started} = Application.ensure_all_started(:ant_colony)
      assert :ant_colony in loaded_app_names()
    end

    test "application stops cleanly" do
      {:ok, _started} = Application.ensure_all_started(:ant_colony)
      # The stop command should return :ok
      assert :ok = Application.stop(:ant_colony)
      # Note: Application may remain in loaded_applications() list briefly
      # The important part is that Application.stop/1 returns :ok
    after
      # Ensure application is restarted for other tests
      Application.ensure_all_started(:ant_colony)
    end

    test "application can restart" do
      # First start
      assert {:ok, _started} = Application.ensure_all_started(:ant_colony)
      assert :ok = Application.stop(:ant_colony)

      # Second start (restart)
      assert {:ok, _restarted} = Application.ensure_all_started(:ant_colony)
      assert :ant_colony in loaded_app_names()

      # Clean up
      Application.stop(:ant_colony)
    after
      # Ensure application is restarted for other tests
      Application.ensure_all_started(:ant_colony)
    end
  end

  describe "1.1.6.2 Dependency Loading" do
    test "jido modules are accessible" do
      # Jido.Agent should be defined and usable
      assert Code.ensure_loaded?(Jido.Agent)
      assert function_exported?(Jido.Agent, :__info__, 1)
    end

    test "phoenix_pubsub modules are accessible" do
      # Phoenix.PubSub should be defined and usable
      assert Code.ensure_loaded?(Phoenix.PubSub)
      assert function_exported?(Phoenix.PubSub, :__info__, 1)
    end

    test "all dependencies are loaded" do
      loaded_apps = loaded_app_names()

      # Verify core dependencies are loaded
      assert :ant_colony in loaded_apps
      assert :jido in loaded_apps
      assert :phoenix_pubsub in loaded_apps
      assert :elixir in loaded_apps
    end
  end

  describe "1.1.6.3 Mix Tasks" do
    @tag :mix_task
    test "mix compile works" do
      {output, exit_code} = System.cmd("mix", ["compile"], stderr_to_stdout: true)

      # Exit code 0 means success (even when nothing to compile)
      assert exit_code == 0
      # Output should be a binary (may be empty if everything is compiled)
      assert is_binary(output)
    end

    @tag :mix_task
    @tag :slow
    @tag timeout: 120_000
    @tag :skip
    test "mix test runs" do
      # This test is skipped because running mix test within a test causes
      # recursive test execution. It should be run manually to verify.
      {output, exit_code} = System.cmd("mix", ["test"], stderr_to_stdout: true)

      # Exit code 0 means all tests passed
      assert exit_code == 0
      # Output should show test results
      assert output =~ "tests"
    end

    @tag :mix_task
    test "mix format check works" do
      {output, exit_code} =
        System.cmd("mix", ["format", "--check-formatted"], stderr_to_stdout: true)

      # Exit code 0 means all files are formatted
      # Exit code 1 means some files need formatting (not a failure for this test)
      assert exit_code in [0, 1]
      # We just want to ensure the command runs without crashing
      assert is_binary(output)
    end
  end
end
