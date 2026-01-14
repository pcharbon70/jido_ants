# Feature: Phase 1.2.3 - Create Broadcast Helper Functions

## Description
Implement section 1.2.3 of the Phase 1.2 PubSub Configuration plan: Create Broadcast Helper Functions with error handling and metadata.

## Branch
`feature/phase1.2.3-broadcast-helpers`

## Tasks from Plan

### 1.2.3.1 Implement Error Handling
- [x] Add try/rescue to broadcast_ant_moved for unexpected errors
- [x] Add try/rescue to broadcast_food_sensed for unexpected errors
- [x] Add try/rescue to broadcast_ant_state_changed for unexpected errors
- [x] Log errors using `require Logger` and `Logger.error/1`

### 1.2.3.2 Add Event Metadata
- [x] Implement `get_timestamp/0` returning `DateTime.utc_now()`
- [x] Add optional metadata map to broadcast functions
- [x] Include timestamp in event metadata when provided
- [x] Document metadata usage in @moduledoc

## Implementation Notes

- Wrapped all broadcast functions in try/rescue via `do_broadcast/4` helper
- Logger.error for logging exceptions with stacktrace
- Metadata is optional keyword list parameter (opts \\ [])
- Timestamp automatically added to metadata map
- Events are now 3-element tuples: {event_type, event_data, metadata}
- User metadata added when opts list is non-empty

## Files Modified

### Modified
- `lib/ant_colony/events.ex` - Added error handling and metadata to broadcast functions

## Verification

```
$ mix compile
Compiling 1 file (.ex)
Generated ant_colony app

$ mix test
Running ExUnit with seed: 313305, max_cases: 40
Excluding tags: [skip: true]
...............
Finished in 3.7 seconds (0.00s async, 3.7s sync)
1 doctest, 25 tests, 0 failures, 1 excluded
```

## Status

**Completed**
