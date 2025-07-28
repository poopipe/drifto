extends Node3D

@export var vehicle: Vehicle
@export var drive_wheel_index: int
@export var longitudinal_slip_threshold:= 0.75
@export var lateral_slip_threshold:= 1.0

var skidmark_scene:Resource = load("res://resources/Scenes/skidmark.tscn")
var skidmarks:Array
var previous_location: Vector3
var distance_to_previous:float = 10000.0

var skid_active: bool = false
var wheel:Wheel
func _process(_delta:float)->void:

	# if we're actually skidding we want to force the dropping of skidmarks
	# we also want skidmarks if we're doing a burnout
	# absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold
	wheel = vehicle.drive_wheels[drive_wheel_index]
	if skid_active or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
		create_skidmark()
				
	# delete old decals
	if len(skidmarks) > 100:
		var sm = skidmarks.pop_front()
		sm.queue_free()
		#skidmarks.erase(sm)
		
func create_skidmark()-> void:
	var location:Vector3 = wheel.last_collision_point
	var normal:Vector3 = wheel.last_collision_normal

	if previous_location:
		distance_to_previous = location.distance_to(previous_location)

	#add our skidmark to the root if we're not too close to the previous one
	if distance_to_previous >= 0.4:
		# and if we're doing a skid according to the car physics
		#if absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
		var skidmark:Node3D = skidmark_scene.instantiate()
		skidmark.position = location
		var t:Transform3D = skidmark.transform.looking_at(previous_location, normal, false)
		skidmark.transform = t
		get_tree().root.add_child(skidmark)
		skidmarks.append(skidmark)
		previous_location = skidmark.transform.origin


func _on_skid_activated() -> void:
	skid_active = true
	
func _on_skid_deactivated() -> void:
	skid_active = false
