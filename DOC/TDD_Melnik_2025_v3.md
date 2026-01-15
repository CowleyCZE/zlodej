# TECHNICAL DESIGN DOCUMENT - ZLODĚJ MĚLNÍK
## VERZE 3.0 - MĚLNÍK 2025 | Technická Architektura

**Projekt**: Zloděj Mělník  
**Engine**: Godot 4.3+ (GDScript)  
**Cílový hardware**: Android (Vulkan Mobile), iPad (iOS)  
**Obsah**: Kompletní technická architektura, systémy, datové modely

---

## 1. ARCHITEKTURA SYSTÉMU

### 1.1 Core Engine Architecture

Hra je postavena na **Event-Driven Architecture** s modulární strukturou:

```
┌─────────────────────────────────────────────────────────────┐
│                     GAME MANAGER (FSM)                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ State: MENU | ADVENTURE | PLANNING | ACTION | RESULTS │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
  ┌──────────┐       ┌──────────┐       ┌──────────┐
  │ Adventure│       │ Planning │       │  Action  │
  │ Manager  │       │ Manager  │       │  Engine  │
  └──────────┘       └──────────┘       └──────────┘
       ↓                   ↓                   ↓
  ┌──────────┐       ┌──────────┐       ┌──────────┐
  │Event Bus │ ←────→│Event Bus │ ←────→│Event Bus │
  └──────────┘       └──────────┘       └──────────┘
        ↓                   ↓                   ↓
  ┌──────────────────────────────────────────────────────┐
  │        SAVE MANAGER | DATA PERSISTENCE               │
  └──────────────────────────────────────────────────────┘
```

### 1.2 Hlavní Singletony (Autoloads)

**GameManager.gd**:
```gdscript
class_name GameManager
extends Node

enum GameState {MENU, ADVENTURE, PLANNING, ACTION, RESULTS}
var current_state: GameState = GameState.MENU
var player_name: String = ""
var current_mission: MissionData = null
```

**EventBus.gd**:
```gdscript
class_name EventBus
extends Node

signal adventure_started(mission: MissionData)
signal planning_activated(mission: MissionData)
signal action_phase_started(plan: PlanningData)
signal mission_completed(success: bool, rank: String)
signal heat_level_changed(new_level: float)
signal reputation_changed(new_reputation: int)
```

**SaveManager.gd**:
```gdscript
class_name SaveManager
extends Node

func save_game() -> bool:
    var save_data = {
        "player_name": GameState.player_name,
        "adventure_state": AdventureState.serialize(),
        "money": GameState.money,
        "reputation": GameState.reputation,
        "heat_levels": GameState.heat_levels,
        "timestamp": Time.get_ticks_msec()
    }
    var encrypted = _aes_256_encrypt(JSON.stringify(save_data))
    var file = FileAccess.open("user://melnik_save.dat", FileAccess.WRITE)
    file.store_string(encrypted)
    return true
```

**AdventureManager.gd**:
```gdscript
class_name AdventureManager
extends Node

var current_location: String
var available_characters: Array[CharacterData]
var hired_characters: Array[CharacterData]
var current_mission: MissionData

func _ready():
    EventBus.adventure_started.connect(_on_adventure_started)
    _load_melnik_map()

func _load_melnik_map():
    # Načtení lokací Mělníka 2025
    var locations = {
        "u_cerneho_orla": LocationData.new(),
        "cafe_vltava": LocationData.new(),
        "stanice_melnik": LocationData.new(),
        # ... atd.
    }
```

