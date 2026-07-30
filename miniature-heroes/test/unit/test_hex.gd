extends GutTest

## Spec for `res://logic/hex/hex.gd` — `class_name Hex`.
##
## Storage is axial:      Vector2i(q, r)
## Computation is cube:   Vector3i(q, r, s), invariant q + r + s == 0
##
## `Hex` holds only static functions. There is no instance state, no
## constructor, and — deliberately — no world or pixel position anywhere in
## this file. Fractional *axial* coordinates go in, axial coordinates come
## out. The mapping to 3D space is a view concern and arrives in step 1.3.
##
## Required public surface:
##
##   const DIRECTIONS         : Array[Vector2i]   (6 entries, order below)
##   to_cube(hex)             -> Vector3i
##   from_cube(cube)          -> Vector2i
##   direction(index)         -> Vector2i         (index wraps, see below)
##   neighbor(hex, index)     -> Vector2i
##   neighbors(hex)           -> Array[Vector2i]
##   distance(a, b)           -> int
##   round_axial(frac)        -> Vector2i         (frac is a Vector2)
##   line(a, b)               -> Array[Vector2i]
##   hexes_in_range(c, r)     -> Array[Vector2i]
##   ring(c, r)               -> Array[Vector2i]
##   spiral(c, r)             -> Array[Vector2i]
##
## Two spec decisions worth knowing before you start:
##
## 1. Direction indices wrap in both directions: index 6 is index 0, index -1
##    is index 5. Look up `posmod` before reaching for `%` — GDScript's `%`
##    keeps the sign of the left operand, which is not what you want here.
## 2. `ring` and `hexes_in_range` are defined for radius 0 (a single hex) and
##    return an empty array for negative radii. The radius-0 case is the one
##    that breaks the textbook ring algorithm; that is intentional.
##
## Ordering: `neighbors` must follow DIRECTIONS order, `line` runs from `a` to
## `b`, and `spiral` starts at the centre. `ring` and `hexes_in_range` are
## specified as sets — any order you like, as long as the contents are right.


# ---------------------------------------------------------------- helpers ---

