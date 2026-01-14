# Phase 2.4: Canvas Rendering

Implement detailed Canvas drawing operations for visualizing the ant colony simulation. This phase focuses on the rendering functions that draw grid elements, nest, food sources, ants, and a status bar with generation information.

## Architecture

```
Canvas Rendering Pipeline
├── Canvas Creation
│   ├── Width: state.width (columns)
│   └── Height: state.height (rows)
│
├── Drawing Layers (Z-order):
│   ├── Layer 1: Grid Background (optional dots/lines)
│   ├── Layer 2: Nest ("N" - white)
│   ├── Layer 3: Food Sources ("F1"-"F5" - yellow to red gradient)
│   ├── Layer 4: Ants ("a" or "A" - red/bold)
│   └── Layer 5: Status Bar (bottom - generation info)
│
├── Character Mapping:
│   ├── Nest → "N"
│   ├── Food → "F" + level (1-5)
│   ├── Ant (no food) → "a"
│   ├── Ant (with food) → "A"
│   └── Empty → " " (space)
│
├── Status Bar Fields:
│   ├── Generation → "Gen: N"
│   ├── Food Count → "Food: M/T" (delivered/trigger)
│   ├── Ant Count → "Ants: N"
│   └── Quit Hint → "Press 'q' to quit"
│
└── Color Mapping:
    ├── Nest → :white
    ├── Food Level 1 → :yellow
    ├── Food Level 2-3 → :yellow + brightness
    ├── Food Level 4-5 → :red
    ├── Ant → :red
    ├── Ant with food → :red + :bold
    └── Status Bar → :dim
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| UI.Canvas | Module for Canvas drawing operations |
| UI.Canvas.draw_grid/2 | Draw background grid |
| UI.Canvas.draw_nest/3 | Draw nest location |
| UI.Canvas.draw_food/3 | Draw food sources |
| UI.Canvas.draw_ants/3 | Draw ant positions |
| UI.Canvas.draw_status_bar/2 | Draw generation KPI status bar |
| UI.Canvas.resolve_overlaps/2 | Handle overlapping elements |

---

## 2.4.1 Create Canvas Drawing Module

Set up the dedicated Canvas drawing module.

### 2.4.1.1 Create Canvas Module File

Create a separate module for Canvas operations.

- [ ] 2.4.1.1.1 Create `lib/ant_colony/ui/canvas.ex`
- [ ] 2.4.1.1.2 Add `defmodule AntColony.UI.Canvas`
- [ ] 2.4.1.1.3 Add comprehensive `@moduledoc`
- [ ] 2.4.1.1.4 Add `import TermUI.Widget`
- [ ] 2.4.1.1.5 Add `require Logger` for debugging

### 2.4.1.2 Define Drawing Constants

Define constants for character and color mappings.

- [ ] 2.4.1.2.1 Define `@nest_char "N"`
- [ ] 2.4.1.2.2 Define `@food_char_base "F"`
- [ ] 2.4.1.2.3 Define `@ant_char "a"`
- [ ] 2.4.1.2.4 Define `@ant_with_food_char "A"`
- [ ] 2.4.1.2.5 Define color constants for each level

### 2.4.1.3 Define Drawing State

Define state for tracking drawn elements.

- [ ] 2.4.1.3.1 Define `@type canvas_state :: %TermUI.Widget.Canvas{}`
- [ ] 2.4.1.3.2 Define `@type position :: {integer(), integer()}`
- [ ] 2.4.1.3.3 Define `@type drawn_elements :: %{position() => :nest | :food | :ant}`

---

## 2.4.2 Implement Grid Background

Draw the optional background grid for reference.

### 2.4.2.1 Draw Basic Grid

Create a simple grid with dots or spaces.

- [ ] 2.4.2.1.1 Define `def draw_grid(canvas, width, height)`
- [ ] 2.4.2.1.2 Iterate over all positions (x, y)
- [ ] 2.4.2.1.3 Draw "." every N positions for reference (optional)
- [ ] 2.4.2.1.4 Use " " (space) for most positions
- [ ] 2.4.2.1.5 Return updated canvas

### 2.4.2.2 Add Border (Optional)

Draw a border around the simulation area.

- [ ] 2.4.2.2.1 Define `def draw_border(canvas, width, height)`
- [ ] 2.4.2.2.2 Draw "+" at corners
- [ ] 2.4.2.2.3 Draw "-" on top and bottom edges
- [ ] 2.4.2.2.4 Draw "|" on left and right edges
- [ ] 2.4.2.2.5 Return updated canvas

### 2.4.2.3 Draw Coordinate Markers

Add position indicators for debugging.

- [ ] 2.4.2.3.1 Define `def draw_markers(canvas, width, height)`
- [ ] 2.4.2.3.2 Draw row numbers every 10 rows
- [ ] 2.4.2.3.3 Draw column numbers every 10 columns
- [ ] 2.4.2.3.4 Use dim color for markers
- [ ] 2.4.2.3.5 Return updated canvas

---

## 2.4.3 Implement Nest Drawing

Draw the nest location on the canvas.

### 2.4.3.1 Draw Nest Character

Render the nest at its position.

- [ ] 2.4.3.1.1 Define `def draw_nest(canvas, nest_location, opts \\ [])`
- [ ] 2.4.3.1.2 Extract x, y from nest_location tuple
- [ ] 2.4.3.1.3 Validate position is within bounds
- [ ] 2.4.3.1.4 Draw @nest_char at position using `Canvas.put_char`
- [ ] 2.4.3.1.5 Apply white color attribute
- [ ] 2.4.3.1.6 Return updated canvas

### 2.4.3.2 Handle Invalid Nest Position

Handle edge case of invalid nest coordinates.

- [ ] 2.4.3.2.1 Check if nest_location is nil
- [ ] 2.4.3.2.2 Check if position is out of bounds
- [ ] 2.4.3.2.3 Log warning if invalid position
- [ ] 2.4.3.2.4 Return canvas unchanged if invalid

### 2.4.3.3 Add Nest Glow Effect (Optional)

Draw additional characters around nest for emphasis.

- [ ] 2.4.3.3.1 Define `def draw_nest_glow(canvas, nest_location)`
- [ ] 2.4.3.3.2 Draw dim characters around nest position
- [ ] 2.4.3.3.3 Use 8 adjacent positions (if valid)
- [ ] 2.4.3.3.4 Return updated canvas

---

## 2.4.4 Implement Food Source Drawing

Draw all food sources with level indicators.

### 2.4.4.1 Draw Food Character

Render a single food source.

- [ ] 2.4.4.1.1 Define `def draw_food(canvas, position, level, quantity)`
- [ ] 2.4.4.1.2 Extract x, y from position tuple
- [ ] 2.4.4.1.3 Check if quantity > 0 (skip if depleted)
- [ ] 2.4.4.1.4 Build character string: "F" + level (e.g., "F3")
- [ ] 2.4.4.1.5 Select color based on level (yellow to red)
- [ ] 2.4.4.1.6 Draw character using `Canvas.put_char`
- [ ] 2.4.4.1.7 Return updated canvas

### 2.4.4.2 Draw All Food Sources

Render all food sources in the list.

- [ ] 2.4.4.2.1 Define `def draw_all_food(canvas, food_sources)`
- [ ] 2.4.4.2.2 Iterate over food_sources list
- [ ] 2.4.4.2.3 Call draw_food for each source
- [ ] 2.4.4.2.4 Accumulate canvas changes
- [ ] 2.4.4.2.5 Return final canvas

### 2.4.4.3 Map Food Level to Color

Determine color based on nutrient level.

- [ ] 2.4.4.3.1 Define `def food_color(level)`
- [ ] 2.4.4.3.2 Level 1 → :yellow (lightest)
- [ ] 2.4.4.3.3 Level 2-3 → :yellow + :bright
- [ ] 2.4.4.3.4 Level 4 → :red
- [ ] 2.4.4.3.5 Level 5 → :red + :bright (highest quality)
- [ ] 2.4.4.3.6 Return color atom or attribute list

### 2.4.4.4 Handle Depleted Food

Skip drawing food sources with zero quantity.

- [ ] 2.4.4.4.1 Check if quantity == 0
- [ ] 2.4.4.4.2 Skip drawing for depleted sources
- [ ] 2.4.4.4.3 Optionally draw "x" or faint marker for depleted
- [ ] 2.4.4.4.4 Continue to next food source

---

## 2.4.5 Implement Ant Drawing

Draw all ants at their positions.

### 2.4.5.1 Draw Ant Character

Render a single ant.

- [ ] 2.4.5.1.1 Define `def draw_ant(canvas, ant_id, position, carrying_food?)`
- [ ] 2.4.5.1.2 Extract x, y from position tuple
- [ ] 2.4.5.1.3 Select character: "a" or "A" based on carrying_food?
- [ ] 2.4.5.1.4 Apply red color
- [ ] 2.4.5.1.5 Add :bold attribute if carrying_food?
- [ ] 2.4.5.1.6 Draw character using `Canvas.put_char`
- [ ] 2.4.5.1.7 Return updated canvas

### 2.4.5.2 Draw All Ants

Render all ants in the map.

- [ ] 2.4.5.2.1 Define `def draw_all_ants(canvas, ant_positions)`
- [ ] 2.4.5.2.2 Iterate over ant_positions map
- [ ] 2.4.5.2.3 Extract position and carrying status for each ant
- [ ] 2.4.5.2.4 Call draw_ant for each ant
- [ ] 2.4.5.2.5 Accumulate canvas changes
- [ ] 2.4.5.2.6 Return final canvas

### 2.4.5.3 Handle Multiple Ants at Same Position

Handle overlapping ant positions.

- [ ] 2.4.5.3.1 Detect when multiple ants share a position
- [ ] 2.4.5.3.2 Count ants at each position
- [ ] 2.4.5.3.3 Draw count number instead of "a" (e.g., "3" = 3 ants)
- [ ] 2.4.5.3.4 Use special character if count > 9 (e.g., "*")
- [ ] 2.4.5.3.5 Return updated canvas

---

## 2.4.6 Implement Overlap Resolution

Handle when elements occupy the same position.

### 2.4.6.1 Define Draw Priority

Establish Z-order for overlapping elements.

- [ ] 2.4.6.1.1 Define priority order: nest > food > ants
- [ ] 2.4.6.1.2 Document priority in @moduledoc
- [ ] 2.4.6.1.3 Create `@priority %{nest: 3, food: 2, ant: 1}`
- [ ] 2.4.6.1.4 Use priority for conflict resolution

### 2.4.6.2 Track Drawn Positions

Track which positions have been drawn.

- [ ] 2.4.6.2.1 Define `def track_position(state, position, element_type)`
- [ ] 2.4.6.2.2 Store position in drawn_elements map
- [ ] 2.4.6.2.3 Check if position already has element
- [ ] 2.4.6.2.4 Compare priorities for conflict resolution
- [ ] 2.4.6.2.5 Return updated state

### 2.4.6.3 Resolve Position Conflicts

Handle overlapping elements by priority.

- [ ] 2.4.6.3.1 Define `def should_draw?(drawn_elements, position, element_type)`
- [ ] 2.4.6.3.2 Check if position is already drawn
- [ ] 2.4.6.3.3 If not drawn, return true
- [ ] 2.4.6.3.4 If drawn, compare priorities
- [ ] 2.4.6.3.5 Return true if new element has higher priority
- [ ] 2.4.6.3.6 Return false otherwise

---

## 2.4.7 Add Status Bar

Add a status bar showing generation information and simulation statistics.

### 2.4.7.1 Draw Status Bar

Render status information with generation KPIs.

- [ ] 2.4.7.1.1 Define `def draw_status_bar(canvas, state)`
- [ ] 2.4.7.1.2 Position at bottom of canvas (last row)
- [ ] 2.4.7.1.3 Build status string: "Gen: {current_generation_id} | Food: {food_delivered_count}/{generation_trigger_count} | Ants: {ant_count} | Press 'q' to quit"
- [ ] 2.4.7.1.4 Use dim color for status
- [ ] 2.4.7.1.5 Return updated canvas

### 2.4.7.2 Format Generation Information

Create formatted generation display string.

- [ ] 2.4.7.2.1 Define `def format_gen_info(state)` helper
- [ ] 2.4.7.2.2 Format: "Gen: {current_generation_id}"
- [ ] 2.4.7.2.3 Highlight generation number if new generation just started
- [ ] 2.4.7.2.4 Return formatted string

### 2.4.7.3 Format Food Progress

Create formatted food progress display string.

- [ ] 2.4.7.3.1 Define `def format_food_progress(state)` helper
- [ ] 2.4.7.3.2 Format: "Food: {food_delivered_count}/{generation_trigger_count}"
- [ ] 2.4.7.3.3 Calculate percentage: (delivered / trigger) * 100
- [ ] 2.4.7.3.4 Optionally add visual progress bar: "Food: [=====     ] 5/50"
- [ ] 2.4.7.3.5 Return formatted string

### 2.4.7.4 Update Status on Events

Refresh status bar when state changes.

- [ ] 2.4.7.4.1 Recalculate ant count from ant_positions map
- [ ] 2.4.7.4.2 Use current food_delivered_count from state
- [ ] 2.4.7.4.3 Redraw status bar with new values
- [ ] 2.4.7.4.4 Return updated canvas

---

## 2.4.8 Unit Tests for Canvas Drawing

Test all drawing functions.

### 2.4.8.1 Test Grid Drawing

Verify grid rendering works.

- [ ] 2.4.8.1.1 Create `test/ant_colony/ui/canvas_test.exs`
- [ ] 2.4.8.1.2 Add test: `test "draw_grid creates canvas with correct dimensions"` - size
- [ ] 2.4.8.1.3 Add test: `test "draw_grid fills canvas with spaces"` - content
- [ ] 2.4.8.1.4 Add test: `test "draw_grid draws markers at intervals"` - markers

### 2.4.8.2 Test Nest Drawing

Verify nest renders correctly.

- [ ] 2.4.8.2.1 Add test: `test "draw_nest draws N at correct position"` - position
- [ ] 2.4.8.2.2 Add test: `test "draw_nest uses white color"` - color
- [ ] 2.4.8.2.3 Add test: `test "draw_nest handles nil position"` - edge case
- [ ] 2.4.8.2.4 Add test: `test "draw_nest handles out of bounds"` - error handling

### 2.4.8.3 Test Food Drawing

Verify food sources render correctly.

- [ ] 2.4.8.3.1 Add test: `test "draw_food draws F with level"` - character
- [ ] 2.4.8.3.2 Add test: `test "draw_food skips depleted sources"` - zero quantity
- [ ] 2.4.8.3.3 Add test: `test "draw_all_food draws all sources"` - completeness
- [ ] 2.4.8.3.4 Add test: `test "food_color returns correct colors"` - color mapping
- [ ] 2.4.8.3.5 Add test: `test "food_color handles all levels 1-5"` - all levels

### 2.4.8.4 Test Ant Drawing

Verify ants render correctly.

- [ ] 2.4.8.4.1 Add test: `test "draw_ant draws a when not carrying"` - character
- [ ] 2.4.8.4.2 Add test: `test "draw_ant draws A when carrying food"` - character
- [ ] 2.4.8.4.3 Add test: `test "draw_ant uses red color"` - color
- [ ] 2.4.8.4.4 Add test: `test "draw_all_ants draws all ants"` - completeness
- [ ] 2.4.8.4.5 Add test: `test "draw_ant handles empty map"` - edge case

### 2.4.8.5 Test Overlap Resolution

Verify overlapping elements are handled.

- [ ] 2.4.8.5.1 Add test: `test "nest has highest priority"` - priority
- [ ] 2.4.8.5.2 Add test: `test "food draws over ant"` - priority
- [ ] 2.4.8.5.3 Add test: `test "track_position records elements"` - tracking
- [ ] 2.4.8.5.4 Add test: `test "should_draw? respects priority"` - logic
- [ ] 2.4.8.5.5 Add test: `test "multiple ants at same position show count"` - count

### 2.4.8.6 Test Multiple Ants at Position

Verify count display for overlapping ants.

- [ ] 2.4.8.6.1 Add test: `test "2 ants at same position shows 2"` - count
- [ ] 2.4.8.6.2 Add test: `test "9 ants at same position shows 9"` - count
- [ ] 2.4.8.6.3 Add test: `test "10+ ants at same position shows *"` - overflow
- [ ] 2.4.8.6.4 Add test: `test "ant count updates on move"` - dynamic

### 2.4.8.7 Test Status Bar

Verify status bar rendering.

- [ ] 2.4.8.7.1 Add test: `test "draw_status_bar shows correct generation ID"` - generation accuracy
- [ ] 2.4.8.7.2 Add test: `test "draw_status_bar shows food count with trigger"` - KPI display
- [ ] 2.4.8.7.3 Add test: `test "draw_status_bar shows ant count"` - ant count accuracy
- [ ] 2.4.8.7.4 Add test: `test "draw_status_bar shows quit hint"` - content
- [ ] 2.4.8.7.5 Add test: `test "status bar updates on generation change"` - generation updates
- [ ] 2.4.8.7.6 Add test: `test "format_food_progress calculates percentage correctly"` - math
- [ ] 2.4.8.7.7 Add test: `test "format_gen_info formats generation ID correctly"` - formatting

---

## 2.4.9 Phase 2.4 Integration Tests

End-to-end tests for canvas rendering.

### 2.4.9.1 Complete Rendering Test

Test full rendering pipeline.

- [ ] 2.4.9.1.1 Create `test/ant_colony/integration/canvas_rendering_integration_test.exs`
- [ ] 2.4.9.1.2 Add test: `test "render shows all elements"` - completeness
- [ ] 2.4.9.1.3 Add test: `test "render handles empty simulation"` - edge case
- [ ] 2.4.9.1.4 Add test: `render produces valid widget tree"` - structure

