class_name CharacterStateDeath
extends CharacterState

@export var root: Node
@export var timer_range := Vector2(2.5, 5.0): set = set_timer_range

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)

	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)


func _physics_process(_delta: float) -> void:
	if not _timer.is_stopped(): return

	var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	if playback.get_current_play_position() >= playback.get_current_length():
		_timer.start(randf_range(timer_range.x, timer_range.y))


func _enter_state() -> void:
	set_animation(CharacterState.DEATH)


func _leave_state() -> void:
	_timer.stop()


func _on_timer_timeout() -> void:
	root.queue_free()


func set_timer_range(value: Vector2) -> void:
	timer_range.x = minf(value.x, value.y)
	timer_range.y = maxf(value.x, value.y)
