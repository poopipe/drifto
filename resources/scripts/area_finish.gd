extends Area3D

@export var finish_area:Node3D
#signal proximity_area_entered(emitter)



func _on_body_entered(_body):
	print("ENTERED END")
	#self.body_entered.emit()

func on_body_exited(body):
	print("EXITED  END")
	#self.body_exited.emit()

func _process(_delta: float) -> void:
	pass
		
