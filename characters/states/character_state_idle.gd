class_name CharacterStateIdle
extends CharacterState


@export var character_body_3d: CharacterBody3D
@export var state_death: CharacterState : set = set_state_death
@export var state_falling: CharacterState
@export var state_walking: CharacterState : set = set_state_walking
@export var timer_range := Vector2(0.5, 1.5) : set = set_timer_range

var _default_state: CharacterState
var _states: Array[CharacterState]
var _timer: Timer
var death := false : set = set_death


func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)

	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	_update_default_state()


func _physics_process(_delta: float) -> void:
	if not character_body_3d.is_on_floor():
		switch_state(state_falling)
	elif _timer.is_stopped():
		if _states.is_empty():
			_timer.start(randf_range(timer_range.x, timer_range.y))
		else:
			_on_timer_timeout()


func _enter_state() -> void:
	set_animation(CharacterState.IDLE)


func _leave_state() -> void:
	_timer.stop()


func _on_timer_timeout() -> void:
	if _states.is_empty() and _default_state:
		_states.push_back(_default_state)
	elif _states.is_empty():
		_timer.start(randf_range(timer_range.x, timer_range.y))
	else:
		switch_state(_states.pop_front())


func add_state(state: CharacterState) -> void:
	if state: _states.push_back(state)


func _update_default_state() -> void:
	if death:
		_default_state = state_death
	else:
		_default_state = state_walking


func clear_states() -> void:
	_states.clear()


func set_death(value: bool) -> void:
	if death == value: return

	death = value
	_update_default_state()


func set_state_death(value: CharacterState) -> void:
	if state_death == value: return

	state_death = value
	_update_default_state()


func set_state_walking(value: CharacterState) -> void:
	if state_walking == value: return

	state_walking = value
	_update_default_state()


func set_timer_range(value: Vector2) -> void:
	timer_range.x = minf(value.x, value.y)
	timer_range.y = maxf(value.x, value.y)
