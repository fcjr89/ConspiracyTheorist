extends Node
# Data class for each combatant
# Used by BattleManager

class_name Battler

var name := "?"
var hp := 100
var max_hp := 100
var power := 10
var defense := 5
var speed := 10
var atb := 0.0
var is_player := false
var alive := true

func take_damage(amount: int) -> void:
	"""Reduce HP and check for knockout"""
	hp = max(0, hp - amount)
	if hp == 0:
		alive = false
		print("%s has been defeated!" % name)

func heal(amount: int) -> void:
	"""Restore HP"""
	hp = min(max_hp, hp + amount)
	print("%s recovered %d HP" % [name, amount])

func get_hp_percent() -> float:
	"""Return HP as percentage (for UI bars)"""
	return float(hp) / float(max_hp)

func get_atb_percent() -> float:
	"""Return ATB as percentage (for UI bars)"""
	return min(atb / 100.0, 1.0)