func _compare_hex(a: Vector2i, b: Vector2i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	return a.y < b.y


func _sorted(hexes: Array[Vector2i]) -> Array[Vector2i]:
	var copy: Array[Vector2i] = hexes.duplicate()
	copy.sort_custom(_compare_hex)
	return copy


func _assert_same_set(got: Array[Vector2i], expected: Array[Vector2i], text: String = "") -> void:
	assert_eq(_sorted(got), _sorted(expected), text)


func _expected_directions() -> Array[Vector2i]:
	return [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
	]


func _sample_hexes() -> Array[Vector2i]:
	return [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(3, -2),
		Vector2i(-4, 7),
		Vector2i(12, -5),
		Vector2i(-9, -3),
	]


# ------------------------------------------------- axial / cube conversion ---

func test_to_cube_maps_q_and_r_directly() -> void:
	assert_eq(Hex.to_cube(Vector2i(0, 0)), Vector3i(0, 0, 0))
	assert_eq(Hex.to_cube(Vector2i(2, -1)), Vector3i(2, -1, -1))
	assert_eq(Hex.to_cube(Vector2i(-3, 5)), Vector3i(-3, 5, -2))


func test_to_cube_always_satisfies_the_invariant() -> void:
	for hex: Vector2i in _sample_hexes():
		var cube: Vector3i = Hex.to_cube(hex)
		assert_eq(cube.x + cube.y + cube.z, 0, "q + r + s must be 0 for %s" % hex)


func test_from_cube_drops_the_third_component() -> void:
	assert_eq(Hex.from_cube(Vector3i(0, 0, 0)), Vector2i(0, 0))
	assert_eq(Hex.from_cube(Vector3i(2, -1, -1)), Vector2i(2, -1))
	assert_eq(Hex.from_cube(Vector3i(-3, 5, -2)), Vector2i(-3, 5))


func test_from_cube_inverts_to_cube() -> void:
	for hex: Vector2i in _sample_hexes():
		assert_eq(Hex.from_cube(Hex.to_cube(hex)), hex, "round trip failed for %s" % hex)


# ------------------------------------------------------------- directions ---

func test_directions_constant_has_six_entries_in_spec_order() -> void:
	assert_eq(Hex.DIRECTIONS, _expected_directions())


func test_direction_returns_the_indexed_vector() -> void:
	var expected: Array[Vector2i] = _expected_directions()
	for i: int in range(6):
		assert_eq(Hex.direction(i), expected[i], "direction(%d)" % i)


func test_direction_index_wraps_forwards() -> void:
	assert_eq(Hex.direction(6), Hex.direction(0))
	assert_eq(Hex.direction(7), Hex.direction(1))
	assert_eq(Hex.direction(13), Hex.direction(1))


func test_direction_index_wraps_backwards() -> void:
	assert_eq(Hex.direction(-1), Hex.direction(5))
	assert_eq(Hex.direction(-6), Hex.direction(0))
	assert_eq(Hex.direction(-8), Hex.direction(4))


# -------------------------------------------------------------- neighbours ---

func test_neighbor_offsets_from_the_origin() -> void:
	var expected: Array[Vector2i] = _expected_directions()
	for i: int in range(6):
		assert_eq(Hex.neighbor(Vector2i(0, 0), i), expected[i], "neighbor(origin, %d)" % i)


func test_neighbor_offsets_from_an_arbitrary_hex() -> void:
	var origin := Vector2i(4, -2)
	assert_eq(Hex.neighbor(origin, 0), Vector2i(5, -2))
	assert_eq(Hex.neighbor(origin, 2), Vector2i(4, -3))
	assert_eq(Hex.neighbor(origin, 4), Vector2i(3, -1))


func test_neighbors_follows_directions_order() -> void:
	var origin := Vector2i(-1, 3)
	var expected: Array[Vector2i] = []
	for dir: Vector2i in _expected_directions():
		expected.append(origin + dir)
	assert_eq(Hex.neighbors(origin), expected)


func test_neighbors_are_six_distinct_hexes() -> void:
	for hex: Vector2i in _sample_hexes():
		var found: Array[Vector2i] = Hex.neighbors(hex)
		assert_eq(found.size(), 6, "neighbour count for %s" % hex)
		var unique: Dictionary = {}
		for n: Vector2i in found:
			unique[n] = true
		assert_eq(unique.size(), 6, "neighbours of %s must be distinct" % hex)


func test_every_neighbor_is_at_distance_one() -> void:
	for hex: Vector2i in _sample_hexes():
		for n: Vector2i in Hex.neighbors(hex):
			assert_eq(Hex.distance(hex, n), 1, "%s -> %s" % [hex, n])


# ---------------------------------------------------------------- distance ---

func test_distance_to_self_is_zero() -> void:
	for hex: Vector2i in _sample_hexes():
		assert_eq(Hex.distance(hex, hex), 0, "distance(%s, %s)" % [hex, hex])


func test_distance_along_each_axis() -> void:
	var origin := Vector2i(0, 0)
	assert_eq(Hex.distance(origin, Vector2i(3, 0)), 3)
	assert_eq(Hex.distance(origin, Vector2i(0, 3)), 3)
	assert_eq(Hex.distance(origin, Vector2i(3, -3)), 3)
	assert_eq(Hex.distance(origin, Vector2i(-3, 0)), 3)


func test_distance_off_axis() -> void:
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(1, 1)), 2)
	assert_eq(Hex.distance(Vector2i(-2, 3), Vector2i(1, -1)), 4)
	assert_eq(Hex.distance(Vector2i(5, -3), Vector2i(-1, 2)), 6)


func test_distance_is_symmetric() -> void:
	var samples: Array[Vector2i] = _sample_hexes()
	for a: Vector2i in samples:
		for b: Vector2i in samples:
			assert_eq(Hex.distance(a, b), Hex.distance(b, a), "%s <-> %s" % [a, b])


# ----------------------------------------------------------------- rounding ---

func test_round_axial_leaves_exact_centres_alone() -> void:
	assert_eq(Hex.round_axial(Vector2(0.0, 0.0)), Vector2i(0, 0))
	assert_eq(Hex.round_axial(Vector2(2.0, -1.0)), Vector2i(2, -1))
	assert_eq(Hex.round_axial(Vector2(-3.0, 1.0)), Vector2i(-3, 1))


func test_round_axial_handles_the_easy_case() -> void:
	assert_eq(Hex.round_axial(Vector2(0.9, 0.1)), Vector2i(1, 0))
	assert_eq(Hex.round_axial(Vector2(-0.1, 2.05)), Vector2i(0, 2))


