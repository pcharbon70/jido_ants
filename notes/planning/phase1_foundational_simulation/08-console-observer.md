# Phase 1.8: Console Observer

Create a console-based observer for initial testing and debugging of the simulation. This provides immediate visual feedback before building the terminal UI.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AntColony.Observer                                │
│                       (GenServer)                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  State:                                                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • total_moves: integer()      - Move events received      │    │
│  │  • food_findings: integer()    - Food sensed events        │    │
│  │  • ant_count: integer()        - Current ant count         │    │
│  │  • last_event_time: DateTime   - Timestamp of last event   │    │
│  │  • verbose: boolean()          - Enable detailed output    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Subscriptions:                                                     │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Phoenix.PubSub topic: "simulation"                      │    │
│  │  • Events received:                                        │    │
│  │    - {:ant_moved, ant_id, old_pos, new_pos}                │    │
│  │    - {:food_sensed, ant_id, position, food_details}        │    │
│  │    - {:ant_registered, ant_id, position}                   │    │
│  │    - {:ant_unregistered, ant_id}                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Output:                                                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Real-time event logging to console                       │    │
│  │  • Periodic statistics summary                             │    │
│  │  • Color-coded output (optional)                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.Observer | Console-based event subscriber and logger |
| Observer.State | Observer state with statistics tracking |
| AntColony.Events | PubSub events to subscribe to |

---

## 1.8.1 Create Observer Module

Create the Observer GenServer module.

### 1.8.1.1 Create Observer Module File

Create the observer module file.

- [ ] 1.8.1.1.1 Create `lib/ant_colony/observer.ex`
- [ ] 1.8.1.1.2 Add `defmodule AntColony.Observer`
- [ ] 1.8.1.1.3 Add `use GenServer`
- [ ] 1.8.1.1.4 Add `require Logger` for logging
- [ ] 1.8.1.1.5 Add comprehensive `@moduledoc`

### 1.8.1.2 Define State Struct

Define the observer's state structure.

- [ ] 1.8.1.2.1 Add `defstruct` with fields:
  - `:total_moves` - default 0
  - `:food_findings` - default 0
  - `:ant_count` - default 0
  - `:last_event_time` - default nil
  - `:verbose` - default false
  - `:subscription_ref` - default nil
- [ ] 1.8.1.2.2 Add type specifications for each field

### 1.8.1.3 Implement init/1 Callback

Initialize the observer with PubSub subscription.

- [ ] 1.8.1.3.1 Define `init(opts)` function
- [ ] 1.8.1.3.2 Extract `verbose` option from opts
- [ ] 1.8.1.3.3 Subscribe to "simulation" topic via Phoenix.PubSub
- [ ] 1.8.1.3.4 Store subscription ref in state
- [ ] 1.8.1.3.5 Return `{:ok, %__MODULE__{...}}`

---

## 1.8.2 Implement Event Handlers

Implement handlers for each event type.

### 1.8.2.1 Handle ant_moved Events

Log and track ant movement events.

- [ ] 1.8.2.1.1 Add `handle_info({:ant_moved, ant_id, old_pos, new_pos}, state)` clause
- [ ] 1.8.2.1.2 Increment `total_moves` counter
- [ ] 1.8.2.1.3 Update `last_event_time` to `DateTime.utc_now()`
- [ ] 1.8.2.1.4 Format and print movement message:
  - `"Ant #{ant_id} moved from #{inspect(old_pos)} to #{inspect(new_pos)}"`
- [ ] 1.8.2.1.5 Return `{:noreply, updated_state}`

### 1.8.2.2 Handle food_sensed Events

Log and track food discovery events.

- [ ] 1.8.2.2.1 Add `handle_info({:food_sensed, ant_id, position, food_details}, state)` clause
- [ ] 1.8.2.2.2 Increment `food_findings` counter
- [ ] 1.8.2.2.3 Update `last_event_time`
- [ ] 1.8.2.2.4 Format and print food discovery message:
  - `"Ant #{ant_id} found food at #{inspect(position)} (level: #{food_details.level})"`
- [ ] 1.8.2.2.5 Return `{:noreply, updated_state}`

