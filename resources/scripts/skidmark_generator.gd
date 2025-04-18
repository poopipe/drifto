extends Node3D

@export var vehicle: Vehicle
@export var drive_wheel_index: int
@export var longitudinal_slip_threshold:= 0.5
@export var lateral_slip_threshold:= 1.0

var skidmark_scene:Resource = load("res://resources/Scenes/skidmark.tscn")
var skidmarks:Array
var previous_location: Vector3
var distance_to_previous:float = 10000.0

func _process(_delta:float)->void:
	var wheel = vehicle.drive_wheels[drive_wheel_index]
	var location:Vector3 = wheel.last_collision_point
	var normal:Vector3 = wheel.last_collision_normal
	
	var skidmark:Node3D = skidmark_scene.instantiate()
	skidmark.global_position = location
	
	if previous_location:
		var t:Transform3D = skidmark.transform.looking_at(previous_location, normal, false)
		skidmark.transform = t
		distance_to_previous = location.distance_to(previous_location)
	
	#add our skidmark to the root if we're not too close to the previous one
	if distance_to_previous >= 0.4:
		# and if we're doing a skid according to the car physics
		if absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
			get_tree().root.add_child(skidmark)
			skidmarks.append(skidmark)
			previous_location = skidmark.transform.origin
	
	# delete old decals
	if len(skidmarks) > 100:
		var sm = skidmarks.pop_front()
		sm.queue_free()
		skidmarks.erase(sm)
		
		
