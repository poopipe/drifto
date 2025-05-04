extends Area3D
@export var vehicle: Vehicle
@export var front: bool
signal proximity_area_entered(emitter)

func _on_body_entered(body):
	self.body_entered.emit()

func on_body_exited(body):
	self.body_exited.emit()

func _process(_delta: float) -> void:
	pass
		
