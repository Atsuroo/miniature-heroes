class_name RayIntersectionResult
extends RefCounted

var position: Vector3
var normal: Vector3
var collider: Object
var collider_id: int
var rid: RID
var shape: int
var metadata: Variant

static func from_dict(d: Dictionary) -> RayIntersectionResult:
	var r := RayIntersectionResult.new()
	r.position = d.get("position")
	r.normal = d.get("normal")
	r.collider = d.get("collider")
	r.collider_id = d.get("collider_id")
	r.rid = d.get("rid")
	r.shape = d.get("shape")
	r.metadata = d.get("metadata")
	return r

func to_custom_string() -> String:
	return "RayIntersectionResult(position=%s, normal=%s, collider=%s, collider_id=%s, rid=%s, shape=%s, metadata=%s)" % [
		position, normal, collider, collider_id, rid, shape, metadata
	]
