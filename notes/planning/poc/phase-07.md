# Phase 7: Ant Communication

This phase implements direct ant-to-ant communication when ants encounter each other within proximity. Ants exchange information about known food sources, with higher quality sources overwriting lower quality information in both ants' memories.

---

## 7.1 Proximity Detection

Implement the system that detects when ants are within communication range.

### 7.1.1 ProximityDetector Module
- [ ] **Task 7.1.1** Create the ProximityDetector service.

- [ ] 7.1.1.1 Create `lib/jido_ants/plane/proximity_detector.ex` with module documentation
- [ ] 7.1.1.2 Add `use GenServer`
- [ ] 7.1.1.3 Define `@communication_radius 3` (units)
- [ ] 7.1.1.4 Define state structure:
  ```elixir
  @type state :: %{
    plane_server: pid(),
    ant_positions: %{ant_id() => Position.t()},
    detection_interval: pos_integer()
  }
  ```
- [ ] 7.1.1.5 Implement `start_link/1` with options

### 7.1.2 Position Tracking
- [ ] **Task 7.1.2** Track ant positions for proximity detection.

- [ ] 7.1.2.1 Implement `register_ant/2` for position updates:
  ```elixir
  def register_ant(detector \\ __MODULE__, ant_id, position) do
    GenServer.call(detector, {:register_ant, ant_id, position})
  end
  ```
- [ ] 7.1.2.2 Implement `handle_call({:register_ant, id, pos}, _, state)`
- [ ] 7.1.2.3 Store position in ant_positions map
- [ ] 7.1.2.4 Trigger proximity check on position update
- [ ] 7.1.2.5 Implement `unregister_ant/2` for removing ants
- [ ] 7.1.2.6 Write unit tests for position tracking

### 7.1.3 Proximity Checking
- [ ] **Task 7.1.3** Implement proximity detection logic.

- [ ] 7.1.3.1 Implement `check_proximity/1` finding nearby ants:
  ```elixir
  defp check_proximity(%{ant_positions: positions} = state) do
    positions
    |> Enum.flat_map(fn {ant_id, pos} ->
      find_nearby_ants(ant_id, pos, positions)
    end)
    |> Enum.each(fn {ant1, ant2} ->
      notify_encounter(ant1, ant2)
    end)
  end
  ```
- [ ] 7.1.3.2 Implement `find_nearby_ants/3` for single ant:
  ```elixir
  defp find_nearby_ants(ant_id, position, all_positions) do
    all_positions
    |> Enum.filter(fn {other_id, _} -> other_id != ant_id end)
    |> Enum.filter(fn {_other_id, other_pos} ->
      Position.distance(position, other_pos) <= @communication_radius
    end)
    |> Enum.map(fn {other_id, _} -> {ant_id, other_id} end)
  end
  ```
- [ ] 7.1.3.3 Use `Position.distance/2` for Euclidean distance
- [ ] 7.1.3.4 Avoid duplicate notifications (A-B and B-A)
- [ ] 7.1.3.5 Write unit tests for proximity checking

### 7.1.4 Encounter Notifications
- [ ] **Task 7.1.4** Send encounter notifications to ants.

- [ ] 7.1.4.1 Implement `notify_encounter/3` sending signal to both ants:
  ```elixir
  defp notify_encounter(ant1_id, ant2_id) do
    # Get ant pids from registry
    # Send encounter signal to both ants
    signal = %Jido.Signal{
      type: "ant_encounter",
      data: %{encountered_ant_id: ant2_id}
    }
    # Emit to both ants
  end
  ```
- [ ] 7.1.4.2 Look up ant PIDs from Agent.Supervisor
- [ ] 7.1.4.3 Send `Jido.Signal` to each ant
- [ ] 7.1.4.4 Include both ant IDs in notification
- [ ] 7.1.4.5 Handle cases where ant processes are dead
- [ ] 7.1.4.6 Write unit tests for encounter notifications

**Unit Tests for Section 7.1:**
- Test ProximityDetector starts with correct state
- Test `register_ant/2` stores ant position
- Test `unregister_ant/2` removes ant
- Test `check_proximity/1` detects ants within radius
- Test `check_proximity/1` ignores ants outside radius
- Test `find_nearby_ants/3` returns correct nearby ants
- Test `notify_encounter/3` sends signals to both ants
- Test proximity checks triggered on position updates

