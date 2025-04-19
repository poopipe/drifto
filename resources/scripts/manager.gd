extends Node3D
@export var player: VehicleController
@export var road:CSGPolygon3D
@export var longitudinal_slip_threshold := 0.5
@export var lateral_slip_threshold := 1.0

@export var vignette_material:ShaderMaterial

var skidding: bool = false
var skids_initiated: int = 0
var skid_start_time  := Time.get_unix_time_from_system()
var skid_end_time := Time.get_unix_time_from_system()
var skid_cooldown: float = 0.5
var total_skidding: int = 0

var skid_amount:float = 0.0	 # use this for any timed effects that are connected to skiddin
var effect_fade_rate:float = 0.02
var skid_score:int = 1

var skid_time_bonus = 1

var front_close:bool = false
var rear_close:bool = false

var proximity_multiplier:int = 2
var proximity_bonus = 1

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

		# how long has it been since we last started or stopped a skid?
		# this seems to be in seconds
		var now = Time.get_unix_time_from_system()
		var skid_end_delta = now - skid_end_time
		var skid_start_delta = now - skid_start_time


		# get skid_amount,. connected to skid cooldown time
		

		# handle skidding
		if wheels_spinning and yaw_angle >= 0.025 and speed >= 10.0 :
			if not skidding:
				skidding = true
				skids_initiated += 1
				skid_start_time = Time.get_unix_time_from_system()
				
		else:
			if skidding:
				skidding = false
				skid_end_time = Time.get_unix_time_from_system()

		
		if skidding:
			skid_amount += effect_fade_rate
		else:
			skid_amount -= effect_fade_rate
		skid_amount = clamp(skid_amount, 0.0, 1.0)

		# get  time multiplier 
		if skidding or skid_end_delta <= skid_cooldown:
			skid_time_bonus = 1 + floor(2.0 * skid_start_delta)
		else:
			skid_time_bonus = 1
			
		# get proximity multiplier
		# TODO: is there a way to reward closeness?
		proximity_bonus = 1
		if front_close or rear_close:
			proximity_bonus = proximity_multiplier	
			
		# TODO: Handle crashing - we should have a short cooldown before score
		# can accumulate.  we shouldn't penalise rubbing cos that's cool
			
		#if skidding or within grace period, add scoar
		if skidding or skid_end_delta <= skid_cooldown :
			total_skidding += skid_score * skid_time_bonus * proximity_bonus
			# do stuff with shader
		
		
		vignette_material.set_shader_parameter("coverage", skid_amount)


func _on_area_3d_front_body_entered(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		front_close = true


func _on_area_3d_front_body_exited(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		front_close = false


func _on_area_3d_rear_body_entered(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		rear_close = true

func _on_area_3d_rear_body_exited(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		rear_close = false
