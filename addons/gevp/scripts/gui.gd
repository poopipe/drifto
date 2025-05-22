extends Control

@export var vehicle : Vehicle
@export var game_manager: Node3D
@onready var speed_label = $VBoxContainer/Speed
@onready var rpm_label = $VBoxContainer/RPM
@onready var gear_label = $VBoxContainer/Gear
@onready var score_label = $VBoxContainer/Score
@onready var skid_score_label =$VBoxContainer/SkidScore
@onready var time_bonus_label = $VBoxContainer/TimeBonus
@onready var prox_bonus_label = $VBoxContainer/ProxBonus
@onready var crashing_label = $VBoxContainer/Crashing

func _process(delta):

	speed_label.text = str(snappedf(vehicle.speed * 3.6, 1.0)) + "km/h" #str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "debuf: " + str(game_manager.skid_debug)
	time_bonus_label.text = "skid score:" + str(game_manager.current_skid_score)
	crashing_label.text = "skidding:" + str(game_manager.skidding)
	prox_bonus_label.text = "skid cooldown:" + str(game_manager.skid_cooldown_active)
	skid_score_label.text = "end delta:" + str(snappedf(game_manager.skid_end_delta, 0.01))
	score_label.text = "start delta:" + str(snappedf(game_manager.skid_start_delta, 0.01))
	
