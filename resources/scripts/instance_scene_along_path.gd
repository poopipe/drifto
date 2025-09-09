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
var scene_instances : Array = []

#TODO: Something is not working right with this,  when it gets dirty it 
#		doesn't generate any child nodes but they'll be there if you reload the scene


func _process(_delta):
	if is_dirty:
		for s in scene_instances:
			remove_child(s)
		scene_instances = []
			
		_update_instances()
		is_dirty = false

func _update_instances():		
	print("update")
	print(get_child_count())
	"""
	if get_child_count() > 0:
		var children = get_children()
		for c in children:
			remove_child(c)
			c.queue_free()
	"""
	rng.seed = this_seed

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
		
	for i in range(0, num_instances):
		scene_instances.append(instance_scene.instantiate())
	
	for i in range(0, len(scene_instances)):
		
		# offsets
		var h = h_offset + rng.randf_range(-h_offset_random, h_offset_random)
		var v = v_offset + rng.randf_range(-v_offset_random, v_offset_random)
		# get separations
		var distance = start_offset + (instance_spacing) * i 
		# bail if outside start and end bounds
		if distance > end or distance < start_offset:
			continue
			
		# get transform at point on curve
		var sample_point_transform:Transform3D
		var sample_point_location := curve.sample_baked(distance, true)
		sample_point_transform.origin = sample_point_location

		# get sample points on left curve
		var left_target_local = path_left.to_local(sample_point_location)
		var left_offset := curve_left.get_closest_offset(left_target_local)
		var left_transform: Transform3D
		left_transform.origin = curve_left.sample_baked(left_offset)
		# get sample points on right curve
		var right_target_local = path_right.to_local(sample_point_location)
		var right_offset := curve_right.get_closest_offset(right_target_local)
		var right_transform: Transform3D
		right_transform.origin = curve_right.sample_baked(right_offset)
		
		var final_rotate = instance_rotate
		var this_transform = Transform3D()

		var t:Transform3D
		if alternate_sides:
			if i % 2 == 0:
				this_transform = right_transform
			else: 
				this_transform = left_transform
			# look at road curve
			t.basis = Basis.looking_at(this_transform.origin - sample_point_location - Vector3(0.0, v, 0.0), Vector3(0.0, 100.0, 0.0), false)
		else:
			this_transform = sample_point_transform	
			# look at right curve
			t.basis = Basis.looking_at(this_transform.origin - right_transform.origin - Vector3(0.0, v, 0.0), Vector3(0.0, 100.0, 0.0), false)
		
		t.origin = this_transform.origin
		t = t.translated_local(Vector3(0.0, v, h))
		this_transform = t
			
		var s = scaling
		this_transform = this_transform.scaled_local(s)			
		
		var r = deg_to_rad(final_rotate) + rng.randf_range(-rotate_random, rotate_random)
		this_transform = this_transform.rotated_local(Vector3(0.0, 1.0, 0.0), r)
		
		
		#DebugDraw3D.draw_box(sample_point_location,Quaternion.IDENTITY,Vector3(1.0, 1.0, 1.0), Color(0, 1, 0), true, 5.0)
		#DebugDraw3D.draw_line(sample_point_location, this_transform.origin, Color(1, 0, 0),5.0)
		
		
		
		var inst = scene_instances[i]

		add_child(inst)
		inst.transform = this_transform
		inst.owner = get_tree().edited_scene_root

		

func _on_path_changed() -> void:
	is_dirty = true
