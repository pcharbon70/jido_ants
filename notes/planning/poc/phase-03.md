# Phase 3: Ant Agent Foundation

This phase implements the AntAgent using Jido v2's agent framework. The ant is modeled as a Jido agent with a Finite State Machine managing its behavioral states (at_nest, searching, returning_to_nest, communicating). Each ant maintains its own state including position, path memory, and knowledge of food sources.

---

## 3.1 AntAgent Struct Definition

Define the AntAgent schema with all required fields for autonomous behavior.

### 3.1.1 AntAgent Module Structure
- [ ] **Task 3.1.1** Create the AntAgent module with Jido.Agent behavior.

- [ ] 3.1.1.1 Create `lib/jido_ants/agent/ant.ex` with module documentation
- [ ] 3.1.1.2 Add `use Jido.Agent` with configuration:
  ```elixir
  use Jido.Agent,
    id: false,
    schema: [
      id: [type: :string, required: true],
      position: [type: :tuple, required: true],
      nest_position: [type: :tuple, required: true],
      path_memory: [type: :list, default: []],
      current_state: [type: :atom, default: :at_nest],
      has_food?: [type: :boolean, default: false],
      carried_food_level: [type: :integer, default: nil],
      known_food_sources: [type: :list, default: []],
      energy: [type: :integer, default: 100]
    ]
  ```
- [ ] 3.1.1.3 Define struct fields with proper types
- [ ] 3.1.1.4 Add typespec for agent state

### 3.1.2 Agent State Types
- [ ] **Task 3.1.2** Define type specifications for agent state.

- [ ] 3.1.2.1 Define `@type position_entry` for path memory:
  ```elixir
  @type position_entry :: {Position.t(), observation()}

  @type observation :: %{
    food_found: boolean(),
    food_level: 1..5 | nil,
    pheromone_sensed: map()
  }
  ```
- [ ] 3.1.2.2 Define `@type food_source_info` for known food:
  ```elixir
  @type food_source_info :: %{
    position: Position.t(),
    level: 1..5,
    last_updated: DateTime.t()
  }
  ```
- [ ] 3.1.2.3 Define `@type agent_state` for FSM states:
  ```elixir
  @type agent_state :: :at_nest | :searching | :returning_to_nest | :communicating
  ```
- [ ] 3.1.2.4 Add typespec for full agent struct

### 3.1.3 Agent Creation
- [ ] **Task 3.1.3** Implement ant agent creation functions.

- [ ] 3.1.3.1 Implement `new/1` accepting keyword options:
  ```elixir
  @spec new(keyword()) :: {:ok, __MODULE__.t()} | {:error, term()}
  def new(opts) do
    id = Keyword.get(opts, :id, generate_id())
    nest_position = Keyword.fetch!(opts, :nest_position)

    agent = %__MODULE__{
      id: id,
      position: nest_position,
      nest_position: nest_position,
      path_memory: [{nest_position, %{} }],
      current_state: :at_nest,
      energy: Keyword.get(opts, :energy, 100)
    }

    {:ok, agent}
  end
  ```
- [ ] 3.1.3.2 Implement `generate_id/0` for unique ant identifiers
- [ ] 3.1.3.3 Validate nest_position is valid position
- [ ] 3.1.3.4 Initialize path_memory with nest position
- [ ] 3.1.3.5 Write unit tests for agent creation

**Unit Tests for Section 3.1:**
- Test agent created with valid options
- Test agent has unique ID
- Test agent starts at nest_position
- Test agent starts in :at_nest state
- Test agent has empty path_memory except for nest
- Test agent has full energy by default
- Test agent has no food initially
- Test `new/1` validates required fields

---

## 3.2 FSM States Definition

Define the Finite State Machine that governs ant behavior transitions.

### 3.2.1 FSM Strategy Module
- [ ] **Task 3.2.1** Create the FSM execution strategy for ant behaviors.

- [ ] 3.2.1.1 Create `lib/jido_ants/agent/fsm_strategy.ex` with module documentation
- [ ] 3.2.1.2 Add `use Jido.Agent.FSM` strategy
- [ ] 3.2.1.3 Define state transition map:
  ```elixir
  @fsm %{
    at_nest: [:searching],
    searching: [:returning_to_nest, :communicating, :at_nest],
    returning_to_nest: [:at_nest, :communicating],
    communicating: [:searching, :returning_to_nest]
  }
  ```
- [ ] 3.2.1.4 Implement `allowed_transitions/1` returning valid next states
- [ ] 3.2.1.5 Implement `can_transition?/2` checking if transition is valid

### 3.2.2 State Behaviors
- [ ] **Task 3.2.2** Define behavior for each FSM state.

