@tool
extends MultiMeshInstance3D

@export var path:	Path3D
@export var instance_spacing: float
@export var start_offset: float
@export var length: float	# 0 = full spline len - end offset
@export var end_offset: float
@export var h_offset: float
@export var v_offset: float
@export var h_offset_random: float
@export var v_offset_random: float
@export var scaling: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var scale_random: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var alternate_sides: bool
@export var force_up: bool
@export var seed: int = 69


var is_dirty := false
var rng = RandomNumberGenerator.new()


func _process(_delta):
	if is_dirty:
		_update_multimesh()
		is_dirty = false

func _update_multimesh():
	'''handle positioning of mesh instances along specified path'''
	print('updating')
	rng.seed = seed
	var curve = path.curve
	var curve_length:float = curve.get_baked_length()
	var end: float
	
	if length > 0.0:
		end = start_offset + min( curve_length - end_offset, length )
	else:
		end = start_offset + curve_length - end_offset
		
	var active_length = end - start_offset

	var num_instances := floor(active_length / instance_spacing)
	var instance_mesh: MultiMesh = multimesh
	instance_mesh.instance_count = num_instances 
	
	for i in range(0, num_instances):

		var h = h_offset + rng.randf_range(-h_offset_random, h_offset_random)
		var v = v_offset + rng.randf_range(-v_offset_random, v_offset_random)
		
		var distance = start_offset + (instance_spacing) * i  + h_offset
		# bail if outside start and end bounds
		if distance > end or distance < start_offset:
			continue
		# get transform at point on curve
		var sample_point_transform := curve.sample_baked_with_rotation(distance, true, true)
		var sample_point_location := curve.sample_baked(distance, true)
	
		if alternate_sides:
			h = h if i % 2 == 0 else 0.0-h
		# set xform before rotating
		var transform = sample_point_transform.translated_local(Vector3(h, v, 0.0))
		
		if force_up:
			# create a new transform k
			var t:Transform3D
			t.basis = Basis.looking_at(transform.origin - sample_point_location - Vector3(0.0, v, 0.0), Vector3(0.0, 1.0, 0.0), false)
			t.origin = transform.origin
			transform = t
			
		var s = scaling
		transform = transform.scaled_local(s)			
		
		instance_mesh.set_instance_transform(i, transform)

func _on_road_path_path_changed() -> void:
	is_dirty = true
