extends Node


enum MenuState {
	MAIN_MENU,
	MAIN_MENU_SETTINGS,
	STARTED,
	STARTED_SETTINGS,
}

const CAMERA_ZOOM_MAX: float = float(Config.DISPLAY_SCALE_MAX) / 100.0
const CAMERA_ZOOM_MIN: float = float(Config.DISPLAY_SCALE_MIN) / 100.0
const CONFIG_PATH := "user://config.tres"
const SPAWN_X_PADDING: float = 1.25

@export var character_list: CharacterList

var _camera_size_default: float
var _config: Config
var _menu_state: MenuState = MenuState.MAIN_MENU

var camera_zoom: float = 1.0 : set = set_camera_zoom

@onready var _camera_3d: Camera3D = $World/Camera3D
@onready var _character_manager: CharacterManager = $World/CharacterManager
@onready var _debug_buttons: Control = $CanvasLayer/DebugButtons
@onready var _main_menu: MainMenu = $CanvasLayer/MainMenu
@onready var _settings_menu: SettingsMenu = $CanvasLayer/SettingsMenu
@onready var _spawn_left: Marker3D = $World/SpawnLeft
@onready var _spawn_right: Marker3D = $World/SpawnRight
@onready var _twitch_client: TwitchClient = $TwitchClient


func _ready() -> void:
	_debug_buttons.visible = false

	_init_config()
	_config.changed.connect(_on_config_changed)

	_character_manager.character_list = character_list

	_main_menu.config = _config
	_settings_menu.character_list = character_list
	_settings_menu.config = _config
	_settings_menu.visible = false

	_update_config()
	_update_camera_zoom()


func _physics_process(_delta: float) -> void:
	if _menu_state == MenuState.STARTED and Input.is_action_just_pressed("toggle_debug"):
		_debug_buttons.visible = not _debug_buttons.visible

	if Input.is_action_just_pressed("ui_cancel"):
		if _menu_state == MenuState.MAIN_MENU_SETTINGS:
			_menu_state_transition(MenuState.MAIN_MENU)
		elif _menu_state == MenuState.STARTED:
			_menu_state_transition(MenuState.STARTED_SETTINGS)
		elif _menu_state == MenuState.STARTED_SETTINGS:
			_menu_state_transition(MenuState.STARTED)


func _init_config() -> void:
	var config = null
	if FileAccess.file_exists(CONFIG_PATH):
		config = ResourceLoader.load(CONFIG_PATH, "Config")

	var modified := false
	if config and config is Config:
		_config = config
	else:
		_config = Config.new()
		modified = true

	modified = _config.sync_characters(character_list) || modified
	if (not _config.characters or len(_config.characters) == 0) and character_list:
		_config.characters = character_list.keys()
		modified = true

	if modified:
		ResourceSaver.save(_config, CONFIG_PATH)


func _menu_state_transition(state: MenuState) -> void:
	if _menu_state == state: return
	_menu_state = state

	_debug_buttons.visible = false
	if _menu_state == MenuState.MAIN_MENU:
		_main_menu.visible = true
		_settings_menu.locked = false
		_settings_menu.visible = false
	elif _menu_state == MenuState.MAIN_MENU_SETTINGS:
		_main_menu.visible = false
		_settings_menu.locked = false
		_settings_menu.visible = true
	elif _menu_state == MenuState.STARTED:
		_main_menu.visible = false
		_settings_menu.locked = true
		_settings_menu.visible = false
	elif _menu_state == MenuState.STARTED_SETTINGS:
		_main_menu.visible = false
		_settings_menu.locked = true
		_settings_menu.visible = true


func _on_config_changed() -> void:
	_update_config()
	ResourceSaver.save(_config, CONFIG_PATH)


func _on_main_menu_exit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_settings_pressed() -> void:
	_menu_state_transition(MenuState.MAIN_MENU_SETTINGS)


func _on_main_menu_start_pressed() -> void:
	_menu_state_transition(MenuState.STARTED)
	_update_config()
	_twitch_client.enabled = true


func _on_settings_menu_close_pressed() -> void:
	if _menu_state == MenuState.MAIN_MENU_SETTINGS:
		_menu_state_transition(MenuState.MAIN_MENU)
	elif _menu_state == MenuState.STARTED_SETTINGS:
		_menu_state_transition(MenuState.STARTED)


func _update_camera_zoom() -> void:
	if not _camera_3d: return

	if _camera_size_default == 0: _camera_size_default = _camera_3d.size

	var length := CAMERA_ZOOM_MAX - CAMERA_ZOOM_MIN
	var current := camera_zoom - CAMERA_ZOOM_MIN
	var zoom := length - current + CAMERA_ZOOM_MIN

	var size := _camera_size_default * zoom
	_camera_3d.size = size
	_camera_3d.global_position.y = size * 0.5

	var spawn_x := size - SPAWN_X_PADDING
	_spawn_left.global_position = Vector3(-spawn_x, size, _spawn_left.global_position.z)
	_spawn_right.global_position = Vector3(spawn_x, size, _spawn_right.global_position.z)
	_character_manager.reset_characters()


func _update_config() -> void:
	camera_zoom = float(_config.display_scale) / 100.0
	_character_manager.characters = _config.characters
	_character_manager.enable_label_color = _config.user_color
	_character_manager.user_timeout = _config.user_timeout
	_twitch_client.channel = _config.channel


func set_camera_zoom(value: float) -> void:
	value = clampf(value, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)
	if camera_zoom == value: return

	camera_zoom = value
	_update_camera_zoom()
