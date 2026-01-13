# Phase 5: Foraging Actions

This phase implements the foraging-specific actions that enable ants to pick up food, carry it back to the nest, and drop it. These actions complete the core foraging loop: search → find → pick up → return → drop.

---

## 5.1 PickUpFoodAction

Implement the action that enables ants to pick up food when they find it.

### 5.1.1 PickUpFoodAction Module Structure
- [ ] **Task 5.1.1** Create the PickUpFoodAction module.

- [ ] 5.1.1.1 Create `lib/jido_ants/actions/pick_up_food.ex` with module documentation
- [ ] 5.1.1.2 Add `use Jido.Action` with empty schema (picks up from current position)
- [ ] 5.1.1.3 Define `@descript "Pick up food at the ant's current position"`
- [ ] 5.1.1.4 Implement `run/2` callback

### 5.1.2 Food Pickup Logic
- [ ] **Task 5.1.2** Implement food pickup from PlaneServer.

- [ ] 5.1.2.1 Get agent position from context
- [ ] 5.1.2.2 Check if agent is already carrying food
- [ ] 5.1.2.3 Return `{:error, :already_carrying}` if has_food? is true
- [ ] 5.1.2.4 Sense food at current position using SenseFoodAction logic
- [ ] 5.1.2.5 Return `{:error, :no_food}` if no food found
- [ ] 5.1.2.6 Query PlaneServer for food level: `PlaneServer.sense_food(position)`
- [ ] 5.1.2.7 Call PlaneServer to pick up food: `PlaneServer.pick_up_food(position)`

### 5.1.3 Agent State Update
- [ ] **Task 5.1.3** Update agent state after successful pickup.

- [ ] 5.1.3.1 Set `has_food?` to true
- [ ] 5.1.3.2 Store `carried_food_level` from picked up food
- [ ] 5.1.3.3 Update path_memory observation with food_found: true
- [ ] 5.1.3.4 Add food source to known_food_sources
- [ ] 5.1.3.5 Return `{:ok, updated_agent, directives}`
- [ ] 5.1.3.6 Include directive to transition to :returning_to_nest state

### 5.1.4 Food Level Decision
- [ ] **Task 5.1.4** Implement decision logic for food pickup.

- [ ] 5.1.4.1 Define minimum food level threshold (e.g., level 2)
- [ ] 5.1.4.2 Only pick up food if level meets or exceeds threshold
- [ ] 5.1.4.3 Return `{:ok, :continue}` if food level too low (continue searching)
- [ ] 5.1.4.4 Make threshold configurable via action parameter
- [ ] 5.1.4.5 Write unit tests for threshold logic

**Unit Tests for Section 5.1:**
- Test PickUpFoodAction fails if already carrying
- Test PickUpFoodAction fails if no food at position
- Test PickUpFoodAction succeeds when food present
- Test PickUpFoodAction sets has_food? to true
- Test PickUpFoodAction stores carried_food_level
- Test PickUpFoodAction reduces plane food quantity
- Test PickUpFoodAction respects minimum level threshold
- Test PickUpFoodAction adds food to known_food_sources
- Test PickUpFoodAction emits state transition directive

---

## 5.2 DropFoodAction

Implement the action that enables ants to drop food at the nest.

### 5.2.1 DropFoodAction Module Structure
- [ ] **Task 5.2.1** Create the DropFoodAction module.

- [ ] 5.2.1.1 Create `lib/jido_ants/actions/drop_food.ex` with module documentation
- [ ] 5.2.1.2 Add `use Jido.Action` with empty schema (drops at current position)
- [ ] 5.2.1.3 Define `@descript "Drop carried food at the nest"`
- [ ] 5.2.1.4 Implement `run/2` callback

### 5.2.2 Drop Validation
- [ ] **Task 5.2.2** Validate drop conditions.

- [ ] 5.2.2.1 Get agent position from context
- [ ] 5.2.2.2 Check if agent is carrying food
- [ ] 5.2.2.3 Return `{:error, :not_carrying}` if has_food? is false
- [ ] 5.2.2.4 Verify agent is at nest position
- [ ] 5.2.2.5 Return `{:error, :not_at_nest}` if not at nest
- [ ] 5.2.2.6 Use `Agent.at_nest?/1` for nest position check

### 5.2.3 Food Deposit
- [ ] **Task 5.2.3** Implement food deposit logic.

- [ ] 5.2.3.1 Get carried_food_level from agent state
- [ ] 5.2.3.2 Emit signal with food deposit information
- [ ] 5.2.3.3 Signal format: `{:food_deposited, ant_id, food_level, position}`
- [ ] 5.2.3.4 Colony food counter updated by listener (not in this action)
- [ ] 5.2.3.5 Write unit tests for food deposit

### 5.2.4 Agent State Reset
- [ ] **Task 5.2.4** Reset agent state after dropping food.

- [ ] 5.2.4.1 Set `has_food?` to false
- [ ] 5.2.4.2 Set `carried_food_level` to nil
- [ ] 5.2.4.3 Replenish energy to full (100)
- [ ] 5.2.4.4 Clear path_memory (reset to nest position only)
- [ ] 5.2.4.5 Return `{:ok, updated_agent, directives}`
- [ ] 5.2.4.6 Include directive to transition to :at_nest or :searching state
- [ ] 5.2.4.7 Write unit tests for state reset

