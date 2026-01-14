# Phase 2.1: term_ui Dependencies

Add the `term_ui` dependency to the project and configure it for terminal UI development. This establishes the foundation for building the visual interface.

## Architecture

```
mix.exs
├── deps/
│   ├── {:jido, "~> 2.0"}
│   ├── {:phoenix_pubsub, "~> 2.1"}
│   ├── {:term_ui, "~> 0.1"}  (new)
│   └── {:nx, "~> 0.x"}  (required by term_ui)
└── config/
    └── config.exs
```

## Components in This Phase

| Component | Purpose |
|-----------|---------|
| mix.exs | Add term_ui and related dependencies |
| config/config.exs | Runtime configuration for term_ui |

---

## 2.1.1 Add term_ui Dependency

Add the term_ui package and its dependencies to the project.

### 2.1.1.1 Add term_ui to deps list

Update mix.exs with the term_ui dependency.

- [ ] 2.1.1.1.1 Open `mix.exs` in the project root
- [ ] 2.1.1.1.2 Locate the `deps/0` function
- [ ] 2.1.1.1.3 Add `{:term_ui, "~> 0.1"}` to the deps list
- [ ] 2.1.1.1.4 Add `{:nx, "~> 0.x"}` if not already present (required by term_ui)
- [ ] 2.1.1.1.5 Ensure proper comma separation between deps

### 2.1.1.2 Verify dependency versions

Ensure we use compatible versions.

- [ ] 2.1.1.2.1 Check term_ui documentation for current stable version
- [ ] 2.1.1.2.2 Verify Nx compatibility with term_ui
- [ ] 2.1.1.2.3 Note: term_ui may require specific Nx version

### 2.1.1.3 Fetch dependencies

Download and compile the new dependencies.

- [ ] 2.1.1.3.1 Run `mix deps.get` to fetch term_ui and its dependencies
- [ ] 2.1.1.3.2 Verify no errors during fetch
- [ ] 2.1.1.3.3 Run `mix deps.compile` to compile dependencies
- [ ] 2.1.1.3.4 Check that term_ui compiled successfully

---

## 2.1.2 Configure term_ui

Configure the term_ui application for proper startup.

### 2.1.2.1 Verify term_ui application

Ensure term_ui starts correctly with the application.

- [ ] 2.1.2.1.1 Check if term_ui requires application children
- [ ] 2.1.2.1.2 Add any required term_ui children to supervision tree (if needed)
- [ ] 2.1.2.1.3 Configure term_ui options in config/config.exs (if needed)

### 2.1.2.2 Configure inets for term_ui

term_ui may require inets for terminal handling.

- [ ] 2.1.2.2.1 Add `:inets` to `extra_applications` in mix.exs if required
- [ ] 2.1.2.2 Verify inets starts with application
- [ ] 2.1.2.3 Test that terminal is accessible

### 2.1.2.3 Set up term_ui environment

Configure environment variables for term_ui.

- [ ] 2.1.2.3.1 Set `TERM` environment variable if needed for testing
- [ ] 2.1.2.3.2 Configure terminal type in config
- [ ] 2.1.2.3.3 Document any required environment setup

---

## 2.1.3 Unit Tests for Dependencies

Verify that term_ui dependency is correctly added.

### 2.1.3.1 Test term_ui Application Loads

Verify the term_ui application can be loaded.

- [ ] 2.1.3.1.1 Create `test/ant_colony/termui_test.exs`
- [ ] 2.1.3.1.2 Add test: `test "term_ui application is available"` - checks `Application.spec(:term_ui)`
- [ ] 2.1.3.1.3 Add test: `test "term_ui modules are accessible"` - check `TermUI` module exists
- [ ] 2.1.3.1.4 Add test: `test "TermUI.Elm behaviour is available"` - check behaviour exists

### 2.1.3.2 Test Nx Dependency

Verify Nx is available (required by term_ui).

- [ ] 2.1.3.2.1 Add test: `test "nx application is available"` - checks `Application.spec(:nx)`
- [ ] 2.1.3.2.2 Add test: `test "Nx.Tensor is available"` - check tensor type exists
- [ ] 2.1.3.2.3 Add test: `test "can create simple tensor"` - basic tensor operation

### 2.1.3.3 Test Project Compiles

Verify the project compiles with new dependencies.

- [ ] 2.1.3.3.1 Add test: `test "project compiles with term_ui"` - runs `Mix.Task.run("compile")`
- [ ] 2.1.3.3.2 Add test: `test "no dependency conflicts"` - check compilation warnings
- [ ] 2.1.3.3.3 Add test: `test "all dependencies load successfully"` - check `Application.loaded_applications()`

---

## 2.1.4 Phase 2.1 Integration Tests

End-to-end tests for dependency setup.

### 2.1.4.1 Start Application with term_ui

Test that the application starts with term_ui loaded.

- [ ] 2.1.4.1.1 Create `test/ant_colony/integration/termui_integration_test.exs`
- [ ] 2.1.4.1.2 Add setup ensuring clean application state
- [ ] 2.1.4.1.3 Add test: `test "application starts with term_ui"` - full start cycle
- [ ] 2.1.4.1.4 Add test: `test "application stops cleanly with term_ui"` - stop cycle

### 2.1.4.2 Verify term_ui Functionality

Basic test that term_ui can be used.

- [ ] 2.1.4.2.1 Add test: `test "can create basic TermUI widget"` - widget creation
- [ ] 2.1.4.2.2 Add test: `test "can render simple Canvas"` - canvas test
- [ ] 2.1.4.2.3 Add test: `test "term_ui event system works"` - basic event

---

## Phase 2.1 Success Criteria

1. **term_ui Added**: Dependency in mix.exs ✅
2. **Dependencies Fetched**: mix deps.get succeeds ✅
3. **Compilation**: Project compiles without errors ✅
4. **Nx Available**: Numerical computing backend loaded ✅
5. **Tests**: All unit and integration tests pass ✅

## Phase 2.1 Critical Files

**New Files:**
- `test/ant_colony/termui_test.exs` - term_ui dependency tests
- `test/ant_colony/integration/termui_integration_test.exs` - Integration tests

**Modified Files:**
- `mix.exs` - Add term_ui and Nx dependencies
- `config/config.exs` - term_ui configuration (if needed)

---

## Next Phase

Proceed to [Phase 2.2: Plane UI API](./02-plane-ui-api.md) to add the Plane API for UI state queries.