### 1.8.2.3 Handle ant_registered Events

Log and track new ant registrations.

- [ ] 1.8.2.3.1 Add `handle_info({:ant_registered, ant_id, position}, state)` clause
- [ ] 1.8.2.3.2 Increment `ant_count` counter
- [ ] 1.8.2.3.3 Update `last_event_time`
- [ ] 1.8.2.3.4 Format and print registration message:
  - `"Ant #{ant_id} registered at #{inspect(position)}"`
- [ ] 1.8.2.3.5 Return `{:noreply, updated_state}`

### 1.8.2.4 Handle ant_unregistered Events

Log and track ant unregistrations.

- [ ] 1.8.2.4.1 Add `handle_info({:ant_unregistered, ant_id}, state)` clause
- [ ] 1.8.2.4.2 Decrement `ant_count` counter
- [ ] 1.8.2.4.3 Update `last_event_time`
- [ ] 1.8.2.4.4 Format and print unregistration message:
  - `"Ant #{ant_id} unregistered"`
- [ ] 1.8.2.4.5 Return `{:noreply, updated_state}`

### 1.8.2.5 Handle Unknown Events

Handle unexpected messages gracefully.

- [ ] 1.8.2.5.1 Add catch-all `handle_info(msg, state)` clause
- [ ] 1.8.2.5.2 Log unknown message with Logger.debug
- [ ] 1.8.2.5.3 Return `{:noreply, state}` unchanged

---

## 1.8.3 Add Statistics Tracking

Track and report simulation statistics.

### 1.8.3.1 Implement get_stats/0

Client function to retrieve current statistics.

- [ ] 1.8.3.1.1 Define `def get_stats()`
- [ ] 1.8.3.1.2 Call `GenServer.call(__MODULE__, :get_stats)`
- [ ] 1.8.3.1.3 Return stats map with all counters

### 1.8.3.2 Implement handle_call :get_stats

Handle stats request.

- [ ] 1.8.3.2.1 Add `handle_call(:get_stats, _from, state)` clause
- [ ] 1.8.3.2.2 Build stats map from state fields
- [ ] 1.8.3.2.3 Return `{:reply, stats_map, state}`

### 1.8.3.3 Implement print_stats/0

Client function to print statistics to console.

- [ ] 1.8.3.3.1 Define `def print_stats()`
- [ ] 1.8.3.3.2 Call `GenServer.call(__MODULE__, :print_stats)`
- [ ] 1.8.3.3.3 Return `:ok`

### 1.8.3.4 Implement handle_call :print_stats

Handle print stats request.

- [ ] 1.8.3.4.1 Add `handle_call(:print_stats, _from, state)` clause
- [ ] 1.8.3.4.2 Format statistics output:
  ```
  === Simulation Statistics ===
  Active Ants: #{ant_count}
  Total Moves: #{total_moves}
  Food Findings: #{food_findings}
  Last Event: #{last_event_time}
  ```
- [ ] 1.8.3.4.3 Print to console with IO.puts
- [ ] 1.8.3.4.4 Return `{:reply, :ok, state}`

### 1.8.3.5 Implement Periodic Stats Printing

Optionally print stats at intervals.

- [ ] 1.8.3.5.1 Add `:print_interval` option to init
- [ ] 1.8.3.5.2 Use `Process.send_after(self(), :print_stats, interval)` in init
- [ ] 1.8.3.5.3 Add `handle_info(:print_stats, state)` clause
- [ ] 1.8.3.5.4 Call print_stats and reschedule next print

---

## 1.8.4 Add Start/Stop Functions

Create helper functions for observer lifecycle.

### 1.8.4.1 Implement start_link/1

Start the observer GenServer.

- [ ] 1.8.4.1.1 Define `def start_link(opts \\ [])`
- [ ] 1.8.4.1.2 Call `GenServer.start_link(__MODULE__, opts, name: __MODULE__)`
- [ ] 1.8.4.1.3 Return `{:ok, pid}` or `{:error, reason}`

### 1.8.4.2 Implement stop/0

Stop the observer GenServer.

