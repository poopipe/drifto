extends TrailEmitter

@export var trail_material:ShaderMaterial
var skidding:bool = false

var skid_start:float
var skid_end:float

var trail_lifetime:float = 0.6		# how long trail takes to die
var trail_init_time:float = 0.6		# how long trail takes to grow

@export var max_opacity:float = 1.0
@export var min_opacity:float = 0.0

var opacity: float = 0.0;

func _init() -> void:
	pass

func _process(delta: float) -> void:
	var now:float = Time.get_unix_time_from_system()
	var trail_delta:float
	
	var shader_opacity = trail_material.get_shader_parameter("opacity")
	
	if skidding:
		if now - skid_start < trail_init_time:
			trail_delta = (now - skid_start) / trail_init_time

			opacity += trail_delta
			opacity = clamp(opacity, min_opacity, max_opacity)
			trail_material.set_shader_parameter("opacity", opacity)
	else:
		if now - skid_end < trail_lifetime:
			trail_delta = (now - skid_end) / trail_lifetime

			opacity -= trail_delta
			opacity = clamp(opacity, min_opacity, max_opacity)
			trail_material.set_shader_parameter("opacity", opacity)	



func _on_vehicle_rigid_body_skid_activated() -> void:
	skidding = true
	skid_start = Time.get_unix_time_from_system()


func _on_vehicle_rigid_body_skid_deactivated() -> void:
	skidding = false
	skid_end = Time.get_unix_time_from_system()
