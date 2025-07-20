extends Node3D

# 
signal skid_activated
signal skid_deactivated

@export var player: VehicleController
@export var road:CSGPolygon3D
@export var camera: Camera3D
@export var start_point: Node3D
@export var main_menu_scene: PackedScene
@export var finish_scene: Node3D
@export var settings_menu_node: Control

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
#var skidding: bool = false
#var skids_initiated: int = 0
#var skid_start_time  := Time.get_unix_time_from_system()
#var skid_end_time:float = Time.get_unix_time_from_system()
#var skid_cooldown_active:bool = false
var skid_start_delta:float = 0.0
var skid_end_delta:float = 0.0
var can_skid:bool = false

var skid_check_time = 0.2
var skid_check_timer = 0.0

# crash tracking
var is_crashing: bool = false
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
var skid_speed_bonus_default:float = 1.0
var skid_link_bonus_default:float = 1.0

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
	var active:bool					# if inactive no score is accumulated but can be reactivated
	var ended:bool					# if ended it's actually dead
	var length:float
	var remaining_cooldown:float	# cooldown is to enable extending skid if new one starts soon enough
	var chain_length:int			# every time we extend we add to this for bunuses
	var skid_time_bonus:float = 	1.0
	var skid_speed_bonus:float = 	1.0
# skidz
var current_skid:Skid
var total_skids:Array[Skid]			# store all the skids for stats



func _ready() -> void:
	
	# get proximity areas 
	var proximity_areas := get_tree().get_nodes_in_group("proximity_areas")
	var finish_areas := get_tree().get_nodes_in_group("finish_area")
	
	
	for pa in proximity_areas:
		if pa.has_signal("body_entered"):
			pa.body_entered.connect(_on_area_3d_front_body_entered.bind(pa.front) )
		if pa.has_signal("body_exited"):
			pa.body_exited.connect(_on_area_3d_front_body_exited.bind(pa.front) )
	
	for fa in finish_areas:
		if fa.has_signal("body_entered"):
			fa.body_entered.connect(_on_area_3d_finish_body_entered.bind())
	
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

	crash_bonus = crash_bonus_default
	proximity_bonus = proximity_bonus_default

func get_wheels_spinning()-> bool:
	# are any wheels spinning / sliding
	for wheel in player.vehicle_node.wheel_array:
		# only check driven wheels cos we dont care about the others
		if wheel.is_driven:
			# check  lateral slip 
			if absf(wheel.slip_vector.x) > lateral_slip_threshold:
				# longitudinal slip disabled until i have a good reason to check it as i want
				# no throttle skids to count
				#if absf(wheel.slip_vector.y) > longitudinal_slip_threshold:
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
		# hide or unhide settings menu
		if settings_menu_node.visible:
			settings_menu_node.visible = false
		else:
			settings_menu_node.visible = true
		#print("settings menu", settings_menu_node.visible)
		
func go_main_menu() -> void:		
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
	# skid must be active and we must be over speed threshold
	var speed = player.vehicle_node.speed * speed_correction
	# multiplier is how many x threshold speed 
	return max(floor(speed / skid_speed_threshold), 1.0)
	
	
func get_time_bonus()->float:
	
	return max(floor(current_skid.length), 1.0)

func get_proximity_bonus()->float:
	if current_skid.active:
		if front_close or rear_close:
			return 2.0 * proximity_bonus_default
	return proximity_bonus_default

func get_link_bonus()->float:
	# link bonus is a function of how many skids are linked
	return max(float(current_skid.chain_length),1.0)
	

func accumulate_skid_score()->void:
	# apply realtime score bonuses
	var speed_bonus = get_speed_bonus()
	var proximity_bonus = get_proximity_bonus()
	# increase current skid score
	current_skid.score += (skid_score * speed_bonus * proximity_bonus )

func commit_skid_score()->void:
	# apply length and link bonuses
	var time_bonus = get_time_bonus()
	var link_bonus = get_link_bonus()
	total_score += current_skid.score * time_bonus * link_bonus
	#print("commit score: ", current_skid.score, " time: ", time_bonus, " link: ", link_bonus)

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
		
	var db:=false
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
	skid.remaining_cooldown = skid_cooldown	# from exported var
	skid.chain_length = 0
	
	skid_activated.emit()
	
	return skid 

func restart_current_skid():
	current_skid.remaining_cooldown = skid_cooldown
	current_skid.active = true
	current_skid.ended = false
	# if our previous skid was short we should not increment the number of links
	# we use end time because skid length cannot be reset 
	var now = Time.get_unix_time_from_system()
	if now - current_skid.end_time >= 1.0:
		current_skid.chain_length += 1
	skid_activated.emit()
	
func pause_current_skid():
	# pause skid - can still be reactivated
	var now = Time.get_unix_time_from_system()
	current_skid.active = false
	current_skid.end_time = now
	skid_deactivated.emit()
	
func end_current_skid():
	var now  = Time.get_unix_time_from_system()
	current_skid.active = false
	current_skid.end_time = now
	current_skid.ended = true
	total_skids.append(current_skid)
	skid_deactivated.emit()
	
func _process(_delta: float) -> void:
	var vehicle_node = player.vehicle_node
	if is_instance_valid(vehicle_node):			
		# time stuff
		var now = Time.get_unix_time_from_system()
		
		# can car skid on this frame?
		# TODO: this check needs to be smoothed out.  probably dont check every frame
		# the solution below hasn't fully helped.  
		# I tihnk it's mostly a problem when going mostly straight or on slow corners  - 
		# might be worth looking at the sheel slip detection
		
		skid_check_timer += _delta 
		if skid_check_timer >= skid_check_time:
			can_skid = skid_conditions_met()	
		
		# is car crashing
		is_crashing = get_crashing_state(now)
		
		# if we can skid and we are not already skidding
		if can_skid:
			# we need a new skid if there isnt one, or our current one has ended
			if not current_skid or current_skid.ended:
				current_skid = new_skid()
			# if our current skid is paused we reactivate it
			else:
				if not current_skid.ended and not current_skid.active:
					restart_current_skid()
			current_skid.active = true		# TODO: probably unnecessary
		# if we cant skid we deactivate current skid and allow it to complete cooldown
		else: 
			if current_skid and current_skid.active and not current_skid.ended:
				pause_current_skid()	
				
		# check for crash if we have an active skid:
		if current_skid and current_skid.active and is_crashing:
			# a crash should immediately end our skid
			if not current_skid.ended:
				end_current_skid()

		
		# all checks that could result in an inactive skid should have happened by now
		# so this is a successful skid state
		if current_skid and current_skid.active:
			# extend current skid length
			# end time is set when skid is paused or ended
			current_skid.length += _delta
			accumulate_skid_score()
			
		# if skid is not active we handle cooldown and end the skid if it has passed
		if current_skid and not current_skid.active:
			if not current_skid.ended:
			# if cooldown has ended, kill the skid properly
				if current_skid.remaining_cooldown <= 0.0: 
					current_skid.remaining_cooldown = 0
					commit_skid_score()
					end_current_skid()
				else:
					current_skid.remaining_cooldown -= _delta
		
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
			
func _on_area_3d_finish_body_entered(body: Node3D)->void:
	if body == player.vehicle_node:
		await get_tree().create_timer(2.0).timeout
		go_main_menu()
		
