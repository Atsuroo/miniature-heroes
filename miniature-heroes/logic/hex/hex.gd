class_name Hex

static func to_cube(from:Vector2i)->Vector3i:
	var x:int=from.x
	var y:int=from.y
	return Vector3i(x,y,-x-y)

static func from_cube(from:Vector3i)->Vector2i:
	return Vector2i(from.x,from.y)


const DIRECTIONS:Array[Vector2i]=[
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1)
		]

static func direction(index:int)->Vector2i:
	return DIRECTIONS[posmod(index,6)]

static func neighbor(hex_cord:Vector2i, index:int)->Vector2i:
	var direction_vector:Vector2i=direction(index)
	return hex_cord+direction_vector

static func neighbors(hex_cord:Vector2i)->Array[Vector2i]:
	var result:Array[Vector2i]=[]
	for dir:Vector2i in DIRECTIONS:
		result.append(hex_cord+dir)
	return result


static func distance(from:Vector2i,to:Vector2i)->int:
	var vector:Vector3i=to_cube(to-from)
	return max(absi(vector.x),absi(vector.y),absi(vector.z))

static func round_axial(hex:Vector2)->Vector2i:
	var cube:Vector3=Vector3(hex.x,hex.y,-hex.x-hex.y)
	var round_cube:Vector3i=cube_round(cube)
	return from_cube(round_cube)

static func line(from:Vector2i,to:Vector2i)->Array[Vector2i]:
	var dist:int = distance(from, to)
	var cube_from:Vector3=to_cube(from)
	var cube_to:Vector3=to_cube(to)
	var results:Array[Vector2i] = []

	if dist ==0:
		return [from]

	for i in dist+1:
		var cube_lerp:Vector3=lerp(cube_from, cube_to, 1.0/dist * i)
		results.append(from_cube(cube_round(cube_lerp)))
	return results



static func hexes_in_range(from:Vector2i,dist:int)->Array[Vector2i]:
	var results:Array[Vector2i]=[]
	for x in range(-dist,dist+1):
		for y in range(maxi(-dist,-x-dist),mini(dist,-x+dist)+1):
			results.append(from+Vector2i(x,y))
	return results


static func ring(from:Vector2i,radius: int)->Array[Vector2i]:
	var results:Array[Vector2i]  = []
	if radius==0:
		return [from]
	var hex:Vector2i =from+direction(4)*radius

	for n in 6:
		for r in radius:
			results.append(hex)
			hex=neighbor(hex,n)
	return results

static func spiral(from:Vector2i,radius: int)->Array[Vector2i]:
	var results:Array[Vector2i] = []
	for n in radius+1:
		results.append_array(ring(from, n))
	return results

static func cube_round(cube_Frac:Vector3)->Vector3i:
	var x:int = roundi(cube_Frac.x)
	var y:int = roundi(cube_Frac.y)
	var z:int = roundi(cube_Frac.z)

	var x_diff:float = absf(x - cube_Frac.x)
	var y_diff:float = absf(y - cube_Frac.y)
	var z_diff:float = absf(z - cube_Frac.z)

	if x_diff > y_diff and x_diff > z_diff:
		x = -y-z
	elif y_diff > z_diff:
		y = -x-z
	else:
		z = -x-y

	return Vector3i(x, y, z)
