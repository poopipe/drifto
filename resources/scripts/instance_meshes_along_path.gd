@tool
extends Node3D

@export var is_dirty : bool = false

@export var meshes: Array[ArrayMesh] = []

@export var path:	Path3D
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
@export var alternate_sides: bool:
	get:
		return alternate_sides
	set(value):
		if value != alternate_sides:
			alternate_sides = value
			is_dirty = true
@export var force_up: bool:
	get:
		return force_up
	set(value):
		if value != force_up:
			force_up = value
			is_dirty = true
@export var seed: int = 69:
	get:
		return seed
	set(value):
		if value != seed:
			seed = value
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

func _process(_delta):
	if is_dirty:
		for m in mesh_instances:
			remove_child(m)
		mesh_instances.clear()	
		_update_instances()
		is_dirty = false

func _update_instances():

	rng.seed = seed

	var curve = path.curve
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
			t.basis = Basis.looking_at(transform.origin - sample_point_location - Vector3(0.0, v, 0.0), Vector3(0.0, 100.0, 0.0), false)
			t.origin = transform.origin
			transform = t
			
		var s = scaling
		transform = transform.scaled_local(s)			
		
		var r = deg_to_rad(instance_rotate) + rng.randf_range(-rotate_random, rotate_random)
		transform = transform.rotated_local(Vector3(0.0, 1.0, 0.0), r)
		
		var inst = mesh_instances[i]
		inst.visibility_range_begin = 0.0
		inst.visibility_range_end = 200.0
		
		add_child(inst)
		inst.transform = transform

		

func _on_path_changed() -> void:
	is_dirty = true
