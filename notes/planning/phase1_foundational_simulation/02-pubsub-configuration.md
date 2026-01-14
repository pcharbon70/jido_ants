# Phase 1.2: PubSub Configuration

Configure Phoenix.PubSub for event-driven communication between simulation components. This establishes the backbone for decoupled messaging between agents, the environment, and future UI/observers.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AntColony.PubSub                                │
│                   (Phoenix.PubSub instance)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌────────────────────────────────────────────────────────────┐    │
│   │                     Topic: "simulation"                     │    │
│   │  ┌──────────────────────────────────────────────────────┐  │    │
│   │  │ Events:                                              │  │    │
│   │  │  • {:ant_moved, ant_id, old_pos, new_pos}            │  │    │
│   │  │  • {:food_sensed, ant_id, position, food_details}    │  │    │
│   │  │  • {:ant_state_changed, ant_id, old_state, new_state}│  │    │
│   │  │  • {:ant_registered, ant_id, position}               │  │    │
│   │  │  • {:ant_unregistered, ant_id}                       │  │    │
│   │  └──────────────────────────────────────────────────────┘  │    │
│   └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│   ┌────────────────────────────────────────────────────────────┐    │
│   │                    Topic: "ui_updates"                      │    │
│   │  (Reserved for Phase 2: Terminal UI Integration)           │    │
│   └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │                           │                           │
         ▼                           ▼                           ▼
   ┌─────────┐                 ┌─────────┐                 ┌─────────┐
   │ AntAgent│                 │  Plane  │                 │ Observer │
   │Publisher│                 │Publisher│                 │Subscriber│
   └─────────┘                 └─────────┘                 └─────────┘
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| AntColony.PubSub | Phoenix.PubSub instance name for PubSub operations |
| AntColony.Events | Module defining event constants and broadcast helpers |
| AntColony.Application | Supervision tree including PubSub child |

---

## 1.2.1 Add Phoenix.PubSub to Application

Integrate Phoenix.PubSub into the application supervision tree.

### 1.2.1.1 Create Events Module

Create a dedicated module for event-related constants and helpers.

- [ ] 1.2.1.1.1 Create `lib/ant_colony/events.ex`
- [ ] 1.2.1.1.2 Add `defmodule AntColony.Events` with `@moduledoc`
- [ ] 1.2.1.1.3 Define topic constants:
  - `@topic_simulation` - "simulation"
  - `@topic_ui_updates` - "ui_updates"
- [ ] 1.2.1.1.4 Add accessor functions: `simulation_topic/0`, `ui_updates_topic/0`

### 1.2.1.2 Define Event Types

Define structured event types for type safety and documentation.

- [ ] 1.2.1.2.1 Add type specification for ant_moved event:
  - `@type ant_moved :: {:ant_moved, ant_id :: String.t(), old_pos :: position(), new_pos :: position()}`
- [ ] 1.2.1.2.2 Add type specification for food_sensed event:
  - `@type food_sensed :: {:food_sensed, ant_id :: String.t(), position :: position(), food_details :: map()}`
- [ ] 1.2.1.2.3 Add type specification for ant_state_changed event:
  - `@type ant_state_changed :: {:ant_state_changed, ant_id :: String.t(), old_state :: atom(), new_state :: atom()}`
- [ ] 1.2.1.2.4 Add type specification for position: `@type position :: {integer(), integer()}`

### 1.2.1.3 Register PubSub in Application

Add Phoenix.PubSub to the application supervision tree.

- [ ] 1.2.1.3.1 Open `lib/ant_colony/application.ex`
- [ ] 1.2.1.3.2 Locate the `start/2` function children list
- [ ] 1.2.1.3.3 Add `{Phoenix.PubSub, name: AntColony.PubSub}` to children
- [ ] 1.2.1.3.4 Verify the children list is properly formatted

---

## 1.2.2 Define Events Module

Implement the Events module with all event definitions and broadcast helpers.

### 1.2.2.1 Implement Broadcast Helper Functions

Create helper functions for broadcasting common events.

- [ ] 1.2.2.1.1 Implement `broadcast_ant_moved/4`:
  - Parameters: `pubsub_name, ant_id, old_pos, new_pos`
  - Returns: `:ok | {:error, reason}`
  - Uses `Phoenix.PubSub.broadcast/3`
