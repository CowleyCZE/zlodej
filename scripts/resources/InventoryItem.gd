# InventoryItem.gd
class_name InventoryItem extends Resource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var weight: float = 0.5
@export var price: int = 100
@export var is_stackable: bool = true
@export var max_stack: int = 99
@export var item_type: String = "tool" # "tool", "consumable", "intel", "loot"

# Simulation Stats (Requirement 4 & 6)
@export var noise_generation: float = 1.0 # 0.0 = Silent, 10.0 = Loud Explosion
@export var action_speed_modifier: float = 1.0 # 1.2 = 20% faster actions
@export var required_hands: int = 1 # 1 or 2

# Gadget Stats (Advanced)
@export var effect_type: String = "none" # "none", "disable_electronics", "block_signal", "stun_npc"
@export var effect_radius: float = 0.0 # Meters/Units
@export var effect_duration: float = 0.0 # Seconds
@export var is_lethal: bool = false
