class_name SettingsMenu
extends PanelContainer

signal close_pressed

var character_list: CharacterList : set = set_character_list
var config: Config : set = set_config
var locked: bool : set = set_locked

@onready var _channel_text_edit: TextEdit = %ChannelTextEdit
@onready var _character_container: VBoxContainer = %CharacterContainer
@onready var _display_scale_spin_box: SpinBox = %DisplayScaleSpinBox
@onready var _user_color_check_button: CheckButton = %UserColorCheckButton
@onready var _user_timeout_spin_box: SpinBox = %UserTimeoutSpinBox


func _ready() -> void:
	_display_scale_spin_box.max_value = float(Config.DISPLAY_SCALE_MAX)
	_display_scale_spin_box.min_value = float(Config.DISPLAY_SCALE_MIN)
	_user_timeout_spin_box.max_value = Config.USER_TIMEOUT_MAX
	_user_timeout_spin_box.min_value = Config.USER_TIMEOUT_MIN
	_update_characters()
	_update_config()


func _on_button_close_pressed() -> void:
	close_pressed.emit()


func _on_channel_text_edit_text_changed() -> void:
	if config: config.channel = _channel_text_edit.text


func _on_character_toggled(toggled_on: bool, key: String) -> void:
	if not config: return

	var contains := config.characters.any(func(character: String) -> bool: return character == key)
	if toggled_on and not contains:
		config.characters.push_back(key)
		config.characters = config.characters
	elif not toggled_on and contains:
		config.characters = config.characters.filter(func(character: String) -> bool:
			return not character == key
		)


func _on_display_scale_spin_box_value_changed(value: float) -> void:
	if config: config.display_scale = int(value)


func _on_user_color_check_button_toggled(toggled_on: bool) -> void:
	if config: config.user_color = toggled_on


func _on_user_timeout_spin_box_value_changed(value: float) -> void:
	if config: config.user_timeout = value


func _update_characters() -> void:
	while _character_container.get_child_count() > 0:
		_character_container.remove_child(_character_container.get_child(0))

	if not character_list: return

	for key in character_list.characters:
		var child: CheckButton = CheckButton.new()

		child.name = "CharacterCheckButton_%s" % key
		_character_container.add_child(child)

		child.button_pressed = config and config.characters.any(func(character: String) -> bool: return character == key)
		child.disabled = locked
		child.text = key.capitalize()
		child.toggled.connect(_on_character_toggled.bind(key))


func _update_config() -> void:
	var channel: String
	var characters: Array[String]
	var display_scale: int
	var user_color: bool
	var user_timeout: float

	if config:
		channel = config.channel
		characters = config.characters
		display_scale = config.display_scale
		user_color = config.user_color
		user_timeout = config.user_timeout

	if _channel_text_edit:
		_channel_text_edit.text = channel

	if _character_container and characters:
		for child in _character_container.get_children():
			var check_button: CheckButton = child
			var button_pressed := false
			for character in config.characters:
				if check_button.name.ends_with("_%s" % character):
					button_pressed = true
					break

			check_button.button_pressed = button_pressed

	if _display_scale_spin_box:
		_display_scale_spin_box.value = display_scale

	if _user_color_check_button:
		_user_color_check_button.button_pressed = user_color

	if _user_timeout_spin_box:
		_user_timeout_spin_box.value = user_timeout


func set_config(value: Config) -> void:
	config = value
	_update_config()


func set_locked(value: bool) -> void:
	if locked == value: return

	locked = value
	_channel_text_edit.editable = not locked

	for child in _character_container.get_children():
		child.disabled = locked


func set_character_list(value: CharacterList) -> void:
	if character_list == value: return

	character_list = value
	_update_characters()
