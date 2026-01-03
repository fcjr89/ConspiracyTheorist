extends Node
# Global save/load manager
# Attach as AutoLoad: Name: SaveManager
# Path: res://scripts/core/SaveManager.gd

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	"""Serialize and save game state"""
	var save_data = {
		"player_stats": Game.player_stats,
		"story_flags": Game.story_flags,
		"quest_state": Game.quest_state,
		"current_map": Game.current_map,
		"timestamp": Time.get_ticks_msec()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file")
		return
	
	var json = JSON.stringify(save_data)
	file.store_string(json)
	print("Game saved to: %s" % SAVE_PATH)

func load_game() -> bool:
	"""Load saved game state"""
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to load save file")
		return false
	
	var json = JSON.new()
	var parsed = json.parse(file.get_as_text())
	
	if parsed == OK:
		var data = json.data as Dictionary
		Game.player_stats = data.get("player_stats", {})
		Game.story_flags = data.get("story_flags", {})
		Game.quest_state = data.get("quest_state", {})
		Game.current_map = data.get("current_map", "")
		print("Game loaded successfully")
		return true
	else:
		push_error("Failed to parse save file")
		return false

func has_save() -> bool:
	"""Check if save file exists"""
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	"""Delete save file (for new game)"""
	if FileAccess.file_exists(SAVE_PATH):
		var err = DirAccess.remove_absolute(SAVE_PATH)
		if err == OK:
			print("Save file deleted")
		else:
			push_error("Failed to delete save file")