**PlanningManager.gd**:
```gdscript
class_name PlanningManager
extends Node

var current_plan: PlanningData
var timeline_duration: float = 600.0  # 10 minut
var validation_errors: Array = []

func validate_plan() -> bool:
    validation_errors.clear()
    _check_collisions()
    _check_detection()
    _check_noise_levels()
    _check_skill_availability()
    return validation_errors.is_empty()

func _check_collisions():
    # Detekce kolizí postav v čase
    for i in range(current_plan.characters.size()):
        for j in range(i + 1, current_plan.characters.size()):
            var char1 = current_plan.characters[i]
            var char2 = current_plan.characters[j]
            for time_step in range(0.1, timeline_duration, 0.1):
                var pos1 = char1.get_position_at_time(time_step)
                var pos2 = char2.get_position_at_time(time_step)
                if pos1.distance_to(pos2) < 1.0:
                    validation_errors.append({
                        "type": "COLLISION",
                        "char1": char1.name,
                        "char2": char2.name,
                        "time": time_step
                    })
```

---

## 2. DATOVÉ MODELY

### 2.1 CharacterData

```gdscript
class_name CharacterData
extends Resource

# Identita
var name: String
var age: int
var description: String

# Dovednosti (0-100)
var driving: int = 50
var lock_picking: int = 50
var electronics: int = 50
var stealth: int = 50
var strength: int = 50

# Osobnostní rysy (0-100)
var greed: float = 50.0       # Jak moc si vezme
var loyalty: float = 50.0      # Zůstane s vámi?
var nerves: float = 50.0       # Stabilita pod tlakem
var dexterity: float = 50.0    # Obratnost

# Stav
var is_hired: bool = false
var is_injured: bool = false
var injury_level: float = 0.0  # 0-1.0
var fatigue: float = 0.0
var stress: float = 0.0

# Finanční
var hiring_cost: float = 5000.0
var current_role: String  # "driver", "hacker", "thief"
var expected_payment: float = 0.0
var satisfaction: float = 0.0  # Ovlivňuje loajalitu
```

### 2.2 MissionData

```gdscript
class_name MissionData
extends Resource

# Identifikace
var mission_id: String
var name: String
var description: String
var briefing: String

# Lokace
var target_location: String  # "bank_melnik", "private_house", atd.
var building_layout: Dictionary  # Architektura

# Cíl
var objective_type: String  # "steal_money", "steal_item", "collect_data"
var objective_item: String
var objective_value: float

# Zabezpečení
var guard_count: int = 2
var camera_count: int = 2
var alarm_system: bool = true
var biometric_locks: bool = false

# Informace
var intel_categories: Dictionary = {
    "architecture": 0.0,      # 0-100%
    "guard_patrols": 0.0,
    "security_systems": 0.0,
    "treasure_location": 0.0,
    "alternate_routes": 0.0
}

var intel_gathered: float = 0.0  # Procento

# Odměny
var base_reward: float = 20000.0
var reputation_gain: int = 20
var difficulty_stars: int = 2  # 1-5 hvězdiček
```

### 2.3 PlanningData

```gdscript
class_name PlanningData
extends Resource

var mission_id: String
var characters: Array[CharacterData] = []
var timeline_duration: float = 600.0
var character_plans: Dictionary = {}  # character_id -> CharacterPlan

class CharacterPlan:
    var character: CharacterData
    var waypoints: Array[TimelineWaypoint] = []
    var actions: Array[TimelineAction] = []

class TimelineWaypoint:
    var position: Vector2
    var time: float
    var speed: float  # 1.0 = chůze, 2.0 = běh, 0.5 = plížení

class TimelineAction:
    var time: float
    var type: String  # "MOVE", "WAIT", "INTERACT", "RADIO", "TAKE_LOOT"
    var duration: float
    var target_id: String  # ID zámku, trezoru, atd.
    var required_skill: String  # "lock_picking", "electronics"
    var success_rate: float  # 0.0-1.0
```

---

## 3. ADVENTURE MODE SYSTÉMY

### 3.1 IntelligenceGatheringSystem

