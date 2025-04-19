extends Control

@export var vehicle : Vehicle
@export var game_manager: Node3D
@onready var speed_label = $VBoxContainer/Speed
@onready var rpm_label = $VBoxContainer/RPM
@onready var gear_label = $VBoxContainer/Gear
@onready var skidding_label = $VBoxContainer/Skidding


func _process(delta):
	speed_label.text = str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "Gear: " + str(vehicle.current_gear)
	skidding_label.text = "Skidding:" + str(game_manager.total_skidding)
