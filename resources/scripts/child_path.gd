@tool
extends Path3D

@export var parent_path:Path3D
@export var source_path:Path3D	# path to conform to parent

@export var start_offset:float = 0.0:
	get:
		return start_offset
	set(value):
		if value != start_offset:
			start_offset = value
			is_dirty = true
			
var is_dirty:bool = true

func _process(_delta):
	if is_dirty:
		#_update_points()
		_update_points_baked()
		is_dirty = false

func _update_points_baked():
	#print('update baked points')
	var parent_curve = parent_path.curve
	var source_curve = source_path.curve
	
	# regenerate curve from source curve
	curve.clear_points()
	
	var baked_points:PackedVector3Array = source_curve.get_baked_points()
	for i in range(len(baked_points)):
		var source_pos:Vector3 = baked_points.get(i)
		var distance:float = source_pos.x + start_offset
		
		# get position on parent curve at distance
		# TODO: Something fucked up is happening at the end of the curve
		var target_transform:Transform3D = parent_curve.sample_baked_with_rotation(distance, true, true)
		
		# handle offsets
		target_transform = target_transform.translated_local(Vector3(source_pos.z, source_pos.y, 0.0))
		# add a point to this curve 
		curve.add_point(target_transform.origin)
		

func _on_parent_path_changed() -> void:
	is_dirty = true
