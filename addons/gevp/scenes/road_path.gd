@tool
extends Path3D

@export var lamp_distance := 5.0
@export var lamp_offset := 5.0
var is_dirty := false

func _process(_delta):
	if is_dirty:
		_update_multimesh()
		is_dirty = false
		
func _update_multimesh():
	var path_length := curve.get_baked_length()
	var lamp_count := floor(path_length/lamp_distance)
	var look_ahead_distance := 0.5
	
	
	var lamp_mesh: MultiMesh = $street_lamps.multimesh
	lamp_mesh.instance_count = lamp_count 
	
	for i in range(0, lamp_count):
		var lamp_distance = lamp_offset + lamp_distance * i
		# get transform at point on curve
		var t := curve.sample_baked_with_rotation(lamp_distance, true, true)

		var offset = lamp_offset if i % 2 == 0 else 0.0-lamp_offset

		var transform = t.translated_local(Vector3(offset, 0.0, 0.0))
		lamp_mesh.set_instance_transform(i, transform)
		


func _on_curve_changed() -> void:
	is_dirty = true


func _on_property_list_changed() -> void:
	print('asshole')
