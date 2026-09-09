class_name Character
extends CharacterBody3D


@export var state_dancing: CharacterState
@export var state_death: CharacterState
@export var state_idle: CharacterStateIdle
@export var state_jumping: CharacterState
@export var state_walking: CharacterState

var walking_space: Vector2 : set = set_walking_space

@onready var _label_3d: Label3D = $Label3D
@onready var _state_machine: StateMachine = $StateMachine


func _ready() -> void:
	state_walking.walking_space = walking_space


func _physics_process(_delta: float) -> void:
	velocity.y = 0
	if not is_on_floor():
		velocity += get_gravity()

	move_and_slide()


func reset() -> void:
	state_idle.clear_states()
	_state_machine.switch_state(state_idle)


func set_dancing() -> void:
	state_idle.add_state(state_dancing)


func set_death() -> void:
	state_idle.death = true


func set_label_color(color: Color) -> void:
	_label_3d.modulate = color


func set_jumping() -> void:
	state_idle.add_state(state_jumping)


func set_username(username: String) -> void:
	_label_3d.text = username


func set_walking_space(value: Vector2) -> void:
	walking_space = value
	if state_walking:
		state_walking.walking_space = walking_space
