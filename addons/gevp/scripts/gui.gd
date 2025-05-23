extends Control

@export var vehicle : Vehicle
@export var game_manager: Node3D
@onready var score_label = $VBoxContainer2/Score
@onready var speed_label = $VBoxContainer2/Speed
@onready var rpm_label = $VBoxContainer2/RPM
@onready var gear_label = $VBoxContainer2/Gear



@onready var crash_state_label = $VBoxContainer/crash_state
@onready var prox_state_label = $VBoxContainer/prox_state
@onready var skid_state_label = $VBoxContainer/skid_state
@onready var skid_score_label = $VBoxContainer/skid_score




func _process(delta):

	speed_label.text = str(snappedf(vehicle.speed * 3.6, 1.0)) + "km/h" #str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "gear: " + str(vehicle.current_gear)
	score_label.text = "score: " + str(game_manager.total_score)
	
	if game_manager.current_skid:
		skid_score_label.text = "skid score:  " + str(game_manager.current_skid.score)
		skid_state_label.text = "skid state:  " + str(game_manager.current_skid.active)
	crash_state_label.text = 	"crash state: " + str(game_manager.crashing)
	prox_state_label.text =     "prox state:  " + str(game_manager.proximity_bonus)
