# Phase 1.7: Supervision Tree

Set up the application supervision tree to orchestrate all simulation components. This establishes the OTP supervision structure for reliable, fault-tolerant operation with generational management.

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
│  │  │ 3. {ColonyIntelligenceAgent, []}                      │ │    │
│  │  │    - Jido Agent managing generations and KPIs         │ │    │
│  │  │    - Spawns AgentSupervisor and initial AntAgents     │ │    │
│  │  │    - Tracks generation_id and triggers next generation │ │    │
│  │  └───────────────────────────────────────────────────────┘ │    │
│  │                                                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ColonyIntelligenceAgent spawns:                                    │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  ┌───────────────────────────────────────────────────────┐ │    │
│  │  │ {DynamicSupervisor, name: AgentSupervisor}           │ │    │
│  │  │   - Dynamic supervisor for ant agents                 │ │    │
│  │  │   - Children: AntAgent instances (by generation)      │ │    │
│  │  │                                                       │ │    │
│  │  │   ┌─────────┐  ┌─────────┐  ┌─────────┐             │ │    │
│  │  │   │AntAgent │  │AntAgent │  │AntAgent │  ...        │ │    │
│  │  │   │gen_id=1 │  │gen_id=1 │  │gen_id=1 │             │ │    │
│  │  │   │  #1     │  │  #2     │  │  #3     │             │ │    │
│  │  │   └─────────┘  └─────────┘  └─────────┘             │ │    │
│  │  └───────────────────────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Application | Application entry point and supervision root |
| AntColony.Agent.ColonyIntelligence | Jido Agent managing generations and KPIs |
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

### 1.7.2.3 Add ColonyIntelligenceAgent Child (NEW)

Configure ColonyIntelligenceAgent as a child (Jido Agent).

- [ ] 1.7.2.3.1 Add `{AntColony.Agent.ColonyIntelligence, []}` to children
- [ ] 1.7.2.3.2 Document that ColonyIntelligenceAgent spawns AgentSupervisor
- [ ] 1.7.2.3.3 Document that ColonyIntelligenceAgent spawns initial AntAgents
- [ ] 1.7.2.3.4 Document generation_id management

### 1.7.2.4 Configure Supervisor Options

Set up the top-level supervisor options.

- [ ] 1.7.2.4.1 Set strategy: `:one_for_one`
- [ ] 1.7.2.4.2 Set name: `AntColony.Supervisor`
- [ ] 1.7.2.4.3 Configure max_restarts (default 3)
- [ ] 1.7.2.4.4 Configure max_seconds (default 5)

---

## 1.7.3 Add ColonyIntelligenceAgent (NEW)

Set up the ColonyIntelligenceAgent for generational management.

### 1.7.3.1 Create ColonyIntelligenceAgent Module

Create the Jido Agent for managing generations.

- [ ] 1.7.3.1.1 Create `lib/ant_colony/agent/colony_intelligence.ex`
- [ ] 1.7.3.1.2 Define `defmodule AntColony.Agent.ColonyIntelligence`
- [ ] 1.7.3.1.3 Add `use Jido.Agent` with appropriate options
- [ ] 1.7.3.1.4 Define state struct with `current_generation_id` and KPI tracking fields

### 1.7.3.2 Implement Generation Management

Implement generation tracking and spawning.

- [ ] 1.7.3.2.1 Add `def spawn_initial_generation(count)` - spawns first AntAgents
- [ ] 1.7.3.2.2 Add `def spawn_next_generation()` - triggers next generation protocol
- [ ] 1.7.3.2.3 Add `def trigger_generation_check()` - checks if trigger conditions met

### 1.7.3.3 Implement KPI Tracking

Implement Key Performance Indicator tracking per generation.

- [ ] 1.7.3.3.1 Add `food_delivered_count` to state
- [ ] 1.7.3.3.2 Add `generation_trigger_count` config (default: 50)
- [ ] 1.7.3.3.3 Subscribe to `{:food_delivered, _ant_id, _gen_id, _qty, _time}` events
- [ ] 1.7.3.3.4 Increment counter on food delivery events

### 1.7.3.4 Configure Agent to Spawn AgentSupervisor

