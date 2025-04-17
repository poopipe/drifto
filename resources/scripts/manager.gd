extends Node3D

@export var player: VehicleController

	
@export var longitudinal_slip_threshold := 0.5
@export var lateral_slip_threshold := 1.0

var skidding:bool = false
@onready var timer = $"../Timer"
var skidmark_scene = load("res://resources/Scenes/skidmark.tscn")
var skidmarks:Array
var skidmark_position:Vector3
var skidmark_direction:Vector3
const RAY_LENGTH = 100


func _ready() -> void:
	var vehicle_node = player.vehicle_node
	print(vehicle_node)

func _physics_process(_delta: float) -> void:
	# this exists purely toupdate the location that we want to spawn our skidmark at
	var space_state = get_world_3d().direct_space_state
	var start = player.vehicle_node.global_position
	var end = start + Vector3(0.0, -RAY_LENGTH, 0.0)
	var ray = PhysicsRayQueryParameters3D.create(start, end)
	ray.collide_with_bodies = true
	ray.exclude = [
		player.vehicle_node
	]

	var result = space_state.intersect_ray(ray)
	if result:
		skidmark_position = result["position"]
		print(skidmark_direction)
	
	
func make_skidmark():
	print('skidmarks', len(skidmarks))
	var skidmark = skidmark_scene.instantiate()

	skidmark.global_position = skidmark_position
	# TODO: this is balls but it is actually rotating things so we call it a win for now
	skidmark.rotate_y(player.vehicle_node.rotation_degrees.y)
	
	add_child(skidmark)
	skidmarks.append(skidmark)
	
	if len(skidmarks) > 100:
		remove_child(skidmarks[0])
		skidmarks.remove_at(0)

func _process(delta: float) -> void:
	var vehicle_node = player.vehicle_node
	if is_instance_valid(vehicle_node):	
		var speed = vehicle_node.speed * 3.6
	
		var plane_xz := Vector2(vehicle_node.local_velocity.x, vehicle_node.local_velocity.z)
		var yaw_angle := 0.0
		if plane_xz.y < 0 and plane_xz.length() > 1.0:
			plane_xz = plane_xz.normalized()
			yaw_angle = 1.0 - absf(plane_xz.dot(Vector2.UP))

		var wheels_spinning := false
		for wheel in vehicle_node.wheel_array:
			if absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
				wheels_spinning = true
				
		if wheels_spinning and yaw_angle >= 0.1 and speed >= 30.0 :
			if not skidding:
				skidding = true
		else:
			if skidding:
				skidding = false
		



func _on_timer_timeout() -> void:
	if skidding:
		make_skidmark()
