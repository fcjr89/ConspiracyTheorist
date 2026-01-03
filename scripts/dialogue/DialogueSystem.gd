extends Node
# Global dialogue manager
# Attach as AutoLoad: Name: DialogueManager
# Path: res://scripts/dialogue/DialogueSystem.gd

signal dialogue_started
signal dialogue_advanced
signal dialogue_finished

var current_dialogue := []
var current_index := 0
var is_active := false
var dialogue_box: Control

func _ready():
	add_to_group("Global")

func load_dialogue(path: String) -> Array:
	"""Load dialogue from JSON file"""
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to load dialogue: " + path)
		return []
	
	var json = JSON.new()
	var parsed = json.parse(file.get_as_text())
	if parsed == OK:
		return json.data as Array
	else:
		push_error("Failed to parse JSON: " + path)
		return []

func start_dialogue(dialogue_data: Array) -> void:
	"""Begin playing dialogue sequence"""
	current_dialogue = dialogue_data
	current_index = 0
	is_active = true
	dialogue_started.emit()
	_show_current_line()

func advance() -> void:
	"""Move to next dialogue line"""
	if not is_active:
		return
	
	current_index += 1
	if current_index >= current_dialogue.size():
		finish()
	else:
		_show_current_line()
	dialogue_advanced.emit()

func finish() -> void:
	"""End dialogue sequence"""
	is_active = false
	dialogue_finished.emit()

func _show_current_line() -> void:
	"""Display current dialogue line"""
	if current_index >= current_dialogue.size():
		return
	
	var line = current_dialogue[current_index]
	var speaker = line.get("speaker", "")
	var text = line.get("text", "")
	
	# For now, print to console (will hook to UI DialogueBox later)
	print("[%s] %s" % [speaker, text])
	
	# Emit data for UI to display
	if dialogue_box:
		dialogue_box.display_line(speaker, text)

func set_dialogue_box(box: Control) -> void:
	"""Assign the UI DialogueBox for rendering"""
	dialogue_box = box

func is_dialogue_active() -> bool:
	return is_active
