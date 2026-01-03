extends Area2D
# Attach to an Area2D child of Player named "InteractArea"
# This detects nearby NPCs/interactables

var nearby_interactables := []

func _ready():
	# Connect area signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
	"""Track when interactable enters range"""
	if area.is_in_group("Interactable"):
		nearby_interactables.append(area)

func _on_area_exited(area: Area2D):
	"""Remove when interactable leaves range"""
	if area.is_in_group("Interactable"):
		nearby_interactables.erase(area)

func _process(_dt):
	"""Check for interact input"""
	if Input.is_action_just_pressed("interact") and nearby_interactables.size() > 0:
		# Interact with closest/first interactable
		var target = nearby_interactables[0]
		if target.has_method("on_interact"):
			target.on_interact()

func get_nearby_count() -> int:
	"""Returns count of nearby interactables (for UI feedback)"""
	return nearby_interactables.size()
