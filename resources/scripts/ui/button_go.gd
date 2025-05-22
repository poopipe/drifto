extends Button

@export var target_scene:PackedScene


func _on_pressed() -> void:
	#get_tree().change_scene_to_packed(target_scene)
	get_tree().change_scene_to_file("res://resources/Scenes/world_001.tscn")