---

## 7.2 CommunicateAction

Implement the action that handles information exchange between ants.

### 7.2.1 CommunicateAction Module Structure
- [ ] **Task 7.2.1** Create the CommunicateAction module.

- [ ] 7.2.1.1 Create `lib/jido_ants/actions/communicate.ex` with module documentation
- [ ] 7.2.1.2 Add `use Jido.Action` with schema:
  ```elixir
  use Jido.Action,
    schema: [
      with_ant_id: [type: :string, required: true],
      share_info: [type: :map, default: nil]  # nil means share all known
    ]
  ```
- [ ] 7.2.1.3 Define `@descript "Exchange food source information with nearby ant"`
- [ ] 7.2.1.4 Implement `run/2` callback

### 7.2.2 Information Sharing
- [ ] **Task 7.2.2** Implement information exchange logic.

- [ ] 7.2.2.1 Get agent's known_food_sources from context
- [ ] 7.2.2.2 Get with_ant_id parameter
- [ ] 7.2.2.3 Query other ant for their known_food_sources
- [ ] 7.2.2.4 Use Jido.Signal for inter-agent communication:
  ```elixir
  request_signal = %Jido.Signal{
    type: "share_food_info",
    data: %{
      from_ant_id: agent.id,
      known_food_sources: agent.known_food_sources
    },
    reply_to: self()
  }
  ```
- [ ] 7.2.2.5 Handle response from other ant
- [ ] 7.2.2.6 Write unit tests for information sharing

### 7.2.3 Information Comparison
- [ ] **Task 7.2.3** Implement comparison and merging of food information.

- [ ] 7.2.3.1 Implement `merge_food_sources/2`:
  ```elixir
  @spec merge_food_sources([food_source_info()], [food_source_info()]) :: [food_source_info()]
  def merge_food_sources(my_sources, their_sources) do
    all_sources = my_sources ++ their_sources

    all_sources
    |> Enum.group_by(fn source -> source.position end)
    |> Enum.map(fn {_pos, sources} ->
      Enum.max_by(sources, fn source -> source.level end)
    end)
  end
  ```
- [ ] 7.2.3.2 Group by position (same location, possibly different quality)
- [ ] 7.2.3.3 Keep highest quality source for each position
- [ ] 7.2.3.4 Remove stale sources (old timestamps)
- [ ] 7.2.3.5 Return merged list
- [ ] 7.2.3.6 Write unit tests for merge logic

### 7.2.4 Knowledge Update
- [ ] **Task 7.2.4** Update agent knowledge after communication.

- [ ] 7.2.4.1 Merge received sources with agent's known sources
- [ ] 7.2.4.2 Update agent's known_food_sources
- [ ] 7.2.4.3 Update timestamps for refreshed sources
- [ ] 7.2.4.4 Log information gained from communication
- [ ] 7.2.4.5 Emit telemetry event for communication
- [ ] 7.2.4.6 Return `{:ok, updated_agent, directives}`
- [ ] 7.2.4.7 Include directive to return to previous state
- [ ] 7.2.4.8 Write unit tests for knowledge update

**Unit Tests for Section 7.2:**
- Test CommunicateAction requires with_ant_id parameter
- Test CommunicateAction shares known_food_sources
- Test CommunicateAction requests info from other ant
- Test `merge_food_sources/2` keeps highest quality per position
- Test `merge_food_sources/2` removes stale sources
- Test CommunicateAction updates agent's known_food_sources
- Test CommunicateAction emits return to previous state directive

---

## 7.3 Direct Ant-to-Ant Signaling

Implement the signaling infrastructure for ant communication.

### 7.3.1 Signal Types
- [ ] **Task 7.3.1** Define signal types for ant communication.

- [ ] 7.3.1.1 Define `"ant_encounter"` signal for proximity notification
- [ ] 7.3.1.2 Define `"share_food_info"` signal for information exchange
- [ ] 7.3.1.3 Define `"share_food_info_reply"` signal for response
- [ ] 7.3.1.4 Create signal module `lib/jido_ants/signals.ex`
- [ ] 7.3.1.5 Implement signal constructors for each type
- [ ] 7.3.1.6 Write unit tests for signal constructors