Have ColonyIntelligenceAgent spawn the DynamicSupervisor for AntAgents.

- [ ] 1.7.3.4.1 Add `start_supervisor_tree()` to agent initialization
- [ ] 1.7.3.4.2 Use `Jido.Directive.Supervisor` to spawn AgentSupervisor
- [ ] 1.7.3.4.3 Store AgentSupervisor name in agent state
- [ ] 1.7.3.4.4 Use AgentSupervisor for spawning AntAgents

---

## 1.7.4 Add Dynamic Agent Supervisor

Set up the dynamic supervisor for ant agents (managed by ColonyIntelligenceAgent).

### 1.7.4.1 Configure Supervisor Strategy

Define how the supervisor manages child failures.

- [ ] 1.7.4.1.1 Use `:one_for_one` strategy
- [ ] 1.7.4.1.2 Document that one agent crash won't affect others
- [ ] 1.7.4.1.3 Set max_restarts: 10 (allow more restarts for agents)
- [ ] 1.7.4.1.4 Set max_seconds: 60 (wider window for agent restarts)

### 1.7.4.2 Add Supervisor Registry

Register the supervisor for later access.

- [ ] 1.7.4.2.1 Set `name: AntColony.AgentSupervisor` in child spec
- [ ] 1.7.4.2.2 Document that name is used for spawning agents
- [ ] 1.7.4.2.3 Verify name is unique within application

---

## 1.7.5 Implement Ant Spawning Functions

Create helper functions to spawn and manage ant agents.

### 1.7.5.1 Create Agent Manager Module

Create a module for agent management operations (used by ColonyIntelligenceAgent).

- [ ] 1.7.5.1.1 Create `lib/ant_colony/agent/manager.ex`
- [ ] 1.7.5.1.2 Define `defmodule AntColony.Agent.Manager`
- [ ] 1.7.5.1.3 Add comprehensive `@moduledoc`
- [ ] 1.7.5.1.4 Add `require Logger` for logging

### 1.7.5.2 Implement spawn_ant/2

Create a single ant agent with generation_id.

- [ ] 1.7.5.2.1 Define `def spawn_ant(generation_id, opts \\ [])`
- [ ] 1.7.5.2.2 Generate unique ant_id if not provided
- [ ] 1.7.5.2.3 Get default position from Plane (nest location)
- [ ] 1.7.5.2.4 Build initial agent state map with `generation_id`
- [ ] 1.7.5.2.5 Call `DynamicSupervisor.start_child(AgentSupervisor, child_spec)`
- [ ] 1.7.5.2.6 Return `{:ok, pid}` or `{:error, reason}`
- [ ] 1.7.5.2.7 Log info message on successful spawn

### 1.7.5.3 Implement spawn_ants/3

Create multiple ant agents for a generation.

- [ ] 1.7.5.3.1 Define `def spawn_ants(generation_id, count, opts \\ [])`
- [ ] 1.7.5.3.2 Validate count is positive integer
- [ ] 1.7.5.3.3 Use `Task.async_stream` for concurrent spawning
- [ ] 1.7.5.3.4 Collect results from all spawns
- [ ] 1.7.5.3.5 Return `{:ok, [pid1, pid2, ...]}` or `{:error, failed_count}`
- [ ] 1.7.5.3.6 Log info message with generation_id and count spawned

### 1.7.5.4 Implement stop_ant/1

Stop a running ant agent.

- [ ] 1.7.5.4.1 Define `def stop_ant(ant_id)`
- [ ] 1.7.5.4.2 Look up ant pid by id (may need registry)
- [ ] 1.7.5.4.3 Call `GenServer.stop(pid, :normal)` or use DynamicSupervisor
- [ ] 1.7.5.4.4 Return `:ok` or `{:error, :not_found}`

### 1.7.5.5 Implement list_ants/0

List all running ant agents.

- [ ] 1.7.5.5.1 Define `def list_ants()`
- [ ] 1.7.5.5.2 Call `DynamicSupervisor.which_children(AgentSupervisor)`
- [ ] 1.7.5.5.3 Extract pids from children list
- [ ] 1.7.5.5.4 Return list of `{ant_id, pid}` tuples

### 1.7.5.6 Implement count_ants/0