- [ ] 3.2.2.1 Define `:at_nest` state behavior:
  - Ant is at nest position
  - Can drop food if carrying
  - Can transition to :searching
  - Energy can be replenished
- [ ] 3.2.2.2 Define `:searching` state behavior:
  - Ant explores the plane
  - Can sense food and pheromones
  - Can transition to :returning_to_nest when food found
  - Can transition to :communicating when encountering other ant
- [ ] 3.2.2.3 Define `:returning_to_nest` state behavior:
  - Ant follows path_memory back to nest
  - Lays pheromone trail
  - Can transition to :communicating when encountering other ant
  - Transitions to :at_nest when nest reached
- [ ] 3.2.2.4 Define `:communicating` state behavior:
  - Ant exchanges information with nearby ant
  - Returns to previous state after communication
  - Updates known_food_sources based on exchange

### 3.2.3 State Transitions
- [ ] **Task 3.2.3** Implement state transition logic.

- [ ] 3.2.3.1 Implement `transition/2` for state changes:
  ```elixir
  @spec transition(__MODULE__.t(), agent_state()) :: {:ok, __MODULE__.t()} | {:error, term()}
  def transition(%__MODULE__{} = ant, new_state) do
    with true <- can_transition?(ant.current_state, new_state),
         {:ok, updated} <- on_exit_state(ant),
         {:ok, updated} <- on_enter_state(%{updated | current_state: new_state}) do
      {:ok, updated}
    end
  end
  ```
- [ ] 3.2.3.2 Implement `on_exit_state/1` handling state exit logic
- [ ] 3.2.3.3 Implement `on_enter_state/1` handling state entry logic
- [ ] 3.2.3.4 Log state transitions for debugging
- [ ] 3.2.3.5 Write unit tests for state transitions

**Unit Tests for Section 3.2:**
- Test `allowed_transitions/1` returns correct states for each state
- Test `can_transition?/2` validates allowed transitions
- Test `can_transition?/2` rejects invalid transitions
- Test `transition/2` successfully changes state
- Test `transition/2` fails for invalid transitions
- Test `on_exit_state/1` handles state-specific exit logic
- Test `on_enter_state/1` handles state-specific entry logic
- Test :at_nest → :searching transition
- Test :searching → :returning_to_nest transition
- Test :returning_to_nest → :at_nest transition

---

## 3.3 Agent State Management

Implement functions for managing and updating agent state.

### 3.3.1 Position Updates
- [ ] **Task 3.3.1** Implement position update functions.

- [ ] 3.3.1.1 Implement `move_to/2` updating agent position:
  ```elixir
  @spec move_to(__MODULE__.t(), Position.t()) :: {:ok, __MODULE__.t()} | {:error, term()}
  def move_to(%__MODULE__{} = ant, new_position) do
    entry = {new_position, %{food_found: false, food_level: nil, pheromone_sensed: %{}}}
    {:ok, %{ant | position: new_position, path_memory: ant.path_memory ++ [entry]}}
  end
  ```
- [ ] 3.3.1.2 Validate new position is within plane bounds (check with plane)
- [ ] 3.3.1.3 Append position to path_memory with observation
- [ ] 3.3.1.4 Implement `at_nest?/1` checking if ant at nest position
- [ ] 3.3.1.5 Write unit tests for position updates

### 3.3.2 Food State Management
- [ ] **Task 3.3.2** Implement food carrying state.

- [ ] 3.3.2.1 Implement `pick_up_food/2` when ant finds food:
  ```elixir
  @spec pick_up_food(__MODULE__.t(), 1..5) :: {:ok, __MODULE__.t()} | {:error, term()}
  def pick_up_food(%__MODULE__{has_food?: true} = _ant, _level), do: {:error, :already_carrying}
  def pick_up_food(%__MODULE__{} = ant, food_level) do
    {:ok, %{ant | has_food?: true, carried_food_level: food_level}}
  end
  ```
- [ ] 3.3.2.2 Implement `drop_food/1` when ant reaches nest:
  ```elixir
  @spec drop_food(__MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, term()}
  def drop_food(%__MODULE__{has_food?: false}), do: {:error, :not_carrying}
  def drop_food(%__MODULE__{} = ant) do
    {:ok, %{ant | has_food?: false, carried_food_level: nil}}
  end
  ```
- [ ] 3.3.2.3 Implement `carrying_food?/1` for checking food status
- [ ] 3.3.2.4 Write unit tests for food state management

### 3.3.3 Path Memory Management
- [ ] **Task 3.3.3** Implement path memory operations.

- [ ] 3.3.3.1 Implement `record_observation/3` adding observation to path_memory:
  ```elixir
  @spec record_observation(__MODULE__.t(), Position.t(), map()) :: __MODULE__.t()
  def record_observation(%__MODULE__{path_memory: memory} = ant, position, observation) do
    updated_memory = List.replace_at(memory, -1, {position, observation})
    %{ant | path_memory: updated_memory}
  end
  ```