### 7.3.2 Signal Handling
- [ ] **Task 7.3.2** Implement signal handling in AntAgent.

- [ ] 7.3.2.1 Add `handle_signal/2` callback to AntAgent
- [ ] 7.3.2.2 Handle `"ant_encounter"` signal:
  ```elixir
  defp handle_signal(%Jido.Signal{type: "ant_encounter"} = signal, agent) do
    # Transition to :communicating state
    # Execute CommunicateAction with encountered ant
  end
  ```
- [ ] 7.3.2.3 Handle `"share_food_info"` signal with reply
- [ ] 7.3.2.4 Handle `"share_food_info_reply"` signal
- [ ] 7.3.2.5 Update agent state based on received info
- [ ] 7.3.2.6 Write unit tests for signal handling

### 7.3.3 Communication State Management
- [ ] **Task 7.3.3** Manage :communicating FSM state.

- [ ] 7.3.3.1 Define `:communicating` state behavior
- [ ] 7.3.3.2 Ant pauses movement during communication
- [ ] 7.3.3.3 Ant returns to previous state after communication
- [ ] 7.3.3.4 Handle communication timeout (don't get stuck)
- [ ] 7.3.3.5 Implement `on_enter_state(:communicating)` handler
- [ ] 7.3.3.6 Implement `on_exit_state(:communicating)` handler
- [ ] 7.3.3.7 Write unit tests for communication state

**Unit Tests for Section 7.3:**
- Test signal constructors create valid signals
- Test `"ant_encounter"` signal triggers communication
- Test `"share_food_info"` signal handled correctly
- Test `"share_food_info_reply"` signal processed
- Test `:communicating` state pauses movement
- Test ant returns to previous state after communication
- Test communication timeout prevents stuck ants

---

## 7.4 Food Source Information Exchange

Implement the complete information exchange protocol.

### 7.4.1 Exchange Protocol
- [ ] **Task 7.4.1** Define the information exchange protocol.

- [ ] 7.4.1.1 Implement `initiate_exchange/2` starting communication:
  ```elixir
  @spec initiate_exchange(Agent.t(), String.t()) :: {:ok, Agent.t(), [Jido.Directive.t()]}
  def initiate_exchange(agent, other_ant_id) do
    signal = Signals.share_food_info_request(agent.id, agent.known_food_sources)
    # Send signal to other ant
    # Wait for response
    # Merge response with own knowledge
  end
  ```
- [ ] 7.4.1.2 Implement `respond_to_exchange/2` handling incoming request
- [ ] 7.4.1.3 Implement `complete_exchange/2` processing response
- [ ] 7.4.1.4 Handle timeouts for unresponsive ants
- [ ] 7.4.1.5 Write unit tests for exchange protocol

### 7.4.2 Information Quality Rules
- [ ] **Task 7.4.2** Implement quality-based information acceptance.

- [ ] 7.4.2.1 Higher quality source replaces lower quality at same position
- [ ] 7.4.2.2 New source positions always added (up to memory limit)
- [ ] 7.4.2.3 Stale sources (older than threshold) removed
- [ ] 7.4.2.4 Sources beyond simulation bounds rejected
- [ ] 7.4.2.5 Implement `should_accept_source?/2` for quality check
- [ ] 7.4.2.6 Write unit tests for quality rules

### 7.4.3 Social Skill
- [ ] **Task 7.4.3** Create SocialSkill grouping communication actions.

- [ ] 7.4.3.1 Create `lib/jido_ants/skills/social.ex`
- [ ] 7.4.3.2 Add `use Jido.Skill`
- [ ] 7.4.3.3 Include CommunicateAction
- [ ] 7.4.3.4 Add signal handlers for communication
- [ ] 7.4.3.5 Define skill-specific state (encounters count, info gained)
- [ ] 7.4.3.6 Implement `mount/1` and `unmount/1`
- [ ] 7.4.3.7 Write unit tests for SocialSkill

**Unit Tests for Section 7.4:**
- Test `initiate_exchange/2` starts communication
- Test `respond_to_exchange/2` replies with own info
- Test `complete_exchange/2` merges information
- Test `should_accept_source?/2` enforces quality rules
- Test higher quality replaces lower quality
- Test stale sources filtered out
- Test SocialSkill includes communication actions
- Test SocialSkill tracks communication metrics

---

## 7.5 Phase 7 Integration Tests

Comprehensive integration tests verifying all Phase 7 components work together correctly.

### 7.5.1 Proximity Detection Integration
- [ ] **Task 7.5.1** Test proximity detection with multiple ants.

- [ ] 7.5.1.1 Create `test/jido_ants/integration/communication_phase7_test.exs`
- [ ] 7.5.1.2 Test: Two ants move within 3 units → encounter detected
- [ ] 7.5.1.3 Test: Ants at 4 units distance → no encounter
- [ ] 7.5.1.4 Test: Multiple ants in proximity → all pairs detected
- [ ] 7.5.1.5 Test: Ant leaves proximity → detection ends
- [ ] 7.5.1.6 Write all proximity integration tests

### 7.5.2 Information Exchange Integration
- [ ] **Task 7.5.2** Test complete information exchange.

- [ ] 7.5.2.1 Test: Ant A knows high-quality source, Ant B knows low-quality
- [ ] 7.5.2.2 Test: After communication, both know high-quality source
- [ ] 7.5.2.3 Test: Ant A knows position X, Ant B knows position Y
- [ ] 7.5.2.4 Test: After communication, both know both positions
- [ ] 7.5.2.5 Test: Conflicting information → higher quality wins
- [ ] 7.5.2.6 Write all exchange integration tests

### 7.5.3 Colony Information Diffusion Integration
- [ ] **Task 7.5.3** Test information spread through colony.

- [ ] 7.5.3.1 Test: One ant discovers food → communicates with nearby ant
- [ ] 7.5.3.2 Test: Information propagates through chain of encounters
- [ ] 7.5.3.3 Test: Eventually all ants know about high-quality source
- [ ] 7.5.3.4 Test: Low-quality source information doesn't override high-quality
- [ ] 7.5.3.5 Test: Stale information filtered out over time
- [ ] 7.5.3.6 Write all diffusion integration tests

**Integration Tests for Section 7.5:**
- Proximity detection works with moving ants
- Information exchange completes successfully
- Colony learns about food sources through communication
- Quality-based information sharing enforced
- Information propagates through ant population

---

## Success Criteria

1. **Proximity Detection**: Ants within 3 units detect each other
2. **Encounter Signals**: Ants notified of nearby ants
3. **CommunicateAction**: Ants exchange food source information
4. **Information Merging**: Higher quality sources override lower quality
5. **Signal Handling**: Agents respond to communication signals
6. **Communication State**: FSM manages :communicating state
7. **Quality Rules**: Information acceptance follows quality rules
8. **Social Skill**: Communication actions grouped in skill
9. **Information Diffusion**: Knowledge spreads through colony
10. **Test Coverage**: Minimum 80% coverage for phase 7 code
11. **Integration Tests**: All Phase 7 components work together (Section 7.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/plane/proximity_detector.ex`
- `lib/jido_ants/actions/communicate.ex`
- `lib/jido_ants/signals.ex`
- `lib/jido_ants/skills/social.ex`
- `lib/jido_ants/communication/exchange_protocol.ex`
- `test/jido_ants/plane/proximity_detector_test.exs`
- `test/jido_ants/actions/communicate_test.exs`
- `test/jido_ants/signals_test.exs`
- `test/jido_ants/skills/social_test.exs`
- `test/jido_ants/communication/exchange_protocol_test.exs`
- `test/jido_ants/integration/communication_phase7_test.exs`

**Modified Files:**
- `lib/jido_ants/agent/ant.ex` - Add signal handling
- `lib/jido_ants/agent/fsm_strategy.ex` - Add :communicating state
- `lib/jido_ants/plane_server.ex` - Add proximity detector integration

---

## Dependencies

- **Depends on Phase 1**: Position for distance calculation
- **Depends on Phase 2**: PlaneServer for position tracking
- **Depends on Phase 3**: AntAgent for communication participants
- **Depends on Phase 5**: Foraging provides food source information
- **Phase 8 depends on this**: ML can optimize communication strategies
