extends Control

@export var vehicle : Vehicle
@export var game_manager: Node3D
@onready var speed_label = $VBoxContainer/Speed
@onready var rpm_label = $VBoxContainer/RPM
@onready var gear_label = $VBoxContainer/Gear
@onready var skidding_label = $VBoxContainer/Skidding
@onready var time_bonus_label = $VBoxContainer/TimeBonus
@onready var prox_bonus_label = $VBoxContainer/ProxBonus
@onready var crashing_label = $VBoxContainer/Crashing

func _process(delta):
	speed_label.text = str(snappedf(vehicle.speed, 1.0)) #str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "Gear: " + str(vehicle.current_gear)
	skidding_label.text = "Skidding:" + str(game_manager.total_skidding)
	time_bonus_label.text = "time bonus:" + str(game_manager.skid_time_bonus)
	prox_bonus_label.text = "prox bonus:" + str(game_manager.proximity_bonus)
	crashing_label.text = "crashing:" + str(game_manager.crashing)