- [ ] 3.3.3.2 Implement `clear_path_memory/1` for resetting after returning to nest
- [ ] 3.3.3.3 Implement `get_return_path/1` returning reversed path_memory
- [ ] 3.3.3.4 Implement `last_position/1` returning most recent position
- [ ] 3.3.3.5 Write unit tests for path memory operations

### 3.3.4 Known Food Sources
- [ ] **Task 3.3.4** Implement known food source tracking.

- [ ] 3.3.4.1 Implement `learn_food_source/3` adding food to knowledge:
  ```elixir
  @spec learn_food_source(__MODULE__.t(), Position.t(), 1..5) :: __MODULE__.t()
  def learn_food_source(%__MODULE__{} = ant, position, level) do
    info = %{position: position, level: level, last_updated: DateTime.utc_now()}
    %{ant | known_food_sources: [info | ant.known_food_sources]}
  end
  ```
- [ ] 3.3.4.2 Implement `update_food_source/3` updating existing knowledge
- [ ] 3.3.4.3 Implement `forget_food_source/2` removing stale information
- [ ] 3.3.4.4 Implement `best_known_food_source/1` returning highest quality known source
- [ ] 3.3.4.5 Write unit tests for food source knowledge

### 3.3.5 Energy Management
- [ ] **Task 3.3.5** Implement energy system for ant lifecycle.

- [ ] 3.3.5.1 Implement `consume_energy/2` reducing energy on actions:
  ```elixir
  @spec consume_energy(__MODULE__.t(), pos_integer()) :: {:ok, __MODULE__.t()} | {:error, :exhausted}
  def consume_energy(%__MODULE__{energy: energy} = ant, amount) when energy > amount do
    {:ok, %{ant | energy: energy - amount}}
  end
  def consume_energy(_, _), do: {:error, :exhausted}
  ```
- [ ] 3.3.5.2 Implement `replenish_energy/1` restoring energy at nest
- [ ] 3.3.5.3 Implement `energy_level/1` returning current energy
- [ ] 3.3.5.4 Implement `alive?/1` checking if ant has energy
- [ ] 3.3.5.5 Write unit tests for energy management

**Unit Tests for Section 3.3:**
- Test `move_to/2` updates position and path_memory
- Test `move_to/2` validates position bounds
- Test `at_nest?/1` returns true when at nest position
- Test `pick_up_food/2` sets has_food? to true
- Test `pick_up_food/2` fails if already carrying
- Test `drop_food/1` resets food carrying state
- Test `drop_food/1` fails if not carrying
- Test `record_observation/3` updates path_memory
- Test `clear_path_memory/1` resets path_memory
- Test `get_return_path/1` returns reversed path
- Test `learn_food_source/3` adds to known sources
- Test `best_known_food_source/1` returns highest quality
- Test `consume_energy/2` reduces energy
- Test `consume_energy/2` returns :exhausted when depleted
- Test `replenish_energy/1` restores full energy

---

## 3.4 Agent Lifecycle

Implement agent startup, supervision, and execution within Jido framework.

### 3.4.1 AgentServer Integration
- [ ] **Task 3.4.1** Integrate AntAgent with Jido.AgentServer.

- [ ] 3.4.1.1 Implement `start_link/1` for starting ant agent:
  ```elixir
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    {agent_opts, server_opts} = Keyword.split(opts, [:id, :nest_position, :energy])
    Jido.AgentServer.start_link(__MODULE__, agent_opts, server_opts)
  end
  ```
- [ ] 3.4.1.2 Implement `child_spec/1` for supervisor integration
- [ ] 3.4.1.3 Handle agent initialization with Jido framework
- [ ] 3.4.1.4 Set up FSM strategy execution
- [ ] 3.4.1.5 Write unit tests for agent startup

### 3.4.2 Agent Supervisor
- [ ] **Task 3.4.2** Create supervisor for ant agents.

- [ ] 3.4.2.1 Create `lib/jido_ants/agent/supervisor.ex` with module documentation
- [ ] 3.4.2.2 Add `use DynamicSupervisor`
- [ ] 3.4.2.3 Implement `start_link/1`:
  ```elixir
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  ```
- [ ] 3.4.2.4 Implement `init/1` with `:one_for_one` strategy
- [ ] 3.4.2.5 Implement `start_ant/1` for starting individual ant:
  ```elixir
  def start_ant(opts) do
    DynamicSupervisor.start_child(__MODULE__, {JidoAnts.Agent.Ant, opts})
  end
  ```