**Unit Tests for Section 5.2:**
- Test DropFoodAction fails if not carrying
- Test DropFoodAction fails if not at nest
- Test DropFoodAction succeeds at nest with food
- Test DropFoodAction resets has_food? to false
- Test DropFoodAction resets carried_food_level to nil
- Test DropFoodAction replenishes energy
- Test DropFoodAction clears path_memory
- Test DropFoodAction emits food_deposited signal
- Test DropFoodAction includes state transition directive

---

## 5.3 RetracePathAction

Implement the action that enables ants to follow their path memory back to the nest.

### 5.3.1 RetracePathAction Module Structure
- [ ] **Task 5.3.1** Create the RetracePathAction module.

- [ ] 5.3.1.1 Create `lib/jido_ants/actions/retrace_path.ex` with module documentation
- [ ] 5.3.1.2 Add `use Jido.Action` with schema:
  ```elixir
  use Jido.Action,
    schema: [
      steps: [type: :integer, default: 1]
    ]
  ```
- [ ] 5.3.1.3 Define `@descript "Move backward along path memory toward nest"`
- [ ] 5.3.1.4 Implement `run/2` callback

### 5.3.2 Path Retracing Logic
- [ ] **Task 5.3.2** Implement path retracing.

- [ ] 5.3.2.1 Get agent path_memory from context
- [ ] 5.3.2.2 Validate path_memory has entries (not at nest)
- [ ] 5.3.2.3 Return `{:error, :at_nest}` if path_memory only has nest position
- [ ] 5.3.2.4 Calculate return path: reverse path_memory and drop current position
- [ ] 5.3.2.5 Take next N positions from return path based on steps parameter
- [ ] 5.3.2.6 Move to next position in return path

### 5.3.3 Multi-Step Retracing
- [ ] **Task 5.3.3** Handle multi-step retracing.

- [ ] 5.3.3.1 For steps > 1, move multiple positions
- [ ] 5.3.3.2 Stop if nest position reached (regardless of remaining steps)
- [ ] 5.3.3.3 Validate each intermediate position
- [ ] 5.3.3.4 Update path_memory by removing visited positions
- [ ] 5.3.3.5 Return actual steps taken (may be less than requested)
- [ ] 5.3.3.6 Write unit tests for multi-step retracing

### 5.3.4 Nest Arrival
- [ ] **Task 5.3.4** Handle arrival at nest during retracing.

- [ ] 5.3.4.1 Detect when next position equals nest_position
- [ ] 5.3.4.2 Move to nest position
- [ ] 5.3.4.3 Reset path_memory to only nest position
- [ ] 5.3.4.4 Emit directive to transition to :at_nest state
- [ ] 5.3.4.5 Include directive to execute DropFoodAction if carrying food
- [ ] 5.3.4.6 Write unit tests for nest arrival

**Unit Tests for Section 5.3:**
- Test RetracePathAction fails if at nest (empty return path)
- Test RetracePathAction moves to previous position
- Test RetracePathAction updates path_memory (removes visited)
- Test RetracePathAction with steps > 1 moves multiple positions
- Test RetracePathAction stops at nest even with steps remaining
- Test RetracePathAction consumes energy per step
- Test RetracePathAction emits :at_nest transition when nest reached
- Test RetracePathAction includes DropFoodAction directive when carrying food

---

## 5.4 Food Transport State Management

Implement the state machine logic for managing food transport throughout the foraging cycle.

### 5.4.1 Foraging State Transitions
- [ ] **Task 5.4.1** Define state transitions for foraging cycle.

- [ ] 5.4.1.1 Define :searching → :returning_to_nest transition trigger
  - Occurs when PickUpFoodAction succeeds
- [ ] 5.4.1.2 Define :returning_to_nest → :at_nest transition trigger
  - Occurs when RetracePathAction reaches nest
- [ ] 5.4.1.3 Define :at_nest → :searching transition trigger
  - Occurs after DropFoodAction completes
- [ ] 5.4.1.4 Add FSM transitions to FSMStrategy configuration
- [ ] 5.4.1.5 Write unit tests for foraging state transitions

### 5.4.2 Foraging Skill
- [ ] **Task 5.4.2** Create ForagingSkill grouping foraging actions.

- [ ] 5.4.2.1 Create `lib/jido_ants/skills/foraging.ex` with module documentation
- [ ] 5.4.2.2 Add `use Jido.Skill`
- [ ] 5.4.2.3 Define skill schema with foraging-specific state
- [ ] 5.4.2.4 Include PickUpFoodAction, DropFoodAction, RetracePathAction
- [ ] 5.4.2.5 Implement `mount/1` callback for skill initialization
- [ ] 5.4.2.6 Implement `unmount/1` callback for cleanup
- [ ] 5.4.2.7 Write unit tests for ForagingSkill

### 5.4.3 Foraging Orchestrator
- [ ] **Task 5.4.3** Create orchestrator for complete foraging cycle.

