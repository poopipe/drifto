@tool
extends Node3D

@export var is_dirty : bool = false

@export var meshes: Array[ArrayMesh] = []

@export var path:	Path3D
@export var road_path:	Path3D
@export var instance_spacing: float:
	# TODO: Why the fuck cant i generalise this?
	get:
		return instance_spacing
	set(value):
		if value != instance_spacing:
			instance_spacing = value
			is_dirty = true
@export var start_offset: float:
	get:
		return start_offset
	set(value):
		if value != start_offset:
			start_offset = value
			is_dirty = true			
@export var length: float:	# 0 = full spline len - end offset
	get:
		return length
	set(value):
		if value != length:
			length = value
			is_dirty = true			
@export var end_offset: float:
	get:
		return end_offset
	set(value):
		if value != end_offset:
			end_offset = value
			is_dirty = true			
@export var h_offset: float:
	get:
		return h_offset
	set(value):
		if value != h_offset:
			h_offset = value
			is_dirty = true			
@export var v_offset: float:
	get:
		return v_offset
	set(value):
		if value != v_offset:
			v_offset = value
			is_dirty = true			
@export var h_offset_random: float:
	get:
		return h_offset_random
	set(value):
		if value != h_offset_random:
			h_offset_random = value
			is_dirty = true			
@export var v_offset_random: float:
	get:
		return v_offset_random
	set(value):
		if value != v_offset_random:
			v_offset_random = value
			is_dirty = true
@export var scaling: Vector3 = Vector3(1.0, 1.0, 1.0):
	get:
		return scaling
	set(value):
		if value != scaling:
			scaling = value
			is_dirty = true
@export var scale_random: Vector3 = Vector3(0.0, 0.0, 0.0):
	get:
		return scale_random
	set(value):
		if value != scale_random:
			scale_random = value
			is_dirty = true
@export var this_seed: int = 69:
	get:
		return this_seed
	set(value):
		if value != this_seed:
			this_seed = value
			is_dirty = true
@export var instance_rotate: float = 0.0:
	get:
		return instance_rotate
	set(value):
		if value != instance_rotate:
			instance_rotate = value
			is_dirty = true
@export var rotate_random: float = 0.0:
	get:
		return rotate_random
	set(value):
		if value != rotate_random:
			rotate_random = value
			is_dirty = true
					
var rng = RandomNumberGenerator.new()

var mesh_instances : Array[MeshInstance3D]

var debug_gizmo : EditorNode3DGizmo 


func _process(_delta):
	if is_dirty:
		for m in mesh_instances:
			remove_child(m)
		mesh_instances.clear()	
		_update_instances()
		is_dirty = false

func _update_instances():
	
	rng.seed = this_seed

	var curve = path.curve
	var road_curve = road_path.curve
	var curve_length:float = curve.get_baked_length()
	var end: float
	
	if length > 0.0:
		end = start_offset + min( curve_length - end_offset, length )
	else:
		end = start_offset + curve_length - end_offset
		
	var active_length : float = end - start_offset

	var num_instances = floor(active_length / instance_spacing)

	
	for i in range(0, num_instances):
		var mi := MeshInstance3D.new()
		var index = rng.randi_range(0, len(meshes) - 1)
		
		mi.mesh = meshes[index]
		mesh_instances.append(mi)
		
	for i in range(0, len(mesh_instances)):
		var h = h_offset + rng.randf_range(-h_offset_random, h_offset_random)
		var v = v_offset + rng.randf_range(-v_offset_random, v_offset_random)
		
		var distance = start_offset + (instance_spacing) * i 
		# bail if outside start and end bounds
		if distance > end or distance < start_offset:
			continue
			
		# get transform at point on curves
		var sample_point_location := curve.sample_baked(distance, true)
		# sample on road curve probably wont be out of range, let's see
		var road_point_location := road_curve.sample_baked(road_curve.get_closest_offset(sample_point_location), true)
		
		
		
		var this_transform = Transform3D()
		var t:Transform3D

		# set xform before rotating
		t.origin = sample_point_location
		t.basis = Basis.looking_at(sample_point_location - road_point_location, Vector3(0.0, 100.0, 0.0), true)
		add_gizmo(debug_gizmo)
		
		this_transform = t.translated_local(Vector3(0.0, v, h))
		
		#DebugDraw3D.draw_box(road_point_location,Quaternion.IDENTITY,Vector3(1.0, 1.0, 1.0), Color(1, 0, 0),true, 5.0)
		#DebugDraw3D.draw_box(sample_point_location,Quaternion.IDENTITY,Vector3(1.0, 1.0, 1.0), Color(0, 1, 0), true, 5.0)
		#DebugDraw3D.draw_line(sample_point_location, this_transform.origin, Color(1, 0, 0),5.0)
		#DebugDraw3D.draw_arrow(sample_point_location, road_point_location, Color(0, 0, 1), 1.0, true, 5.0)
		
		var s = scaling
		this_transform = this_transform.scaled_local(s)			
		
		var r = deg_to_rad(instance_rotate) + rng.randf_range(-rotate_random, rotate_random)
		this_transform = this_transform.rotated_local(Vector3(0.0, 1.0, 0.0), r)
		
		var inst = mesh_instances[i]
		inst.visibility_range_begin = 0.0
		inst.visibility_range_end = 200.0
		
		add_child(inst)
		inst.transform = this_transform

		

func _on_path_changed() -> void:
	is_dirty = true
