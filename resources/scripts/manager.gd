extends Node3D
@export var player: VehicleController
@export var road:CSGPolygon3D
@export var camera: Camera3D
@export var start_point: Node3D

@export_group("skid thresholds")
@export var longitudinal_slip_threshold := 0.7
@export var lateral_slip_threshold := 1.0
@export var skid_yaw_threshold:float = 0.025
@export var skid_speed_threshold:float = 15.0	# not in km/h

@export_group("scores and stuff")
@export var skid_cooldown: float = 0.5
@export var skid_score:int = 1	# base amount to increase score

@export_group("crashing")
@export var crash_cooldown: float = 0.5

@export_group("effects")
@export var vignette_material:ShaderMaterial
@export var road_material:ShaderMaterial
@export var armco_material:ShaderMaterial
@export var effect_fade_rate:float = 1.25

var is_resetting: bool = false

# skid tracking
var skidding: bool = false
var skids_initiated: int = 0
var skid_start_time  := Time.get_unix_time_from_system()
var skid_end_time := Time.get_unix_time_from_system()
var total_score: int = 0

# crash tracking
var crashing: bool = false
var crash_start_time := Time.get_unix_time_from_system()
var crash_end_time := Time.get_unix_time_from_system()
var crash_impulse:Vector3 = Vector3(0.0, 0.0, 0.0)
var crash_bonus_default = 1.0	# this is multiplied, we set to 0.0 when we crash
var crash_bonus = 1.0

# proximity tracking
var front_close:bool = false
var rear_close:bool = false

var proximity_bonus_default:float = 2.0
var proximity_bonus:float = 1.0
# score multipliers
var skid_time_bonus_default:float = 1.0
var skid_time_bonus:float = 1.0


# visuals
var effect_amount:float = 0.0	 # use this for any timed effects that are connected to skiddin



func _ready() -> void:
	# get proximity areas 
	var proximity_areas := get_tree().get_nodes_in_group("proximity_areas")
	for pa in proximity_areas:
		if pa.has_signal("body_entered"):
			pa.body_entered.connect(_on_area_3d_front_body_entered.bind(pa.front) )
		if pa.has_signal("body_exited"):
			pa.body_exited.connect(_on_area_3d_front_body_exited.bind(pa.front) )
	var vehicle_node = player.vehicle_node
	if vehicle_node.has_signal("body_entered"):
		vehicle_node.body_entered.connect(_on_vehicle_body_entered.bind())
	if vehicle_node.has_signal("body_exited"):
		vehicle_node.body_exited.connect(_on_vehicle_body_exited.bind())
	
	# init run
	init_run()
		
func init_run()-> void:
	# position vehicle controller:
	player.transform = start_point.transform
	# tell vehiclebody we're resetting and where to reset to
	player.vehicle_node.start_xform = start_point.transform
	player.vehicle_node.is_resetting = true
	# tell camera we're resetting
	camera.is_resetting = true
	# reset scores and bonuses
	total_score = 0
	skid_time_bonus = skid_time_bonus_default
	crash_bonus = crash_bonus_default
	proximity_bonus = proximity_bonus_default
	
	

func get_wheels_spinning(vehicle_node:Vehicle)-> bool:
	# are any wheels spinning / sliding
	# TODO: 
	#	perhaps we want to check that more than one are slipping
	#	or perhaps we want to check back wheels only?
	for wheel in vehicle_node.wheel_array:
		if absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
			return true
	return false
	
func get_yaw_angle(vehicle_node:Vehicle)-> float:
	var plane_xz := Vector2(vehicle_node.local_velocity.x, vehicle_node.local_velocity.z)
	if plane_xz.y < 0 and plane_xz.length() > 1.0:
		plane_xz = plane_xz.normalized()
		return 1.0 - absf(plane_xz.dot(Vector2.UP))
	return 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_back"):
		init_run()
		
				
	if event.is_action_pressed("action_menu"):
		print("MENU", event)

