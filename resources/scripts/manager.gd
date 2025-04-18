extends Node3D

@export var player: VehicleController

	
@export var longitudinal_slip_threshold := 0.5
@export var lateral_slip_threshold := 1.0

var skidding:bool = false

func _ready() -> void:
	pass


		
func _process(_delta: float) -> void:
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
				
		if wheels_spinning and yaw_angle >= 0.1 and speed >= 20.0 :
			if not skidding:
				skidding = true
		else:
			if skidding:
				skidding = false
	
