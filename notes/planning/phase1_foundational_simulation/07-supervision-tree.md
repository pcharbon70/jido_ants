# Phase 1.7: Supervision Tree

Set up the application supervision tree to orchestrate all simulation components. This establishes the OTP supervision structure for reliable, fault-tolerant operation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                  AntColony.Application                               │
│                   (Application Module)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Supervisor (one_for_one):                                          │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                                                             │    │
│  │  ┌───────────────────────────────────────────────────────┐ │    │
│  │  │ 1. {Phoenix.PubSub, name: AntColony.PubSub}          │ │    │
│  │  │    - PubSub for event-driven communication             │ │    │
│  │  └───────────────────────────────────────────────────────┘ │    │
│  │                                                             │    │
│  │  ┌───────────────────────────────────────────────────────┐ │    │
│  │  │ 2. {AntColony.Plane, []}                              │ │    │
│  │  │    - Environment GenServer managing world state        │ │    │
│  │  └───────────────────────────────────────────────────────┘ │    │
│  │                                                             │    │
│  │  ┌───────────────────────────────────────────────────────┐ │    │
│  │  │ 3. {DynamicSupervisor, name: AgentSupervisor}         │ │    │
│  │  │    - Dynamic supervisor for ant agents                │ │    │
│  │  │    - Strategy: one_for_one                            │ │    │
│  │  │    - Children: AntAgent instances (dynamically)       │ │    │
│  │  │                                                       │ │    │
│  │  │    ┌─────────┐  ┌─────────┐  ┌─────────┐             │ │    │
│  │  │    │AntAgent │  │AntAgent │  │AntAgent │  ...        │ │    │
│  │  │    │  #1     │  │  #2     │  │  #3     │             │ │    │
│  │  │    └─────────┘  └─────────┘  └─────────┘             │ │    │
│  │  └───────────────────────────────────────────────────────┘ │    │
│  │                                                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Application | Application entry point and supervision root |
| AntColony.AgentSupervisor | Dynamic supervisor for ant agents |
| AntColony.Agent.Manager | Helper module for spawning/managing agents |
| AntColony.Plane | Environment GenServer (child of Application) |
| AntColony.PubSub | Phoenix.PubSub instance (child of Application) |

---

## 1.7.1 Create Application Module

Set up the main Application module.

### 1.7.1.1 Define Application Behavior

Configure the module as an Application behavior.

- [ ] 1.7.1.1.1 Open `lib/ant_colony/application.ex`
- [ ] 1.7.1.1.2 Ensure `use Application` is present
- [ ] 1.7.1.1.3 Verify module name is `AntColony.Application`
- [ ] 1.7.1.1.4 Add comprehensive `@moduledoc`

### 1.7.1.2 Implement start/2 Callback

Implement the required Application callback.

- [ ] 1.7.1.2.1 Define `start(_type, _args)` function
- [ ] 1.7.1.2.2 Define children list for supervision tree
- [ ] 1.7.1.2.3 Define supervision options
- [ ] 1.7.1.2.4 Return `{:ok, pid}` or `{:ok, pid, state}` from start/2

### 1.7.1.3 Configure Application Options

Set up application configuration options.

- [ ] 1.7.1.3.1 Add `def application do` in mix.exs
- [ ] 1.7.1.3.2 Set `mod: {AntColony.Application, []}`
- [ ] 1.7.1.3.3 Add `extra_applications: [:logger]`
- [ ] 1.7.1.3.4 Verify mix.exs configuration

---

## 1.7.2 Configure Children List

Define the children for the supervision tree.

### 1.7.2.1 Add Phoenix.PubSub Child

Configure PubSub as a child.

- [ ] 1.7.2.1.1 Add `{Phoenix.PubSub, name: AntColony.PubSub}` to children
- [ ] 1.7.2.1.2 Use tuple format for child spec
- [ ] 1.7.2.1.3 Ensure PubSub starts first (order matters)
- [ ] 1.7.2.1.4 Document PubSub dependency in comments

### 1.7.2.2 Add Plane GenServer Child

Configure Plane as a child.

- [ ] 1.7.2.2.1 Add `{AntColony.Plane, []}` to children
- [ ] 1.7.2.2.2 Use tuple format with init args
- [ ] 1.7.2.2.3 Pass empty list or config options
- [ ] 1.7.2.2.4 Document Plane dependency on PubSub (for events)

