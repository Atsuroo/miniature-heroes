# Miniature Heroes — Learning Plan

*Companion to [GAME_CONCEPT.md](GAME_CONCEPT.md). That document says **what** the game is; this one says **in what order to build it** and **what to learn at each stage**.*

*v1.0 — 2026-07-25. Godot 4.x (use latest stable), GDScript with static typing.*

---

## How we work together

This project exists so you learn Godot. The default way that goes wrong is subtle: you get stuck, you ask, I write the solution, it works — and forty repetitions later you have a codebase you can't debug. The rules below are structural guards against that, not politeness.

### The boundary

**I do not write `.gd` production code.** I write specs, test suites, documentation and reviews. You write every line that ships.

You can lift this deliberately — "just show me what a signal connection looks like" is completely fine. The point is that it's a conscious request, not a slow drift.

### Hint tiers

When stuck, say which tier you want. Default is **tier 1**, escalate when it isn't enough.

| Tier | What you get |
|---|---|
| 1 | The name of the concept and where to read about it. Nothing else. |
| 2 | The shape of the approach in prose. No code. |
| 3 | A minimal example in a *different* domain, so you still have to translate. |
| 4 | The actual answer. |

The struggle before tier 1 resolves is where most of the learning happens. Give it a genuine attempt first.

### The escape hatch

If you're stuck more than **~2 hours on something that isn't the thing you're trying to learn** — an import setting, an export quirk, an obscure editor checkbox — skip straight to tier 4 and ask outright. Your learning time belongs to game logic and engine idiom, not tooling archaeology.

### Explain-it-back

At the steps marked **[EXPLAIN]**, write me a paragraph on how your implementation works and why you chose it. This is cheap and it reliably catches the "it works and I don't know why" state — the one that turns into an unfixable bug two months later.

### Reviews

At the steps marked **[REVIEW]**, ask me for a code review. Say `review step X.Y` and I'll read what you've written. I'm not just checking correctness — I'm looking at:

- Is the logic/view boundary holding, or is engine code leaking into the rules?
- Is this idiomatic Godot, or C#-in-GDScript?
- Will this survive the next milestone, or will M4 force a rewrite?
- Static typing coverage, naming, dead code.
- Concrete tips and tricks you'd only learn from someone who's seen the engine before.

Reviews are the single highest-value part of this arrangement: you've already struggled with the problem, so the feedback lands and sticks.

### Tests as spec

For the algorithmic steps marked **[TESTS PROVIDED]** I write a failing test suite encoding the rules from the concept doc, and you make it pass. Precise spec, instant feedback, and it never shows you the implementation.

Note the progression: I write the suites early, you take over around Phase 2, and from then on I review your tests instead of writing them.

### Keep a log

Maintain `LEARNING_LOG.md` — what you tried, what confused you, what you'd do differently. It reinforces the learning and gives future sessions of me real continuity instead of re-deriving your context every time.

---

## The one architectural rule

**The rules engine must not know the scene tree exists.**

Hex math, line of sight, turn order, combat resolution: plain `RefCounted` classes with zero references to nodes, scenes, or 3D. The board, the minis, and the dice are a **view layer** that reads from the rules engine and renders it.

Why this matters more than usual for your project:

- It's genuinely unit-testable, which plays directly to your existing skills as a developer.
- The concept doc predicts heavy rules iteration at M2. With this split, changing a combat rule doesn't touch a single visual.
- It's the difference between M4 customization being a feature and being a rewrite.

Suggested layout:

```
res://
  logic/          # RefCounted only. No Node, no Node3D, no preload of scenes.
    hex/
    rules/
  view/           # Nodes, scenes, meshes, cameras, UI
  data/           # .tres Resources — hero stats, ability definitions
  test/           # GUT tests. Should be able to test everything in logic/ headlessly.
```

A useful smell test: **if `logic/` can't be tested without opening a window, something has leaked.**

---

# Phase 0 — Warm-up (throwaway project)

**Do not start Miniature Heroes yet.** Your first Godot code will be bad, and you don't want it to be load-bearing. Spend three evenings somewhere disposable. Create a separate project called `godot-warmup` and delete it later without ceremony.

### Step 0.1 — Node tree literacy ✅ *done 2026-07-25*

