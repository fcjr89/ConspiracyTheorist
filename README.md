# ISLIP: VERTICAL SLICE

## What This Is
A **playable 30-60 minute opening** of your story game, built in Godot 4 with:
- **Top-down movement** (Chrono Trigger style)
- **Real-time ATB combat** (Final Fantasy VII formula)
- **Data-driven dialogue system** (JSON-based, easily expandable)
- **Multi-controller support** (keyboard + Xbox/PS/Switch Pro)
- **Save/load system** (persists game state)

## Files Included

### Core Scripts (res://scripts/)
- **Game.gd** - Global singleton for game state, scene switching
- **SaveManager.gd** - Save/load game data to disk
- **Player.gd** - Player movement, sprite animation, direction handling
- **Interact.gd** - Detects nearby NPCs, handles interact input
- **DialogueSystem.gd** - Dialogue parser and flow manager
- **NPC.gd** - Template for all NPCs (dialogue + quests)
- **BattleTrigger.gd** - Area that initiates combat
- **BattleManager.gd** - ATB combat engine (core mechanics)
- **Battler.gd** - Individual character/enemy data class

### Data Files (res://data/)
- **prologue.json** - Intro dialogue (Narrator → McKenna → Frankie)
- **chapter1.json** - Quest tracking (Defend the Weak, Burger Joint)

### Scene Guides
- **SCENE_SETUP_GUIDE.md** - Exact node hierarchies for each scene
- **InputMap_Setup.txt** - Input mapping reference

---

## QUICK START (10 MINUTES)

### 1. Godot Project Setup
```
1. Open Godot 4.x
2. New Project → Mobile Renderer, Git enabled
3. Create folder structure from SCENE_SETUP_GUIDE.md
```

### 2. Add Scripts
```
Copy all .gd files into res://scripts/ (organized in subfolders)
Copy all .json files into res://data/ (organized in subfolders)
```

### 3. Configure AutoLoads
```
Project Settings → AutoLoad
- Game: res://scripts/core/Game.gd
- DialogueManager: res://scripts/dialogue/DialogueSystem.gd
- SaveManager: res://scripts/core/SaveManager.gd
```

### 4. Set Input Map
```
Project Settings → Input Map
Add these actions:
- move_left, move_right, move_up, move_down
- interact, menu_pause, battle_confirm, battle_cancel

See InputMap_Setup.txt for full mapping
```

### 5. Create Scenes
```
Using SCENE_SETUP_GUIDE.md:
- res://scenes/world/Prologue.tscn
- res://scenes/battle/BattleScene.tscn
- res://scenes/ui/DialogueBox.tscn
```

### 6. Test
```
Run Prologue.tscn
- WASD/Arrows to move
- E to talk to NPCs
- Walk into red zone to start battle
- Watch combat in Output console
```

---

## ARCHITECTURE

### Scene Graph
```
Prologue (main world)
  ├─ Player (CharacterBody2D) - controlled by player
  ├─ McKenna (NPC) - talks, triggers dialogue
  ├─ BullyTrigger (Area2D) - collision zone for "Defend the Weak" quest
  └─ DialogueBox (UI) - shows text at bottom

BattleScene (combat)
  ├─ BattleManager - runs ATB loop
  └─ BattleUI - displays HP/ATB bars, log
```

### Data Flow
```
Player Interaction
  ↓
NPC.on_interact() called
  ↓
DialogueManager.start_dialogue(json_data)
  ↓
DialogueBox displays each line
  ↓
Player presses E/A to advance

Combat Trigger
  ↓
BattleTrigger._start_battle()
  ↓
Game.goto_scene("BattleScene.tscn")
  ↓
BattleManager._process() fills ATB bars
  ↓
Turn executes when ATB ≥ 100
  ↓
Victory/Defeat → return to Prologue
```

---

## GAMEPLAY LOOP

### Prologue Map
1. **Start** - Narrator introduces Islip/Bayshore
2. **Meet McKenna** - Talk to school guide, learn rules
3. **Encounter Bully** - Walk into trigger zone
4. **Battle** - ATB combat vs. bully (auto-attack only for now)
5. **Victory** - Quest "Defend the Weak" marked complete
6. **Respawn** - Return to Prologue map

