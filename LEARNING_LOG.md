# Learning Log

Running notes on building Miniature Heroes. One entry per session. Keep it honest — the confusions are the most useful part, both for reinforcing what you learned and for giving Claude real context in later sessions.

Template:

```
## YYYY-MM-DD — Step X.Y
**Did:**
**Learned:**
**Confused me:**
**Would do differently:**
```

---

## 2026-07-29 — Step 0.2 closed (code review session)

Project: `C:\Users\Atsuro\Documents\godot-warm-up`.

**Did:** Worked through the whole review agenda from the last entry, then kept going. Scope changed slightly on purpose: only *one* cube carries the highlight at a time. Final shape is `CubeManager` (wiring only) → `CubeSpawner` (creates, emits `cube_spawned`) + `CubeSelector` (owns `selected`, decides who lights up) → `Cube` (emits `clicked`, offers `set_highlighted(bool)`).

**Learned:**
- `class_name` + concrete type annotations are what buy static checking — the modern `signal.connect(callable)` syntax alone gives almost nothing if the variable is still typed `Node`. The three belong together.
- Godot 3 vs 4 signal APIs, and why online answers are split. `node.clicked.connect(_on_clicked)` is the Godot 4 form; the string version is the low-level API underneath, only needed for runtime-determined names.
- `class_name` is about *other scripts naming the type*, not about signals or the editor. It's a flat project-wide namespace, so not everything should have one.
- `_ready()` runs children-before-parent — that's a guarantee. Sibling order is not something to build on.
- `set_surface_override_material()` beats swapping the whole mesh: one mesh, appearance layered on top.
- Leading underscore = private to the script. It goes on signal handlers and internal helpers, not on a node's public API.
- `.tscn` files keep orphaned properties around after an export is renamed or removed.

**Confused me:**
- Hit the `_ready()` ordering problem by accident before understanding it — the whole thing only worked because `CubePainter` happened to sit above `CubeSpawner` in the scene tree. Fixed by giving `CubeManager` the start order explicitly.
- Overcorrected on the underscore convention: put `_` on `_change_surface_material` while it was still being called from outside. Ironically it became correct later, once the call moved inside the cube.
- Argued for passing a `StandardMaterial3D` into the cube because paint/colour picking would come from outside later. Half right — but highlight and paint are two systems that must *compose*, not overwrite each other, so they need separate interfaces. Highlight stays binary.

**The architecture lesson (the actual one):** the responsibility for "who is selected" moved four times in one evening — Cube decides itself → Painter decides → Manager swallowed the Painter (leaving a node that did nothing) → Selector owns it. The rule that fell out: **state belongs where the decision is made.** Here that's `CubeSelector`. In Miniature Heroes it will *not* be the view layer — "which unit is active" is a rules question (whose turn, already activated, which faction), so `logic/` will own it and the view will just react to a `selection_changed` signal. Same rule, different answer, because the decision sits somewhere else.

**Would do differently:** Fix the whole flagged batch in one pass instead of piecemeal — a couple of items (`signal clicked(who: Node)` should be `Cube`, missing `-> void`) survived four rounds of review simply because they were small. Also introduced `CubeManager` without immediately checking whether `CubePainter` still had anything to do; it sat there as a dead node with a live reference for a while.

**Open / deliberately parked:**
- Design question: should clicking the already-selected cube deselect it (toggle) or re-select it? Currently re-selects. Matters for unit selection later.
- `Cube` is a `RigidBody3D` — fine for the warm-up, wrong for hex tiles. Clickable without physics simulation is a different body class.
- The spawner is a plain `Node` positioning 3D children. Works because it sits at the origin; a board container you want to move or rotate would need `Node3D`.

**Next:** step 0.3 — manual raycast picking, replacing `_input_event` with the version that gives the *ground position*, not just the hit object.

---

## 2026-07-29 (later) — Step 0.3 started

**Did:** Read up on the picking APIs first, checked my understanding against Claude before touching code, then built the manual raycast. `camera_3d.gd` on the `Camera3D`: click → `project_ray_origin` / `project_ray_normal` → `PhysicsRayQueryParameters3D.create(from, to)` → `intersect_ray` → empty check. Plus `RayIntersectionResult` (`RefCounted`), a statically typed wrapper around the result dictionary. Both picking approaches now run side by side — the cube's `_input_event` still drives selection, the camera raycast prints.

**Learned:**
- **"normal" is two different words in graphics.** *Surface normal* = perpendicular to a face. *Normalized* = length 1. `project_ray_normal()` means the second one: it returns the ray's **direction** as a unit vector. Only the pixel at screen centre gives a direction perpendicular to the camera plane — every other pixel is slanted, and that slant *is* the perspective. Confusingly, `intersect_ray()` then hands back a `normal` field that really is a surface normal.
- `project_ray_origin()` returns a **world-space** point, not a screen point. Screen coords in, world coords out — that's the whole job. Still to nail down: why it isn't simply the camera position (the answer involves orthogonal cameras).
- `intersect_ray()` returns **one** hit — the closest — or an **empty** dictionary. Not a list. Getting all hits along a ray is a different technique (matters later for line of sight).
- Layer = "what am I", mask = "what am I looking for". Both are 32-bit masks. A raycast *query* has only a mask, no layer, so detection is asymmetric by nature.
- **`_input_event` is a raycast too** — Godot just fires it for me when object picking is enabled. Manual vs. `Area3D` isn't two mechanisms, it's the same one automatic vs. by hand. The real question is who owns the ray and who owns the result.

