extends GPUParticles3D

@export var vehicle : Vehicle


var skid_active: bool = false

func _on_skid_activated():
	skid_active = true

func _on_skid_deactivated():
	skid_active = false

func _process(delta):
	# what we really want to do is have smoke when wheels are spinning and do something more dramatic 
	# when there's a skid but save that for a bit later
	if skid_active:
		if is_instance_valid(vehicle):
			for wheel in vehicle.wheel_array:
				if wheel.is_driven:
					emitting = true
					
	else:
		emitting = false