### Next Chapter Hook
After victory, NPC dialogue could say:
> "There's a burger place down by the water. Safe spot."
> Quest "Find The All-American" → leads to McKennaSchool.tscn

---

## EXPANSION POINTS (TODO)

### Immediate (Session 2)
- [ ] Replace white-box sprites with your pixel art (16×32 Frankie)
- [ ] Create actual TileMap (school layout, streets, shops)
- [ ] Add more NPCs (copy NPC.gd, change dialogue_file)
- [ ] Expand dialogue with branching choices

### Short-term (Week 1)
- [ ] **Battle Menu** - Attack/Skill/Item/Defend options
- [ ] **Skill System** - read skills.json, let player choose moves
- [ ] **Limit Meter** - build up for special attacks
- [ ] **Multi-party** - add more members (Bear Jew, etc)
- [ ] **Enemy presets** - different bully types with stat variations

### Medium-term (Week 2+)
- [ ] **Save/Load UI** - menu for managing saves
- [ ] **Quest Journal** - display active quests
- [ ] **Healing system** - All-American serves healing items
- [ ] **Level progression** - exp/level-up system
- [ ] **Story flags** - gate content based on plot progress
- [ ] **Chapter 2 maps** - McKenna School, All-American, more encounters

---

## KEY SYSTEMS EXPLAINED

### ATB Combat (BattleManager.gd)
```
Each turn:
1. Fill ATB bars at (speed * fill_rate) per second
2. When ATB ≥ 100, add to turn_queue
3. Pop first actor from queue, execute their turn
4. Reset ATB to 0, repeat
5. Battle ends when party or enemies all dead
```

**Formula for damage:**
```
damage = random(8, 14) + attacker.power - target.defense
```

**Current behavior:** Auto-attack. Later you'll add:
- Menu prompt (Attack/Skill/Item/Defend)
- Skill selection from skills.json
- Multi-target vs single-target

### Dialogue System (DialogueSystem.gd)
```
1. Load JSON array of {speaker, text} objects
2. Show current line in DialogueBox
3. Player presses E/A → advance()
4. Emit dialogue_finished signal when done
5. Quest/flags can update mid-dialogue using callbacks
```

Example prologue.json:
```json
[
  {"speaker": "Narrator", "text": "Islip. Bayshore. The beginning."},
  {"speaker": "Frankie", "text": "New place... same rules."},
  {"speaker": "McKenna", "text": "Welcome to school."}
]
```

### Quest Tracking (Game.quest_state)
```
quest_state = {
  "defend_weak": {
    "progress": "completed",  // inactive / started / in_progress / completed
    "timestamp": 1234567890
  }
}
```

Quests persist across saves. Use `Game.get_quest_progress(id)` to gate content.

---

## TROUBLESHOOTING

### "Player doesn't move"
- Check Input Map has move_* actions bound to WASD/Arrows
- Check Player.gd is attached to Player node
- Check CharacterBody2D has a CollisionShape2D

### "Dialogue won't show"
- Check NPC.gd is attached to NPC node
- Check dialogue_file path is correct (res://data/dialogue/prologue.json)
- Check DialogueBox.gd is attached to DialogueBox UI
- Watch console for load errors

### "Battle doesn't start"
- Check BattleTrigger.gd is attached to battle trigger zone
- Check Area2D collision shapes are configured
- Check battle_id and quest_id are set in inspector
- Watch console: should print "Battle triggered: bully_encounter"

### "Battle output is silent"
- Check BattleManager.gd is attached to BattleManager node
- Open Godot Output console (View → Output)
- Combat messages print there (not UI yet)

---

## PIXEL ART REQUIREMENTS

For your 16×32 sprites:
- **Spritesheet layout** - 4 columns (directions) × 4 rows (frames)
  - Rows: down, up, left, right
  - Columns: frame 0-3 for each direction
  - Each cell: 16×32 pixels
  - Total sheet: 64×128 pixels

- **Import settings** in Godot:
  - Texture → Sprite Sheet mode (for Sprite2D animation later)
  - hframes: 4, vframes: 4

---

## NEXT MESSAGE
Once you have sprites and a TileMap, reply with:
1. What does Frankie look like? (description for pixel art reference)
2. Do you want McKenna School or All-American first?
3. Any battle mechanics you want to test before adding more NPCs?

This skeleton is rock-solid. You're not guessing anymore—every system connects.