- [ ] 3.4.2.6 Implement `stop_ant/1` for stopping ant by ID
- [ ] 3.4.2.7 Write unit tests for supervisor

### 3.4.3 Agent Commands
- [ ] **Task 3.4.3** Implement command interface for ant agents.

- [ ] 3.4.3.1 Implement `command/2` for sending commands via Jido:
  ```elixir
  @spec command(pid(), Jido.Action.t()) :: {:ok, __MODULE__.t(), [Jido.Directive.t()]} | {:error, term()}
  def command(ant_pid, action) do
    Jido.AgentServer.command(ant_pid, action)
  end
  ```
- [ ] 3.4.3.2 Implement `get_state/1` for querying agent state
- [ ] 3.4.3.3 Implement `get_position/1` for getting ant position
- [ ] 3.4.3.4 Implement `get_current_state/1` for getting FSM state
- [ ] 3.4.3.5 Write unit tests for command interface

**Unit Tests for Section 3.4:**
- Test agent starts via AgentServer
- Test agent initializes with correct state
- Test agent has FSM strategy configured
- Test DynamicSupervisor manages multiple ants
- Test `start_ant/1` creates new ant process
- Test `stop_ant/1` terminates ant process
- Test `command/2` executes actions on agent
- Test `get_state/1` returns current agent state
- Test `get_position/1` returns ant position
- Test `get_current_state/1` returns FSM state

---

## 3.5 Phase 3 Integration Tests

Comprehensive integration tests verifying all Phase 3 components work together correctly.

### 3.5.1 Agent Lifecycle Integration
- [ ] **Task 3.5.1** Test complete ant agent lifecycle.

- [ ] 3.5.1.1 Create `test/jido_ants/integration/agent_phase3_test.exs`
- [ ] 3.5.1.2 Test: Start agent → verify initial state → transition to searching → verify state change
- [ ] 3.5.1.3 Test: Agent at nest → pick up food (simulate) → transition to returning → drop food → back to nest
- [ ] 3.5.1.4 Test: Agent moves → position updates → path_memory grows
- [ ] 3.5.1.5 Test: Agent consumes energy → eventually exhausted → agent stops
- [ ] 3.5.1.6 Write all lifecycle integration tests

### 3.5.2 State Machine Integration
- [ ] **Task 3.5.2** Test FSM state transitions end-to-end.

- [ ] 3.5.2.1 Test: Full cycle - at_nest → searching → returning_to_nest → at_nest
- [ ] 3.5.2.2 Test: searching → communicating → searching
- [ ] 3.5.2.3 Test: returning_to_nest → communicating → returning_to_nest
- [ ] 3.5.2.4 Test: Invalid transition rejected with error
- [ ] 3.5.2.5 Write all FSM integration tests

### 3.5.3 Multi-Agent Integration
- [ ] **Task 3.5.3** Test multiple agents running simultaneously.

- [ ] 3.5.3.1 Test: Start 10 agents → verify all have unique IDs
- [ ] 3.5.3.2 Test: Each agent maintains independent state
- [ ] 3.5.3.3 Test: Agent crash → supervisor restarts with fresh state
- [ ] 3.5.3.4 Test: Stop supervisor → all agents terminate
- [ ] 3.5.3.5 Write all multi-agent integration tests

**Integration Tests for Section 3.5:**
- Agent lifecycle works end-to-end
- FSM transitions execute correctly
- Multiple agents operate independently
- Supervisor manages agent failures

---

## Success Criteria

1. **AntAgent Struct**: Complete agent schema with all required fields
2. **FSM States**: Four behavioral states with valid transitions
3. **State Management**: Position, food, path memory, energy all manageable
4. **AgentServer**: Ant agents run under Jido.AgentServer
5. **Supervisor**: DynamicSupervisor manages multiple ant processes
6. **Command Interface**: Actions can be executed via Jido framework
7. **Energy System**: Ants consume energy and can replenish
8. **Test Coverage**: Minimum 80% coverage for phase 3 code
9. **Integration Tests**: All Phase 3 components work together (Section 3.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/agent/ant.ex`
- `lib/jido_ants/agent/fsm_strategy.ex`
- `lib/jido_ants/agent/supervisor.ex`
- `test/jido_ants/agent/ant_test.exs`
- `test/jido_ants/agent/fsm_strategy_test.exs`
- `test/jido_ants/agent/supervisor_test.exs`
- `test/jido_ants/integration/agent_phase3_test.exs`

**Modified Files:**
- `mix.exs` - Add Jido v2 dependency if not already present

---

## Dependencies

- **Depends on Phase 1**: Position types, core data structures
- **Depends on Phase 2**: PlaneServer for environment interaction
- **Phase 4 depends on this**: Actions need AntAgent struct
- **Phase 7 depends on this**: Communication between agents
