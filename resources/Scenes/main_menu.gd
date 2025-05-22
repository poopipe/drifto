extends Control
@export var target_scene:PackedScene

func _input(event):
	if event.is_action_pressed("action_back"):
		#get_tree().change_scene_to_packed(target_scene)
		get_tree().change_scene_to_file("res://resources/Scenes/world_001.tscn")
	if event.is_action_pressed("action_menu"):
		print("MENU", event)

	
