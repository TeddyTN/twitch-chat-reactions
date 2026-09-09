class_name Config
extends Resource


const DISPLAY_SCALE_MAX: int = 175
const DISPLAY_SCALE_MIN: int = 25
const USER_TIMEOUT_MAX: float = 3600.0
const USER_TIMEOUT_MIN: float = 60.0

@export var channel: String : set = set_channel
@export var characters: Array[String] : set = set_characters
@export var display_scale: int = 100 : set = set_display_scale
@export var user_color: bool = true : set = set_user_color
@export var user_timeout: float = 300.0 : set = set_user_timeout


func is_valid() -> bool:
	return not channel.is_empty() and not characters.is_empty()


func set_channel(value: String) -> void:
	value = value.strip_edges()
	if channel == value: return

	channel = value
	emit_changed()


func set_characters(value: Array[String]) -> void:
	if value:
		var map: Dictionary[String, bool] = {}
		characters = value.filter(func(entry: String) -> bool:
			if entry in map: return false
			map[entry] = true

			return true
		)
		characters.sort()
	else:
		characters = value
	emit_changed()


func set_display_scale(value: int) -> void:
	value = clampi(value, DISPLAY_SCALE_MIN, DISPLAY_SCALE_MAX)
	if display_scale == value: return

	display_scale = value
	emit_changed()


func set_user_color(value: bool) -> void:
	if user_color == value: return

	user_color = value
	emit_changed()


func set_user_timeout(value: float) -> void:
	value = clampf(value, USER_TIMEOUT_MIN, USER_TIMEOUT_MAX)
	if user_timeout == value: return

	user_timeout = value
	emit_changed()


func sync_characters(character_list: CharacterList) -> bool:
	if not characters: return false

	var count := len(characters)
	characters = characters.filter(func(entry: String) -> bool:
		return character_list and entry in character_list.characters
	)
	emit_changed()

	return not count == len(characters)
