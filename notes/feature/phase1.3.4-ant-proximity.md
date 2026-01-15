# Feature: Phase 1.3.4 - Ant Position Registry (Proximity Detection)

## Description
Implement section 1.3.4 of the Phase 1.3 Plane GenServer plan: Add Ant Position Registry with proximity detection.

## Branch
`feature/phase1.3.4-ant-proximity`

## Tasks from Plan

### 1.3.4.4 Implement get_nearby_ants/2
- [x] Define `def get_nearby_ants(position, radius, opts \\ [])`
- [x] Call GenServer to get all ant positions
- [x] Filter for ants within Euclidean distance of radius
- [x] Return list of `{ant_id, position}` tuples
- [x] Support optional `exclude_ant_id` parameter for self-exclusion

## Implementation Notes

- Most of 1.3.3 and 1.3.4 was implemented in 1.3.2
- Remaining function: `get_nearby_ants/2` with optional `exclude_ant_id`
- Uses Euclidean distance: sqrt((x2-x1)^2 + (y2-y1)^2)
- Self-exclusion useful for ant-to-ant communication (exclude self)
- Uses squared distance comparison to avoid sqrt calculation

## Files Modified

### Modified
- `lib/ant_colony/plane.ex` - Added get_nearby_ants/3 function

## Verification

```
$ mix compile
Compiling 1 file (.ex)
Generated ant_colony app

$ mix test
Running ExUnit with seed: 385825, max_cases: 40
Excluding tags: [skip: true]
..................
Finished in 4.7 seconds (0.00s async, 0.09s sync)
1 doctest, 25 tests, 0 failures, 1 excluded
```

## Status

**Completed**
