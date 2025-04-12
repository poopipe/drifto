@tool
extends Path3D

@export var lamp_distance := 5.0
@export var lamp_z := 10.0
var is_dirty := false

func _process(_delta):
	if is_dirty:
		_update_multimesh()
		is_dirty = false
		
func _update_multimesh():
	var path_length := curve.get_baked_length()
	var lamp_count := floor(path_length/lamp_distance)
	
	var lamp_mesh: MultiMesh = $MultiMeshInstance3D.multimesh
	lamp_mesh.instance_count = lamp_count 
	var lamp_offset = lamp_distance / 2.0
	
	for i in range(0, lamp_count):
		var lamp_distance = lamp_offset + lamp_distance * i
		var lamp_position = curve.sample_baked(lamp_distance, true)
		
		var z = lamp_z if i % 2 == 0 else 0.0-lamp_z
		
		
		
		lamp_position = lamp_position 
		
		var lamp_basis = Basis()
		var transform = Transform3D(lamp_basis, lamp_position)
		lamp_mesh.set_instance_transform(i, transform)
		


func _on_curve_changed() -> void:
	is_dirty = true


func _on_property_list_changed() -> void:
	print('asshole')
