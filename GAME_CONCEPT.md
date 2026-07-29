# Miniature Heroes — Concept Draft

*Draft v0.2 — 2026-07-25 — living document, expect everything below to change once the prototype exists.*

## One-line pitch

A turn-based hex tactics game that looks and feels like playing with real miniatures on a hobby table — you pick heroes from your collection, roll visible dice, and over time paint and customize the minis themselves.

## Context & constraints (read this first, future me)

- Solo hobby project by a developer with software experience but almost no game dev experience.
- Godot engine.
- No deadline, but the biggest risk is scope death. Every decision below favors *finishable* over *impressive*.
- Success for v1 is: "two people at one keyboard have fun for 20 minutes."

## Design pillars

Every feature must serve at least one of these. If it serves none, it's cut.

1. **Tactical clarity** — small numbers, readable rules, positioning matters (height!). You should be able to plan a turn in your head.
2. **The tabletop feel** — the game is fiction-framed as toys on a table: minis on bases, terrain tiles, dice that physically roll. Low-poly, slightly toy-like art is the *style*, not a compromise.
3. **Your minis are yours** — heroes are collectible objects you customize (paint zones, decals, gear swaps). Attachment to the pieces, not just the tactics.

## Theme & framing

- **Frame:** these are literally toys/minis on someone's hobby table. Menus can look like a shelf or carrying case; the battlefield is modular terrain pieces.
- **Content:** classic fantasy roster first (knights, mages, orcs, archers) — this is where free/cheap low-poly asset packs live.
- **The toy frame is a license:** anything can join the roster later (a wind-up robot, a toy dinosaur) without breaking theme. Nothing is off-limits if it would sit believably on a hobby shelf.

## Presentation

- 3D, low-poly, digital tabletop. Orbitable camera looking down at the board.
- Units are minis on round bases; bases snap to hexes.
- Dice are physical objects rolled on the table — the roll IS the feedback.
- Initial art from CC0/cheap packs (KayKit, Kenney, Quaternius). Custom or commissioned models come later, and only once the paint-zone system defines what a model needs (see Customization).

## Core gameplay (rules v0 — a starting point to playtest, not a bible)

### Board
- Hex grid, small maps (roughly 9×9 to start).
- Tiles have a **height level** (0–2 to start). Height is the launch mechanic; cover and terrain effects are parked (see Cut/Later list).
- **Climbing costs +1 movement per level.** Reaching a summit should take two activations, not one — this is what makes taking the high ground a real decision rather than a free upgrade (see Height design notes).
- **Summits are small — 1–2 hexes.** A peak that fits one model is a duel spot; a six-hex plateau is a fortress. This is the cheapest balance knob available and it's tunable per map without touching the rules.

### Squads
- Each player picks **3 heroes** from a shared roster (target: 6 heroes at v1, so picks feel like choices).
- Heroes are asymmetric: e.g. Knight (tanky, melee), Archer (ranged, fragile), Mage (area damage, slow), Rogue (mobile, flanker), Cleric (support), Brute (big damage, big target).

