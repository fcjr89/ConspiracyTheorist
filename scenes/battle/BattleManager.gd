extends Node
# Attach to BattleManager node in BattleScene.tscn
# This handles all ATB combat logic

class_name BattleManager

signal turn_started(battler: Battler)
signal turn_finished
signal battle_over(player_won: bool)

@export var atb_fill_rate := 25.0  # how fast ATB bars fill
@export var base_damage_range := Vector2i(8, 14)  # base attack variance

var party: Array[Battler] = []
var enemies: Array[Battler] = []
var turn_queue: Array[Battler] = []
var current_actor: Battler = null
var battle_active := false

func _ready():
	setup_test_battle()
	battle_active = true

func setup_test_battle() -> void:
	"""TEMP: spawn player + one bully for testing"""
	var p = Battler.new()
	p.name = "Frankie"
	p.max_hp = 120
	p.hp = 120
	p.power = 10
	p.defense = 6
	p.speed = 10
	p.is_player = true
	
	var e = Battler.new()
	e.name = "Bully"
	e.max_hp = 80
	e.hp = 80
	e.power = 7
	e.defense = 4
	e.speed = 8
	e.is_player = false
	
	party = [p]
	enemies = [e]

func _process(dt):
	if not battle_active:
		return
	
	# Fill ATB bars
	for b in party + enemies:
		if not b.alive:
			continue
		b.atb += (b.speed * atb_fill_rate) * dt
		if b.atb >= 100.0 and not turn_queue.has(b):
			turn_queue.append(b)
	
	# Execute turns in order
	if turn_queue.size() > 0:
		var actor = turn_queue.pop_front()
		if actor.alive:
			current_actor = actor
			actor.atb = 0.0
			_execute_turn(actor)
			turn_finished.emit()
	
	# Check battle end
	if _is_battle_over():
		_end_battle()

func _execute_turn(actor: Battler) -> void:
	"""Perform actor's turn"""
	turn_started.emit(actor)
	
	if actor.is_player:
		# Player: basic attack for now (will add menu later)
		_basic_attack(actor, enemies)
	else:
		# Enemy: simple AI - attack random party member
		_basic_attack(actor, party)

func _basic_attack(attacker: Battler, targets: Array[Battler]) -> void:
	"""Execute basic attack"""
	var target = _get_random_alive(targets)
	if target == null:
		return
	
	var damage = randi_range(base_damage_range.x, base_damage_range.y)
	damage = max(1, damage + attacker.power - target.defense)
	
	target.take_damage(damage)
	
	print("%s attacks %s for %d damage! (%d/%d HP)" % [
		attacker.name, target.name, damage, target.hp, target.max_hp
	])

func _get_random_alive(targets: Array[Battler]) -> Battler:
	"""Get random alive target"""
	var alive = targets.filter(func(b): return b.alive)
	if alive.size() > 0:
		return alive[randi() % alive.size()]
	return null

func _get_first_alive(targets: Array[Battler]) -> Battler:
	"""Get first alive target"""
	for b in targets:
		if b.alive:
			return b
	return null

func _is_battle_over() -> bool:
	"""Check if battle end condition met"""
	var party_alive = _get_first_alive(party) != null
	var enemy_alive = _get_first_alive(enemies) != null
	return (not party_alive) or (not enemy_alive)

func _end_battle() -> void:
	"""Resolve battle outcome"""
	battle_active = false
	var player_won = (_get_first_alive(enemies) == null)
	
	if player_won:
		print("=== VICTORY ===")
		Game.update_quest("defend_weak", "completed")
	else:
		print("=== DEFEAT ===")
	
	battle_over.emit(player_won)
	await get_tree().create_timer(2.0).timeout
	Game.goto_scene("res://scenes/world/Prologue.tscn")