- [x] **Goal:** Understand what scenes and nodes actually are. This is the concept that everything else in Godot rests on, and the one experienced developers most often bring wrong assumptions to.
- [x] **Learn first:** Official docs, "Step by step" tutorial (the whole thing — it's short). Focus on: nodes vs scenes, the scene tree, scene instancing, `class_name`.
- [x] **Build:** A 3D scene with a floor, a cube, and a camera. Move the cube with arrow keys. Then make the cube its own scene and instance five of them at runtime from code.
- [x] **Done when:** You can explain, without looking it up, the difference between a node and a scene — and why "a scene is a reusable node" is the more useful way to think about it. *Answered with an atoms/molecules analogy — recursion insight correct; refined to "a scene instance **is** a node, so scenes are how you define your own node types", plus scene file = class, instance = object.*
- [ ] **Traps:** Thinking of scenes as "levels" only. They're the composition primitive — a unit, a die, a button, a whole board are all scenes. Also: don't reach for inheritance where Godot expects composition via child nodes.

### Step 0.2 — Signals and input ✅ *done 2026-07-29 (built 25th, reviewed 29th)*

- [x] **Goal:** Event-driven communication between nodes, and the input pipeline.
- [x] **Learn first:** Signals (Godot 4 syntax: `signal died(who: Unit)`, `died.emit(self)`, `died.connect(_on_died)`). Then `_input` vs `_unhandled_input` vs `_gui_input`, the `Input` singleton, and the InputMap in project settings.
- [x] **Build:** Click a cube → it changes colour and emits a custom signal → a parent node hears it and prints a message. Add a keyboard action through the InputMap rather than hardcoding keys.
- [x] **Done when:** No polling anywhere. Nothing in `_process` is checking whether something happened.
- [x] **Traps:** The big one for a turn-based game — polling state in `_process` instead of reacting to signals. Also using raw key codes instead of named InputMap actions, which you'll regret when you add rebinding or a controller. *Both avoided — InputMap actions used from the start, nothing polls.*
- [x] **Review closed 2026-07-29:** button filtering, per-click resource allocation, Godot 3 string-connect syntax and the typing gaps are all fixed. Scope was extended to single-selection highlighting, which turned into the real lesson — see the log.

> **Detour worth keeping:** most of this session went into resources rather than signals — the node → mesh → material chain, and discovering that **resources are shared between scene instances by default while nodes are not.** That's the same class/instance lesson one level down, and it's the foundation the M4 paint-zone system rests on. Not a diversion; a preview.

> **Second detour, kept on purpose:** the review turned into an ownership exercise. Responsibility for "who is selected" moved four times before it settled — the clicked object deciding for itself, then a painter, then a coordinator that swallowed the painter, then a dedicated selector owning the state. The rule that came out of it: **state belongs where the decision is made.** Note for Phase 2: in the real project that answer is *not* the view layer, because "which unit is active" is a rules question. Same rule, different owner.

### Step 0.3 — Picking objects in 3D ✅ *done 2026-07-29*

- [ ] **Goal:** Click a 3D thing and know what you clicked. This is a direct prerequisite for clicking hexes, so it's worth doing on a toy first.
- [x] **Learn first:** `Camera3D.project_ray_origin()` and `project_ray_normal()`, `PhysicsRayQueryParameters3D`, `get_world_3d().direct_space_state.intersect_ray()`. Also read about collision layers and masks. Look at `Area3D`'s `input_event` signal as the alternative approach and form an opinion on which you prefer. *Read up front and checked against Claude before coding — two misconceptions caught that way ("normal" = normalized, not perpendicular; `intersect_ray` returns one hit, not a list). Opinion on manual vs. `Area3D` still open by design: both approaches are running side by side to compare.*
- [x] **Build:** Click anywhere on the floor → print the exact world coordinates. *Done — `RaycastManager` emits `world_position_clicked(position)`.* Click a cube → identify *which* cube by name. *Done twice over: `Cube.clicked` via `_input_event`, and the raycast, which sees the cube too and deliberately stays quiet about it.*
- [x] **Done when:** Clicks report correct positions reliably, including near the screen edges. *Tested at the edges, holds.*
- [x] **Traps:** Forgetting that a body needs a `CollisionShape3D` to be hit at all. Layer/mask confusion is the number one source of "my raycast hits nothing" — when it silently fails, check masks first. *Hit a subtler variant of exactly this: `collision_layer == FLOOR_LAYER` instead of a bitwise test. Would have failed silently the moment any body sat on two layers. Layers are now named in project settings (floor / cube / player).*
- [x] **[EXPLAIN]** Describe how a screen-space click becomes a world-space position. *Passed with one correction: the click is a `Vector2`, and the 2D→3D step is the substance of the answer, not its precondition. Also settled the origin question from the previous session — `project_ray_origin()` is just the camera position for a perspective camera; the pair exists in that shape for orthographic ones.*
- [x] **Open from review:** space state now fetched per physics frame, `_unhandled_input` instead of `_input`, `RayIntersectionResult` field list checked against the doc table with a real `face_index` default and `_to_string()`. Ownership resolved **before** it came up in review — picking moved off the `Camera3D` into a `RaycastManager` that finds its camera through the viewport.
- [ ] **Newly parked (decide in Phase 1):** two picking systems still run side by side, configured through two different mechanisms — `collision_mask`/`exclude` in code for the raycast, `input_ray_pickable` per body in the inspector for physics picking. Only one should survive. Also unresolved: the ray is built in the input frame but cast in the next physics frame, while the camera hangs off a body that moves every physics frame.

---

# Phase 1 — M0: The board

**Milestone goal:** a mini walks a path across a hex board with height levels. This is the real Godot literacy hurdle; finishing it is a genuine achievement.

### Step 1.1 — Project setup ✅ *done 2026-07-30*

- [x] **Goal:** Create the actual project with an architecture that won't need unpicking later.
- [x] **Learn first:** Godot's `.gitignore` requirements (ignore `.godot/`, keep `.import` handling correct for your version). GUT installation — the Godot Unit Test addon, via the Asset Library or a git clone into `addons/`.
- [x] **Build:** New project. The folder structure from the architecture rule above. `git init` — the project isn't under version control yet and should be from day one. Install GUT and get it running. *GUT 9.7.1 vendored under `addons/` and committed — Godot has no lockfile, so the version only exists inside the addon itself.*
- [x] **Build — strict mode, do this before writing a single line:** turn the GDScript warnings up in `project.godot` (`Project Settings → Advanced → Debug → GDScript`). `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access`, `unsafe_call_argument`, `unsafe_cast`, `shadowed_variable` and `standalone_expression` to **Error** (`=2`); `unused_variable`, `unused_parameter`, `unused_signal`, `return_value_discarded`, `integer_division` to warn (`=1`). Leave `inferred_declaration` off — `:=` is statically typed and idiomatic. Also `Editor Settings → Text Editor → Completion → Add Type Hints` on, and `Trim Trailing Whitespace on Save` on. *All seven set. Two more were added in 1.2 after each cost a real bug: `shadowed_global_identifier` and `narrowing_conversion` — the list here was incomplete.*
- [x] **Done when:** GUT runs successfully with zero tests, and you have a first commit. Bonus: get GUT running from the command line, not just the editor panel — you'll want that later. *Bonus done. Windows catch: only the `_console.exe` build writes to stdout, the normal one runs the suite and shows nothing.*
- [x] **Traps:** Committing `.godot/`. Also, don't over-engineer the folder structure now; four folders is enough. *`.godot/` stayed out. The folder trap was half-triggered — `hex/` and `rules/` were created at top level instead of inside `logic/`, which is exactly the split that makes the architecture rule unreadable. Deleted before the first commit.*
- [ ] **Why strict mode first:** the plan says "static typing everywhere", and in Phase 0 that turned out to be a discipline problem — missing `-> void` and untyped locals survived four rounds of review because nothing complained. `untyped_declaration=2` makes it a compile error instead of a habit. `unsafe_*` on Error is the actual guard on the architecture rule: without it, `logic/` can quietly decay into `Variant` and you won't notice until it's expensive. Retrofitting this into an existing codebase means fixing hundreds of lines at once — that's why it belongs in step 1.1 and not later.

### Step 1.2 — Hex coordinates **[TESTS PROVIDED]** ✅ *done 2026-07-31*

- [x] **Goal:** Complete hex math with zero engine dependencies. This is the most important step in Phase 1 — it establishes the logic/view split in the very first real code you write.
- [x] **Learn first:** Red Blob Games' hex grids page (redblobgames.com/grids/hexagons). Read the coordinate systems section properly and *decide* between axial and cube — don't drift into one. Understand why cube coordinates make distance trivial. *Decided: **axial for storage, cube for the arithmetic**. The initial reason — "cube makes neighbours easier" — turned out to be wrong; neighbours are identical in both, because axial simply drops the redundant `s`. The real case for cube is distance, rounding, and `q + r + s == 0` as a free assertion.*
- [x] **Build:** A `HexCoord` class extending `RefCounted` (or a struct-like approach — form an opinion). Neighbours, distance, line drawing, range/spiral. Fully statically typed. *Opinion formed against `RefCounted`: GDScript has no operator overloading, so a custom class can never compare or hash by value and silently fails as a `Dictionary` key. `Hex` is a static-only utility over `Vector2i`.*
- [x] **Test:** I provide the suite. Make it pass. *42 tests, 2674 asserts, green.*
- [x] **Done when:** All provided tests green, and `logic/hex/` contains no reference to any Node type whatsoever. *Holds — no Node, no `preload`, no world or pixel coordinate.*
- [x] **Traps:** Putting pixel/world position on the coordinate class. Coordinates are pure math; the mapping to world space is a *view* concern and belongs in the next step. If you feel tempted, that's the exact instinct this architecture exists to train out. *Avoided. `round_axial` takes fractional **axial** and returns axial; nothing in the file knows about world space.*

> **The lesson from this step was about types, not hexes.** Both real bugs were silent conversions, neither was a hex-maths error. A parameter named `range` shadowed the built-in and worked only by accident; `absi()` on a float difference truncated it to zero, which made `cube_round` always correct the same component and quietly broke line drawing too. The correction that came out of it: **the typed function variants are not "cleaner because typed" — they are narrower, and narrower only helps when the value actually fits.** Reach for them when the result flows onward into more typed code, not when it lands at a typed boundary immediately. `max()` over three ints stays `max()`.

### Step 1.3 — Rendering the grid ✅ *done 2026-08-05*

- [x] **Goal:** See the board.
- [x] **Learn first:** Hex layout math (same Red Blob page, "hex to pixel"). Pointy-top vs flat-top — pick one and write it down, because mixing them produces subtly wrong layouts that are miserable to debug. `MeshInstance3D`, `Node3D` transforms. Skim `MultiMeshInstance3D` and note it as an optimisation for later, not now. *Still one scene instance per tile — 91 tiles, each with a border mesh and three `Label3D`, so roughly 450 nodes. Comfortable at this size; `MultiMeshInstance3D` stays the lever if it ever isn't.*
- [x] **Decided before building — orientation: pointy-top.** The aesthetic argument does not apply here: with the orbiting camera from 1.4, rotating the view by 30° turns one orientation into the look of the other, so visually the choice is moot. It is fixed anyway because **1.5 must assume the same orientation as 1.3** — a mismatch between `hex → world` and `world → hex` does not crash, it just picks the wrong tile near the edges, which reads like a rounding bug and isn't one. Pointy-top specifically because it is the variant most references show, so there is less risk of mistranscribing the basis vectors.
- [x] **Decided before building — map shape: hexagonal, not rectangular.** In axial coordinates `q ∈ 0..8, r ∈ 0..8` is a rhombus, not a square; a rectangular board needs a per-row offset. A hex-shaped map avoids that entirely and is the better board for cover and approach lanes anyway. `Hex.hexes_in_range(Vector2i.ZERO, 5)` yields the map directly — 91 tiles, the same order of magnitude as the 81 the "9×9" below was reaching for. **`logic/` supplies the map shape, `view/` turns it into geometry.** *How it landed: `Hex.spiral` supplies the coordinates, but the node that asks for them lives in `view/` — an attempt to move it into `logic/` put a `Node` with `@export` there and broke the architecture rule mechanically. The rule is about files, not just intent: `logic/` holds no `Node` scripts. A real `HexMap` in `logic/` becomes worth it in 1.6, when there is per-hex data to hold.*
- [x] **Build:** Generate a 9×9 hex board of flat tiles from the coordinate data. *Superseded by the line above: radius-5 hexagonal map.*
- [x] **Done when:** A hex grid renders in 3D with no gaps or overlaps, and the mapping from `Hex` coordinates (`Vector2i`) to world position lives in the view layer. *Both hold. Gaps and overlaps checked from directly above — worth doing deliberately, because the mesh's own rotation is a second place the pointy-top decision has to be honoured and the spacing formula will not tell you if it isn't.*
- [x] **Traps:** Hardcoding the hex size constant in six places. One source of truth. *The orientation and the axis mapping belong at that same single place: the board lies on the **X/Z plane**, because `Y` carries the height levels from 1.6. Red Blob's formulas produce a 2D `(x, y)` — that `y` becomes `z` here, and that substitution is made once, in writing, not per call site.* **The resolution: `hex_size` is the circumradius.** *That single reading makes it both the cylinder radius and the unit of the lattice spacing (`√3·size` across, `3/2·size` down), so one value in `HexSettings.tres` moves geometry and spacing together.*
- [x] **Trap that follows from the orbiting camera:** nothing in the view may assume a fixed viewing direction. The first case is the debug labels that show `(q, r)` per tile — worth building, but flat text on a tile is mirrored and upside down from half of all camera angles. `Label3D`/`Sprite3D` have a billboard mode for exactly this. The distinction to keep: elements that describe something *for the viewer* get billboarded, elements that describe something *about the world* — a facing arrow, say — must not. *Billboarded from the start. Billboarding only fixes rotation, though — see below.*

> **The lesson was *where* a size is applied, not which.** The same mistake appeared three times in a row and looked different every time: mesh height times node scale, then resource size times node scale, then label and border offsets tuned against the doubled transform. Each was invisible while the value in play happened to be `1.0`, and each surfaced only in the one dimension where it wasn't — `tile_height = 0.2` rendering as `0.04`. The billboarded labels were the tell: node scale is inherited by every descendant, so a non-uniform scale on the tile squashed the debug text, and billboarding could not undo it because it only touches rotation. The resolution each time was the same shape as the "one source of truth" trap, one level down: **one source, and one place where it is applied.**

### Step 1.4 — Camera rig

- [ ] **Goal:** An orbit camera that looks at the board.
- [ ] **Learn first:** The gimbal pattern — a pivot `Node3D` at the focus point, a second node for elevation, `Camera3D` as a child offset backwards. Rotate the pivots, never the camera itself. Also look at `Tween` / `lerp` for smoothing.
- [ ] **Build:** Mouse-drag orbits, wheel zooms, WASD or edge-scroll pans.
- [ ] **Done when:** You can look at the board from any angle without gimbal weirdness or the camera rolling.
- [ ] **Traps:** Directly setting `camera.rotation` — this is the classic mistake and it produces exactly the "why is my camera tilting sideways" bug. Use the rig.

### Step 1.5 — Click a hex **[REVIEW]**

- [ ] **Goal:** Connect input to the grid — hover highlights a hex, click selects it.
- [ ] **Learn first:** World-to-hex conversion and **cube rounding** (Red Blob covers it). This is where naive rounding produces wrong results near hex boundaries.
- [ ] **Build:** Raycast → world position → hex coordinate → highlight that tile.
- [ ] **Test:** Round-trip tests — hex → world → hex should be identity for every hex on the board. Write these yourself; they're a good first test-writing exercise.
- [ ] **Done when:** Hover highlights the correct hex every time, including right at the boundaries between tiles.
- [ ] **[REVIEW]** First real architecture review. I'll look at whether the logic/view boundary is holding, your static typing discipline, signal usage, and naming. Worth doing properly — corrections here are cheap and compound.

### Step 1.6 — Height levels

- [ ] **Goal:** Tiles have heights 0–2, rendered as stacked slabs (per the concept doc's "slabs, not slopes" commitment).
- [ ] **Learn first:** Nothing new engine-wise. This is a data modelling step — think about where tile data lives and how the view subscribes to it.
- [ ] **Build:** Per-hex height in the logic layer; the view renders prisms of the right height. A hand-authored test map with interesting elevation.
- [ ] **Done when:** A board with visible plateaus and cliff edges, and height queryable from pure logic with no view involved.
- [ ] **Traps:** Storing height on the mesh node. The view should be able to be deleted and rebuilt from data at any moment — that's the test of whether you've done this right.

### Step 1.7 — Pathfinding **[TESTS PROVIDED]**

- [ ] **Goal:** Movement range and paths, with the +1-per-level climb cost from the concept doc.
- [ ] **Learn first:** BFS vs Dijkstra vs A\* and which one you actually need (hint: "all hexes reachable within N movement" is a different question from "shortest path to X"). Look at Godot's built-in `AStar3D` and then decide whether to use it — think about whether it gives you enough control over the climb-cost rule.
- [ ] **Build:** Reachable-set calculation and pathfinding over the hex grid, respecting climb costs and impassable tiles.
- [ ] **Test:** I provide the suite, including climb-cost cases.
- [ ] **Done when:** Tests green. Still zero engine dependencies in `logic/`.
- [ ] **Traps:** Conflating "can I path through it" with "can I stop there". You'll want both eventually.

### Step 1.8 — Move a mini **[REVIEW] [EXPLAIN]**

- [ ] **Goal:** **M0 complete.**
- [ ] **Learn first:** `create_tween()` and tween chaining for step-by-step movement along a path. Also `await` in GDScript — worth understanding properly, you'll use it constantly for animation sequencing.
- [ ] **Build:** Select a unit → reachable hexes highlight → click a destination → the mini walks the path, one hex at a time, stepping up and down levels.
- [ ] **Done when:** It looks good enough that you want to show someone.
- [ ] **Traps:** Animation logic creeping into the rules layer. The logic layer should say "unit moved from A to B"; the view decides that takes 0.3 seconds per hex.
- [ ] **[REVIEW]** Full architecture review at the milestone boundary — the most valuable review in the whole plan. Everything after this builds on it.
- [ ] **[EXPLAIN]** Walk me through your data flow from click to finished animation.

---

# Phase 2 — M1: Graybox hotseat skirmish

**Milestone goal:** two people play a full match at one keyboard. Deliberately ugly.

### Step 2.1 — Game state and turn structure

- [ ] **Goal:** Alternating activations per the concept doc.
- [ ] **Learn first:** State machine patterns in GDScript. GDScript `enum`. Think about whether your turn system is a state machine or just a queue — argue it both ways before deciding.
- [ ] **Build:** A `GameState` class in `logic/`. Squads, activation order, per-unit "has acted" tracking, phase transitions. Signals so the view can react.
- [ ] **Test:** **You write these now.** Turn order advances correctly, units can't act twice, the round ends when everyone has acted.
- [ ] **Done when:** The whole turn cycle runs headlessly in tests with no view attached.
- [ ] **Traps:** Turn logic living in UI nodes. If your "end turn" button contains rules, they're in the wrong place.

### Step 2.2 — Heroes as Resources

- [ ] **Goal:** Data-driven hero definitions. **This is the most important Godot-specific idiom in the entire plan.**
- [ ] **Learn first:** Custom `Resource` classes, `class_name`, `@export` annotations, `.tres` files, and how the inspector edits them. Understand why Resources are Godot's answer to data-driven design and how they differ from plain classes.
- [ ] **Build:** A `HeroStats` Resource — move, HP, attack dice, range, name, mesh reference. Author three heroes as `.tres` files in `data/`.
- [ ] **Done when:** You can add a fourth hero by creating a file in the editor, without touching a single line of code.
- [ ] **Traps:** Hardcoding stats in scripts, or building a JSON loader out of habit. Godot has a first-class answer here and it's integrated with the editor — use it. This step pays off enormously at M4.

### Step 2.3 — Attacks and death

- [ ] **Goal:** Units can kill each other; matches can end.
- [ ] **Build:** Melee attack action, deterministic damage for now (dice come at M2), HP tracking, unit removal, elimination victory check.
- [ ] **Test:** You write. Include the edge cases — last unit dies, simultaneous conditions, attacking an already-dead unit.
- [ ] **Done when:** A match can be won.
- [ ] **Traps:** Deleting the unit node from the logic layer. Logic marks it dead and emits; the view handles the disappearing.

### Step 2.4 — UI

- [ ] **Goal:** Play without knowing the code.
- [ ] **Learn first:** `Control` nodes, anchors and margins, the container system (`VBoxContainer`, `MarginContainer`). This is the part of Godot people most often fight — read the "Design interfaces with the Control nodes" docs before improvising. Also `Label3D` / `Sprite3D` for world-space health display, and `unproject_position()` for pinning 2D UI to 3D objects.
- [ ] **Build:** Whose turn it is, selected unit panel, HP visible on or near each mini, an end-turn button.
- [ ] **Done when:** Someone who has never seen the project can tell what's going on.
- [ ] **Traps:** Manually positioning Controls in pixels instead of using anchors and containers. It'll look fine at your resolution and break everywhere else.

### Step 2.5 — Close the loop **[REVIEW]**

- [ ] **Goal:** **M1 complete.**
- [ ] **Build:** Win screen, restart without relaunching, clear hotseat handoff so players know when control passes.
- [ ] **Done when:** Two people play a full match start to finish without you touching the editor. **Actually do this with a real person.**
- [ ] **[REVIEW]** Milestone review, with an eye on whether the M2 rules work will fit cleanly or fight the current structure.

---

# Phase 3 — M2: The game shows up

**Milestone goal:** the first honest answer to "is this fun". Expect to change rules heavily here — that's the point, and it's why the logic layer is isolated.

### Step 3.1 — Dice pools **[TESTS PROVIDED]**

- [ ] **Goal:** Combat resolution as specified in the concept doc — d6 pools, 4+ hits.
- [ ] **Learn first:** `RandomNumberGenerator` and **seeding**. Understand why an injectable seeded RNG is the difference between testable and untestable combat.
- [ ] **Build:** A dice roller with an injectable RNG, hit counting, damage application.
- [ ] **Test:** I provide the suite, using fixed seeds.
- [ ] **Traps:** Calling the global `randi()` directly. It works, and it makes your combat permanently untestable and unreplayable.

### Step 3.2 — Visible dice

- [ ] **Goal:** The tabletop feel — dice that physically roll.
- [ ] **Learn first:** `RigidBody3D` and physics basics. Then read the trap below before you build anything, because it changes the design.
- [ ] **Build:** 3D dice that tumble onto the table and land showing the result.
- [ ] **⚠ The important tip:** **Determine the result in logic first, then animate dice to land on it.** Do not let physics decide the outcome. Physics-determined results are non-deterministic, unreplayable, untestable, impossible to network later, and will occasionally throw a die off the table. Every game that does this well fakes it. Landing a die on a chosen face is a solvable animation problem; recovering from physics deciding your combat is not.
- [ ] **Done when:** Attacks roll dice whose faces match the logical result exactly, every time.

### Step 3.3 — Height bonus

- [ ] **Goal:** +1 die for ranged attacks downhill (concept doc, height notes).
- [ ] **Build:** The modifier, plus UI that *explains* it: "4 dice — 3 base, +1 height".
- [ ] **Done when:** A player can see why they're rolling the number of dice they're rolling.
- [ ] **Traps:** Making modifiers invisible. In a dice game, an unexplained number reads as a bug. Build the explanation alongside the rule, not afterwards.

### Step 3.4 — Line of sight **[TESTS PROVIDED]**

- [ ] **Goal:** The LoS rule from the concept doc — blocks if higher than both shooter and target.
- [ ] **Learn first:** Re-read the Line of sight design notes in the concept doc, including the symmetry argument and the marginal case. Then Red Blob's line drawing, and specifically the boundary-ambiguity problem.
- [ ] **Build:** Line tracing with permissive dual-line handling, the blocking rule, and the ruling that units never block.
- [ ] **Test:** I provide the suite, encoding every row of the doc's table plus the marginal cases.
- [ ] **Traps:** The hex-boundary ambiguity is the whole difficulty here. If your tests pass but diagonal shots feel wrong in play, that's where to look.

### Step 3.5 — LoS visualisation **[REVIEW]**

- [ ] **Goal:** Legibility. The concept doc says this ships *with* the rule as one task, because the rule is unusable without it.
- [ ] **Build:** Valid targets outlined on selection, blocked targets marked, the offending hex flagged on hover.
- [ ] **Learn first:** Outline/highlight approaches — a shader, a duplicated inverted-hull mesh, or `MeshInstance3D` overlay material. Compare and pick one. First real shader contact, and good preparation for M4.
- [ ] **Done when:** A new player can tell why a shot is unavailable **without asking you.** Test this on an actual human.
- [ ] **[REVIEW]** LoS is the most intricate rule in the game — worth a careful look at both correctness and how the view queries it.

### Step 3.6 — Heroes with abilities **[REVIEW] [EXPLAIN]**

- [ ] **Goal:** 3–4 genuinely distinct heroes with signature abilities.
- [ ] **Learn first:** Think hard about ability architecture *before* writing it. Options: Resource-based ability definitions, a command pattern, composition via child nodes. Consider how an ability declares its own targeting rules.
- [ ] **Build:** Four heroes whose abilities feel different to play.
- [ ] **Traps:** The giant `match` statement. This is the classic place where a tactics game turns into an unmaintainable mess, and it's precisely where the earlier architecture investment either pays off or doesn't.
- [ ] **[REVIEW]** Ask for this one *before* you've built all four — show me the pattern with one ability implemented, so a redesign costs one ability instead of four.
- [ ] **[EXPLAIN]** Why this ability structure, and how would you add a "push the target one hex" ability to it?

### Step 3.7 — Playtest 🎲

- [ ] **Goal:** **M2 complete** — answer "is this fun?"
- [ ] **Build:** Nothing. This step is not a coding step and it is not optional.
- [ ] **Do:** Play several full matches with a real opponent. Watch where they hesitate, what they misread, what they never use.
- [ ] **Done when:** You have preliminary answers to open questions 1–11 in the concept doc, written into that document.
- [ ] **Expect:** To change rules. That's success, not failure. This is exactly why the rules live in an isolated, tested layer.

---

# Phase 4+ — Sketch only

Deliberately loose. Anything past your first fun-check is speculative and will change based on what M2 teaches you.

**M3 — The tabletop feel.** Topics: materials and PBR, lighting and shadows in Godot 4, `WorldEnvironment`, post-processing, audio (`AudioStreamPlayer3D`, bus layout), juice and game feel — screen shake, hit pauses, easing curves.

**M4 — Customization phase 1.** The big learning topic here is **shaders**: Godot's shading language, `ShaderMaterial`, mask textures, per-instance uniforms. Plus save/load via `Resource` serialisation or `FileAccess` + JSON, and skeleton attachment points (`BoneAttachment3D`) for gear swapping. Step 2.2's Resource work is the foundation for all of it.

**M5 — AI.** Topics: minimax and why it probably doesn't suit this game, utility/scoring-based AI, behaviour trees, threading long computations. The rules being pure and headless is what makes AI tractable at all — it can simulate moves without touching the view.

---

## Standing list — Godot traps for experienced developers

Things your existing instincts will get wrong. Re-read occasionally.

- **Fighting the node tree.** Godot wants composition through child nodes; deep inheritance hierarchies fight the engine.
- **Polling instead of signals.** Especially damaging in a turn-based game where almost nothing needs per-frame updates.
- **Ignoring Resources.** Godot's data-driven answer is first-class and editor-integrated. Reaching for a custom JSON loader is a code smell here.
- **God scripts.** A 600-line `Game.gd` is the natural drift. Split by responsibility early.
- **Autoload abuse.** Singletons are convenient and become invisible coupling. Two or three, deliberately chosen, not twelve.
- **Untyped GDScript.** You chose static typing — actually use it everywhere, including return types (`-> void`). You get real editor errors and meaningfully better performance.
- **`get_node()` path strings scattered everywhere.** `@onready var x: Node = $Path` or `@export` references. Long `../../` paths are a design smell.
- **Physics deciding gameplay outcomes.** See the dice step. Physics is for looks.
- **Not reading the class reference.** Godot's built-in docs (F1 in-editor) are excellent and searchable offline. The answer is usually there.

## Reference links

- Godot docs: `docs.godotengine.org` — the "Step by step" and "Your first 3D game" tutorials are worth doing in full.
- Red Blob Games hex grids: `redblobgames.com/grids/hexagons` — the definitive hex reference. You'll return to it at steps 1.2, 1.3, 1.5, 1.7 and 3.4.
- GUT (Godot Unit Test): the addon you'll install at step 1.1.
- In-editor class reference: **F1**. Faster than a web search and always matches your version.