### 1.7.2.3 Add DynamicSupervisor Child

Configure dynamic supervisor for agents.

- [ ] 1.7.2.3.1 Add DynamicSupervisor spec to children
- [ ] 1.7.2.3.2 Set name: `AntColony.AgentSupervisor`
- [ ] 1.7.2.3.3 Set strategy: `:one_for_one`
- [ ] 1.7.2.3.4 Set max_restarts and max_seconds (reasonable defaults)
- [ ] 1.7.2.3.5 Document purpose for dynamic agent spawning

### 1.7.2.4 Configure Supervisor Options

Set up the top-level supervisor options.

- [ ] 1.7.2.4.1 Set strategy: `:one_for_one`
- [ ] 1.7.2.4.2 Set name: `AntColony.Supervisor`
- [ ] 1.7.2.4.3 Configure max_restarts (default 3)
- [ ] 1.7.2.4.4 Configure max_seconds (default 5)

---

## 1.7.3 Add Dynamic Agent Supervisor

Set up the dynamic supervisor for ant agents.

### 1.7.3.1 Configure Supervisor Strategy

Define how the supervisor manages child failures.

- [ ] 1.7.3.1.1 Use `:one_for_one` strategy
- [ ] 1.7.3.1.2 Document that one agent crash won't affect others
- [ ] 1.7.3.1.3 Set max_restarts: 10 (allow more restarts for agents)
- [ ] 1.7.3.1.4 Set max_seconds: 60 (wider window for agent restarts)

### 1.7.3.2 Add Supervisor Registry

Register the supervisor for later access.

- [ ] 1.7.3.2.1 Set `name: AntColony.AgentSupervisor` in child spec
- [ ] 1.7.3.2.2 Document that name is used for spawning agents
- [ ] 1.7.3.2.3 Verify name is unique within application

### 1.7.3.3 Create Agent Supervisor Module (Optional)

Create a dedicated module for supervisor helpers.

- [ ] 1.7.3.3.1 Create `lib/ant_colony/agent/supervisor.ex`
- [ ] 1.7.3.3.2 Define `defmodule AntColony.Agent.Supervisor`
- [ ] 1.7.3.3.3 Add helper functions for supervisor operations
- [ ] 1.7.3.3.4 Add `@moduledoc` with usage examples

---

## 1.7.4 Implement Ant Spawning Functions

Create helper functions to spawn and manage ant agents.

### 1.7.4.1 Create Agent Manager Module

Create a module for agent management operations.

- [ ] 1.7.4.1.1 Create `lib/ant_colony/agent/manager.ex`
- [ ] 1.7.4.1.2 Define `defmodule AntColony.Agent.Manager`
- [ ] 1.7.4.1.3 Add comprehensive `@moduledoc`
- [ ] 1.7.4.1.4 Add `require Logger` for logging

### 1.7.4.2 Implement spawn_ant/1

Create a single ant agent.

- [ ] 1.7.4.2.1 Define `def spawn_ant(opts \\ [])`
- [ ] 1.7.4.2.2 Generate unique ant_id if not provided
- [ ] 1.7.4.2.3 Get default position from Plane (nest location)
- [ ] 1.7.4.2.4 Build initial agent state map
- [ ] 1.7.4.2.5 Call `DynamicSupervisor.start_child(AntColony.AgentSupervisor, child_spec)`
- [ ] 1.7.4.2.6 Return `{:ok, pid}` or `{:error, reason}`
- [ ] 1.7.4.2.7 Log info message on successful spawn

### 1.7.4.3 Implement spawn_ants/2

Create multiple ant agents at once.

- [ ] 1.7.4.3.1 Define `def spawn_ants(count, opts \\ [])`
- [ ] 1.7.4.3.2 Validate count is positive integer
- [ ] 1.7.4.3.3 Use `Task.async_stream` for concurrent spawning
- [ ] 1.7.4.3.4 Collect results from all spawns
- [ ] 1.7.4.3.5 Return `{:ok, [pid1, pid2, ...]}` or `{:error, failed_count}`
- [ ] 1.7.4.3.6 Log info message with count spawned

### 1.7.4.4 Implement stop_ant/1

Stop a running ant agent.

