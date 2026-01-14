# Phase 4.4: Observability and Logging

Implement comprehensive observability infrastructure for the ant colony simulation. This cycle adds structured logging, telemetry events, metrics collection, and tracing capabilities to provide deep insight into simulation behavior, performance, and emergent patterns.

## Architecture

```
Observability Infrastructure
├── Structured Logging
│   ├── Logger Configuration
│   ├── Log Levels (:debug, :info, :warn, :error)
│   ├── JSON Format Output
│   ├── Contextual Metadata
│   └── Log Aggregation
│
├── Telemetry Events
│   [:ant_colony, :action, :execute]
│   [:ant_colony, :agent, :state_changed]
│   [:ant_colony, :plane, :food_updated]
│   [:ant_colony, :communication, :encounter]
│   [:ant_colony, :ml, :model_updated]
│   [:ant_colony, :pheromone, :laid]
│   [:ant_colony, :simulation, :tick]
│   [:ant_colony, :generation, :started] (NEW)
│   [:ant_colony, :generation, :ended] (NEW)
│   [:ant_colony, :generation, :kpi_updated] (NEW)
│   [:ant_colony, :generation, :breeding_completed] (NEW)
│
├── Metrics Collection
│   ├── Agent Count by State
│   ├── Food Collection Rate
│   ├── Pheromone Evaporation Cycles
│   ├── ML Training Progress
│   ├── UI Frame Rate
│   ├── Memory Usage
│   ├── Message Queue Lengths
│   ├── Generation KPIs (NEW)
│   └── Historical KPI Trends (NEW)
│
├── Tracing
│   ├── Action Execution Traces
│   ├── Agent Lifecycle Traces
│   ├── Communication Traces
│   ├── Request-Response Correlation
│   └── Generation Transition Traces (NEW)
│
└── Jido Integration
    ├── Jido.Observe
    ├── Jido.Telemetry
    └── Jido.AgentServer.status/1
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| Logger Configuration | Configure structured logging with metadata |
| Telemetry Handlers | Process and emit telemetry events |
| Metrics Collectors | Gather and aggregate system metrics |
| Tracing Module | Correlate related events across components |
| Observability API | Query and retrieve observability data |

---

## 4.4.1 Configure Structured Logging

Set up Elixir's Logger for structured, contextual logging throughout the system.

### 4.4.1.1 Logger Configuration

Configure Logger with appropriate backends and formatters.

- [ ] 4.4.1.1.1 Add `:logger` configuration to `config/config.exs`
- [ ] 4.4.1.1.2 Configure `LoggerJSONBackend` for structured output
- [ ] 4.4.1.1.3 Set log level based on environment (`:debug` for dev, `:info` for prod)
- [ ] 4.4.1.1.4 Add metadata fields: `:module`, `:function`, `:ant_id`, `:plane_id`
- [ ] 4.4.1.1.5 Configure log file rotation for long-running simulations

### 4.4.1.2 Create Logging Helper Module

Create a centralized logging module with domain-specific log functions.

- [ ] 4.4.1.2.1 Create `lib/ant_colony/observability/logger.ex`
- [ ] 4.4.1.2.2 Add `defmodule AntColony.Observability.Logger`
- [ ] 4.4.1.2.3 Define `log_action/3` for action execution logging
- [ ] 4.4.1.2.4 Define `log_state_change/3` for agent state transitions
- [ ] 4.4.1.2.5 Define `log_event/3` for general simulation events
- [ ] 4.4.1.2.6 Define `log_communication/3` for agent communication events
- [ ] 4.4.1.2.7 Define `log_error/3` for error conditions with stack traces

### 4.4.1.3 Integrate Logging into Actions

Add logging calls throughout action execution.

- [ ] 4.4.1.3.1 Add `log_action/3` to `MoveAction.run/2`
- [ ] 4.4.1.3.2 Add `log_action/3` to `SenseFoodAction.run/2`
- [ ] 4.4.1.3.3 Add `log_action/3` to `PickUpFoodAction.run/2`
- [ ] 4.4.1.3.4 Add `log_action/3` to `DropFoodAction.run/2`
- [ ] 4.4.1.3.5 Add `log_action/3` to `LayPheromoneAction.run/2`
- [ ] 4.4.1.3.6 Add `log_action/3` to `SensePheromoneAction.run/2`
- [ ] 4.4.1.3.7 Add `log_action/3` to `CommunicateAction.run/2`
- [ ] 4.4.1.3.8 Add `log_action/3` to ML-related actions

### 4.4.1.4 Integrate Logging into Plane

Add logging for Plane state changes.

- [ ] 4.4.1.4.1 Add food pickup logging to `Plane.pickup_food/2`
- [ ] 4.4.1.4.2 Add food deposit logging to `Plane.deposit_food/2`
- [ ] 4.4.1.4.3 Add pheromone lay logging to `Plane.add_pheromone/3`
- [ ] 4.4.1.4.4 Add pheromone evaporation logging
- [ ] 4.4.1.4.5 Add agent registration/deregistration logging

### 4.4.1.5 Integrate Logging into Agent

Add logging for agent lifecycle and state changes.

- [ ] 4.4.1.5.1 Add agent initialization logging
- [ ] 4.4.1.5.2 Add state transition logging via `log_state_change/3`
- [ ] 4.4.1.5.3 Add communication event logging
- [ ] 4.4.1.5.4 Add death/removal logging

### 4.4.1.6 Unit Tests for Logger

Test the logging infrastructure.

- [ ] 4.4.1.6.1 Test `log_action/3` emits correct log with metadata
- [ ] 4.4.1.6.2 Test `log_state_change/3` includes old and new state
- [ ] 4.4.1.6.3 Test `log_communication/3` includes both agents
- [ ] 4.4.1.6.4 Test `log_error/3` includes stack trace
- [ ] 4.4.1.6.5 Test Logger configuration loads correctly
- [ ] 4.4.1.6.6 Test log level filtering works

---

## 4.4.2 Implement Telemetry Events

Set up `:telemetry` for event emission and handling throughout the system.

### 4.4.2.1 Configure Telemetry

Add and configure the telemetry library.

- [ ] 4.4.2.1.1 Add `{:telemetry, "~> 1.0"}` to `mix.exs` deps
- [ ] 4.4.2.1.2 Create `lib/ant_colony/observability/telemetry.ex`
- [ ] 4.4.2.1.3 Add `defmodule AntColony.Observability.Telemetry`
- [ ] 4.4.2.1.4 Define event name constants as module attributes

### 4.4.2.2 Define Telemetry Event Schemas

Document all telemetry events with their metadata structure.

- [ ] 4.4.2.2.1 Define `[:ant_colony, :action, :execute]` event:
  - Measurements: `duration` (native time)
  - Metadata: `action_name`, `ant_id`, `result`
- [ ] 4.4.2.2.2 Define `[:ant_colony, :agent, :state_changed]` event:
  - Measurements: `duration`
  - Metadata: `ant_id`, `old_state`, `new_state`, `reason`
- [ ] 4.4.2.2.3 Define `[:ant_colony, :plane, :food_updated]` event:
  - Measurements: `new_quantity`
  - Metadata: `position`, `delta`, `source` (pickup/deposit/spawn)
- [ ] 4.4.2.2.4 Define `[:ant_colony, :communication, :encounter]` event:
  - Measurements: `distance`
  - Metadata: `agent1_id`, `agent2_id`, `info_exchanged`
- [ ] 4.4.2.2.5 Define `[:ant_colony, :ml, :model_updated]` event:
  - Measurements: `training_time`, `loss`
  - Metadata: `model_version`, `sample_count`, `accuracy`
- [ ] 4.4.2.2.6 Define `[:ant_colony, :pheromone, :laid]` event:
  - Measurements: `amount`
  - Metadata: `position`, `ant_id`, `pheromone_type`
- [ ] 4.4.2.2.7 Define `[:ant_colony, :simulation, :tick]` event:
  - Measurements: `tick_duration`
  - Metadata: `tick_number`, `active_agent_count`
- [ ] 4.4.2.2.8 Define `[:ant_colony, :generation, :started]` event (NEW):
  - Measurements: `generation_duration` (0 at start)
  - Metadata: `generation_id`, `start_time`, `parent_generation_id`
- [ ] 4.4.2.2.9 Define `[:ant_colony, :generation, :ended]` event (NEW):
  - Measurements: `generation_duration`, `food_collected`
  - Metadata: `generation_id`, `end_reason` (plateau/training_complete/manual)
- [ ] 4.4.2.2.10 Define `[:ant_colony, :generation, :kpi_updated]` event (NEW):
  - Measurements: kpi values
  - Metadata: `generation_id`, `kpi_name`, `value`
- [ ] 4.4.2.2.11 Define `[:ant_colony, :generation, :breeding_completed]` event (NEW):
  - Measurements: `breeding_duration`
  - Metadata: `generation_id`, `parent_count`, `offspring_count`

### 4.4.2.3 Create Telemetry Emitter Functions

Create helper functions to emit telemetry events consistently.

- [ ] 4.4.2.3.1 Define `emit_action_execute/4` helper
- [ ] 4.4.2.3.2 Define `emit_state_change/4` helper
- [ ] 4.4.2.3.3 Define `emit_food_updated/4` helper
- [ ] 4.4.2.3.4 Define `emit_communication/4` helper
- [ ] 4.4.2.3.5 Define `emit_ml_updated/4` helper
- [ ] 4.4.2.3.6 Define `emit_pheromone_laid/4` helper
- [ ] 4.4.2.3.7 Define `emit_simulation_tick/3` helper
- [ ] 4.4.2.3.8 Define `emit_generation_started/3` helper (NEW)
- [ ] 4.4.2.3.9 Define `emit_generation_ended/4` helper (NEW)
- [ ] 4.4.2.3.10 Define `emit_kpi_updated/4` helper (NEW)
- [ ] 4.4.2.3.11 Define `emit_breeding_completed/4` helper (NEW)

### 4.4.2.4 Integrate Telemetry into Actions

Wrap action execution with telemetry.

- [ ] 4.4.2.4.1 Add telemetry to `MoveAction.run/2`
- [ ] 4.4.2.4.2 Add telemetry to `SenseFoodAction.run/2`
- [ ] 4.4.2.4.3 Add telemetry to `PickUpFoodAction.run/2`
- [ ] 4.4.2.4.4 Add telemetry to `DropFoodAction.run/2`
- [ ] 4.4.2.4.5 Add telemetry to `LayPheromoneAction.run/2`
- [ ] 4.4.2.4.6 Add telemetry to `SensePheromoneAction.run/2`
- [ ] 4.4.2.4.7 Add telemetry to `CommunicateAction.run/2`

### 4.4.2.5 Integrate Telemetry into Plane

Emit telemetry for Plane state changes.

- [ ] 4.4.2.5.1 Emit telemetry on `pickup_food/2`
- [ ] 4.4.2.5.2 Emit telemetry on `deposit_food/2`
- [ ] 4.4.2.5.3 Emit telemetry on `add_pheromone/3`
- [ ] 4.4.2.5.4 Emit telemetry on pheromone evaporation

### 4.4.2.6 Integrate Telemetry into Agent

Emit telemetry for agent state changes.

- [ ] 4.4.2.6.1 Emit telemetry on state transition
- [ ] 4.4.2.6.2 Emit telemetry on communication encounters
- [ ] 4.4.2.6.3 Emit telemetry on agent death

### 4.4.2.7 Integrate Telemetry into ColonyIntelligenceAgent (NEW)

Emit telemetry for generation lifecycle events.

- [ ] 4.4.2.7.1 Emit telemetry on generation start
- [ ] 4.4.2.7.2 Emit telemetry on generation end
- [ ] 4.4.2.7.3 Emit telemetry on KPI updates
- [ ] 4.4.2.7.4 Emit telemetry on breeding completion
- [ ] 4.4.2.7.5 Emit telemetry on plateau detection
- [ ] 4.4.2.7.6 Emit telemetry on manual generation trigger

### 4.4.2.8 Unit Tests for Telemetry

Test telemetry event emission.

- [ ] 4.4.2.8.1 Test `emit_action_execute/4` emits correct event
- [ ] 4.4.2.8.2 Test `emit_state_change/4` includes state values
- [ ] 4.4.2.8.3 Test `emit_food_updated/4` measures quantity
- [ ] 4.4.2.8.4 Test `emit_communication/4` includes both agents
- [ ] 4.4.2.8.5 Test `emit_ml_updated/4` includes training metrics
- [ ] 4.4.2.8.6 Test telemetry emitted from actual Action execution
- [ ] 4.4.2.8.7 Test telemetry emitted from Plane operations
- [ ] 4.4.2.8.8 Test telemetry emitted from Agent operations
- [ ] 4.4.2.8.9 Test generation telemetry emitted correctly (NEW)

---

## 4.4.3 Implement Metrics Collection

Create a metrics collection system that aggregates telemetry data into useful statistics.

### 4.4.3.1 Create Metrics Collector

Implement a GenServer to collect and aggregate metrics.

- [ ] 4.4.3.1.1 Create `lib/ant_colony/observability/metrics.ex`
- [ ] 4.4.3.1.2 Add `defmodule AntColony.Observability.Metrics`
- [ ] 4.4.3.1.3 Add `use GenServer`
- [ ] 4.4.3.1.4 Define `defstruct` for metrics state:
  - `:agent_counts` - map of state to count
  - `:food_collected` - total units
  - `:food_collection_rate` - units per minute
  - `:pheromone_cycles` - count of evaporation cycles
  - `:ml_trainings` - count and success rate
  - `:ui_fps` - current frame rate
  - `:memory_usage` - MB
  - `:message_queue_lengths` - map of process to length
  - `:current_generation_id` - current generation (NEW)
  - `:generation_kpis` - current generation KPIs (NEW)
  - `:generation_history` - historical KPIs per generation (NEW)
- [ ] 4.4.3.1.5 Add `@type` specifications

### 4.4.3.2 Implement Metrics Collection

Collect metrics from various sources.

- [ ] 4.4.3.2.1 Implement periodic agent count sampling
- [ ] 4.4.3.2.2 Calculate food collection rate from telemetry
- [ ] 4.4.3.2.3 Count pheromone evaporation cycles
- [ ] 4.4.3.2.4 Track ML training events
- [ ] 4.4.3.2.5 Sample UI frame rate from TermUI events
- [ ] 4.4.3.2.6 Read memory usage from `:erlang.memory/0`
- [ ] 4.4.3.2.7 Sample message queue lengths from `Process.info/2`
- [ ] 4.4.3.2.8 Track current_generation_id from ColonyIntelligenceAgent (NEW)
- [ ] 4.4.3.2.9 Collect generation KPIs on generation end (NEW)
- [ ] 4.4.3.2.10 Store generation KPIs in history (NEW)

### 4.4.3.3 Implement Metrics Query API

Create client functions to query metrics.

- [ ] 4.4.3.3.1 Define `def get_metrics/0` - returns all metrics
- [ ] 4.4.3.3.2 Define `def get_agent_counts/0` - returns state distribution
- [ ] 4.4.3.3.3 Define `def get_food_stats/0` - returns collection metrics
- [ ] 4.4.3.3.4 Define `def get_pheromone_stats/0` - returns pheromone metrics
- [ ] 4.4.3.3.5 Define `def get_ml_stats/0` - returns ML metrics
- [ ] 4.4.3.3.6 Define `def get_performance_stats/0` - returns FPS, memory, queues
- [ ] 4.4.3.3.7 Define `def get_generation_kpis/0` - returns current generation KPIs (NEW)
- [ ] 4.4.3.3.8 Define `def get_generation_history/0` - returns all generation KPIs (NEW)
- [ ] 4.4.3.3.9 Define `def get_generation_kpi(generation_id)` - returns specific generation KPIs (NEW)

### 4.4.3.4 Implement Metrics Reporting

Create periodic metrics reporting.

- [ ] 4.4.3.4.1 Add `handle_info` for periodic metrics snapshots
- [ ] 4.4.3.4.2 Store historical metrics for trend analysis
- [ ] 4.4.3.4.3 Implement sliding window for rate calculations
- [ ] 4.4.3.4.4 Add metrics reset functionality
- [ ] 4.4.3.4.5 Store generation KPIs on generation end (NEW)
- [ ] 4.4.3.4.6 Implement generation KPI trend tracking (NEW)

### 4.4.3.5 Unit Tests for Metrics

Test metrics collection and aggregation.

- [ ] 4.4.3.5.1 Test metrics initialization
- [ ] 4.4.3.5.2 Test agent count sampling
- [ ] 4.4.3.5.3 Test food collection rate calculation
- [ ] 4.4.3.5.4 Test memory usage sampling
- [ ] 4.4.3.5.5 Test message queue length sampling
- [ ] 4.4.3.5.6 Test `get_metrics/0` returns all fields
- [ ] 4.4.3.5.7 Test metrics reset functionality
- [ ] 4.4.3.5.8 Test sliding window rate calculations
- [ ] 4.4.3.5.9 Test generation KPI tracking (NEW)
- [ ] 4.4.3.5.10 Test generation history storage (NEW)

---

## 4.4.4 Implement Tracing

Add distributed tracing capabilities to correlate related events.

### 4.4.4.1 Create Tracing Module

Implement tracing for action execution flows.

- [ ] 4.4.4.1.1 Create `lib/ant_colony/observability/tracing.ex`
- [ ] 4.4.4.1.2 Add `defmodule AntColony.Observability.Tracing`
- [ ] 4.4.4.1.3 Define trace context struct with `trace_id` and `span_id`
- [ ] 4.4.4.1.4 Add `def new_trace/0` - generates unique trace ID
- [ ] 4.4.4.1.5 Add `def new_span/1` - generates unique span ID
- [ ] 4.4.4.1.6 Add `def start_span/2` - begins a traced operation
- [ ] 4.4.4.1.7 Add `def end_span/2` - completes a traced operation

### 4.4.4.2 Integrate Tracing into Actions

Add automatic tracing to action execution.

- [ ] 4.4.4.2.1 Create `def trace_action/3` wrapper macro
- [ ] 4.4.4.2.2 Apply tracing to `MoveAction.run/2`
- [ ] 4.4.4.2.3 Apply tracing to `SenseFoodAction.run/2`
- [ ] 4.4.4.2.4 Apply tracing to `PickUpFoodAction.run/2`
- [ ] 4.4.4.2.5 Apply tracing to `DropFoodAction.run/2`
- [ ] 4.4.4.2.6 Apply tracing to `LayPheromoneAction.run/2`
- [ ] 4.4.4.2.7 Apply tracing to `CommunicateAction.run/2`

### 4.4.4.3 Integrate Tracing into Agent

Add tracing for agent lifecycle events.

- [ ] 4.4.4.3.1 Trace agent initialization
- [ ] 4.4.4.3.2 Trace state transitions with parent trace from action
- [ ] 4.4.4.3.3 Trace communication events between agents

### 4.4.4.4 Integrate Tracing into Generation Transitions (NEW)

Add tracing for generation lifecycle.

- [ ] 4.4.4.4.1 Trace generation start with generation_id
- [ ] 4.4.4.4.2 Trace evaluation phase with ranked agents
- [ ] 4.4.4.4.3 Trace breeding phase with parent/offspring
- [ ] 4.4.4.4.4 Trace spawning phase with new generation_id
- [ ] 4.4.4.4.5 Link generation spans across the full transition

### 4.4.4.5 Implement Trace Storage

Store traces for querying and analysis.

- [ ] 4.4.4.5.1 Create `TraceStore` GenServer for trace storage
- [ ] 4.4.4.5.2 Implement ring buffer for recent traces (limit: 1000)
- [ ] 4.4.4.5.3 Add `def get_trace/1` - retrieve by trace_id
- [ ] 4.4.4.5.4 Add `def get_recent_traces/1` - retrieve N recent traces
- [ ] 4.4.4.5.5 Add `def get_traces_for_ant/1` - retrieve by ant_id
- [ ] 4.4.4.5.6 Add `def get_traces_for_generation/1` - retrieve by generation_id (NEW)

### 4.4.4.6 Unit Tests for Tracing

Test tracing functionality.

- [ ] 4.4.4.6.1 Test `new_trace/0` generates unique IDs
- [ ] 4.4.4.6.2 Test `new_span/1` generates unique IDs
- [ ] 4.4.4.6.3 Test `start_span/2` and `end_span/2` correlate
- [ ] 4.4.4.6.4 Test `trace_action/3` wraps execution correctly
- [ ] 4.4.4.6.5 Test trace storage and retrieval
- [ ] 4.4.4.6.6 Test ring buffer eviction
- [ ] 4.4.4.6.7 Test `get_traces_for_ant/1` filtering
- [ ] 4.4.4.6.8 Test generation span linking (NEW)
- [ ] 4.4.4.6.9 Test `get_traces_for_generation/1` (NEW)

---

## 4.4.5 Integrate Jido Observability

Leverage Jido's built-in observability features.

### 4.4.5.1 Integrate Jido.Observe

Use Jido's observation capabilities.

- [ ] 4.4.5.1.1 Review Jido.Observe API documentation
- [ ] 4.4.5.1.2 Attach Jido.Observe to AntAgent processes
- [ ] 4.4.5.1.3 Attach Jido.Observe to ColonyIntelligenceAgent (NEW)
- [ ] 4.4.5.1.4 Configure observation handlers for agent events
- [ ] 4.4.5.1.5 Forward observed events to telemetry

### 4.4.5.2 Integrate Jido.Telemetry

Use Jido's telemetry integration.

- [ ] 4.4.5.2.1 Review Jido.Telemetry API documentation
- [ ] 4.4.5.2.2 Attach Jido.Telemetry handlers
- [ ] 4.4.5.2.3 Subscribe to Jido action telemetry events
- [ ] 4.4.5.2.4 Correlate Jido events with ant colony events

### 4.4.5.3 Use Jido.AgentServer.status/1

Leverage built-in agent status inspection.

- [ ] 4.4.5.3.1 Create helper: `def inspect_agent/1`
- [ ] 4.4.5.3.2 Use `Jido.AgentServer.status/1` to query agent state
- [ ] 4.4.5.3.3 Format status output for debugging
- [ ] 4.4.5.3.4 Add CLI command for agent inspection

### 4.4.5.4 Unit Tests for Jido Integration

Test Jido observability integration.

- [ ] 4.4.5.4.1 Test Jido.Observe attachment
- [ ] 4.4.5.4.2 Test event forwarding to telemetry
- [ ] 4.4.5.4.3 Test `inspect_agent/1` returns correct status
- [ ] 4.4.5.4.4 Test Jido.Telemetry event correlation

---

## 4.4.6 Create Observability CLI

Create command-line tools for querying observability data.

### 4.4.6.1 Create Mix Tasks

Create mix tasks for observability queries.

- [ ] 4.4.6.1.1 Create `mix ant.metrics` task
- [ ] 4.4.6.1.2 Create `mix ant.logs` task (with filtering)
- [ ] 4.4.6.1.3 Create `mix ant.traces` task
- [ ] 4.4.6.1.4 Create `mix ant.inspect` task for agent inspection

### 4.4.6.2 Implement Metrics Display

Format and display metrics.

- [ ] 4.4.6.2.1 Format metrics as table
- [ ] 4.4.6.2.2 Color-code metric values (warning thresholds)
- [ ] 4.4.6.2.3 Support JSON output format
- [ ] 4.4.6.2.4 Add filtering by metric type

### 4.4.6.3 Implement Log Query

Query and display logs.

- [ ] 4.4.6.3.1 Filter logs by level
- [ ] 4.4.6.3.2 Filter logs by module
- [ ] 4.4.6.3.3 Filter logs by ant_id
- [ ] 4.4.6.3.4 Support tailing logs (follow mode)

### 4.4.6.4 Implement Trace Display

Format and display traces.

- [ ] 4.4.6.4.1 Display trace as tree of spans
- [ ] 4.4.6.4.2 Show span durations
- [ ] 4.4.6.4.3 Highlight slow spans
- [ ] 4.4.6.4.4 Support filtering by ant_id

### 4.4.6.5 Unit Tests for Observability CLI

Test CLI functionality.

- [ ] 4.4.6.5.1 Test `mix ant.metrics` displays metrics
- [ ] 4.4.6.5.2 Test `mix ant.logs` filters correctly
- [ ] 4.4.6.5.3 Test `mix ant.traces` displays trace tree
- [ ] 4.4.6.5.4 Test `mix ant.inspect` shows agent status
- [ ] 4.4.6.5.5 Test JSON output format

---

## 4.4 Phase 4.4 Integration Tests

### 4.4.1 End-to-End Observability Tests

Test observability across the full system.

- [ ] 4.4.1.1 Verify telemetry events emitted during full simulation
- [ ] 4.4.1.2 Verify metrics reflect actual simulation state
- [ ] 4.4.1.3 Verify traces correlate action sequences
- [ ] 4.4.1.4 Verify logs contain contextual metadata
- [ ] 4.4.1.5 Verify CLI tools return correct data

### 4.4.2 Observability Performance Tests

Ensure observability doesn't degrade simulation performance.

- [ ] 4.4.2.1 Measure telemetry overhead
- [ ] 4.4.2.2 Measure logging overhead
- [ ] 4.4.2.3 Measure metrics collection overhead
- [ ] 4.4.2.4 Verify trace storage doesn't cause memory issues

## Phase 4.4 Success Criteria

1. **Structured Logging**: All components log with consistent metadata ✅
2. **Telemetry Events**: All key events emit telemetry ✅
3. **Metrics Collection**: System metrics collected and queryable ✅
4. **Tracing**: Action execution traces captured and correlated ✅
5. **Jido Integration**: Jido observability features leveraged ✅
6. **CLI Tools**: Mix tasks for querying observability data ✅
7. **Generation Telemetry**: Generation lifecycle events emitted ✅
8. **Generation KPIs**: Historical KPIs tracked and queryable ✅
9. **Generation Traces**: Generation transition spans captured ✅

## Phase 4.4 Critical Files

**New Files:**
- `lib/ant_colony/observability/logger.ex`
- `lib/ant_colony/observability/telemetry.ex`
- `lib/ant_colony/observability/metrics.ex`
- `lib/ant_colony/observability/tracing.ex`
- `lib/ant_colony/observability/trace_store.ex`
- `lib/mix/tasks/ant/metrics.ex`
- `lib/mix/tasks/ant/logs.ex`
- `lib/mix/tasks/ant/traces.ex`
- `lib/mix/tasks/ant/inspect.ex`

**Modified Files:**
- `config/config.exs` - Logger configuration
- All Action modules - telemetry and logging calls
- `lib/ant_colony/plane.ex` - telemetry and logging calls
- `lib/ant_colony/agent.ex` - telemetry and logging calls
- `lib/ant_colony/colony_intelligence_agent.ex` - generation telemetry (NEW)
- `mix.exs` - telemetry dependency

**Test Files:**
- `test/ant_colony/observability/logger_test.exs`
- `test/ant_colony/observability/telemetry_test.exs`
- `test/ant_colony/observability/metrics_test.exs`
- `test/ant_colony/observability/tracing_test.exs`
- `test/ant_colony/observability/observability_integration_test.exs`