Get count of running ant agents.

- [ ] 1.7.5.6.1 Define `def count_ants()`
- [ ] 1.7.5.6.2 Call `list_ants()` and get length
- [ ] 1.7.5.6.3 Return integer count

---

## 1.7.6 Unit Tests for Application

Test the application startup and children.

### 1.7.6.1 Test Application Starts

Verify the application starts correctly.

- [ ] 1.7.6.1.1 Create `test/ant_colony/application_test.exs`
- [ ] 1.7.6.1.2 Add test: `test "application starts without errors"` - start check
- [ ] 1.7.6.1.3 Add test: `test "application returns valid pid"` - pid check
- [ ] 1.7.6.1.4 Add test: `test "application can be stopped"` - stop check

### 1.7.6.2 Test All Children Running

Verify all children start and stay running.

- [ ] 1.7.6.2.1 Add test: `test "PubSub child is running"` - Process.whereis
- [ ] 1.7.6.2.2 Add test: `test "Plane child is running"` - Process.whereis
- [ ] 1.7.6.2.3 Add test: `test "ColonyIntelligenceAgent child is running"` - Process.whereis
- [ ] 1.7.6.2.4 Add test: `test "AgentSupervisor child is running"` - Process.whereis
- [ ] 1.7.6.2.5 Add test: `test "all children respond to ping"` - GenServer.call

### 1.7.6.3 Test Application Restart

Verify the application can restart after crash.

- [ ] 1.7.6.3.1 Add test: `test "application restarts after crash"` - kill/start
- [ ] 1.7.6.3.2 Add test: `test "children restart after crash"` - verify
- [ ] 1.7.6.3.3 Add test: `test "state is preserved on restart"` - depends on implementation

---

## 1.7.7 Unit Tests for ColonyIntelligenceAgent

Test the ColonyIntelligenceAgent generation management.

### 1.7.7.1 Test Generation Initialization

Verify initial generation is created correctly.

- [ ] 1.7.7.1.1 Create `test/ant_colony/agent/colony_intelligence_test.exs`
- [ ] 1.7.7.1.2 Add test: `test "starts with generation_id 1"` - initial state
- [ ] 1.7.7.1.3 Add test: `test "spawns initial AntAgents on start"` - spawn check
- [ ] 1.7.7.1.4 Add test: `test "spawns AgentSupervisor before AntAgents"` - order check

### 1.7.7.2 Test KPI Tracking

Verify KPI tracking works correctly.

- [ ] 1.7.7.2.1 Add test: `test "increments food_delivered_count on event"` - counter
- [ ] 1.7.7.2.2 Add test: `test "resets counter on new generation"` - reset
- [ ] 1.7.7.2.3 Add test: `test "calculates food_collection_rate"` - rate

### 1.7.7.3 Test Generation Trigger

Verify generation trigger works correctly.

- [ ] 1.7.7.3.1 Add test: `test "triggers next generation at count threshold"` - trigger
- [ ] 1.7.7.3.2 Add test: `test "does not trigger before threshold"` - early check
- [ ] 1.7.7.3.3 Add test: `test "publishes generation_ended event on trigger"` - event

---

## 1.7.8 Unit Tests for Agent Spawning

Test agent spawning and management functions.

### 1.7.8.1 Test spawn_ant/2

Verify single agent spawning works with generation_id.

- [ ] 1.7.8.1.1 Create `test/ant_colony/agent/manager_test.exs`
- [ ] 1.7.8.1.2 Add test: `test "spawn_ant/2 creates new agent with generation_id"` - check pid
- [ ] 1.7.8.1.3 Add test: `test "spawn_ant/2 returns {:ok, pid}"` - return type
- [ ] 1.7.8.1.4 Add test: `test "spawn_ant/2 generates unique id"` - uniqueness
- [ ] 1.7.8.1.5 Add test: `test "spawn_ant/2 starts at nest by default"` - position

### 1.7.8.2 Test spawn_ants/3

Verify batch spawning works with generation_id.

