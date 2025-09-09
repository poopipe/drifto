extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://resources/Scenes/world_001.tscn")
