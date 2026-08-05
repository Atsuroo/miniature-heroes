class_name HexWorld


static func axial_to_world(axial:Vector2i, size:float)->Vector3:
	var x:float = size * sqrt(3) * (axial.x + axial.y/2.0)
	var z:float = size * 3/2.0 * axial.y
	return Vector3(x, 0, z)
