class_name CharacterStateAnimation
extends CharacterState

enum CharacterAnimation {
	DANCING,
	JUMPING,
}

@export var animation: CharacterAnimation
@export var state_idle: CharacterState
@export var timer_range := Vector2(0.5, 3.0) : set = set_timer_range

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)

	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)


func _enter_state() -> void:
	var next := CharacterState.IDLE
	if animation == CharacterAnimation.DANCING:
		next = CharacterState.DANCING
	elif animation == CharacterAnimation.JUMPING:
		next = CharacterState.JUMPING

	set_animation(next)
	_timer.start(randf_range(timer_range.x, timer_range.y))


func _leave_state() -> void:
	_timer.stop()


func _on_timer_timeout() -> void:
	switch_state(state_idle)


func set_timer_range(value: Vector2) -> void:
	timer_range.x = minf(value.x, value.y)
	timer_range.y = maxf(value.x, value.y)
