extends Area2D
# Attach to NPC nodes in scenes
# Set @export variables in editor per NPC

class_name NPC

@export var npc_name := "NPC"
@export var dialogue_file := "res://data/dialogue/prologue.json"
@export var quest_id := ""  # optional quest trigger

var has_interacted := false
var player_in_range := false

func _ready():
	add_to_group("Interactable")
	area_entered.connect(_on_player_enter)
	area_exited.connect(_on_player_exit)

func _on_player_enter(area):
	if area.is_in_group("Player") or area.name == "Player":
		player_in_range = true

func _on_player_exit(area):
	if area.is_in_group("Player") or area.name == "Player":
		player_in_range = false

func on_interact():
	"""Called when player presses interact button"""
	if not DialogueManager.is_dialogue_active():
		var dialogue = DialogueManager.load_dialogue(dialogue_file)
		if dialogue.size() > 0:
			DialogueManager.start_dialogue(dialogue)
			
			# Update quest if this NPC triggers one
			if quest_id:
				Game.update_quest(quest_id, "started")

func show_interaction_prompt():
	"""Optional: show "Press E" indicator above NPC"""
	pass  # Hook this to a visual indicator later
