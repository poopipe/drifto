extends Control	

@export var vehicle : Vehicle
@export var game_manager: Node3D

@onready var label_total_score = $label_total_score
@onready var label_skid_score = $label_skid_score


var opaque:= Color(1.0, 1.0, 1.0, 1.0)
var transparent:= Color(1.0, 1.0, 1.0, 0.0)


var tween = Tween

func _ready() -> void:
	pass

# TODO: Fade in a skid score gui when skid starts and display current skid score
#		On commit score update multipliers and total score

func _process(delta: float) -> void:
	# update skid score all the time - might as well
	if game_manager.current_skid:
		label_skid_score.text = str(game_manager.current_skid.score)
	


func _on_manager_commit_score() -> void:	
	tween = get_tree().create_tween() 
	tween.tween_property(label_total_score, "modulate", opaque, 0.5).set_trans(Tween.TRANS_BOUNCE)
	label_total_score.text = str(game_manager.total_score)
	tween.connect("finished", on_faded_in)
	
func on_faded_in()->void:
	print("finished")
	tween = get_tree().create_tween() 
	tween.tween_property(label_total_score, "modulate", transparent, 0.5).set_trans(Tween.TRANS_BOUNCE)
	


func _on_manager_skid_activated() -> void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_score, "modulate", opaque, 0.5).set_trans(Tween.TRANS_BOUNCE)


func _on_manager_skid_deactivated() -> void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_score, "modulate", transparent, 0.5).set_trans(Tween.TRANS_BOUNCE)