- [ ] 1.8.4.2.1 Define `def stop()`
- [ ] 1.8.4.2.2 Call `GenServer.stop(__MODULE__)`
- [ ] 1.8.4.2.3 Return `:ok`

### 1.8.4.3 Set Verbose Mode

Add function to enable/disable verbose output.

- [ ] 1.8.4.3.1 Define `def set_verbose(verbose)`
- [ ] 1.8.4.3.2 Call `GenServer.call(__MODULE__, {:set_verbose, verbose})`
- [ ] 1.8.4.3.3 Add `handle_call({:set_verbose, verbose}, _from, state)` clause
- [ ] 1.8.4.3.4 Return `{:reply, :ok, %{state | verbose: verbose}}`

### 1.8.4.4 Reset Statistics

Add function to reset all counters.

- [ ] 1.8.4.4.1 Define `def reset_stats()`
- [ ] 1.8.4.4.2 Call `GenServer.call(__MODULE__, :reset_stats)`
- [ ] 1.8.4.4.3 Add `handle_call(:reset_stats, _from, state)` clause
- [ ] 1.8.4.4.4 Return `{:reply, :ok, %{state | total_moves: 0, food_findings: 0, ...}}`

---

## 1.8.5 Unit Tests for Observer

Test the Observer functionality.

### 1.8.5.1 Test Observer Starts

Verify the observer GenServer starts correctly.

- [ ] 1.8.5.1.1 Create `test/ant_colony/observer_test.exs`
- [ ] 1.8.5.1.2 Add setup starting PubSub
- [ ] 1.8.5.1.3 Add test: `test "observer starts with default options"` - start
- [ ] 1.8.5.1.4 Add test: `test "observer starts with verbose option"` - verbose
- [ ] 1.8.5.1.5 Add test: `test "observer subscribes to simulation topic"` - subscription

### 1.8.5.2 Test Event Handlers

Verify each event type is handled correctly.

- [ ] 1.8.5.2.1 Add test: `test "ant_moved event increments total_moves"` - counter
- [ ] 1.8.5.2.2 Add test: `test "food_sensed event increments food_findings"` - counter
- [ ] 1.8.5.2.3 Add test: `test "ant_registered event increments ant_count"` - counter
- [ ] 1.8.5.2.4 Add test: `test "ant_unregistered event decrements ant_count"` - counter

### 1.8.5.3 Test Statistics

Verify statistics are tracked correctly.

- [ ] 1.8.5.3.1 Add test: `test "get_stats returns current statistics"` - stats map
- [ ] 1.8.5.3.2 Add test: `test "reset_stats clears all counters"` - reset
- [ ] 1.8.5.3.3 Add test: `test "print_stats outputs to console"` - output capture
- [ ] 1.8.5.3.4 Add test: `test "last_event_time is updated"` - timestamp

### 1.8.5.4 Test Verbose Mode

Verify verbose mode works correctly.

- [ ] 1.8.5.4.1 Add test: `test "set_verbose enables verbose mode"` - set true
- [ ] 1.8.5.4.2 Add test: `test "set_verbose disables verbose mode"` - set false
- [ ] 1.8.5.4.3 Add test: `test "verbose option persists in state"` - check state

---

## 1.8.6 Integration Tests

Test the Observer with real simulation components.

### 1.8.6.1 Observer with Plane Test

Test Observer observing Plane events.

- [ ] 1.8.6.1.1 Create `test/ant_colony/integration/observer_integration_test.exs`
- [ ] 1.8.6.1.2 Add setup starting Application and Observer
- [ ] 1.8.6.1.3 Add test: `test "observer receives ant_moved events"` - move
- [ ] 1.8.6.1.4 Add test: `test "observer tracks move count correctly"` - counter
- [ ] 1.8.6.1.5 Add test: `test "observer output is readable"` - format check

### 1.8.6.2 Observer with Agents Test

Test Observer observing agent events.

- [ ] 1.8.6.2.1 Add test: `test "observer receives ant_registered events"` - spawn
- [ ] 1.8.6.2.2 Add test: `test "observer tracks ant count correctly"` - count
- [ ] 1.8.6.2.3 Add test: `test "observer receives ant_unregistered events"` - stop
- [ ] 1.8.6.2.4 Add test: `test "observer handles multiple agents"` - multi-agent

