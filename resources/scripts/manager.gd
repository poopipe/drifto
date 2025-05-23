extends Node3D
@export var player: VehicleController
@export var road:CSGPolygon3D
@export var camera: Camera3D
@export var start_point: Node3D
@export var main_menu_scene: PackedScene

@export_group("skid thresholds")
@export var longitudinal_slip_threshold := 0.7
@export var lateral_slip_threshold := 1.0
@export var skid_yaw_threshold:float = 0.025
@export var skid_speed_threshold:float = 20.0	# corrected speed - not raw speed

@export_group("scores and stuff")
@export var skid_cooldown: float = 1.0
@export var skid_score:float = 1.0	# base amount to increase score

@export_group("crashing")
@export var crash_cooldown: float = 0.5

@export_group("effects")
@export var vignette_material:ShaderMaterial
@export var road_material:ShaderMaterial
@export var armco_material:ShaderMaterial
@export var effect_fade_rate:float = 1.25

var is_resetting: bool = false

var skid_debug:String = "nothign yetk"

# speed 
var speed_correction = 3.6

# score tracking
var total_score: float = 0.0
var current_skid_score: float = 0.0

# skid tracking
var skidding: bool = false
var skids_initiated: int = 0
var skid_start_time  := Time.get_unix_time_from_system()
var skid_end_time:float = Time.get_unix_time_from_system()
var skid_cooldown_active:bool = false
var skid_start_delta:float = 0.0
var skid_end_delta:float = 0.0


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
var proximity_bonus_default:float = 1.0
var proximity_bonus:float = 1.0

# score multipliers
var skid_time_bonus_default:float = 1.0
var skid_time_bonus:float = 1.0
var skid_speed_bonus_default:float = 1.0
var skid_speed_bonus:float = 1.0
var skid_link_bonus_default:float = 1.0
var skid_link_bonus:float = 1.0

# visuals
var effect_amount:float = 0.0	 # use this for any timed effects that are connected to skiddin


# right - our current skid can be a class
#			we'll call it current_skid
# 			each fram we check to see if current_skid is active
# 			if it is, we modify score, set end time and move on
#			if we crash current_skid becomes inactive and score is discarded
#			if skid ends naturally we run cooldown and when it expires we deactivate and discard
#			if we initiate a skid and current_skid is active, we set end_time pick up it's score and 
#			work with that
 
class Skid:
	var start_time:float
	var end_time:float
	var score:float
	var active:bool			# if inactive no score is accumulated but can be reactivated
	var ended:bool			# if ended it's actually dead
	var length:float

# skidz
var previous_skid:Skid
var current_skid:Skid


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

func get_wheels_spinning()-> bool:
	# are any wheels spinning / sliding
	# TODO: 
	#	perhaps we want to check that more than one are slipping
	#	or perhaps we want to check back wheels only?
	for wheel in player.vehicle_node.wheel_array:
		if absf(wheel.slip_vector.x) > lateral_slip_threshold or absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
			return true
	return false

func get_yaw_angle()-> float:
	var plane_xz := Vector2(player.vehicle_node.local_velocity.x, player.vehicle_node.local_velocity.z)
	if plane_xz.y < 0 and plane_xz.length() > 1.0:
		plane_xz = plane_xz.normalized()
		return 1.0 - absf(plane_xz.dot(Vector2.UP))
	return 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_back"):
		init_run()
				
	if event.is_action_pressed("action_menu"):
		print("menu", main_menu_scene)
		
		#var s := get_tree().change_scene_to_packed(main_menu_scene)
		get_tree().change_scene_to_file("res://resources/Scenes/main_menu.tscn")

func get_crashing_state(now)-> bool:
	# crash start and end times are set by signals
	var crash_start_delta = now - crash_start_time
	var crash_end_delta = now - crash_end_time
	if crash_end_delta <= crash_cooldown:
		return true
	return false

func initiate_crash()->void:
	# crashing must be true
	# crash start time is set
	crash_impulse = player.vehicle_node.current_impulse
	crash_start_time = Time.get_unix_time_from_system()