- [ ] 1.2.2.1.2 Implement `broadcast_food_sensed/4`:
  - Parameters: `pubsub_name, ant_id, position, food_details`
  - Returns: `:ok | {:error, reason}`
- [ ] 1.2.2.1.3 Implement `broadcast_ant_state_changed/4`:
  - Parameters: `pubsub_name, ant_id, old_state, new_state`
  - Returns: `:ok | {:error, reason}`
- [ ] 1.2.2.1.4 Implement `broadcast_ant_registered/3`:
  - Parameters: `pubsub_name, ant_id, position`
  - Returns: `:ok | {:error, reason}`

### 1.2.2.2 Implement Subscribe Helper Functions

Create helper functions for subscribing to event topics.

- [ ] 1.2.2.2.1 Implement `subscribe_to_simulation/1`:
  - Parameters: `pubsub_name`
  - Returns: `{:ok, subscription_ref}`
  - Subscribes to simulation topic
- [ ] 1.2.2.2.2 Implement `subscribe_to_ui_updates/1`:
  - Parameters: `pubsub_name`
  - Returns: `{:ok, subscription_ref}`
  - Subscribes to ui_updates topic

### 1.2.2.3 Add Event Validation Functions

Create functions to validate event structures.

- [ ] 1.2.2.3.1 Implement `valid_position?/1`:
  - Checks if argument is a `{integer(), integer()}` tuple
  - Returns `boolean()`
- [ ] 1.2.2.3.2 Implement `valid_ant_id?/1`:
  - Checks if argument is a non-empty binary string
  - Returns `boolean()`
- [ ] 1.2.2.3.3 Implement `valid_ant_state?/1`:
  - Checks if argument is one of: `:at_nest, :searching, :returning_to_nest`
  - Returns `boolean()`

---

## 1.2.3 Create Broadcast Helper Functions

Ensure broadcast functions handle errors and provide consistent behavior.

### 1.2.3.1 Implement Error Handling

Add error handling to broadcast functions.

- [ ] 1.2.3.1.1 Add try/rescue to broadcast_ant_moved for unexpected errors
- [ ] 1.2.3.1.2 Add try/rescue to broadcast_food_sensed for unexpected errors
- [ ] 1.2.3.1.3 Add try/rescue to broadcast_ant_state_changed for unexpected errors
- [ ] 1.2.3.1.4 Log errors using `require Logger` and `Logger.error/1`

### 1.2.3.2 Add Event Metadata

Enhance events with timestamp and metadata information.

- [ ] 1.2.3.2.1 Implement `get_timestamp/0` returning `DateTime.utc_now()`
- [ ] 1.2.3.2.2 Add optional metadata map to broadcast functions
- [ ] 1.2.3.2.3 Include timestamp in event metadata when provided
- [ ] 1.2.3.2.4 Document metadata usage in @moduledoc

---

## 1.2.4 Unit Tests for PubSub Configuration

Test PubSub startup and event broadcast/subscription functionality.

### 1.2.4.1 Test PubSub Starts in Supervision Tree

Verify PubSub is started as part of the application.

- [ ] 1.2.4.1.1 Create `test/ant_colony/events_test.exs`
- [ ] 1.2.4.1.2 Add setup block that starts application: `setup :start_application`
- [ ] 1.2.4.1.3 Add test: `test "pubsub is registered"` - checks `Process.whereis(AntColony.PubSub)`
- [ ] 1.2.4.1.4 Add test: `test "pubsub responds to ping"` - calls `GenServer.call(AntColony.PubSub, :ping)`
- [ ] 1.2.4.1.5 Add test: `test "pubsub child spec is valid"` - checks child specification

### 1.2.4.2 Test Event Broadcast Functions

Verify each broadcast helper function works correctly.

- [ ] 1.2.4.2.1 Add test: `test "broadcast_ant_moved publishes correct event"` - subscribe and verify message
- [ ] 1.2.4.2.2 Add test: `test "broadcast_ant_moved returns :ok on success"` - check return value
- [ ] 1.2.4.2.3 Add test: `test "broadcast_food_sensed publishes correct event"` - subscribe and verify
- [ ] 1.2.4.2.4 Add test: `test "broadcast_ant_state_changed publishes correct event"` - subscribe and verify
- [ ] 1.2.4.2.5 Add test: `test "broadcast_ant_registered publishes correct event"` - subscribe and verify