### 1.8.6.3 Output Capture Test

Test that console output is correct.

- [ ] 1.8.6.3.1 Add test: `test "observer prints move events to console"` - capture IO
- [ ] 1.8.6.3.2 Add test: `test "observer prints food events to console"` - capture IO
- [ ] 1.8.6.3.3 Add test: `test "observer includes ant_id in output"` - format
- [ ] 1.8.6.3.4 Add test: `test "observer includes position in output"` - format

---

## 1.8.7 Phase 1.8 Integration Tests

End-to-end tests with complete simulation.

### 1.8.7.1 Complete Simulation Test

Test observer with full simulation running.

- [ ] 1.8.7.1.1 Add test: `test "observer survives full simulation lifecycle"` - start/stop
- [ ] 1.8.7.1.2 Add test: `test "observer tracks all simulation events"` - completeness
- [ ] 1.8.7.1.3 Add test: `test "observer stats match actual events"` - accuracy
- [ ] 1.8.7.1.4 Add test: `test "observer doesn't crash simulation"` - isolation

### 1.8.7.2 Statistics Summary Test

Test periodic and on-demand statistics.

- [ ] 1.8.7.2.1 Add test: `test "print_stats shows correct summary"` - format
- [ ] 1.8.7.2.2 Add test: `test "stats update in real-time"` - dynamic
- [ ] 1.8.7.2.3 Add test: `test "reset_stats clears and restarts tracking"` - reset

### 1.8.7.3 Multi-Observer Test

Test multiple observers can coexist.

- [ ] 1.8.7.3.1 Add test: `test "multiple observers can subscribe"` - 2 observers
- [ ] 1.8.7.3.2 Add test: `test "each observer tracks independently"` - separate stats
- [ ] 1.8.7.3.3 Add test: `test "observer crash doesn't affect simulation"` - fault isolation

### 1.8.7.4 Performance Test

Basic performance test for observer overhead.

- [ ] 1.8.7.4.1 Add test: `test "observer handles 1000 events without lag"` - timing
- [ ] 1.8.7.4.2 Add test: `test "observer doesn't slow down simulation"` - comparison
- [ ] 1.8.7.4.3 Add test: `test "observer mailbox doesn't overflow"` - heavy load

---

## Phase 1.8 Success Criteria

1. **Observer Module**: GenServer compiles and starts ✅
2. **PubSub Subscription**: Subscribes to simulation topic ✅
3. **Event Handlers**: All event types logged correctly ✅
4. **Statistics Tracking**: Counters accurate ✅
5. **Console Output**: Readable event logging ✅
6. **Start/Stop**: Clean lifecycle ✅
7. **Tests**: All unit and integration tests pass ✅

## Phase 1.8 Critical Files

**New Files:**
- `lib/ant_colony/observer.ex` - Observer GenServer module
- `test/ant_colony/observer_test.exs` - Observer unit tests
- `test/ant_colony/integration/observer_integration_test.exs` - Integration tests

**Modified Files:**
- None

---

## Phase 1 Complete

All Phase 1: Foundational Simulation Skeleton planning documents are now complete!

### Summary of Phase 1

1. **Project Setup** - Elixir project with Jido v2 and dependencies
2. **PubSub Configuration** - Event-driven communication backbone
3. **Plane GenServer** - Environment state management
4. **AntAgent Schema** - Jido.Agent definition for ants
5. **Move Action** - Ant movement with event publishing
6. **Sense Food Action** - Food detection at current position
7. **Supervision Tree** - OTP application with fault tolerance
8. **Console Observer** - Event logging for debugging

### Next Phase

Proceed to **Phase 2: Initial UI Integration** to build the terminal UI using term_ui.

### Files to Reference During Implementation

- `notes/research/development_cycles.md` - Original development workflow
- `notes/research/original_research.md` - Detailed architecture
- `notes/research/terminal_ui.md` - Terminal UI patterns
- `CLAUDE.md` - Project overview
