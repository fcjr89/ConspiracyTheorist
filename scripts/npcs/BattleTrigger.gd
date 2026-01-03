extends Area2D
# Attach to trigger zones that initiate battles
# Place in Prologue scene where bully roams

class_name BattleTrigger

@export var battle_id := "bully_encounter"
@export var enemy_preset := "bully_1"  # which enemies spawn
@export var quest_id := "defend_weak"
@export var one_time := true  # only trigger once

var has_triggered := false

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	"""Trigger battle when player touches this zone"""
	if has_triggered and one_time:
		return
	
	if area.name == "Player" or area.is_in_group("Player"):
		has_triggered = true
		_start_battle()

func _start_battle() -> void:
	"""Initiate combat encounter"""
	print("Battle triggered: %s" % battle_id)
	
	# Update quest
	if quest_id:
		Game.update_quest(quest_id, "in_progress")
	
	# Switch to battle scene
	Game.goto_scene("res://scenes/battle/BattleScene.tscn")
