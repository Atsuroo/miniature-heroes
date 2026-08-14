class_name RayIntersectionResult
extends RefCounted

var position: Vector3
var normal: Vector3
var collider: Object
var collider_id: int
var rid: RID
var shape: int
var face_index: int
const REQUIRED:Array[String] = ["position", "normal", "collider", "collider_id", "rid", "shape"]



static func from_dict(d: Dictionary) -> RayIntersectionResult:


	for key in REQUIRED:
		if not d.has(key):
			push_error("RayIntersectionResult missing key: %s" % key)
			return null

	var r := RayIntersectionResult.new()
	r.position = d.get("position")
	r.normal = d.get("normal")
	r.collider = d.get("collider")
	r.collider_id = d.get("collider_id")
	r.rid = d.get("rid")
	r.shape = d.get("shape")
	r.face_index = d.get("face_index",-1)
	return r

func _to_string() -> String:
	return "RayIntersectionResult(position=%s, normal=%s, collider=%s, collider_id=%s, rid=%s, shape=%s, face_index=%s)" % [
		position, normal, collider, collider_id, rid, shape, face_index
	]