- [ ] 1.7.8.2.1 Add test: `test "spawn_ants/3 creates multiple agents"` - count
- [ ] 1.7.8.2.2 Add test: `test "spawn_ants/3 assigns same generation_id to all"` - gen_id
- [ ] 1.7.8.2.3 Add test: `test "spawn_ants/3 returns all pids"` - return list
- [ ] 1.7.8.2.4 Add test: `test "spawn_ants/3 starts all at nest"` - positions
- [ ] 1.7.8.2.5 Add test: `test "spawn_ants/3 handles count of 0"` - edge case

### 1.7.8.3 Test Agent Registration

Verify agents register with Plane.

- [ ] 1.7.8.3.1 Add test: `test "spawned agent registers with Plane"` - Plane check
- [ ] 1.7.8.3.2 Add test: `test "spawned agent has correct generation_id"` - gen_id check
- [ ] 1.7.8.3.3 Add test: `test "agent unregisters on stop"` - cleanup

---

## 1.7.9 Phase 1.7 Integration Tests

End-to-end tests for the supervision tree.

### 1.7.9.1 Full Application Lifecycle Test

Test starting, using, and stopping the complete application.

- [ ] 1.7.9.1.1 Create `test/ant_colony/integration/application_integration_test.exs`
- [ ] 1.7.9.1.2 Add test: `test "complete application lifecycle"` - start/use/stop
- [ ] 1.7.9.1.3 Add test: `test "can spawn and interact with agents"` - full flow
- [ ] 1.7.9.1.4 Add test: `test "all components communicate via PubSub"` - events

### 1.7.9.2 Multi-Agent Simulation Test

Test multiple agents running concurrently.

- [ ] 1.7.9.2.1 Add test: `test "spawn 100 agents successfully"` - scale test
- [ ] 1.7.9.2.2 Add test: `test "agents can move concurrently"` - concurrency
- [ ] 1.7.9.2.3 Add test: `test "Plane tracks all agent positions"` - consistency
- [ ] 1.7.9.2.4 Add test: `test "agent crash doesn't affect others"` - isolation

### 1.7.9.3 Generational Lifecycle Test

Test complete generation lifecycle.

- [ ] 1.7.9.3.1 Add test: `test "first generation spawns with generation_id=1"` - initial
- [ ] 1.7.9.3.2 Add test: `test "generation triggers after threshold deliveries"` - trigger
- [ ] 1.7.9.3.3 Add test: `test "new generation spawns with incremented generation_id"` - increment
- [ ] 1.7.9.3.4 Add test: `test "old generation agents are stopped"` - cleanup

---

## Phase 1.7 Success Criteria

1. **Application Module**: Compiles and starts correctly ✅
2. **Supervision Tree**: All children start under supervision ✅
3. **PubSub**: Phoenix.PubSub runs and is accessible ✅
4. **Plane**: Plane GenServer runs and is accessible ✅
5. **ColonyIntelligenceAgent**: Runs and manages generations ✅
6. **AgentSupervisor**: Dynamic supervisor runs and accepts children ✅
7. **Agent Spawning**: spawn_ant/2 and spawn_ants/3 work with generation_id ✅
8. **Agent Management**: stop_ant, list_ants, count_ants work ✅
9. **Generation Triggers**: Count-based trigger works correctly ✅
10. **Fault Tolerance**: Children restart after crashes ✅
11. **Tests**: All unit and integration tests pass ✅

## Phase 1.7 Critical Files

**New Files:**
- `lib/ant_colony/agent/colony_intelligence.ex` - ColonyIntelligenceAgent (Jido)
- `lib/ant_colony/agent/manager.ex` - Agent spawning/management helpers
- `lib/ant_colony/agent/supervisor.ex` - (Optional) Supervisor helpers
- `test/ant_colony/application_test.exs` - Application tests
- `test/ant_colony/agent/colony_intelligence_test.exs` - ColonyIntelligence tests
- `test/ant_colony/agent/manager_test.exs` - Manager tests
- `test/ant_colony/integration/application_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/application.ex` - Complete supervision tree with ColonyIntelligenceAgent
- `mix.exs` - Ensure application config is correct

---

## Next Phase

Proceed to [Phase 1.8: Console Observer](./08-console-observer.md) to create a console-based observer for testing and debugging, then [Phase 1.9: ColonyIntelligenceAgent](./09-colony-intelligence-agent.md) for detailed generational management implementation.