### 2.4.9.2 Performance Test

Test rendering performance with many elements.

- [ ] 2.4.9.2.1 Add test: `test "render 100 ants performs acceptably"` - performance
- [ ] 2.4.9.2.2 Add test: `test "render 50 food sources performs acceptably"` - performance
- [ ] 2.4.9.2.3 Add test: `render doesn't leak memory"` - memory

### 2.4.9.3 Visual Accuracy Test

Verify rendered output matches expected state.

- [ ] 2.4.9.3.1 Add test: `test "nest always visible"` - visibility
- [ ] 2.4.9.3.2 Add test: `test "all food sources visible"` - visibility
- [ ] 2.4.9.3.3 Add test: `test "all ants visible"` - visibility
- [ ] 2.4.9.3.4 Add test: `test "element positions match simulation"` - accuracy

---

## Phase 2.4 Success Criteria

1. **Canvas Module**: Drawing functions implemented ✅
2. **Grid**: Background grid renders correctly ✅
3. **Nest**: Draws "N" at correct position ✅
4. **Food**: Draws "F{level}" with appropriate colors ✅
5. **Ants**: Draws "a"/"A" at positions ✅
6. **Overlaps**: Priority-based resolution works ✅
7. **Status Bar**: (Optional) Shows simulation stats ✅
8. **Tests**: All unit and integration tests pass ✅

## Phase 2.4 Critical Files

**New Files:**
- `lib/ant_colony/ui/canvas.ex` - Canvas drawing module
- `test/ant_colony/ui/canvas_test.exs` - Canvas unit tests
- `test/ant_colony/integration/canvas_rendering_integration_test.exs` - Integration tests

**Modified Files:**
- `lib/ant_colony/ui.ex` - Use Canvas drawing functions in view/1

---

## Next Phase

Proceed to [Phase 2.5: UI Integration](./05-ui-integration.md) to integrate the UI with the simulation and verify end-to-end functionality.