func test_round_axial_where_naive_rounding_breaks_the_invariant() -> void:
	# (0.7, 0.6) is cube (0.7, 0.6, -1.3). Rounding each component on its own
	# gives (1, 1, -1), which sums to 1 and is not a hex at all. The nearest
	# real hex is unambiguously (1, 0).
	assert_eq(Hex.round_axial(Vector2(0.7, 0.6)), Vector2i(1, 0))

	# Same trap mirrored: cube (-0.7, 0.4, 0.3) rounds naively to (-1, 0, 0),
	# which sums to -1. The nearest real hex is (-1, 1).
	assert_eq(Hex.round_axial(Vector2(-0.7, 0.4)), Vector2i(-1, 1))


func test_round_axial_always_returns_a_valid_hex() -> void:
	for q: int in range(-20, 21):
		for r: int in range(-20, 21):
			var frac := Vector2(q * 0.17, r * 0.23)
			var cube: Vector3i = Hex.to_cube(Hex.round_axial(frac))
			assert_eq(cube.x + cube.y + cube.z, 0, "invalid hex from %s" % frac)


# --------------------------------------------------------------------- line ---

func test_line_to_self_is_a_single_hex() -> void:
	var expected: Array[Vector2i] = [Vector2i(2, -1)]
	assert_eq(Hex.line(Vector2i(2, -1), Vector2i(2, -1)), expected)


func test_line_straight_along_a_direction() -> void:
	var east: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	assert_eq(Hex.line(Vector2i(0, 0), Vector2i(3, 0)), east)

	var north: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, -1), Vector2i(0, -2), Vector2i(0, -3)]
	assert_eq(Hex.line(Vector2i(0, 0), Vector2i(0, -3)), north)

	var south_west: Array[Vector2i] = [Vector2i(0, 0), Vector2i(-1, 1), Vector2i(-2, 2), Vector2i(-3, 3)]
	assert_eq(Hex.line(Vector2i(0, 0), Vector2i(-3, 3)), south_west)


func test_line_starts_and_ends_at_its_endpoints() -> void:
	var a := Vector2i(-2, 4)
	var b := Vector2i(5, -1)
	var path: Array[Vector2i] = Hex.line(a, b)
	var first: Vector2i = path[0]
	var last: Vector2i = path[path.size() - 1]
	assert_eq(first, a, "line must start at a")
	assert_eq(last, b, "line must end at b")


func test_line_length_is_distance_plus_one() -> void:
	var pairs: Array[Vector2i] = _sample_hexes()
	for a: Vector2i in pairs:
		for b: Vector2i in pairs:
			var path: Array[Vector2i] = Hex.line(a, b)
			assert_eq(path.size(), Hex.distance(a, b) + 1, "line %s -> %s" % [a, b])


func test_line_steps_are_adjacent() -> void:
	var pairs: Array[Vector2i] = _sample_hexes()
	for a: Vector2i in pairs:
		for b: Vector2i in pairs:
			var path: Array[Vector2i] = Hex.line(a, b)
			for i: int in range(1, path.size()):
				assert_eq(
					Hex.distance(path[i - 1], path[i]), 1,
					"step %d of line %s -> %s jumped" % [i, a, b]
				)


# ----------------------------------------------------------------- in range ---

func test_hexes_in_range_zero_is_just_the_centre() -> void:
	var expected: Array[Vector2i] = [Vector2i(3, -1)]
	assert_eq(Hex.hexes_in_range(Vector2i(3, -1), 0), expected)


func test_hexes_in_range_negative_radius_is_empty() -> void:
	var expected: Array[Vector2i] = []
	assert_eq(Hex.hexes_in_range(Vector2i(0, 0), -1), expected)


func test_hexes_in_range_has_the_right_count() -> void:
	for radius: int in range(0, 6):
		var expected_count: int = 3 * radius * radius + 3 * radius + 1
		var found: Array[Vector2i] = Hex.hexes_in_range(Vector2i(-2, 1), radius)
		assert_eq(found.size(), expected_count, "count at radius %d" % radius)


