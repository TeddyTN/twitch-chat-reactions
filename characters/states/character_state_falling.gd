class_name CharacterStateFalling
extends CharacterState


@export var character_body_3d: CharacterBody3D
@export var state_idle: CharacterState


func _physics_process(_delta: float) -> void:
	if character_body_3d.is_on_floor():
		switch_state(state_idle)


func _enter_state() -> void:
	set_animation(CharacterState.WALKING)