```gdscript
class_name IntelligenceGatheringSystem
extends Node

func gather_intel(method: String, mission: MissionData) -> float:
    var intel_gained = 0.0
    var heat_increase = 0
    
    match method:
        "physical_reconnaissance":
            intel_gained = randf_range(0.05, 0.15)
            heat_increase = 5
        "buy_floorplans":
            intel_gained = 0.20
            heat_increase = 2
            GameState.money -= 2000
        "insider_conversation":
            intel_gained = 0.15
            heat_increase = 3
            GameState.money -= 1000
        "hacking":
            intel_gained = 0.20
            heat_increase = 10
    
    mission.intel_gathered += intel_gained
    mission.intel_gathered = clamp(mission.intel_gathered, 0.0, 1.0)
    GameState.heat_levels["melnik"] += heat_increase
    
    return intel_gained
```

### 3.2 RecruitmentSystem

```gdscript
class_name RecruitmentSystem
extends Node

var all_available_characters: Array[CharacterData] = []

func _ready():
    _initialize_melnik_characters()

func _initialize_melnik_characters():
    # Josef Novák
    var josef = CharacterData.new()
    josef.name = "Josef \"Pepík\" Novák"
    josef.age = 41
    josef.driving = 90
    josef.loyalty = 50
    josef.greed = 85
    josef.hiring_cost = 5000.0
    all_available_characters.append(josef)
    
    # Petra Svobodová
    var petra = CharacterData.new()
    petra.name = "Petra \"Tříska\" Svobodová"
    petra.age = 28
    petra.electronics = 95
    petra.loyalty = 80
    petra.greed = 40
    petra.hiring_cost = 8000.0
    all_available_characters.append(petra)
    
    # Milan Kovářík
    var milan = CharacterData.new()
    milan.name = "Milan \"Grizzly\" Kovářík"
    milan.age = 55
    milan.strength = 100
    milan.loyalty = 40
    milan.greed = 90
    milan.hiring_cost = 6000.0
    all_available_characters.append(milan)

func hire_character(character: CharacterData) -> bool:
    if GameState.money >= character.hiring_cost:
        GameState.money -= character.hiring_cost
        character.is_hired = true
        AdventureManager.hired_characters.append(character)
        EventBus.character_hired.emit(character)
        return true
    return false
```

---

## 4. PLANNING MODE SYSTÉMY

### 4.1 GhostRunController (formerly TimelineController)

```gdscript
class_name GhostRunController
extends Node

var current_time: float = 0.0
var is_recording: bool = false
var active_character: CharacterData

# Data pro replay
var recorded_tracks: Dictionary = {} # char_id -> Array[TimelineInput]

signal time_changed(new_time: float)
signal recording_started(character: CharacterData)
signal recording_finished

func start_recording(character: CharacterData):
    active_character = character
    current_time = 0.0
    is_recording = true
    recording_started.emit(character)
    
func _physics_process(delta: float):
    if is_recording:
        current_time += delta
        _record_input_for_frame(delta)
        _replay_ghosts(current_time)
        time_changed.emit(current_time)

func _replay_ghosts(time: float):
    # Projde všechny UŽ NAHRANÉ postavy a posune jejich "duchy"
    for char_id in recorded_tracks.keys():
        if char_id == active_character.name: continue # Nehrát sebe sama
        
        var inputs = recorded_tracks[char_id]
        var input_at_time = _get_input_at_time(inputs, time)
        _apply_input_to_ghost(char_id, input_at_time)

func _get_input_at_time(inputs: Array, time: float) -> Vector2:
    # Najde správný input pro daný čas (interpolace nebo nearest)
    # ... implementace
    return Vector2.ZERO
```

### 4.2 InputRecordingSystem (formerly PathDrawing)

```gdscript
class_name InputRecordingSystem
extends Node

var current_recording: Array[TimelineInput] = []

class TimelineInput:
    var time: float
    var direction: Vector2
    var action_pressed: bool

func _record_input_for_frame(delta: float):
    var input = Vector2.ZERO
    input.x = Input.get_axis("ui_left", "ui_right")
    input.y = Input.get_axis("ui_up", "ui_down")
    
    var frame_data = TimelineInput.new()
    frame_data.time = GhostRunController.current_time
    frame_data.direction = input
    frame_data.action_pressed = Input.is_action_just_pressed("interact")
    
    current_recording.append(frame_data)

func commit_recording(char_id: String):
    # Uloží nahrávku do GhostRunController
    GhostRunController.recorded_tracks[char_id] = current_recording.duplicate()
    current_recording.clear()
```

