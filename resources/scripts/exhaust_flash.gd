extends GPUParticles3D
@export var vehicle : Vehicle


func _on_exhaust_flame() -> void:
	self.restart()
	self.emitting = true
	print("gear_change ", self.emitting)
