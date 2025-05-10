@tool
extends Node3D

@export  var is_dirty := false

@export var instance_scene:PackedScene 
@export var path:	Path3D
@export var path_left:	Path3D
@export var path_right:	Path3D

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

var scene_instances : Array = []

func _process(_delta):
	if is_dirty:
		_update_instances()
		is_dirty = false

func _update_instances():
	rng.seed = seed

	var curve = path.curve
	var curve_left = path_left.curve
	var curve_right = path_right.curve
	
	var curve_length:float = curve.get_baked_length()
	var end: float
	
	if length > 0.0:
		end = start_offset + min( curve_length - end_offset, length )
	else:
		end = start_offset + curve_length - end_offset
		
	var active_length : float = end - start_offset

	var num_instances = floor(active_length / instance_spacing)
	
	for si in scene_instances:
		remove_child(si)
	
	for i in range(0, num_instances):
		scene_instances.append(instance_scene.instantiate())
	
	for i in range(0, len(scene_instances)):
		var h = h_offset + rng.randf_range(-h_offset_random, h_offset_random)
		var v = v_offset + rng.randf_range(-v_offset_random, v_offset_random)
		
		var distance = start_offset + (instance_spacing) * i 
		# bail if outside start and end bounds
		if distance > end or distance < start_offset:
			continue
			
		# get transform at point on curve
		var sample_point_transform := curve.sample_baked_with_rotation(distance, true, true)
		var sample_point_location := curve.sample_baked(distance, true)
		
		var left_target_local = path_left.to_local(sample_point_location)
		var left_offset := curve_left.get_closest_offset(left_target_local)
		var left_transform := curve_left.sample_baked_with_rotation(left_offset)
		var right_target_local = path_right.to_local(sample_point_location)
		var right_offset := curve_right.get_closest_offset(right_target_local)
		var right_transform := curve_right.sample_baked_with_rotation(right_offset)
		var final_rotate = instance_rotate
		var transform = Transform3D()
		if alternate_sides:
			if i % 2 == 0:
				transform = right_transform.translated_local(Vector3(h, v, 0.0))
				
			else: 
				transform = left_transform.translated_local(Vector3(-h, v, 0.0))
				final_rotate = 0.0 - instance_rotate
			#h = h if i % 2 == 0 else 0.0-h
		else:
			transform = sample_point_transform.translated_local(Vector3(h, v, 0.0))	
			# set xform before rotating
		
		
		if force_up:
			# create a new transform k
			var t:Transform3D
			t.basis = Basis.looking_at(transform.origin - sample_point_location - Vector3(0.0, v, 0.0), Vector3(0.0, 100.0, 0.0), false)
			t.origin = transform.origin
			transform = t
			
		var s = scaling
		transform = transform.scaled_local(s)			
		
		var r = deg_to_rad(final_rotate) + rng.randf_range(-rotate_random, rotate_random)
		transform = transform.rotated_local(Vector3(0.0, 1.0, 0.0), r)
		
		var inst = scene_instances[i]

		add_child(inst)
		inst.transform = transform

		

func _on_path_changed() -> void:
	is_dirty = true