---

## 5. ACTION MODE SYSTÉMY

### 5.1 ExecutionEngine

```gdscript
class_name ExecutionEngine
extends Node

var current_time: float = 0.0
var is_paused: bool = false
var alert_level: float = 0.0
var mission_success: bool = true

signal execution_started
signal execution_paused
signal character_action_completed(character: CharacterData, action: String)
signal alert_level_changed(new_level: float)

func _process(delta: float):
    if not is_paused:
        current_time += delta
        _process_character_actions()
        _check_guard_detection()
        _update_audio_feedback()

func _process_character_actions():
    for character_plan in PlanningManager.current_plan.character_plans.values():
        var current_action = character_plan.get_action_at_time(current_time)
        
        if current_action and not current_action.is_complete:
            match current_action.type:
                "MOVE":
                    _execute_move_action(character_plan.character, current_action)
                "INTERACT":
                    _execute_interact_action(character_plan.character, current_action)
                "WAIT":
                    pass  # Nic nedělá
                "TAKE_LOOT":
                    _execute_loot_action(character_plan.character, current_action)

func _check_guard_detection():
    for guard in current_level.guards:
        for character_plan in PlanningManager.current_plan.character_plans.values():
            var char_pos = character_plan.character.global_position
            
            # Kontrola vizuální detekce
            if guard.vision_cone.contains_point(char_pos):
                _on_character_detected(character_plan.character, "VISUAL")
                alert_level = min(alert_level + 20, 100.0)
            
            # Kontrola akustické detekce
            if _is_noise_audible(char_pos, guard.position):
                _on_character_detected(character_plan.character, "AUDIO")
                alert_level = min(alert_level + 10, 100.0)
```

---

## 6. PERSISTENCE A SAVE SYSTÉM

### 6.1 Cloud Sync (Volitelné)

```gdscript
# Pro budoucnost - integraci s Google Play Services
func sync_to_cloud(save_data: Dictionary) -> bool:
    if OS.has_feature("android"):
        # Integrace s Google Play Games Services
        # Cloudový backup pro cross-device play
        pass
    return true
```

---

## 7. ANDROID OPTIMIZACE

### 7.1 Memory Management

- ResourcePreloader: Načítá assety během loading screenu
- Object Pooling: Recyklování NPC, efektů, zvuků
- Texture Streaming: .ctex formáty pro velké mapy

### 7.2 Performance Settings

```gdscript
# project.godot
[rendering]
renderer/mobile/xr_enabled = false
textures/vram_compression/import_etc2 = true
textures/vram_compression/import_s3tc = false

[physics]
2d/run_on_separate_thread = true
```

---

## 8. AI SYSTÉM

### 8.1 Guard Behavior Tree

```gdscript
class_name GuardAI
extends CharacterBody2D

enum State {PATROL, SUSPICIOUS, SEARCH, ALERT}
var current_state: State = State.PATROL
var patrol_points: Array[Vector2] = []
var vision_cone: Polygon2D
var hearing_range: float = 20.0

func _process(delta: float):
    match current_state:
        State.PATROL:
            _patrol_behavior(delta)
        State.SUSPICIOUS:
            _suspicious_behavior(delta)
        State.SEARCH:
            _search_behavior(delta)
        State.ALERT:
            _alert_behavior(delta)

func _patrol_behavior(delta: float):
    # Pohyb podle patrol_points
    var target = patrol_points[current_patrol_index]
    var direction = (target - global_position).normalized()
    velocity = direction * patrol_speed
    move_and_slide()

func trigger_alert():
    current_state = State.ALERT
    # Vypálí alarm, přivolá posily, pronásleduje hráče
    EventBus.alert_triggered.emit(self)
```