- [ ] 1.7.4.4.1 Define `def stop_ant(ant_id)`
- [ ] 1.7.4.4.2 Look up ant pid by id (may need registry)
- [ ] 1.7.4.4.3 Call `GenServer.stop(pid, :normal)` or use DynamicSupervisor
- [ ] 1.7.4.4.4 Return `:ok` or `{:error, :not_found}`

### 1.7.4.5 Implement list_ants/0

List all running ant agents.

- [ ] 1.7.4.5.1 Define `def list_ants()`
- [ ] 1.7.4.5.2 Call `DynamicSupervisor.which_children(AntColony.AgentSupervisor)`
- [ ] 1.7.4.5.3 Extract pids from children list
- [ ] 1.7.4.5.4 Return list of `{ant_id, pid}` tuples

### 1.7.4.6 Implement count_ants/0

Get count of running ant agents.

- [ ] 1.7.4.6.1 Define `def count_ants()`
- [ ] 1.7.4.6.2 Call `list_ants()` and get length
- [ ] 1.7.4.6.3 Return integer count

---

## 1.7.5 Unit Tests for Application

Test the application startup and children.

### 1.7.5.1 Test Application Starts

Verify the application starts correctly.

- [ ] 1.7.5.1.1 Create `test/ant_colony/application_test.exs`
- [ ] 1.7.5.1.2 Add test: `test "application starts without errors"` - start check
- [ ] 1.7.5.1.3 Add test: `test "application returns valid pid"` - pid check
- [ ] 1.7.5.1.4 Add test: `test "application can be stopped"` - stop check

### 1.7.5.2 Test All Children Running

Verify all children start and stay running.

- [ ] 1.7.5.2.1 Add test: `test "PubSub child is running"` - Process.whereis
- [ ] 1.7.5.2.2 Add test: `test "Plane child is running"` - Process.whereis
- [ ] 1.7.5.2.3 Add test: `test "AgentSupervisor child is running"` - Process.whereis
- [ ] 1.7.5.2.4 Add test: `test "all children respond to ping"` - GenServer.call

### 1.7.5.3 Test Application Restart

Verify the application can restart after crash.

- [ ] 1.7.5.3.1 Add test: `test "application restarts after crash"` - kill/start
- [ ] 1.7.5.3.2 Add test: `test "children restart after crash"` - verify
- [ ] 1.7.5.3.3 Add test: `test "state is preserved on restart"` - depends on implementation

---

## 1.7.6 Unit Tests for Agent Spawning

Test agent spawning and management functions.

### 1.7.6.1 Test spawn_ant/1

Verify single agent spawning works.

- [ ] 1.7.6.1.1 Create `test/ant_colony/agent/manager_test.exs`
- [ ] 1.7.6.1.2 Add test: `test "spawn_ant/1 creates new agent"` - check pid
- [ ] 1.7.6.1.3 Add test: `test "spawn_ant/1 returns {:ok, pid}"` - return type
- [ ] 1.7.6.1.4 Add test: `test "spawn_ant/1 generates unique id"` - uniqueness
- [ ] 1.7.6.1.5 Add test: `test "spawn_ant/1 starts at nest by default"` - position

### 1.7.6.2 Test spawn_ants/2

Verify batch spawning works.

- [ ] 1.7.6.2.1 Add test: `test "spawn_ants/2 creates multiple agents"` - count
- [ ] 1.7.6.2.2 Add test: `test "spawn_ants/2 returns all pids"` - return list
- [ ] 1.7.6.2.3 Add test: `test "spawn_ants/2 starts all at nest"` - positions
- [ ] 1.7.6.2.4 Add test: `test "spawn_ants/2 handles count of 0"` - edge case
- [ ] 1.7.6.2.5 Add test: `test "spawn_ants/2 handles large count"` - stress test

### 1.7.6.3 Test Agent Registration

Verify agents register with Plane.

- [ ] 1.7.6.3.1 Add test: `test "spawned agent registers with Plane"` - Plane check
- [ ] 1.7.6.3.2 Add test: `test "spawned agent position matches Plane"` - consistency
- [ ] 1.7.6.3.3 Add test: `test "agent unregisters on stop"` - cleanup

### 1.7.6.4 Test Agent Listing

Verify agent listing functions work.

