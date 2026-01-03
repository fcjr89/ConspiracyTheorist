extends Node

# Global game state singleton
# Attach this as AutoLoad in Project Settings → AutoLoad
# Name: Game
# Path: res://scripts/core/Game.gd

var player_stats := {
	"name": "Frankie",
	"hp": 120,
	"max_hp": 120,
	"power": 10,
	"defense": 6,
	"speed": 10
}

var story_flags := {}        # story progression flags
var quest_state := {}        # quest progress tracking
var current_map := ""        # track which map player is on
var last_spawn_pos := Vector2.ZERO  # respawn after battle

func _ready():
	# Make this persist across scenes
	if not is_node_in_group("Global"):
		add_to_group("Global")

func goto_scene(path: String, spawn_pos: Vector2 = Vector2.ZERO) -> void:
	"""Change scene and optionally set spawn position"""
	last_spawn_pos = spawn_pos
	get_tree().change_scene_to_file(path)

func set_flag(flag: String, value: bool = true) -> void:
	"""Set a story flag"""
	story_flags[flag] = value

func has_flag(flag: String) -> bool:
	"""Check if flag is set"""
	return story_flags.get(flag, false)

func update_quest(quest_id: String, progress: String) -> void:
	"""Update quest progress"""
	if not quest_id in quest_state:
		quest_state[quest_id] = {}
	quest_state[quest_id]["progress"] = progress
	quest_state[quest_id]["timestamp"] = Time.get_ticks_msec()

func get_quest_progress(quest_id: String) -> String:
	"""Get quest current status"""
	return quest_state.get(quest_id, {}).get("progress", "inactive")
