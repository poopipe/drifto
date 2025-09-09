extends Button

func _on_pressed() -> void:
	print("ass")
	get_tree().change_scene_to_file("res://resources/Scenes/ui/settings.tscn")
