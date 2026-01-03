extends Area2D

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if triggered:
		return
	if body is CharacterBody2D and body.name == "Player":
		triggered = true
		Game.goto_scene("res://scenes/battle/BattleScene.tscn")
