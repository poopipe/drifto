extends Camera3D

## The distance, in meters, that the camera will be from the
## [Node3D] in [member follow_this].
@export var follow_distance = 5
## The height, in meters, that the camera will be from the
## [Node3D] in [member follow_this].
@export var follow_height = 2
## The speed, in meters per second, that the camera will
## move to reach the [Node3D] in [member follow_this].
@export var speed:=20.0
## The [Node3D] that the camera will follow.
@export var follow_this : Node3D

var start_rotation : Vector3
var start_position : Vector3
var is_resetting : bool = false

func _ready():
	start_rotation = rotation
	start_position = position

func _physics_process(delta : float):
	if is_resetting:
		var camera_offset := Vector3(0.0, float(follow_height), float(follow_distance))
		global_position = follow_this.global_transform .origin
		self.translate(camera_offset)
		speed = 0.0
	else:
		var delta_v := global_transform.origin - follow_this.global_transform.origin
		delta_v.y = 0.0
		if (delta_v.length() > follow_distance):
			delta_v = delta_v.normalized() * follow_distance
			delta_v.y = follow_height
			global_position = follow_this.global_transform.origin + delta_v
		look_at(follow_this.global_transform.origin, Vector3.UP)
	
	is_resetting = false
