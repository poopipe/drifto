extends Control
@export var target_scene:PackedScene

func _input(event):
	if event is InputEventJoypadButton:
		print(event.button_index)
		if event.button_index == 6 or event.button_index == 0:
			get_tree().change_scene_to_packed(target_scene)
			
	
