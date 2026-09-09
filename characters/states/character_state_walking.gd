class_name CharacterStateWalking
extends CharacterState


const ROTATAION_ANGLE := PI * 0.5

@export var character_body_3d: CharacterBody3D
@export var state_idle: CharacterState
@export var walking_distance := Vector2(0.25, 0.5) : set = set_walking_distance

var walking_space: Vector2
var _target: Vector3


func _physics_process(_delta: float) -> void:
	var dist := (_target - character_body_3d.global_position).length_squared()
	if dist < 0.01:
		_target = Vector3(0, 0, 0)
		switch_state(state_idle)


func _enter_state() -> void:
	_next_target()
	if _target.x - character_body_3d.global_position.x < 0:
		character_body_3d.global_rotation.y = -ROTATAION_ANGLE
	else:
		character_body_3d.global_rotation.y = ROTATAION_ANGLE
	set_animation(CharacterState.WALKING)
	character_body_3d.velocity = character_body_3d.global_basis * Vector3.MODEL_FRONT


func _leave_state() -> void:
	character_body_3d.global_rotation.y = 0
	character_body_3d.velocity = Vector3(0, 0, 0)


func _next_target() -> void:
	var dist_max := walking_space.y - walking_space.x
	var pos := character_body_3d.global_position

	var dist := randf_range(dist_max * walking_distance.x, dist_max * walking_distance.y) * -signf(pos.x)
	var new_x := clampf(pos.x + dist, walking_space.x, walking_space.y)
	_target = Vector3(new_x, pos.y, pos.z)


func set_walking_distance(value: Vector2) -> void:
	walking_distance.x = minf(value.x, value.y)
	walking_distance.y = maxf(value.x, value.y)
