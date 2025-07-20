extends GPUParticles3D

@export var vehicle : Vehicle

@export var longitudinal_slip_threshold := 0.5
@export var lateral_slip_threshold := 1.0

var skid_active: bool = false

func _on_skid_activated():
	skid_active = true

func _on_skid_deactivated():
	skid_active = false

func _process(delta):\
	#what we really want to do is have smoke when wheels are spinning and do something more dramatic 
	#when there's a skid but save that for a bit later
	if skid_active:
		if is_instance_valid(vehicle):
			for wheel in vehicle.wheel_array:
				if wheel.is_driven:
					var smoke_transform : Transform3D = wheel.global_transform
					smoke_transform.origin = wheel.last_collision_point
					emit_particle(smoke_transform,  wheel.global_transform.basis * ((wheel.local_velocity * 0.2) - (Vector3.FORWARD * wheel.spin * wheel.tire_radius * 0.2)) * self.global_transform.basis, Color.WHITE, Color.WHITE, 5) #EMIT_FLAG_POSITION + EMIT_FLAG_VELOCITY)