func _process(_delta: float) -> void:
	var vehicle_node = player.vehicle_node
	if is_instance_valid(vehicle_node):	
		var speed = vehicle_node.speed * 3.6
		var yaw_angle := get_yaw_angle(vehicle_node)
		var wheels_spinning := get_wheels_spinning(vehicle_node)
		# time stuff
		var now = Time.get_unix_time_from_system()
		# how long has it been since we last started or stopped a skid?
		# this seems to be in seconds
		var skid_start_delta = now - skid_start_time
		var skid_end_delta = now - skid_end_time
		# how long has it been since we last started or stopped crashing
		var crash_start_delta = now - crash_start_time
		var crash_end_delta = now - crash_end_time
		# check for skidding
		# extend this:
		# skid is valid if:
		#	speed : 	
		#		above a threshold to  enter drift state
		#		speed stays above a lower threshold to retain drift state
		#	angle : 
		#		above a threshold to enter drift state
		#		remains above a lower threshold to retain drift state
		#		requires cooldown to support transitions left/right
		#		speed should prevent donuts qualifying (unless somehow done at speed which is cool and thus counts)
		#	wheel slip / spin:
		#		lateral slip is the more important factor
		#		perhaps bonus points for spin/smoke
		if wheels_spinning and yaw_angle >= skid_yaw_threshold and speed >= skid_speed_threshold and skid_end_delta >= skid_cooldown:
			if not skidding:
				skidding = true
				skids_initiated += 1
				skid_start_time = Time.get_unix_time_from_system()
		else:
			if skidding:
				skidding = false
				skid_end_time = Time.get_unix_time_from_system()		
		
		if crash_end_delta <= crash_cooldown:
			if not crashing:
				crashing = true
		else:
			if crashing:
				crashing = false
	
		# get  time multiplier 
		if skidding:
			skid_time_bonus = skid_time_bonus_default + floor(2.0 * skid_start_delta)
		else:
			skid_time_bonus = 1.0
			
		# get proximity multiplier
		# TODO: is there a way to reward closeness?
		if front_close or rear_close:
			proximity_bonus = proximity_bonus_default	
		else:
			proximity_bonus = 1.0
				
		# Handle crashing - we should have a short cooldown before score
		# can accumulate.  
		# TODO : how do we not penalise rubbing cos that's cool?
		if crashing:
			#if crash_impulse.length() > 0.0:
			#print(crash_impulse.length(), crash_impulse)
			crash_bonus = 0.0
		else:
			crash_bonus = crash_bonus_default
		
		var frame_score = 0.0
		#if skidding or within grace period, add score
		if skidding or skid_end_delta <= skid_cooldown :
			frame_score = skid_score * skid_time_bonus * proximity_bonus * crash_bonus
		
		total_score += floor(frame_score)
		
		
		
		# attach effect amount to speed 
		effect_amount = remap(vehicle_node.speed,10.0, 25.0, 0.0, 1.0)
		effect_amount = clamp(effect_amount, 0.0, 1.0)
		# set uniforms on materials (TODO: find a way to set these globally)
		# anything we pipe into a material should be 0-1 range (or -1:1)
		#vignette_material.set_shader_parameter("coverage", effect_amount)		
		road_material.set_shader_parameter("coverage", effect_amount)
		armco_material.set_shader_parameter("coverage", effect_amount)
		
		camera.fov = 75.0 + (effect_amount * 10.0)


func _on_vehicle_body_entered(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		crash_impulse = player.vehicle_node.current_impulse
		crash_start_time = Time.get_unix_time_from_system()
		print("crash")
		
			
func _on_vehicle_body_exited(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		crash_impulse = Vector3(0.0, 0.0, 0.0)
		crash_end_time = Time.get_unix_time_from_system()
		# end skid as well
		skidding = false
		skid_end_time = Time.get_unix_time_from_system()
		print("un-crash")
	

func _on_area_3d_front_body_entered(body: Node3D, source) -> void:
	if not body == player.vehicle_node and not body == road:
		if source:
			front_close = true
		else:
			rear_close = true
			
func _on_area_3d_front_body_exited(body: Node3D, source) -> void:
	if not body == player.vehicle_node and not body == road:
		if source:
			front_close = false
		else:
			rear_close = false
