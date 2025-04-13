@tool
extends Path3D

signal path_changed

func _process(_delta):
	pass

func _on_curve_changed() -> void:

	path_changed.emit()
		
