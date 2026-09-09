class_name CharacterManager
extends Node3D


@export_category("Config")
@export var twitch: TwitchClient
@export var spawn_point_left: Marker3D
@export var spawn_point_right: Marker3D

@export_category("Debug")
@export var button_debug_characters_jumping: Button
@export var button_debug_kill_characters: Button
@export var button_debug_spawn_character: Button

var _users := {}

var character_list: CharacterList
var characters: Array[String] = []
var enable_label_color := true : set = set_enable_label_color
var user_timeout: float = 300.0


func _ready() -> void:
	if button_debug_characters_jumping:
		button_debug_characters_jumping.pressed.connect(_debug_characters_jumping)

	if button_debug_kill_characters:
		button_debug_kill_characters.pressed.connect(_debug_kill_characters)

	if button_debug_spawn_character:
		button_debug_spawn_character.pressed.connect(_debug_spwan_character)

	if twitch:
		twitch.chat_message.connect(_on_twitch_chat_message)


func _physics_process(_delta: float) -> void:
	var list: Array[String] = []
	for handle in _users:
		var user: UserCharacter = _users[handle]
		if user.get_time() >= user_timeout:
			_kill_character(user.character)
			list.append(handle)

	for handle in list: _users.erase(handle)


func _debug_characters_jumping() -> void:
	for handle in _users:
		var user: UserCharacter = _users[handle]
		_on_twitch_chat_message(user.username, "", user.tags)


func _debug_kill_characters() -> void:
	for handle in _users:
		var user: UserCharacter = _users[handle]
		_kill_character(user.character)
	_users.clear()


func _debug_spwan_character() -> void:
	var username := "justinfan%d" % randi()
	_on_twitch_chat_message(username, "", {TwitchClient.TAG_HANDLE: [username]})


func _get_character_spawn_position() -> Vector3:
	var walking_space := _get_walking_space()

	var x := randf_range(walking_space.x, walking_space.y)
	var y := randf_range(spawn_point_left.global_position.y, spawn_point_right.global_position.y)
	var z := randf_range(spawn_point_left.global_position.z, spawn_point_right.global_position.z)

	return Vector3(x, y, z)


func _get_walking_space() -> Vector2:
	return Vector2(spawn_point_left.global_position.x, spawn_point_right.global_position.x)


func _kill_character(character: Character) -> void:
	character.set_death()

func _on_twitch_chat_message(username: String, _text: String, tags: Dictionary[String, PackedStringArray]) -> void:
	var handle := TwitchClient.get_tag(tags, TwitchClient.TAG_HANDLE)
	if not handle in _users:
		_spawn_character(handle, tags, username)
	else:
		_update_character(handle, tags, username)


func _set_character_spawn_point(character: Character) -> void:
	character.global_position = _get_character_spawn_position()
	character.walking_space = _get_walking_space()
	character.set_dancing()


func _spawn_character(handle: String, tags: Dictionary[String, PackedStringArray], username: String):
	var count := len(characters)

	var index := 0
	for retries in range(10):
		if count == 0: return null
		elif count > 1: index = randi_range(0, count - 1)

		var character_name := characters[index]
		if not character_name in character_list.characters or not character_list.characters[character_name]: continue
		var character: Character = character_list.characters[character_name].instantiate()

		character.name = "Character-%s" % handle
		add_child(character)
		_users[handle] = UserCharacter.new(character, tags, username)

		_set_character_spawn_point(character)
		_update_character_label(character, tags, username)
		return
	push_error("Unable to spawn user character: can not find valid character")


func _update_character(handle: String, tags: Dictionary[String, PackedStringArray], username: String):
	var user: UserCharacter = _users[handle]

	user.message_received()

	user.tags = tags
	user.character.set_jumping()

	_update_character_label(user.character, tags, username)


func _update_character_label(character: Character, tags: Dictionary[String, PackedStringArray], username: String) -> void:
	if not character: return

	var color := Color.WHITE
	if enable_label_color:
		color = Color.from_string(TwitchClient.get_tag(tags, TwitchClient.TAG_COLOR), Color.WHITE)

	character.set_label_color(color)
	character.set_username(username)


func reset_characters() -> void:
	for handle in _users:
		var user: UserCharacter = _users[handle]

		user.character.reset()
		_set_character_spawn_point(user.character)


func set_enable_label_color(value: bool) -> void:
	if enable_label_color == value: return
	enable_label_color = value

	for handle in _users:
		var user: UserCharacter = _users[handle]
		_update_character_label(user.character, user.tags, user.username)


class UserCharacter:
	var character: Character
	var last_message_time: float
	var tags: Dictionary[String, PackedStringArray]
	var username: String


	func _init(p_character: Character, p_tags: Dictionary[String, PackedStringArray], p_username: String) -> void:
		character = p_character
		last_message_time = Time.get_unix_time_from_system()
		tags = p_tags
		username = p_username


	func get_time() -> float:
		return Time.get_unix_time_from_system() - last_message_time


	func message_received() -> void:
		last_message_time = Time.get_unix_time_from_system()