- [ ] 5.4.3.1 Create `lib/jido_ants/foraging_orchestrator.ex`
- [ ] 5.4.3.2 Implement `start_foraging/1` initiating search behavior
- [ ] 5.4.3.3 Implement `handle_food_found/2` processing food discovery
- [ ] 5.4.3.4 Implement `initiate_return/1` starting return journey
- [ ] 5.4.3.5 Implement `complete_delivery/1` handling food deposit
- [ ] 5.4.3.6 Write unit tests for orchestrator

**Unit Tests for Section 5.4:**
- Test :searching → :returning_to_nest on food pickup
- Test :returning_to_nest → :at_nest on nest arrival
- Test :at_nest → :searching after food drop
- Test ForagingSkill mounts correctly
- Test ForagingSkill includes foraging actions
- Test ForagingSkill initializes state
- Test orchestrator manages complete foraging cycle

---

## 5.5 Phase 5 Integration Tests

Comprehensive integration tests verifying all Phase 5 components work together correctly.

### 5.5.1 Complete Foraging Cycle Integration
- [ ] **Task 5.5.1** Test end-to-end foraging cycle.

- [ ] 5.5.1.1 Create `test/jido_ants/integration/foraging_phase5_test.exs`
- [ ] 5.5.1.2 Test: Ant at nest → search → find food → pick up → return → drop food
- [ ] 5.5.1.3 Test: Verify state transitions: at_nest → searching → returning_to_nest → at_nest
- [ ] 5.5.1.4 Test: Verify path_memory accumulates during search
- [ ] 5.5.1.5 Test: Verify path_memory consumed during return
- [ ] 5.5.1.6 Test: Verify food quantity decreases on pickup
- [ ] 5.5.1.7 Test: Verify energy replenished at nest
- [ ] 5.5.1.8 Write all foraging cycle integration tests

### 5.5.2 Multiple Trips Integration
- [ ] **Task 5.5.2** Test multiple foraging trips by same ant.

- [ ] 5.5.2.1 Test: Complete first trip → immediately start second trip
- [ ] 5.5.2.2 Test: Verify path_memory cleared between trips
- [ ] 5.5.2.3 Test: Verify energy reset between trips
- [ ] 5.5.2.4 Test: Continue until food source depleted
- [ ] 5.5.2.5 Test: Ant returns to nest empty-handed when source depleted
- [ ] 5.5.2.6 Write all multi-trip integration tests

### 5.5.3 Food Source Depletion Integration
- [ ] **Task 5.5.3** Test food source depletion across foraging.

- [ ] 5.5.3.1 Test: Multiple ants forage from same source
- [ ] 5.5.3.2 Test: Verify source quantity decreases with each pickup
- [ ] 5.5.3.3 Test: Verify source removed when quantity reaches 0
- [ ] 5.5.3.4 Test: Ants arriving after depletion find no food
- [ ] 5.5.3.5 Test: Known food sources updated on depletion
- [ ] 5.5.3.6 Write all depletion integration tests

**Integration Tests for Section 5.5:**
- Complete foraging cycle works end-to-end
- State transitions occur correctly
- Path memory managed properly
- Food source depletion handled correctly
- Multiple trips work seamlessly

---

## Success Criteria

1. **PickUpFoodAction**: Ants pick up food when found
2. **DropFoodAction**: Ants drop food at nest
3. **RetracePathAction**: Ants return to nest following path memory
4. **State Transitions**: FSM transitions through foraging states
5. **ForagingSkill**: Actions grouped in reusable skill
6. **Energy Management**: Energy consumed and replenished appropriately
7. **Path Memory**: Accumulates during search, consumed during return
8. **Food Depletion**: Source quantity tracked and removed when depleted
9. **Test Coverage**: Minimum 80% coverage for phase 5 code
10. **Integration Tests**: All Phase 5 components work together (Section 5.5)

---

## Critical Files

**New Files:**
- `lib/jido_ants/actions/pick_up_food.ex`
- `lib/jido_ants/actions/drop_food.ex`
- `lib/jido_ants/actions/retrace_path.ex`
- `lib/jido_ants/skills/foraging.ex`
- `lib/jido_ants/foraging_orchestrator.ex`
- `test/jido_ants/actions/pick_up_food_test.exs`
- `test/jido_ants/actions/drop_food_test.exs`
- `test/jido_ants/actions/retrace_path_test.exs`
- `test/jido_ants/skills/foraging_test.exs`
- `test/jido_ants/integration/foraging_phase5_test.exs`

**Modified Files:**
- `lib/jido_ants/agent/fsm_strategy.ex` - Add foraging state transitions
- `lib/jido_ants/agent/ant.ex` - Add foraging state helpers

---

## Dependencies

- **Depends on Phase 1**: FoodSource types
- **Depends on Phase 2**: PlaneServer for food operations
- **Depends on Phase 3**: AntAgent for state management
- **Depends on Phase 4**: Movement for traveling to/from food
- **Phase 6 depends on this**: Pheromone laying during return trip
- **Phase 7 depends on this**: Communication about food sources
