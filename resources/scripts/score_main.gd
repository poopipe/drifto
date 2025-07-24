extends Control	

@export var vehicle : Vehicle
@export var game_manager: Node3D

@onready var label_total_score = $label_total_score
@onready var label_skid_score = $label_skid_score
@onready var label_skid_slider = $label_skid_slider

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
	slide_score()	
	
	
	
	
	
func slide_score() -> void:
	label_total_score.text = str(game_manager.total_score)
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_slider,"modulate", opaque, 0.05).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label_skid_slider,"position", label_total_score.position, 0.5).set_trans(Tween.TRANS_BOUNCE)	
	tween.connect("finished", show_total_score)
	
func show_total_score()->void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_total_score, "modulate", opaque, 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label_skid_slider, "modulate", transparent, 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.connect("finished", on_faded_in)
	
	
func on_faded_in()->void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_slider,"position", label_skid_score.position, 0.05).set_trans(Tween.TRANS_LINEAR)


func _on_manager_skid_activated() -> void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_score, "modulate", opaque, 0.2).set_trans(Tween.TRANS_BOUNCE)


func _on_manager_skid_deactivated() -> void:
	tween = get_tree().create_tween() 
	tween.tween_property(label_skid_score, "modulate", transparent, 0.2).set_trans(Tween.TRANS_BOUNCE)