### Turn structure
- Alternating activations: Player A activates one hero, then Player B, until all heroes have acted. (Alternating > "I move my whole team" — less downtime, more counterplay, and it's how modern miniature games work.)
- An activated hero can **Move** and take **one Action** (attack, ability, defend), in either order.

### Stats (keep them countable on one hand)
- **Move** (hexes), **HP** (small numbers, ~3–8), **Attack dice**, **Range**, one **signature ability**.

### Combat resolution — visible dice
- Attacker rolls their **Attack dice** (d6 pool). Each die ≥ 4+ is a hit; each hit = 1 damage. (Numbers are placeholders; the *shape* — dice pool, count successes — is the decision.)
- **Height advantage (ranged only):** a ranged attack against a target on lower ground grants **+1 die**. **Melee ignores height entirely** at M2 — see the design notes below for why the melee uphill penalty was removed before it was ever tested.
- Ranged attacks require **line of sight**: an intervening tile blocks if its height is greater than both the shooter's tile and the target's tile. Blocking is binary — blocked means unshootable, not shootable at a penalty. Full rule, rationale and edge cases in the Line of sight design notes below.

### Winning
- Last squad standing, on small maps this stays fast. Objective modes (grab the relic, hold a point) come later if elimination proves degenerate (turtling) — but note the Height design notes: an objective placed *away from* the high ground is also the main structural counterweight to hill-camping, so this may need to arrive earlier than planned.

## Height — design notes

*Recorded 2026-07-25. This is the reasoning behind the height rules above; revisit it before changing them.*

**The framing.** There is no natural "risk" to standing on a hill, and inventing one (vertigo, exposure to wind) would be artificial and unfun. A positional bonus doesn't need a risk, it needs an **opportunity cost**. The design target is high ground that is *easy to want and hard to hold* — not high ground that is dangerous to stand on.

**Why the melee uphill penalty was cut.** With d6 pools hitting on 4+, every die is half a point of expected damage. Under the original v0.1 rules a 3-die attacker on high ground rolled 4 dice (2.0 expected damage) while an attacker coming uphill rolled 2 (1.0) — a **2:1 swing**, meaning whoever took the hill killed twice as fast and could not realistically be dislodged. The ranged bonus on its own is 4 dice against 3, a much healthier +33%. Conclusion: the ranged bonus creates interesting positioning, while the melee penalty is what turned a magnet into an unstormable fortress. Archers and mages should covet the hill; melee should be able to storm it at roughly fair odds. The penalty can be added back later if the hill proves too easy to take.

**The four levers that give height an opportunity cost**, cheapest to implement first:

1. **Small summits** — map design only, zero rules cost, tunable per map. Also lets the Mage's area damage punish anyone stacking the peak.
2. **Exposure through line of sight** — free, falls straight out of the LoS system. Being high means seeing everything, which means being seen by everything: you gain a bonus against one target and become shootable by the whole enemy team. Against a ranged-heavy squad the hill is a bad place to be.
3. **Climbing costs tempo** — the +1 movement per level rule. Turns "is high ground better?" (obviously yes) into "is it worth two turns of doing nothing else?", which is an actual decision.
4. **Win conditions located elsewhere** — the structural fix. Under pure elimination the hill is unambiguously correct because there is nothing else to want. With an objective off the peak, camping the high ground means sniping while slowly losing.

**Reasons a player might legitimately not climb**, all consequences of the above: the hill is three turns from the objective; the enemy brought two archers and the summit has no cover; a melee-heavy squad gains little and has to close anyway; the peak fits one model and sending your best hero up there isolates it from the healer; and — the most interesting case — high ground and concealment are opposites, so sometimes the right play is to sit *behind* the hill rather than on it.

**A point in favour of dice.** A 2-vs-4 dice exchange is bad odds but not impossible, so a hill position is never mathematically airtight the way it would be under deterministic damage. Randomness is doing real design work here.

**What to actually playtest at M2:** melee ignores height, ranged gets +1 die downhill, climbing costs +1 movement per level, summits are 1–2 hexes.

## Line of sight — design notes

*Recorded 2026-07-25. Same status as the height notes: this is reasoning, not scripture.*

### The rule

> Trace a line from the shooter's hex to the target's hex. An intervening tile blocks line of sight if its height is **greater than both the shooter's tile and the target's tile.**

Only tiles strictly between the two count — never the shooter's own tile or the target's. What it produces:

| Shooter | Target | Blocker between | Result |
|---|---|---|---|
| 0 | 0 | 1 | Blocked |
| 1 | 0 | 1 | Visible — level with the ridge, you see over it |
| 0 | 1 | 1 | Visible — the target stands on top of the obstacle |
| 2 | 0 | 1 | Visible — shooting down from a peak over a low ridge |
| 0 | 2 | 1 | Visible — a unit on a high peak is exposed to everyone |

The last row matters most: the exposure counterweight promised in the height notes falls out of the geometry instead of needing its own rule. Climbing buys sightlines *and* the damage bonus, but it also makes you visible to the whole board. See more, be seen more.

### Why this rule and not a more intuitive one

The rule treats shooter and target identically, so **line of sight is always mutual**. That is not a nice-to-have. The variant that matches gut feeling more closely — roughly "blocks if the obstacle is at least as high as the target" — makes an archer standing back from a plateau edge able to see and shoot a unit below while that unit cannot see them. One-way line of sight in a PvP tactics game is genuinely broken: players get shot from positions they had no way to identify as threats, with no feedback explaining why. Every rule that produces the "feels blocked" intuition breaks symmetry, and symmetry is worth more than the marginal case. This is close to the only clean symmetric rule available.

### The marginal case, worked out

The scenario that feels wrong: my unit on level 0 is pressed against an empty level-1 step, and an enemy archer stands on a level-1 tile one hex behind it. The rule says visible. Does that survive crouching to eye level?

Yes. Setting one level equal to one model height and the eye at ~90% of model height, the sightline clears the near lip of the step at about 1.3 levels up, while the archer's body spans 1.0 to 2.0 levels. **Roughly the top 70% of the archer is above the sightline** — visible from about the knees up. The misleading intuition is picturing the archer *behind* a wall at your own level; they are standing *on* that level, one hex back, so they sit well above your line. Rule and geometry agree.

### Rulings

- **Units never block line of sight** (at least through M2). Body-blocking adds a frustration layer disproportionate to what it contributes.
- **Blocking is binary, not partial.** A blocked target is unshootable, not shootable-at-a-penalty. Partial cover would mean a second modifier system stacking with the height dice, and cover is deliberately parked.
- **Melee ignores line of sight entirely** — adjacency is the only requirement, at any level difference. Reaching up a two-metre cliff is physically odd, but forbidding it rebuilds the unstormable fortress the height rules exist to prevent.

### Visual consequence — commit to slabs, not slopes

For a level-1 tile to block a level-0 unit, the step must be taller than a model. So terrain is **stacked slabs, plateaus and cliff edges — not gentle rolling hills.** This is good news three times over: it is exactly what real hobby terrain looks like (foam risers stacked into mesas), it reads unambiguously at a glance, and hex prisms are far easier to model and to write pathfinding against than smooth slopes.

### Implementation

- Convert both hexes to cube coordinates, interpolate between them, round each sample to the nearest hex.
- The one wrinkle is lines running exactly along a hex boundary, where rounding is ambiguous. Compute both candidate lines and treat the target as **visible if either line is clear** — go permissive. Restrictive line of sight in a three-unit squad game produces turns where you genuinely cannot act, which reads as broken rather than tactical.
- Red Blob Games' hex grid reference has the canonical line-drawing code. Read it before writing any of this.

### Legibility — where the real work is

Line of sight is trivial to compute and notoriously hard to communicate. If a player cannot see why a shot is blocked, they file it as a bug.

- **Highlighting is the answer.** Valid targets outlined green the moment a unit is selected; blocked ones red, with the offending hex flashing on hover. This is what teaches the rule.
- **No true raycast line of sight, ever.** Model-to-model raycasting is what tabletop calls "true LoS" and it is the most argued-about rule in the hobby — unpredictable, unplannable from a top-down view, and miserable to write AI against. The hex rule is the truth.
- **The eye-level camera is atmosphere, not adjudication.** Dropping the camera to model height is charming and orients the player, but it must never be the targeting tool — and even in that view, target outlines stay drawn through terrain so the view can never appear to contradict the rule.

### Escape hatch, if this proves confusing

Make height **not block line of sight at all**: height gives the dice bonus and costs movement, full stop, and sight is blocked only by explicit tall props placed on tiles (rock spires, ruined walls, big trees). Trivially readable — if there is a thing in the way, you cannot shoot through it. The cost is losing the "climb to see over the ridge" interaction and the free exposure counterweight, plus needing props to become a system. Keep this in the back pocket for the first playtester who bounces off the height rule.

## Mini customization (the differentiator — scoped honestly)

The dream is freeform painting. The v1-achievable version that delivers ~90% of the fantasy:

- **Paint zones:** each model has 4–6 masked regions (armor, cloth, metal, skin, base rim). Player picks a color per zone. Tech: shader with mask texture + color parameters. Very doable in Godot.
- **Decals:** pre-made emblems placeable in fixed slots (shield face, banner, shoulder). Tech: decal projector or pre-UV'd overlay slot.
- **Gear swaps:** weapons/shields/helmets as separate meshes on attachment bones. Swaps are cosmetic-first; light stat effects only after combat is proven fun.
- **Consequence for assets:** models must be *built or chosen* with paint masks and attachment points in mind. This is a hard requirement when evaluating asset packs or commissioning models.
- Freeform brush painting = parked as a dream feature. Do not attempt before everything else works.

Customization is **phase 2**. It's the soul of the game, but it decorates a core that must already be fun. Painting minis for a boring game is a model viewer.

## Roadmap (milestones, not dates)

- **M0 — Godot literacy:** hex grid rendered in 3D, click a hex, a placeholder mini moves to it. Pathfinding on hexes. Orbit camera. *(This alone is a real achievement for a first project.)*
- **M1 — Graybox hotseat skirmish:** 2 players, one screen, 3 identical units each, move + melee attack, deterministic damage, elimination win. Ugly on purpose.
- **M2 — The game shows up:** dice-pool combat with visible rolls, height levels + advantage rules, 3–4 distinct hero types, ranged attacks + line of sight. LoS ships *with* its target highlighting — the rule is unusable without it, so they are one task, not two. **← First "is this fun?" checkpoint. Be willing to change rules v0 heavily here.**
- **M3 — The tabletop feel:** minis on bases, terrain-tile look, dice rolling with weight and sound, UI framed as tabletop paraphernalia.
- **M4 — Customization phase 1:** paint zones + gear swaps, a "collection shelf" screen, choices persist between matches.
- **M5 — Solo play:** simple AI (or scripted scenario opponents as a stepping stone). Only now, with rules stable — AI built on shifting rules is wasted work.
- **Beyond (unpromised):** campaign/progression, objective modes, cover & terrain effects, decals, more heroes, online multiplayer (explicitly last — networking multiplies everything).

## Cut / Later list (things we are NOT doing yet, on purpose)

| Feature | Status | Why |
|---|---|---|
| Cover system | Later (post-M5) | Height already provides positional play; two positional systems at once muddies both. |
| Terrain effects (mud, water…) | Later | Same reason; add when maps feel samey. |
| Enemy AI | M5, not before | Biggest hidden cost in the genre; hotseat answers "is it fun?" for free. |
| Freeform painting | Dream shelf | Real texture painting is a project of its own. Paint zones deliver the fantasy. |
| Online multiplayer | Dream shelf | Networking + a first game = the classic hobby-project killer. |
| Campaign/story | Dream shelf | Skirmish must be fun standalone first. |

## Risks & honest mitigations

- **Scope death** → the pillars + cut list exist to say no. Re-read them when excited about a new idea.
- **AI turns out too hard** → the game is designed to be complete as a hotseat game; AI is an expansion, not a foundation.
- **Rules v0 isn't fun at M2** → that's the point of M2. Iterate on rules with graybox art; changing numbers is cheap, changing engines/art isn't.
- **Asset packs don't support paint zones** → accept flat-color tinting (whole-material tint) as an interim; commission 1–2 proper heroes only after the game is fun.
- **Motivation dips (it's a hobby)** → milestones are sized to produce something *visible* each time; M0 is deliberately achievable.

## Open questions (to answer with playtests, not more design docs)

1. Do alternating activations feel better than full-team turns at this squad size?
2. Is 4+ to hit / +1 die for height swingy in a good way or a frustrating way?
3. Right squad size — is 3 v 3 enough for tactics, or does it need 4–5?
4. Does elimination-only lead to turtling on 9×9 maps?
5. How generous can line of sight be before ranged units dominate?
6. With melee ignoring height, does the hill still feel worth taking — or has it become a mere archer perch nobody contests?
7. Is +1 movement per level enough of a tempo cost, or does climbing need to eat a whole activation?
8. Does the exposure counterweight actually materialise, or do maps need deliberate sightlines onto every summit for it to bite?
9. Can a player predict from the top-down view whether a shot exists, or do they have to try it and find out? (If the latter, the highlighting isn't doing its job.)
10. Does binary blocking produce dead turns where a unit has no legal target and nothing useful to do?
11. Is permissive dual-line tracing too generous — do ranged units end up shooting through gaps that visibly look closed?
