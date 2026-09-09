class_name State
extends Node


var state_machine: StateMachine


func _init() -> void:
	process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED


func _enter_state() -> void:
	pass


func _leave_state() -> void:
	pass


func enter() -> void:
	process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
	_enter_state()


func leave() -> void:
	process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	_leave_state()


func switch_state(state: State) -> void:
	state_machine.switch_state(state)