func terminate_crash()->void:
	# crashing must be false
	# crash end time is set
	crash_impulse = Vector3(0.0, 0.0, 0.0)
	crash_end_time = Time.get_unix_time_from_system()

func get_speed_bonus() -> float:
	# bonus hsould be a function of speed when greater than threshold
	# for now we just return 0 if less than threshold
	if crashing:
		return skid_speed_bonus_default
	if not current_skid.active:
		return skid_speed_bonus_default
	var corrected_speed = player.vehicle_node.speed * speed_correction	# not sure why it's 3.6 - check this
	if corrected_speed >= skid_speed_threshold:
		# TODO: better meths plx
		return 1.0 * skid_speed_bonus_default
	return skid_speed_bonus_default

func get_time_bonus(now)->float:
	if current_skid.active:
		return skid_time_bonus_default + floor(1.0 + current_skid.length)
	return skid_time_bonus_default

func get_proximity_bonus()->float:
	if current_skid.active:
		if front_close or rear_close:
			return 2.0 * proximity_bonus_default
	return proximity_bonus_default

func accumulate_skid_score()->void:
	current_skid.score += skid_score * skid_time_bonus * skid_speed_bonus * skid_link_bonus

func commit_skid_score()->void:
	total_score += current_skid.score
	#print("commit score: ", current_skid.score, " total: ", total_score, " length: ", current_skid.length)

func skid_conditions_met()->bool:
	var enough_yaw := false
	var enough_slip := false
	var enough_speed := false

	var speed = player.vehicle_node.speed * speed_correction
	var wheels_spinning := get_wheels_spinning()
	var yaw_angle := get_yaw_angle()
			
	if wheels_spinning:
		enough_slip = true
	if yaw_angle >= skid_yaw_threshold:
		enough_yaw = true
	if speed >= skid_speed_threshold:
		enough_speed = true		
		
	var db:=true
	if db:	
		skid_debug = ""
		if not enough_slip:
			skid_debug += "no slip "
		if not enough_speed:
			skid_debug += "no speed "
		if not enough_yaw:
			skid_debug += "no yaw"
		
		
	return enough_slip and enough_yaw and enough_speed

func new_skid()->Skid:
	var now = Time.get_unix_time_from_system()
	var skid = Skid.new()
	skid.start_time = now
	skid.end_time = now 
	skid.score = 0.0
	skid.active = false
	skid.ended = false
	skid.length = 0.0
	return skid 
	
func _process(_delta: float) -> void:
	var vehicle_node = player.vehicle_node
	if is_instance_valid(vehicle_node):	
		
		# time stuff
		var now = Time.get_unix_time_from_system()
		skid_start_delta = now - skid_start_time
		# can car skid on this frame?
		var can_skid:bool = skid_conditions_met()	
		# is car crashing
		crashing = get_crashing_state(now)
		
		# we need a current skid regardless
		if not current_skid:
			current_skid = new_skid()

		skid_end_delta = now - current_skid.end_time
		
		# if cooldown time reached burn current skid
		if skid_end_delta >= skid_cooldown:
			if current_skid.active:
				commit_skid_score()
			current_skid = new_skid()
		
		# if crashed burn current skid
		if crashing:
			current_skid = new_skid()
		
		# if skid conditions aren't met, set the end time 
		# but do not end the skid this is successful skid exit and can be reactivated
		if not can_skid:
			if current_skid.active:
				current_skid.end_time = now
				current_skid.length = now - current_skid.start_time
				current_skid.active = false
		# if we can skid, continue skidding
		else:
			if not current_skid.ended:
				if not current_skid.active:
					current_skid.active = true
				else:
					#update skid object
					current_skid.length = now - current_skid.start_time
				
		# skid state should be correct at this point
		# so we can handle scoring
		skidding = current_skid.active	
		if current_skid.active and not current_skid.ended and not crashing:
			skid_time_bonus = get_time_bonus(now)
			skid_speed_bonus = get_speed_bonus()
			proximity_bonus = get_proximity_bonus()
			accumulate_skid_score()



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
		initiate_crash()


func _on_vehicle_body_exited(body: Node3D) -> void:
	if not body == player.vehicle_node and not body == road:
		terminate_crash()


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
