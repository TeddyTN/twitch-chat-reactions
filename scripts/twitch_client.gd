class_name TwitchClient
extends Node


signal chat_message(username: String, text: String, tags: Dictionary[String, PackedStringArray])

enum ConnectionState {
	INVALID = -1,
	CONNECTING = 0,
	CAP = 1,
	LOGIN = 2,
	JOINING = 3,
	JOINED = 4,
	DISCONNECTED = 5,
}

const CAP_SUCCESS_CODES := ["ACK"]
const LOGIN_SUCCESS_CODES := ["001", "002", "003", "004", "372", "375", "376"]
const JOIN_SUCCESS_CODES := ["535", "366"]
const TAG_COLOR := "color"
const TAG_DISPLAY_NAME := "display-name"
const TAG_HANDLE := "handle"
const WEBSOCKET_URL = "wss://irc-ws.chat.twitch.tv:443"

@export var ignore_users: Array[String] = []
@export var nick := "justinfan12345"

var _socket := WebSocketPeer.new()
var _state := ConnectionState.DISCONNECTED

var channel: String
var enabled: bool : set = _set_enabled


static func get_tag(tags: Dictionary[String, PackedStringArray], tag_name: String, default_value := "") -> String:
	if tag_name in tags and not tags[tag_name].is_empty(): return tags[tag_name][0]

	return default_value


func _process(_delta: float) -> void:
	_socket.poll()

	var state := _socket.get_ready_state()
	if state == WebSocketPeer.STATE_CONNECTING:
		_state = ConnectionState.CONNECTING
	elif state == WebSocketPeer.STATE_OPEN:
		_handle_connection()
	elif state == WebSocketPeer.STATE_CLOSING:
		_state = ConnectionState.DISCONNECTED
	elif state == WebSocketPeer.STATE_CLOSED:
		_connect()


func _connect() -> void:
	if not enabled: return

	if channel.is_empty():
		push_error("Channel is not configured.")
		_state = ConnectionState.INVALID
		set_process(false)
		return

	if _socket.connect_to_url(WEBSOCKET_URL) == OK:
		print("Connect to: %s" % WEBSOCKET_URL)
	else:
		push_error("Unable to connect.")
		set_process(false)


func _handle_chat_messages(messages: PackedStringArray) -> void:
	for message in messages:
		var message_index := message.find(" PRIVMSG ")
		if message_index == -1: continue

		var tags := {}
		var tags_index := _parse_tags(message, tags)

		var index := message.find("!", tags_index)
		var username := message.substr(tags_index + 1, index - tags_index - 1)
		var text := message.substr(message.find(":", message_index) + 1)

		if username == channel or ignore_users.any(func(user: String): return user == username): continue

		tags[TAG_HANDLE] = [username]
		username = TwitchClient.get_tag(tags, TAG_DISPLAY_NAME, username)

		chat_message.emit(username, text, tags)


func _handle_connection() -> void:
	if _state == ConnectionState.CONNECTING:
		print("Request capabilities")
		_send_command("CAP", ["REQ", ":twitch.tv/tags"])
		_state = ConnectionState.CAP
		return

	var messages := _read_messages()
	if len(messages) == 0:
		return

	if _state == ConnectionState.CAP:
		if _state_transition(CAP_SUCCESS_CODES, messages, ConnectionState.LOGIN):
			print("Login as: %s" % nick)
			_send_command("NICK", [nick])
		else:
			push_error("Failed to request capabilities")
	elif _state == ConnectionState.LOGIN:
		if _state_transition(LOGIN_SUCCESS_CODES, messages, ConnectionState.JOINING):
			print("Join channel: %s" % channel)
			_send_command("JOIN", ["#%s" % channel])
		else:
			push_error("Login failed")
	elif _state == ConnectionState.JOINING:
		if _state_transition(JOIN_SUCCESS_CODES, messages, ConnectionState.JOINED):
			print("Ready")
		else:
			push_error("Failed to join")
	elif _state == ConnectionState.JOINED:
		_handle_chat_messages(messages)
	else:
		print("Handle connection: State(%d)" % _state)
		for message in messages:
			print("< Got text data from server: %s" % message)


func _parse_tags(message: String, tags: Dictionary[String, PackedStringArray]) -> int:
	if not message.begins_with("@"): return 0

	var index := 1
	var last := false

	while index < len(message):
		if last: return index

		var end_index = message.find(";", index)
		if end_index == -1:
			end_index = message.find(" ", index)
			last = true

		if end_index == -1: break

		var tag := message.substr(index, end_index - index)
		index = end_index + 1

		var eq_index = tag.find("=")
		if eq_index == -1: continue

		var tag_name := tag.substr(0, eq_index)
		var tag_value := tag.substr(eq_index + 1)
		if tag_value == "": continue

		if tag_name in tags:
			tags[tag_name].append(tag_value)
		else:
			tags[tag_name] = PackedStringArray([tag_value])

	return index


func _read_messages() -> PackedStringArray:
	var list := PackedStringArray([])
	while _socket.get_available_packet_count() > 0:
		var packet = _socket.get_packet()
		if _socket.was_string_packet():
			var messages := packet.get_string_from_utf8().split("\r\n")
			for message in messages:
				message = message.strip_edges()
				if message.begins_with("PING "):
					_send_command("PONG", [message.substr(5)])
				elif not message == "":
					list.append(message)
		else:
			print("< Got binary data from server: %d bytes" % packet.size())
	return list


func _send_command(command: String, args: Array = []):
	var line := "%s %s" % [command, " ".join(args)]
	_socket.send_text("%s\r\n" % line.strip_edges())


func _set_enabled(value: bool) -> void:
	if enabled == value: return

	enabled = value
	if not enabled:
		_socket.close()


func _state_transition(codes: Array, messages: PackedStringArray, state: ConnectionState) -> bool:
	for message in messages:
		if codes.any(func(code): return message.contains(code)):
			_state = state
			return true

	print(messages)
	_state = ConnectionState.INVALID
	return false
