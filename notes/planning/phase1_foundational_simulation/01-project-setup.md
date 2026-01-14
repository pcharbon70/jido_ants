# Phase 1.1: Project Setup

Initialize the Elixir project with Jido v2 framework and required dependencies. This phase creates the foundation for all subsequent development.

## Architecture

```
jido_ants/
├── mix.exs                 # Project configuration and dependencies
├── config/
│   └── config.exs          # Application configuration
├── lib/
│   └── ant_colony/         # Main application namespace
│       ├── actions/        # Jido action modules
│       ├── agent/          # Jido agent modules
│       ├── plane/          # Environment modules
│       └── application.ex  # Application entry point
└── test/
    ├── test_helper.exs     # Test configuration
    └── ant_colony/         # Test modules mirroring lib structure
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| mix.exs | Project configuration, OTP app definition, dependencies |
| config/config.exs | Runtime configuration |
| lib/ directory structure | Organized namespace for application code |
| test/ directory structure | Test files matching lib structure |

---

## 1.1.1 Create New Elixir Project

Initialize the project using Mix, the Elixir build tool, with proper OTP application structure.

### 1.1.1.1 Initialize Mix Project

Create a new Elixir project with OTP application structure.

- [ ] 1.1.1.1.1 Run `mix new jido_ants --sup` to create project with supervision tree
- [ ] 1.1.1.1.2 Verify the following files are created:
  - `mix.exs`
  - `config/config.exs`
  - `lib/jido_ants.ex` (rename/adjust later)
  - `lib/jido_ants/application.ex`
  - `test/test_helper.exs`
  - `test/jido_ants_test.exs`
- [ ] 1.1.1.1.3 Change into the project directory

### 1.1.1.2 Configure OTP Application Name

Set the application name to `:ant_colony` for consistency with the planned namespace.

- [ ] 1.1.1.2.1 Edit `mix.exs` and change `app: :jido_ants` to `app: :ant_colony`
- [ ] 1.1.1.2.2 Update the `module` option to use `AntColony.Application`
- [ ] 1.1.1.2.3 Rename `lib/jido_ants/` to `lib/ant_colony/`
- [ ] 1.1.1.2.4 Rename `lib/jido_ants.ex` to `lib/ant_colony.ex`
- [ ] 1.1.1.2.5 Rename `lib/jido_ants/application.ex` to `lib/ant_colony/application.ex`
- [ ] 1.1.1.2.6 Rename `test/jido_ants_test.exs` to `test/ant_colony_test.exs`

### 1.1.1.3 Verify Project Structure

Ensure all files are in the correct locations after renaming.

- [ ] 1.1.1.3.1 Run `tree -L 3` or `ls -R` to verify structure
- [ ] 1.1.1.3.2 Verify `lib/ant_colony/` directory exists
- [ ] 1.1.1.3.3 Verify `test/` directory exists
- [ ] 1.1.1.3.4 Verify `config/` directory exists

---

## 1.1.2 Configure mix.exs Dependencies

Add all required dependencies for the ant colony simulation project.

### 1.1.2.1 Add Production Dependencies

Configure the dependencies needed for runtime operation of the simulation.

- [ ] 1.1.2.1.1 Edit `mix.exs` and locate the `deps/0` function
- [ ] 1.1.2.1.2 Add `{:jido, "~> 2.0"}` to the deps list
- [ ] 1.1.2.1.3 Add `{:phoenix_pubsub, "~> 2.1"}` to the deps list
- [ ] 1.1.2.1.4 Ensure deps are properly formatted with commas

### 1.1.2.2 Add Development Dependencies

Add dependencies used only during development and testing.

- [ ] 1.1.2.2.1 Add `{:ex_doc, "~> 0.30", only: :dev, runtime: false}` for documentation
- [ ] 1.1.2.2.2 Add `{:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}` for dialyzer
- [ ] 1.1.2.2.3 Consider adding `{:credo, "~> 1.7", only: [:dev, :test], runtime: false}` for linting

### 1.1.2.3 Fetch and Compile Dependencies

Download and compile all dependencies to verify they work correctly.

- [ ] 1.1.2.3.1 Run `mix deps.get` to fetch dependencies
- [ ] 1.1.2.3.2 Run `mix deps.compile` to compile dependencies
- [ ] 1.1.2.3.3 Verify no errors occur during fetch/compile
- [ ] 1.1.2.3.4 Check that `deps/` directory contains jido and phoenix_pubsub

---

## 1.1.3 Set Up Directory Structure

Create the organized directory structure for the application modules.

### 1.1.3.1 Create Actions Directory

Create the directory for Jido action modules.

- [ ] 1.1.3.1.1 Run `mkdir -p lib/ant_colony/actions`
- [ ] 1.1.3.1.2 Create placeholder `.gitkeep` file: `touch lib/ant_colony/actions/.gitkeep`
- [ ] 1.1.3.1.3 Verify directory exists with `ls -la lib/ant_colony/`

### 1.1.3.2 Create Agent Directory

Create the directory for Jido agent modules.

- [ ] 1.1.3.2.1 Run `mkdir -p lib/ant_colony/agent`
- [ ] 1.1.3.2.2 Create placeholder `.gitkeep` file: `touch lib/ant_colony/agent/.gitkeep`
- [ ] 1.1.3.2.3 Verify directory exists with `ls -la lib/ant_colony/`

### 1.1.3.3 Create Plane Directory

Create the directory for environment/simulation modules.

- [ ] 1.1.3.3.1 Run `mkdir -p lib/ant_colony/plane`
- [ ] 1.1.3.3.2 Create placeholder `.gitkeep` file: `touch lib/ant_colony/plane/.gitkeep`
- [ ] 1.1.3.3.3 Verify directory exists with `ls -la lib/ant_colony/`

### 1.1.3.4 Create Test Directory Structure

Mirror the lib directory structure in tests.

- [ ] 1.1.3.4.1 Run `mkdir -p test/ant_colony/actions`
- [ ] 1.1.3.4.2 Run `mkdir -p test/ant_colony/agent`
- [ ] 1.1.3.4.3 Run `mkdir -p test/ant_colony/plane`
- [ ] 1.1.3.4.4 Create `.gitkeep` files in each test subdirectory
- [ ] 1.1.3.4.5 Verify complete test structure exists

---

## 1.1.4 Configure ExUnit

Set up the test configuration for proper testing behavior.

### 1.1.4.1 Update test_helper.exs

Configure ExUnit with appropriate settings.

- [ ] 1.1.4.1.1 Open `test/test_helper.exs`
- [ ] 1.1.4.1.2 Add `ExUnit.start(exclude: [skip: true])` to enable skip tags
- [ ] 1.1.4.1.3 Add `Application.put_env(:ant_colony, :plane_size, {20, 20})` for test configuration
- [ ] 1.1.4.1.4 Keep the file minimal; additional configuration per test module

### 1.1.4.2 Create Test Support Module

Create a helper module for common test utilities.

- [ ] 1.1.4.2.1 Create `test/support/test_helper.ex`
- [ ] 1.1.4.2.2 Define module `AntColony.TestHelper`
- [ ] 1.1.4.2.3 Add helper function `start_plane/0` to start Plane for tests
- [ ] 1.1.4.2.4 Add helper function `stop_plane/0` to stop Plane after tests
- [ ] 1.1.4.2.5 Add `@moduledoc` explaining the helper's purpose

### 1.1.4.3 Ensure Test Directory is in Elixir Path

Configure Mix to include the test/support directory.

- [ ] 1.1.4.3.1 Open `mix.exs`
- [ ] 1.1.4.3.2 Locate the `project/0` function
- [ ] 1.1.4.3.3 Add `elixirc_paths: elixirc_paths(Mix.env())` function
- [ ] 1.1.4.3.4 Define `elixirc_paths(:test)` to include "test/support"
- [ ] 1.1.4.3.5 Define `elixirc_paths(_)` for default lib path

---

## 1.1.5 Unit Tests for Project Setup

Verify that the project setup is correct and functional.

### 1.1.5.1 Test Project Compilation

Ensure the project compiles without errors.

- [ ] 1.1.5.1.1 Create `test/ant_colony/project_setup_test.exs`
- [ ] 1.1.5.1.2 Add test: `test "project compiles successfully"` - calls `mix compile`
- [ ] 1.1.5.1.3 Add test: `test "application module exists"` - checks `Code.ensure_loaded?(AntColony.Application)`
- [ ] 1.1.5.1.4 Add test: `test "dependencies are available"` - checks `Application.spec(:jido)`
- [ ] 1.1.5.1.5 Add test: `test "pubsub dependency is available"` - checks `Application.spec(:phoenix_pubsub)`

### 1.1.5.2 Test Directory Structure

Verify all expected directories exist.

- [ ] 1.1.5.2.1 Create test helper to check directory existence
- [ ] 1.1.5.2.2 Add test: `test "actions directory exists"` - checks `File.dir?("lib/ant_colony/actions")`
- [ ] 1.1.5.2.3 Add test: `test "agent directory exists"` - checks `File.dir?("lib/ant_colony/agent")`
- [ ] 1.1.5.2.4 Add test: `test "plane directory exists"` - checks `File.dir?("lib/ant_colony/plane")`
- [ ] 1.1.5.2.5 Add test: `test "test directories mirror lib structure"`

### 1.1.5.3 Test Application Configuration

Verify application is configured correctly.

- [ ] 1.1.5.3.1 Add test: `test "application name is ant_colony"` - checks `Application.app_dir(:ant_colony)`
- [ ] 1.1.5.3.2 Add test: `test "application module is correct"` - checks `Application.get_application(AntColony.Application)`
- [ ] 1.1.5.3.3 Add test: `test "mix project has correct app name"` - checks `Mix.Project.config()[:app]`

---

## 1.1.6 Phase 1.1 Integration Tests

End-to-end tests verifying the complete project setup.

### 1.1.6.1 Start Application Test

Verify the application can start and stop correctly.

- [ ] 1.1.6.1.1 Create `test/ant_colony/integration/project_setup_integration_test.exs`
- [ ] 1.1.6.1.2 Add setup block that ensures application is stopped
- [ ] 1.1.6.1.3 Add test: `test "application starts without errors"` - calls `Application.ensure_all_started(:ant_colony)`
- [ ] 1.1.6.1.4 Add test: `test "application stops cleanly"` - calls `Application.stop(:ant_colony)`
- [ ] 1.1.6.1.5 Add test: `test "application can restart"` - start/stop/start sequence

### 1.1.6.2 Dependency Loading Test

Verify all dependencies are loaded and accessible.

- [ ] 1.1.6.2.1 Add test: `test "jido modules are accessible"` - checks `Jido.Agent` is defined
- [ ] 1.1.6.2.2 Add test: `test "phoenix_pubsub modules are accessible"` - checks `Phoenix.PubSub` is defined
- [ ] 1.1.6.2.3 Add test: `test "all dependencies are loaded"` - iterates through `Application.loaded_applications()`

### 1.1.6.3 Mix Tasks Test

Verify common Mix tasks work correctly.

- [ ] 1.1.6.3.1 Add test: `test "mix compile works"` - runs `System.cmd("mix", ["compile"])`
- [ ] 1.1.6.3.2 Add test: `test "mix test runs"` - runs `System.cmd("mix", ["test"])`
- [ ] 1.1.6.3.3 Add test: `test "mix format works"` - runs `System.cmd("mix", ["format", "--check-formatted"])`

---

## Phase 1.1 Success Criteria

1. **Project Structure**: All directories created correctly ✅
2. **Dependencies**: Jido v2 and Phoenix.PubSub installed ✅
3. **Compilation**: `mix compile` succeeds without errors ✅
4. **Tests**: `mix test` runs and passes setup tests ✅
5. **Application**: `Application.ensure_all_started(:ant_colony)` succeeds ✅

## Phase 1.1 Critical Files

**New Files:**
- `mix.exs` - Project configuration with dependencies
- `config/config.exs` - Runtime configuration
- `lib/ant_colony/application.ex` - Application entry point
- `lib/ant_colony/actions/.gitkeep` - Actions directory placeholder
- `lib/ant_colony/agent/.gitkeep` - Agent directory placeholder
- `lib/ant_colony/plane/.gitkeep` - Plane directory placeholder
- `test/test_helper.exs` - Test configuration
- `test/support/test_helper.ex` - Test utilities
- `test/ant_colony/project_setup_test.exs` - Setup tests

**Modified Files:**
- None (all files are newly created)

---

## Next Phase

Proceed to [Phase 1.2: PubSub Configuration](./02-pubsub-configuration.md) to set up the event-driven communication backbone.