func test_hexes_in_range_contains_no_duplicates() -> void:
	var found: Array[Vector2i] = Hex.hexes_in_range(Vector2i(0, 0), 4)
	var unique: Dictionary = {}
	for hex: Vector2i in found:
		unique[hex] = true
	assert_eq(unique.size(), found.size(), "range must not repeat a hex")


func test_hexes_in_range_holds_exactly_the_hexes_within_radius() -> void:
	var centre := Vector2i(2, 2)
	var radius := 3
	var found: Array[Vector2i] = Hex.hexes_in_range(centre, radius)
	for hex: Vector2i in found:
		assert_lte(Hex.distance(centre, hex), radius, "%s is outside the radius" % hex)

	# and nothing inside the radius is missing
	var expected: Array[Vector2i] = []
	for q: int in range(centre.x - radius, centre.x + radius + 1):
		for r: int in range(centre.y - radius, centre.y + radius + 1):
			var candidate := Vector2i(q, r)
			if Hex.distance(centre, candidate) <= radius:
				expected.append(candidate)
	_assert_same_set(found, expected)


# --------------------------------------------------------------------- ring ---

func test_ring_zero_is_just_the_centre() -> void:
	var expected: Array[Vector2i] = [Vector2i(-4, 2)]
	assert_eq(Hex.ring(Vector2i(-4, 2), 0), expected)


func test_ring_negative_radius_is_empty() -> void:
	var expected: Array[Vector2i] = []
	assert_eq(Hex.ring(Vector2i(0, 0), -2), expected)


func test_ring_has_six_times_radius_hexes() -> void:
	for radius: int in range(1, 6):
		var found: Array[Vector2i] = Hex.ring(Vector2i(1, 1), radius)
		assert_eq(found.size(), 6 * radius, "ring size at radius %d" % radius)


func test_ring_hexes_are_all_at_exactly_that_distance() -> void:
	var centre := Vector2i(-3, 4)
	for radius: int in range(1, 6):
		for hex: Vector2i in Hex.ring(centre, radius):
			assert_eq(Hex.distance(centre, hex), radius, "%s not on ring %d" % [hex, radius])


func test_ring_is_a_closed_walk() -> void:
	# Consecutive hexes on a ring touch, and the ring closes back on itself.
	var centre := Vector2i(0, 0)
	for radius: int in range(1, 5):
		var found: Array[Vector2i] = Hex.ring(centre, radius)
		for i: int in range(1, found.size()):
			assert_eq(
				Hex.distance(found[i - 1], found[i]), 1,
				"ring %d is not contiguous at index %d" % [radius, i]
			)
		var first: Vector2i = found[0]
		var last: Vector2i = found[found.size() - 1]
		assert_eq(
			Hex.distance(last, first), 1,
			"ring %d does not close" % radius
		)


func test_ring_matches_the_difference_of_two_ranges() -> void:
	var centre := Vector2i(2, -3)
	var radius := 3
	var outer: Array[Vector2i] = Hex.hexes_in_range(centre, radius)
	var expected: Array[Vector2i] = []
	for hex: Vector2i in outer:
		if Hex.distance(centre, hex) == radius:
			expected.append(hex)
	_assert_same_set(Hex.ring(centre, radius), expected)


# ------------------------------------------------------------------- spiral ---

func test_spiral_zero_is_just_the_centre() -> void:
	var expected: Array[Vector2i] = [Vector2i(7, 7)]
	assert_eq(Hex.spiral(Vector2i(7, 7), 0), expected)


func test_spiral_starts_at_the_centre() -> void:
	var centre := Vector2i(-1, 5)
	var found: Array[Vector2i] = Hex.spiral(centre, 4)
	assert_eq(found[0], centre)


func test_spiral_covers_the_same_hexes_as_range() -> void:
	var centre := Vector2i(3, 3)
	for radius: int in range(0, 5):
		_assert_same_set(
			Hex.spiral(centre, radius),
			Hex.hexes_in_range(centre, radius),
			"spiral and range disagree at radius %d" % radius
		)


func test_spiral_visits_hexes_in_non_decreasing_distance() -> void:
	var centre := Vector2i(0, 0)
	var found: Array[Vector2i] = Hex.spiral(centre, 4)
	for i: int in range(1, found.size()):
		assert_lte(
			Hex.distance(centre, found[i - 1]),
			Hex.distance(centre, found[i]),
			"spiral went inwards at index %d" % i
		)
