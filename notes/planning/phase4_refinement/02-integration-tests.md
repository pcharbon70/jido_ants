# Phase 4.2: Integration Tests

Implement comprehensive integration tests that verify interactions between components. Integration tests ensure that modules work correctly when combined and that events flow properly through the system.

## Architecture

```
Integration Test Scenarios
├── Agent ↔ Plane
│   ├── Agent registers position with Plane
│   ├── Agent picks up food from Plane
│   ├── Agent deposits food at Plane (nest)
│   ├── Agent lays pheromone on Plane
│   └── Agent senses pheromones from Plane
│
├── Agent ↔ Agent
│   ├── Proximity detection
│   ├── Information exchange
│   └── Conflict resolution
│
├── Simulation ↔ UI
│   ├── Ant moved events update UI
│   ├── Food updated events update UI
│   ├── Pheromone events update UI
│   ├── Communication events update UI
│   └── ML events update UI
│
├── End-to-End Scenarios
│   ├── Single ant finds food
│   ├── Multiple ants optimize foraging
│   ├── Pheromone trail formation
│   └── ML model improves efficiency
│
└── Application Lifecycle
    ├── Startup sequence
    ├── Shutdown sequence
    └── Supervision tree restart
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Agent-Plane Tests | Verify agent interactions with environment |
| Agent-Agent Tests | Verify communication between ants |
| Simulation-UI Tests | Verify event flow to UI |
| E2E Scenarios | Verify complete simulation workflows |
| Lifecycle Tests | Verify application startup/shutdown |

---

## 4.2.1 Agent-Plane Integration Tests

Test interactions between ants and the environment.

### 4.2.1.1 Setup Agent-Plane Test Environment

Configure test environment for agent-plane tests.

- [ ] 4.2.1.1.1 Create `test/ant_colony/integration/agent_plane_integration_test.exs`
- [ ] 4.2.1.1.2 Add `use ExUnit.Case, async: false` (integration tests are synchronous)
- [ ] 4.2.1.1.3 Describe "Agent-Plane integration context"
- [ ] 4.2.1.1.4 Setup function: start Plane, PubSub
- [ ] 4.2.1.1.5 Cleanup function: stop all processes

### 4.2.1.2 Test Agent Registration

Verify ants register with Plane correctly.

- [ ] 4.2.1.2.1 Test `test "agent registers position on spawn"`
  - Start Plane
  - Spawn ant at nest
  - Assert ant in Plane.ant_positions
  - Assert position matches nest
- [ ] 4.2.1.2.2 Test `test "agent unregisters on stop"`
  - Spawn ant
  - Stop ant
  - Assert ant removed from Plane.ant_positions
- [ ] 4.2.1.2.3 Test `test "agent updates position after move"`
  - Spawn ant at nest
  - Execute move action
  - Assert position updated in Plane
  - Assert event published

### 4.2.1.3 Test Food Pickup

Verify food pickup interaction.

- [ ] 4.2.1.3.1 Test `test "agent picks up food from Plane"`
  - Setup: Plane with food at {5, 5}
  - Spawn ant at {5, 5}
  - Execute PickUpFoodAction
  - Assert Plane food quantity decreased
  - Assert ant has_food? is true
- [ ] 4.2.1.3.2 Test `test "food pickup publishes event"`
  - Verify {:food_picked_up, ...} published
- [ ] 4.2.1.3.3 Test `test "agent cannot pick up empty food source"`
  - Setup: depleted food source
  - Execute PickUpFoodAction
  - Assert returns error

### 4.2.1.4 Test Food Deposit

Verify food deposit at nest.

- [ ] 4.2.1.4.1 Test `test "agent deposits food at nest"`
  - Setup: ant with food at nest
  - Execute DropFoodAction
  - Assert Plane total_food_collected increased
  - Assert ant has_food? is false
- [ ] 4.2.1.4.2 Test `test "food deposit publishes event"`
  - Verify {:food_dropped_at_nest, ...} published
- [ ] 4.2.1.4.3 Test `test "agent cannot deposit away from nest"`
  - Setup: ant with food away from nest
  - Execute DropFoodAction
  - Assert returns error

### 4.2.1.5 Test Pheromone Interaction

Verify pheromone laying and sensing.

- [ ] 4.2.1.5.1 Test `test "agent lays pheromone on Plane"`
  - Setup: ant with food
  - Execute LayPheromoneAction
  - Assert pheromone added to Plane
  - Assert pheromone level correct
- [ ] 4.2.1.5.2 Test `test "agent senses pheromones from Plane"`
  - Setup: Plane with pheromones
  - Execute SensePheromoneAction
  - Assert returns pheromone data
- [ ] 4.2.1.5.3 Test `test "pheromone accumulation works"`
  - Multiple ants lay pheromone at same spot
  - Assert level accumulates correctly
- [ ] 4.2.1.5.4 Test `test "pheromone evaporation reduces levels"`
  - Trigger Plane evaporation
  - Assert all levels reduced

---

## 4.2.2 Agent-Agent Integration Tests

Test communication between ants.

### 4.2.2.1 Setup Communication Test Environment

Configure test environment for communication tests.

- [ ] 4.2.2.1.1 Create `test/ant_colony/integration/agent_communication_integration_test.exs`
- [ ] 4.2.2.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.2.2.1.3 Describe "Agent-Agent communication context"
- [ ] 4.2.2.1.4 Setup function: start Plane, PubSub
- [ ] 4.2.2.1.5 Cleanup function: stop all processes

### 4.2.2.2 Test Proximity Detection

Verify Plane detects nearby ants.

- [ ] 4.2.2.2.1 Test `test "plane detects ants within 3 squares"`
  - Spawn ant1 at {5, 5}
  - Spawn ant2 at {6, 5} (distance 1)
  - Call Plane.check_proximity(ant1)
  - Assert ant2 in result
- [ ] 4.2.2.2.2 Test `test "plane excludes ants beyond 3 squares"`
  - Spawn ant1 at {5, 5}
  - Spawn ant2 at {9, 5} (distance 4)
  - Call Plane.check_proximity(ant1)
  - Assert ant2 not in result
- [ ] 4.2.2.2.3 Test `test "multiple ants detected in same area"`
  - Spawn 5 ants in radius
  - Call check_proximity
  - Assert all returned

### 4.2.2.3 Test Information Exchange

Verify ants share food information.

- [ ] 4.2.2.3.1 Test `test "ants exchange known_food_sources"`
  - Setup: ant1 with known source, ant2 without
  - Move ants within proximity
  - Trigger communication
  - Assert ant2 now has ant1's source
- [ ] 4.2.2.3.2 Test `test "higher quality source overrides lower"`
  - Setup: ant1 knows level 3, ant2 knows level 5 at same position
  - Trigger communication
  - Assert both ants now know level 5
- [ ] 4.2.2.3.3 Test `test "communication respects cooldown"`
  - Setup: ants just communicated
  - Trigger proximity again
  - Assert no second communication

### 4.2.2.4 Test Communication Behavior

Verify communication influences ant behavior.

- [ ] 4.2.2.4.1 Test `test "ant changes direction after receiving better info"`
  - Setup: ant1 searching randomly
  - ant2 shares high-quality food location
  - Assert ant1 moves toward new location
- [ ] 4.2.2.4.2 Test `test "ant ignores worse information"`
  - Setup: ant1 knows level 5, ant2 knows level 3
  - Trigger communication
  - Assert ant1 keeps level 5 info

---

## 4.2.3 Simulation-UI Integration Tests

Test event flow from simulation to UI.

### 4.2.3.1 Setup Simulation-UI Test Environment

Configure test environment for UI integration.

- [ ] 4.2.3.1.1 Create `test/ant_colony/integration/simulation_ui_integration_test.exs`
- [ ] 4.2.3.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.2.3.1.3 Describe "Simulation-UI integration context"
- [ ] 4.2.3.1.4 Setup function: start Application
- [ ] 4.2.3.1.5 Cleanup function: stop Application

### 4.2.3.2 Test Ant Moved Events

Verify UI receives and displays ant movements.

- [ ] 4.2.3.2.1 Test `test "UI receives ant_moved events"`
  - Start Application with UI
  - Spawn ant
  - Move ant
  - Get UI state
  - Assert ant position updated in UI
- [ ] 4.2.3.2.2 Test `test "UI renders ant at new position"`
  - Setup: UI with ant at {5, 5}
  - Move ant to {5, 6}
  - Trigger UI render
  - Assert ant shows at {5, 6}
- [ ] 4.2.3.2.3 Test `test "ant state changes visible in UI"`
  - Setup: ant searching
  - Ant picks up food
  - Assert UI shows "A" (returning)

### 4.2.3.3 Test Food Events

Verify UI displays food updates.

- [ ] 4.2.3.3.1 Test `test "UI receives food_updated events"`
  - Start Application with UI
  - Setup: food source at {5, 5}
  - Ant picks up food
  - Assert UI food quantity updated
- [ ] 4.2.3.3.2 Test `test "UI removes depleted food sources"`
  - Setup: food with quantity 1
  - Ant picks up last food
  - Assert UI no longer shows food at position
- [ ] 4.2.3.3.3 Test `test "UI shows food levels correctly"`
  - Setup: food levels 1-5
  - Assert UI displays "F1" through "F5"
  - Assert colors applied correctly

### 4.2.3.4 Test Pheromone Events

Verify UI displays pheromone data.

- [ ] 4.2.3.4.1 Test `test "UI receives pheromone_updated events"`
  - Start Application with UI
  - Enable pheromone display
  - Ant lays pheromone
  - Assert UI shows pheromone at position
- [ ] 4.2.3.4.2 Test `test "UI pheromone intensity maps correctly"`
  - Setup: pheromone levels 10, 30, 60, 90
  - Assert correct characters displayed
- [ ] 4.2.3.4.3 Test `test "UI toggle hides/shows pheromones"`
  - Toggle pheromone display
  - Assert visibility changes

### 4.2.3.5 Test Communication Events

Verify UI shows communication.

- [ ] 4.2.3.5.1 Test `test "UI receives communication events"`
  - Start Application with UI
  - Setup: two ants nearby
  - Trigger communication
  - Assert UI shows communication indicator
- [ ] 4.2.3.5.2 Test `test "UI communication indicator fades"`
  - Setup: communicating ants
  - Wait for timeout
  - Assert indicator removed

### 4.2.3.6 Test Control Commands

Verify UI commands control simulation.

- [ ] 4.2.3.6.1 Test `test "UI pause command pauses simulation"`
  - Start Application with UI
  - Send SPACE key to UI
  - Assert Controller.paused is true
- [ ] 4.2.3.6.2 Test `test "UI resume command resumes simulation"`
  - Setup: paused simulation
  - Send SPACE key to UI
  - Assert Controller.paused is false
- [ ] 4.2.3.6.3 Test `test "UI speed command adjusts speed"`
  - Send "+" key to UI
  - Assert Controller.speed_multiplier increased
- [ ] 4.2.3.6.4 Test `test "UI quit command with confirmation"`
  - Send "q" key to UI
  - Assert confirmation dialog shows
  - Send "y" key
  - Assert :quit command returned

---

## 4.2.4 End-to-End Scenario Tests

Test complete simulation workflows.

### 4.2.4.1 Setup E2E Test Environment

Configure test environment for scenarios.

- [ ] 4.2.4.1.1 Create `test/ant_colony/integration/e2e_scenarios_test.exs`
- [ ] 4.2.4.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.2.4.1.3 Describe "End-to-end scenario context"
- [ ] 4.2.4.1.4 Setup: start Application with Plane, PubSub, AgentSupervisor
- [ ] 4.2.4.1.5 Cleanup: stop all processes

### 4.2.4.2 Test Single Ant Foraging

Verify single ant can find and return food.

- [ ] 4.2.4.2.1 Test `test "single ant finds nearby food"`
  - Setup: 10x10 plane, nest at {5, 5}, food at {5, 6}
  - Spawn ant at nest
  - Wait/step simulation
  - Assert ant reaches food
  - Assert ant picks up food
  - Assert ant returns to nest
  - Assert food deposited
- [ ] 4.2.4.2.2 Test `test "single ant finds distant food"`
  - Setup: food at {5, 9}
  - Spawn ant
  - Run simulation
  - Assert ant eventually finds food
- [ ] 4.2.4.2.3 Test `test "single ant ignores low quality food"`
  - Setup: level 1 food nearby
  - Spawn ant
  - Run simulation
  - Assert ant doesn't pick up food

### 4.2.4.3 Test Multiple Ant Optimization

Verify colony optimizes foraging.

- [ ] 4.2.4.3.1 Test `test "multiple ants find food efficiently"`
  - Setup: 10 ants, one high-quality food source
  - Run simulation for N steps
  - Assert multiple ants find food
  - Assert pheromone trail forms
- [ ] 4.2.4.3.2 Test `test "ants converge on shortest path"`
  - Setup: nest at {1, 1}, food at {8, 8}
  - Spawn 20 ants
  - Run simulation
  - Assert ants use reasonably direct path
- [ ] 4.2.4.3.3 Test `test "ants adapt when food depletes"`
  - Setup: one food source with limited quantity
  - Spawn ants
  - Run until food depleted
  - Assert ants search for new sources

### 4.2.4.4 Test Pheromone Trail Formation

Verify pheromone system works end-to-end.

- [ ] 4.2.4.4.1 Test `test "pheromone trail forms to food"`
  - Setup: food source, returning ants
  - Run simulation
  - Assert pheromone levels highest on shortest path
- [ ] 4.2.4.4.2 Test `test "pheromone evaporation prevents stagnation"`
  - Setup: depleted food source with old trail
  - Run simulation
  - Assert old trail evaporates
  - Assert ants explore new areas
- [ ] 4.2.4.4.3 Test `test "pheromone influences searching ants"`
  - Setup: returning ant lays trail, searching ant starts
  - Run simulation
  - Assert searching ant biased toward trail

### 4.2.4.5 Test Communication Acceleration

Verify communication speeds up optimization.

- [ ] 4.2.4.5.1 Test `test "communication accelerates food discovery"`
  - Setup: two groups of ants, each knows different food
  - Move groups within proximity
  - Run simulation
  - Assert both groups know both foods
- [ ] 4.2.4.5.2 Test `test "ants prefer higher quality after communication"`
  - Setup: ant knows low quality, communicates with ant knowing high quality
  - Assert ant moves toward high quality

### 4.2.4.6 Test ML Model Integration

Verify ML system improves foraging.

- [ ] 4.2.4.6.1 Test `test "ML training cycle completes"`
  - Setup: Trainer, foraging ants
  - Run N foraging trips
  - Assert model trained after interval
- [ ] 4.2.4.6.2 Test `test "ML predictions influence movement"`
  - Setup: trained model, searching ant
  - Query model for directions
  - Assert ant chooses highest-scored direction
- [ ] 4.2.4.6.3 Test `test "foraging efficiency improves with training"`
  - Setup: measure initial efficiency
  - Run simulation for M training cycles
  - Measure efficiency again
  - Assert improvement (within statistical variance)

---

## 4.2.5 Application Lifecycle Tests

Test application startup and shutdown.

### 4.2.5.1 Setup Lifecycle Test Environment

Configure test environment for lifecycle tests.

- [ ] 4.2.5.1.1 Create `test/ant_colony/integration/application_lifecycle_test.exs`
- [ ] 4.2.5.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.2.5.1.3 Describe "Application lifecycle context"

### 4.2.5.2 Test Startup Sequence

Verify application starts correctly.

- [ ] 4.2.5.2.1 Test `test "application starts all children"`
  - Start Application
  - Assert PubSub running
  - Assert Plane running
  - Assert AgentSupervisor running
  - Assert Controller running (if started)
- [ ] 4.2.5.2.2 Test `test "application starts in reasonable time"`
  - Measure startup time
  - Assert < 5 seconds
- [ ] 4.2.5.2.3 Test `test "application handles restart"`
  - Start Application
  - Stop Application
  - Start again
  - Assert clean start

### 4.2.5.3 Test Shutdown Sequence

Verify application shuts down cleanly.

- [ ] 4.2.5.3.1 Test `test "application stops gracefully"`
  - Start Application with ants
  - Stop Application
  - Assert all processes stopped
  - Assert no orphaned processes
- [ ] 4.2.5.3.2 Test `test "application stops during active simulation"`
  - Start Application with running simulation
  - Stop Application
  - Assert clean shutdown
- [ ] 4.2.5.3.3 Test `test "UI shutdown doesn't crash simulation"`
  - Start Application with UI
  - Stop UI
  - Assert simulation continues

### 4.2.5.4 Test Supervision and Fault Tolerance

Verify supervision tree handles failures.

- [ ] 4.2.5.4.1 Test `test "Plane restarts on crash"`
  - Start Application
  - Kill Plane process
  - Assert Plane restarted
  - Assert state recovered or reset
- [ ] 4.2.5.4.2 Test `test "ant crash doesn't crash Plane"`
  - Start Application with ants
  - Kill one ant
  - Assert Plane still running
  - Assert other ants unaffected
- [ ] 4.2.5.4.3 Test `test "PubSub restart doesn't crash system"`
  - Kill PubSub
  - Assert system continues
  - Assert PubSub restarted

---

## 4.2.6 Test Performance and Scalability

Verify system performs adequately under load.

### 4.2.6.1 Setup Performance Test Environment

Configure test environment for performance tests.

- [ ] 4.2.6.1.1 Create `test/ant_colony/integration/performance_test.exs`
- [ ] 4.2.6.1.2 Add `use ExUnit.Case, async: false`
- [ ] 4.2.6.1.3 Add `@tag :performance` for conditional running
- [ ] 4.2.6.1.4 Describe "Performance context"

### 4.2.6.2 Test Concurrent Ant Operations

Verify system handles many ants.

- [ ] 4.2.6.2.1 Test `test "system handles 100 ants"`
  - Start Application
  - Spawn 100 ants
  - Run for 100 ticks
  - Assert no crashes
  - Assert all ants still running
- [ ] 4.2.6.2.2 Test `test "system handles 1000 ants"`
  - Start Application
  - Spawn 1000 ants
  - Run for 50 ticks
  - Assert reasonable performance (> 1 tick/sec)
- [ ] 4.2.6.2.3 Test `test "plane operations scale with ant count"`
  - Measure Plane response time
  - With 10, 100, 1000 ants
  - Assert sub-millisecond response

### 4.2.6.3 Test Event Throughput

Verify PubSub handles event volume.

- [ ] 4.2.6.3.1 Test `test "system handles 1000 events/second"`
  - Setup: 100 ants moving every tick
  - Publish events
  - Measure PubSub latency
  - Assert < 10ms latency
- [ ] 4.2.6.3.2 Test `test "UI updates keep up with events"`
  - Start Application with UI
  - Generate rapid events
  - Measure UI frame rate
  - Assert > 30 FPS maintained

### 4.2.6.4 Test Memory Usage

Verify system doesn't leak memory.

- [ ] 4.2.6.4.1 Test `test "memory usage stable over time"`
  - Start Application
  - Run simulation for 10 minutes
  - Measure memory every minute
  - Assert no significant growth
- [ ] 4.2.6.4.2 Test `test "many action cycles don't leak"`
  - Run 10,000 action cycles
  - Measure memory before/after
  - Assert minimal growth

---

## 4.2.7 Phase 4.2 Integration Tests

End-to-end tests for integration test infrastructure.

### 4.2.7.1 Test Infrastructure Validation

Verify integration test framework works.

- [ ] 4.2.7.1.1 Create `test/phase4/integration_tests_infrastructure_test.exs`
- [ ] 4.2.7.1.2 Add test: `test "integration test setup works"`
- [ ] 4.2.7.1.3 Add test: `test "all integration test files exist"`
- [ ] 4.2.7.1.4 Add test: `test "integration tests can run in parallel where supported"`
- [ ] 4.2.7.1.5 Add test: `test "integration test cleanup works"`

---

## Phase 4.2 Success Criteria

1. **Agent-Plane Tests**: All interactions tested ✅
2. **Agent-Agent Tests**: Communication tested ✅
3. **Simulation-UI Tests**: Event flow tested ✅
4. **E2E Scenarios**: Complete workflows tested ✅
5. **Lifecycle Tests**: Startup/shutdown tested ✅
6. **Performance Tests**: System scales adequately ✅
7. **Tests**: All integration tests pass ✅

## Phase 4.2 Critical Files

**New Files:**
- `test/ant_colony/integration/agent_plane_integration_test.exs`
- `test/ant_colony/integration/agent_communication_integration_test.exs`
- `test/ant_colony/integration/simulation_ui_integration_test.exs`
- `test/ant_colony/integration/e2e_scenarios_test.exs`
- `test/ant_colony/integration/application_lifecycle_test.exs`
- `test/ant_colony/integration/performance_test.exs`
- `test/phase4/integration_tests_infrastructure_test.exs`

**Modified Files:**
- None

---

## Next Phase

Proceed to [Phase 4.3: Property-Based Tests](./03-property-based-tests.md) to add property-based testing with StreamData.
