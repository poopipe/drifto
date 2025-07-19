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
@onready var skid_end_label = $VBoxContainer/skid_end
@onready var skid_start_label = $VBoxContainer/skid_start
@onready var skid_ended_label = $VBoxContainer/skid_ended
@onready var skid_len_label = $VBoxContainer/skid_length
@onready var time_bonus_label = $VBoxContainer/time_bonus
@onready var speed_bonus_label = $VBoxContainer/speed_bonus

func _process(delta):

	speed_label.text = str(snappedf(vehicle.speed * 3.6, 1.0)) + "km/h" #str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "gear: " + str(vehicle.current_gear)
	score_label.text = "score: " + str(game_manager.total_score)
	
	if game_manager.current_skid:
		skid_score_label.text = "skid score:  " + str(game_manager.current_skid.score)
		skid_state_label.text = "skid state:  " + str(game_manager.current_skid.active)
		skid_start_label.text = "start time:  " + str(game_manager.current_skid.start_time)
		skid_end_label.text = 	"end time:    " + str(game_manager.current_skid.end_time)
		skid_ended_label.text = "ended:       " + str(game_manager.current_skid.ended)
		skid_len_label.text =	"skid length  " + str(game_manager.current_skid.length)
		time_bonus_label.text =		"cooldown:  " + str(game_manager.current_skid.remaining_cooldown)
		speed_bonus_label.text =    "linked skids: " + str(game_manager.current_skid.chain_length)
	crash_state_label.text = 	"crash state: " + str(game_manager.is_crashing)
	prox_state_label.text =     "prox state:  " + str(game_manager.proximity_bonus)

	
