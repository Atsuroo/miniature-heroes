extends GutTest

var randomizer:RandomNumberGenerator=RandomNumberGenerator.new()
var sizes: Array[float]=[00.6,0.35,1.72,2.32]

func test_round_trip_hex_world_hex()-> void:

	var tiles:Array[Vector2i]= Hex.spiral(Vector2i.ZERO,5)
	for size in range(1,5):
		for tile in tiles:
			var world:Vector3=HexWorld.axial_to_world(tile,size)
			var hex:Vector2i=HexWorld.world_to_axial(world,size)
			assert_eq(tile,hex,"world : %s; hex: %s;size: %s" % [world,hex,size])

func test_round_trip_hex_world_hex_uneven_size()-> void:

	var tiles:Array[Vector2i]= Hex.spiral(Vector2i.ZERO,5)

	for size in sizes:
		for tile in tiles:
			var world:Vector3=HexWorld.axial_to_world(tile,size)
			var hex:Vector2i=HexWorld.world_to_axial(world,size)
			assert_eq(tile,hex,"world : %s; hex: %s;size: %s" % [world,hex,size])

func test_hex_rounding_is_correct() -> void:

	for size in sizes:
		for i in 100:
			var scaled_size:float=size*8
			var rdm_x:float = randomizer.randf_range(-scaled_size,scaled_size)
			var rdm_z:float = randomizer.randf_range(-scaled_size,scaled_size)

			var world_point := Vector3(rdm_x, 0, rdm_z)
			var axial := HexWorld.world_to_axial(world_point, size)
			var center := HexWorld.axial_to_world(axial, size)
			var dist_center := world_point.distance_to(center)
			var neighbors :Array[Vector2i]=Hex.neighbors(axial)

			for n in neighbors:
				var n_center := HexWorld.axial_to_world(n, size)
				var n_dist := world_point.distance_to(n_center)

				assert_lte(dist_center , n_dist,
		            "Rundung falsch: Tile %s ist weiter entfernt als Nachbar %s für Punkt %s für seed :%d"
					% [axial, n, world_point,randomizer.seed]
				)