- [ ] 1.7.6.4.1 Add test: `test "list_ants/0 returns all agents"` - list check
- [ ] 1.7.6.4.2 Add test: `test "list_ants/0 returns empty when none"` - empty
- [ ] 1.7.6.4.3 Add test: `test "count_ants/0 returns correct count"` - count
- [ ] 1.7.6.4.4 Add test: `test "count_ants/0 updates on spawn/stop"` - dynamic

### 1.7.6.5 Test Agent Stopping

Verify agents can be stopped cleanly.

- [ ] 1.7.6.5.1 Add test: `test "stop_ant/1 stops running agent"` - verify stop
- [ ] 1.7.6.5.2 Add test: `test "stop_ant/1 returns :ok for valid agent"` - return
- [ ] 1.7.6.5.3 Add test: `test "stop_ant/1 returns error for unknown agent"` - error
- [ ] 1.7.6.5.4 Add test: `test "stopped agent unregisters from Plane"` - cleanup

---

## 1.7.7 Phase 1.7 Integration Tests

End-to-end tests for the supervision tree.

### 1.7.7.1 Full Application Lifecycle Test

Test starting, using, and stopping the complete application.

- [ ] 1.7.7.1.1 Create `test/ant_colony/integration/application_integration_test.exs`
- [ ] 1.7.7.1.2 Add test: `test "complete application lifecycle"` - start/use/stop
- [ ] 1.7.7.1.3 Add test: `test "can spawn and interact with agents"` - full flow
- [ ] 1.7.7.1.4 Add test: `test "all components communicate via PubSub"` - events

### 1.7.7.2 Multi-Agent Simulation Test

Test multiple agents running concurrently.

- [ ] 1.7.7.2.1 Add test: `test "spawn 100 agents successfully"` - scale test
- [ ] 1.7.7.2.2 Add test: `test "agents can move concurrently"` - concurrency
- [ ] 1.7.7.2.3 Add test: `test "Plane tracks all agent positions"` - consistency
- [ ] 1.7.7.2.4 Add test: `test "agent crash doesn't affect others"` - isolation

### 1.7.7.3 Fault Tolerance Test

Test supervision tree handles failures correctly.

- [ ] 1.7.7.3.1 Add test: `test "Plane crash restarts Plane"` - Plane restart
- [ ] 1.7.7.3.2 Add test: `test "Plane restart doesn't crash agents"` - isolation
- [ ] 1.7.7.3.3 Add test: `test "agent crash restarts that agent"` - agent restart
- [ ] 1.7.7.3.4 Add test: `test "PubSub crash restarts PubSub"` - PubSub restart
- [ ] 1.7.7.3.5 Add test: `test "application survives child crashes"` - resilience

### 1.7.7.4 Event Flow Test

Test complete event flow through the system.

- [ ] 1.7.7.4.1 Add test: `test "ant move events reach subscribers"` - event flow
- [ ] 1.7.7.4.2 Add test: `test "food sensed events reach subscribers"` - event flow
- [ ] 1.7.7.4.3 Add test: `test "multiple agents events are distinguishable"` - unique ids
- [ ] 1.7.7.4.4 Add test: `test "event subscribers don't affect simulation"` - decoupling

---

## Phase 1.7 Success Criteria

1. **Application Module**: Compiles and starts correctly ✅
2. **Supervision Tree**: All children start under supervision ✅
3. **PubSub**: Phoenix.PubSub runs and is accessible ✅
4. **Plane**: Plane GenServer runs and is accessible ✅
5. **AgentSupervisor**: Dynamic supervisor runs and accepts children ✅
6. **Agent Spawning**: spawn_ant/1 and spawn_ants/2 work ✅
7. **Agent Management**: stop_ant, list_ants, count_ants work ✅
8. **Fault Tolerance**: Children restart after crashes ✅
9. **Tests**: All unit and integration tests pass ✅

## Phase 1.7 Critical Files

**New Files:**
- `lib/ant_colony/agent/manager.ex` - Agent spawning/management helpers
- `lib/ant_colony/agent/supervisor.ex` - (Optional) Supervisor helpers
- `test/ant_colony/application_test.exs` - Application tests
- `test/ant_colony/agent/manager_test.exs` - Manager tests
- `test/ant_colony/integration/application_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/application.ex` - Complete supervision tree
- `mix.exs` - Ensure application config is correct

---

## Next Phase

Proceed to [Phase 1.8: Console Observer](./08-console-observer.md) to create a console-based observer for testing and debugging.