**Confused me:**
- Went in thinking `project_ray_normal` returned something perpendicular to the camera plane. Wrong word, right definition. Worth remembering as a vocabulary trap rather than a maths gap.
- Assumed `intersect_ray` returned a collection of everything hit. It doesn't.
- Still not intuitive: when to prefer manual raycasting over `Area3D`, in practice rather than on paper. Both are running now precisely so I can compare.

**Found in review, not by me:**
- Cached `get_direct_space_state()` in `_ready()` and queried it from `_input`. There is a documented restriction on when the space state is valid and which callback physics queries belong in — I broke both. Works today, would fail intermittently later.
- `_input` is likely the wrong callback anyway: with UI on top, a click on a button would fire the world raycast as well.
- `RayIntersectionResult` mirrors the engine dictionary field for field — one field doesn't exist in the result at all (arrives as silent `null`) and one real one is missing. Also `Dictionary.get()` takes a default for exactly this case, and GDScript already has a `_to_string` convention instead of my `to_custom_string()`.

**Would do differently:** Check the doc's return-value table *field by field* instead of from memory — I'd flagged "look up the result keys" as a to-do and then wrote the wrapper from what I thought I'd seen.

**The open thread (third time now):** ownership. Picking currently lives on the `Camera3D`, because that's where `project_ray_*` happens to be. Same question as "who owns the selection" and "who distributes the click", one level over: does the camera need picking, or does a picker need a camera? Goal for next session: **ask this myself before it comes up in review.**

**Also noted:** `RayIntersectionResult` currently *mirrors* the engine dictionary. The payoff comes when it *translates* into domain vocabulary instead — for the real project the interesting answer is "which hex, which unit", not "which `Object`, which `RID`". Right instinct, stopped one level short.

**Next:** finish 0.3 — click the floor, get exact world coordinates. That's the half that actually matters for hex tiles, and where the layer/mask trap lives. Deliberately learn that one by breaking it rather than reading about it.

---

## 2026-07-25 (evening) — Steps 0.1 + 0.2 — **NEXT SESSION STARTS WITH A CODE REVIEW**

Project: `C:\Users\Atsuro\Documents\godot-warm-up` (throwaway, not under git).

**Done:** Step 0.1 complete. Step 0.2 complete pending review — cube emits a custom `clicked(who)` signal via `_input_event`, spawner connects to it and prints, and clicking a cube changes only that cube's colour.

**Learned:** `PackedScene` vs instance (signals live on instances, not the scene file). The node → mesh → material chain and which links are shared: resources are shared by default, only the *node* is per-instance. Shallow vs deep `duplicate()`. Where `albedo_color` actually lives (`StandardMaterial3D`, not any node).

**Fixed from the first review:** files renamed to snake_case, `node_3d.tscn` → `main_scene.tscn`, `add_child()` now happens before positioning, `@onready`+`preload` contradiction removed, some type annotations added.

**Confused me:** finding `albedo_color` in the docs — searching for a "path" rather than for the owning class. Resolved: F1 searches property names directly, and the inspector's resource sub-panel names the class.

### Review agenda for next session

Ask Claude: `review warm-up 0.2`. Things already spotted, to work through together:

**`scripts/cube.gd`**
- [ ] `if event.pressed` doesn't check *which* button — right-click and scroll wheel currently count as clicks. Filtering is half-done.
- [ ] A new Mesh **and** a new Material are allocated on *every single click*. Ten clicks, ten orphaned mesh/material pairs. Where should that duplication actually happen?
- [ ] `duplicate()` is shallow by default — that's precisely why the second duplicate for the material was needed. Look up the parameter that changes this, and see how many lines it collapses.
- [ ] Compare against the surface-override approach that was abandoned: it needs no mesh duplication at all. Which is better here, and why?
- [ ] `var new_material` is untyped — and ironically that's the only reason the script compiles. Work out why typing it `Material` would *fail* while `StandardMaterial3D` would succeed. Good illustration of what static typing buys.
- [ ] Design question: the cube both emits `clicked` *and* decides its own new colour. Defensible — but for "select a unit and highlight it" in Miniature Heroes, who should own that decision?

**`scripts/cube_spawner.gd`**
- [ ] `connect("clicked", ...)` uses the **Godot 3 string-based API**. Godot 4 has a first-class signal object syntax that gets checked at compile time — a typo'd signal name here fails silently at runtime instead. Exactly the version trap discussed.
- [ ] `cubeBody` is still camelCase, and it's a `preload` in a `var` rather than a `const`.
- [ ] `cubeInstance: Node` is too general to resolve `.clicked`. Chain worth doing: add `class_name` to cube.gd → type the variable properly → switch to the modern connect syntax → get real static checking.
- [ ] `on_cube_clicked` — convention is a leading underscore, and it's missing its `-> void`.
- [ ] The `who` parameter is passed but unused; the handler prints "Test" regardless of which cube was clicked. Making it identify the cube is the natural finish to 0.2.

**Next after the review:** step 0.3 — manual raycast picking. This replaces the engine's built-in picking with the version needed for hex tiles, where the *ground position* matters, not just which object was hit.

---

## 2026-07-25 — Planning

**Did:** Wrote GAME_CONCEPT.md and LEARNING_PLAN.md with Claude. Settled the collaboration model: Claude writes specs, tests, docs and reviews but no production `.gd` code; tier-1 hints by default; GDScript with static typing.

**Decided:** Rules engine stays free of the scene tree — pure `RefCounted` logic, separate view layer. Everything in the plan depends on holding that line.

**Next:** Phase 0, step 0.1 — throwaway warm-up project, node tree literacy.
