class_name HexWorld


static func axial_to_world(axial:Vector2i, size:float)->Vector3:
	var x:float = size * sqrt(3) * (axial.x + axial.y/2.0)
	var z:float = size * 3/2.0 * axial.y
	return Vector3(x, 0, z)

static func world_to_axial(world:Vector3,size:float)->Vector2i:
	var x:float = world.x / size
	var z:float = world.z / size

	var q:float = (sqrt(3)/3 * x  -  1.0/3 * z)
	var r:float = (2.0/3 * z)
	return Hex.round_axial(Vector2(q,r))
