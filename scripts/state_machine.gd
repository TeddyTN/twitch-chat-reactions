class_name StateMachine
extends Node


@export var state_default: State

var _state: State


func _ready() -> void:
	if state_default:
		switch_state(state_default)


func get_state() -> State:
	return _state


func switch_state(state: State) -> void:
	if _state:
		_state.leave()

	_state = state
	_state.state_machine = self

	if _state:
		_state.enter()
