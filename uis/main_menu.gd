class_name MainMenu
extends CenterContainer

signal exit_pressed
signal settings_pressed
signal start_pressed


var config: Config : set = set_config

@onready var _button_start: Button = $VBoxContainer/ButtonStart


func _ready() -> void:
	_on_config_changed()


func _on_button_exit_pressed() -> void:
	exit_pressed.emit()


func _on_button_settings_pressed() -> void:
	settings_pressed.emit()


func _on_button_start_pressed() -> void:
	start_pressed.emit()


func _on_config_changed() -> void:
	_button_start.disabled = not config or not config.is_valid()


func set_config(value: Config) -> void:
	if config: config.changed.disconnect(_on_config_changed)

	config = value
	if config:
		config.changed.connect(_on_config_changed)
		_on_config_changed()
