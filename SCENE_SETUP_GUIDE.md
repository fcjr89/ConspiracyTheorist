# GODOT SCENE STRUCTURE GUIDE
# Copy these node hierarchies into your .tscn files

## SCENE 1: res://scenes/world/Prologue.tscn
# This is the opening map where Frankie meets McKenna

Prologue (Node2D)
├── TileMap (TileMap)
│   └── [Load your tileset here]
├── Player (CharacterBody2D) *CRITICAL*
│   ├── Sprite2D
│   │   └── texture: [your 16x32 spritesheet]
│   │   └── hframes: 4
│   │   └── vframes: 4
│   ├── CollisionShape2D
│   │   └── shape: CapsuleShape2D (16w × 24h)
│   ├── InteractArea (Area2D)
│   │   ├── CollisionShape2D
│   │   │   └── shape: CircleShape2D (radius: 40)
│   │   └── [Attach Interact.gd script]
│   └── [Attach Player.gd script]
├── McKenna (Area2D) *NPC*
│   ├── Sprite2D
│   │   └── texture: [McKenna spritesheet]
│   ├── CollisionShape2D
│   │   └── shape: CircleShape2D (radius: 20)
│   └── [Attach NPC.gd script]
│       └── npc_name: "McKenna"
│       └── dialogue_file: "res://data/dialogue/prologue.json"
├── BullyTrigger (Area2D) *BATTLE TRIGGER*
│   ├── CollisionShape2D
│   │   └── shape: RectangleShape2D (200w × 100h)
│   └── [Attach BattleTrigger.gd script]
│       └── battle_id: "bully_encounter"
│       └── quest_id: "defend_weak"
└── HUD (CanvasLayer)
    └── [Attach DialogueBox.tscn here - see below]

---

## SCENE 2: res://scenes/ui/DialogueBox.tscn
# Displays dialogue at bottom of screen

DialogueBox (CanvasLayer)
├── Control
│   ├── ColorRect [Background]
│   │   └── color: black (semi-transparent)
│   │   └── custom_minimum_size: (640, 120)
│   │   └── anchor_bottom: 1.0
│   │   └── margin_top: -120
│   ├── VBoxContainer
│   │   ├── Label [Speaker]
│   │   │   └── text: "[NPC Name]"
│   │   │   └── add_theme_font_size_override/font_size: 20
│   │   ├── Label [Dialogue Text]
│   │   │   └── text: "[Dialogue line]"
│   │   │   └── custom_minimum_size: (600, 60)
│   │   │   └── autowrap_mode: WORD_WRAP
│   │   │   └── add_theme_font_size_override/font_size: 16
│   │   └── Label [Prompt]
│   │       └── text: "[Press E or A to continue]"
│   │       └── add_theme_font_size_override/font_size: 12
│   │       └── alignment: RIGHT
│   └── [Attach DialogueBox.gd script - see below]

DialogueBox.gd script content:
```gdscript
extends Control

@onready var speaker_label = $VBoxContainer/Label
@onready var text_label = $VBoxContainer/Label2
@onready var prompt_label = $VBoxContainer/Label3

func _ready():
	DialogueManager.set_dialogue_box(self)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	hide()

func display_line(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	text_label.text = text
	show()

func _process(_dt):
	if Input.is_action_just_pressed("interact"):
		DialogueManager.advance()

func _on_dialogue_finished():
	hide()
```

---

## SCENE 3: res://scenes/battle/BattleScene.tscn
# Where ATB combat happens

BattleScene (Node)
├── BattleManager (Node)
│   └── [Attach BattleManager.gd script]
├── BattleUI (CanvasLayer)
│   ├── ColorRect [Background - battle field]
│   │   └── color: dark (your battle background)
│   ├── Label [Enemy Name + HP]
│   │   └── position: (500, 50)
│   │   └── text: "Bully - 80/80 HP"
│   ├── ProgressBar [Enemy ATB]
│   │   └── position: (500, 100)
│   │   └── min_value: 0
│   │   └── max_value: 100
│   ├── Label [Player Name + HP]
│   │   └── position: (50, 200)
│   │   └── text: "Frankie - 120/120 HP"
│   ├── ProgressBar [Player ATB]
│   │   └── position: (50, 250)
│   └── Label [Battle Log]
│       └── position: (320, 400)
│       └── text: "[Combat messages print here]"

IMPORTANT: BattleScene automatically runs when called.
Output Console shows: "[Frankie] attacks Bully for 12 damage!"

---

## FOLDER STRUCTURE TO CREATE IN res://

res://
├── scenes/
│   ├── world/
│   │   ├── Prologue.tscn
│   │   ├── McKennaSchool.tscn
│   │   └── AllAmerican.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   └── DialogueBox.tscn
│   └── battle/
│       └── BattleScene.tscn
├── scripts/
│   ├── core/
│   │   ├── Game.gd
│   │   └── SaveManager.gd
│   ├── player/
│   │   ├── Player.gd
│   │   └── Interact.gd
│   ├── dialogue/
│   │   └── DialogueSystem.gd
│   ├── quests/
│   │   └── QuestSystem.gd [optional, future]
│   ├── battle/
│   │   ├── BattleManager.gd
│   │   ├── Battler.gd
│   │   └── Skills.gd [optional, future]
│   ├── npcs/
│   │   ├── NPC.gd
│   │   └── BattleTrigger.gd
│   └── ui/
│       └── DialogueBox.gd
└── data/
    ├── dialogue/
    │   └── prologue.json
    ├── quests/
    │   └── chapter1.json
    └── skills/
        └── skills.json [optional, future]

---

## SETUP CHECKLIST (DO THIS IN GODOT)

1. Create new Godot 4.x project (Mobile renderer) ✓
2. Create folder structure above
3. Copy all .gd scripts into res://scripts/ folders
4. Copy JSON files into res://data/ folders
5. **Project Settings → AutoLoad:**
   - Add Game (res://scripts/core/Game.gd)
   - Add DialogueManager (res://scripts/dialogue/DialogueSystem.gd)
   - Add SaveManager (res://scripts/core/SaveManager.gd)
6. **Project Settings → Input Map:**
   - Add all actions from InputMap_Setup.txt
7. Create scenes (Prologue.tscn, BattleScene.tscn) with node hierarchies above
8. Attach scripts to nodes as indicated
9. Run Prologue.tscn - you should be able to walk around with WASD
10. Press E near McKenna - dialogue prints to console
11. Walk into BullyTrigger zone - battle starts
12. Watch ATB combat in Output console

---

## NEXT STEPS (AFTER TESTING)

1. **Replace test sprites** - add your pixel art (16x32 for Frankie, etc)
2. **Create TileMap** - your school/town layout
3. **Add more NPCs** - duplicate McKenna.tscn, change dialogue_file
4. **Expand battle UI** - progress bars, battle menu (Attack/Skill/Item/Defend)
5. **Add more scenes** - McKennaSchool.tscn, AllAmerican.tscn (burger joint)
6. **Implement Skills system** - read skills.json, let players choose attacks

This is your playable skeleton. The bones are connected - just add meat.