### 1.2.4.3 Test Subscribe Helper Functions

Verify subscription helpers create valid subscriptions.

- [ ] 1.2.4.3.1 Add test: `test "subscribe_to_simulation creates subscription"` - check return value
- [ ] 1.2.4.3.2 Add test: `test "subscribe_to_ui_updates creates subscription"` - check return value
- [ ] 1.2.4.3.3 Add test: `test "subscriber receives broadcasted messages"` - full round-trip test
- [ ] 1.2.4.3.4 Add test: `test "subscriber can unsubscribe"` - subscribe then unsubscribe

### 1.2.4.4 Test Validation Functions

Verify event validation functions correctly validate inputs.

- [ ] 1.2.4.4.1 Add test: `test "valid_position? returns true for valid positions"` - test `{1, 2}`, `{0, 0}`, `{100, 100}`
- [ ] 1.2.4.4.2 Add test: `test "valid_position? returns false for invalid positions"` - test `{1, "a"}`, `nil`, `:invalid`
- [ ] 1.2.4.4.3 Add test: `test "valid_ant_id? returns true for non-empty strings"` - test `"ant_1"`, `"ant-123"`
- [ ] 1.2.4.4.4 Add test: `test "valid_ant_id? returns false for invalid IDs"` - test `""`, `nil`, `123`
- [ ] 1.2.4.4.5 Add test: `test "valid_ant_state? returns true for valid states"` - test all valid states
- [ ] 1.2.4.4.6 Add test: `test "valid_ant_state? returns false for invalid states"` - test `:invalid`, `"searching"`

---

## 1.2.5 Phase 1.2 Integration Tests

End-to-end tests for PubSub functionality within the application context.

### 1.2.5.1 PubSub Message Flow Test

Test complete message flow from publisher to subscriber.

- [ ] 1.2.5.1.1 Create `test/ant_colony/integration/pubsub_integration_test.exs`
- [ ] 1.2.5.1.2 Add setup starting application and PubSub
- [ ] 1.2.5.1.3 Add test: `test "multiple subscribers receive same message"` - 3 subscribers, one broadcast
- [ ] 1.2.5.1.4 Add test: `test "subscriber receives only messages from subscribed topic"` - cross-topic isolation
- [ ] 1.2.5.1.5 Add test: `test "subscriber receives messages in order"` - sequence test

### 1.2.5.2 PubSub Performance Test

Basic performance test to ensure PubSub is suitable for simulation needs.

- [ ] 1.2.5.2.1 Add test: `test "broadcast 1000 events completes quickly"` - timing test, should be < 100ms
- [ ] 1.2.5.2.2 Add test: `test "100 concurrent broadcasts succeed"` - concurrent Task.async test
- [ ] 1.2.5.2.3 Add test: `test "subscriber can keep up with rapid broadcasts"` - no mailbox overflow

### 1.2.5.3 PubSub Fault Tolerance Test

Test behavior when PubSub encounters errors.

- [ ] 1.2.5.3.1 Add test: `test "broadcast with invalid pubsub name returns error"` - error handling
- [ ] 1.2.5.3.2 Add test: `test "subscriber crash does not affect PubSub"` - subscriber isolation
- [ ] 1.2.5.3.3 Add test: `test "PubSub restarts after crash"` - supervision verification

---

## Phase 1.2 Success Criteria

1. **PubSub Instance**: `AntColony.PubSub` is registered and running ✅
2. **Events Module**: All event types and helpers defined ✅
3. **Broadcast Functions**: All broadcast helpers work correctly ✅
4. **Subscription**: Subscribers can subscribe and receive messages ✅
5. **Error Handling**: Invalid inputs and errors are handled gracefully ✅
6. **Tests**: All unit and integration tests pass ✅

## Phase 1.2 Critical Files

**New Files:**
- `lib/ant_colony/events.ex` - Event constants and broadcast helpers
- `test/ant_colony/events_test.exs` - Unit tests for Events module
- `test/ant_colony/integration/pubsub_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/application.ex` - Add PubSub to supervision tree

---

## Next Phase

Proceed to [Phase 1.3: Plane GenServer](./03-plane-genserver.md) to implement the simulated environment.
