# EconomyManager.gd (Autoload)
extends Node

var wallet: int = 10000:
	set(value):
		wallet = value
		EventBus.wallet_changed.emit(wallet)

# We'll use a dictionary of resources for the database
var item_db: Dictionary = {}

func _ready():
	_initialize_item_db()

func _initialize_item_db():
	# Create items programmatically as resources
	var lp = InventoryItem.new()
	lp.id = "lockpick_set"
	lp.name = "Paklíčová sada"
	lp.price = 500
	lp.description = "Základní sada pro tiché otevírání dveří a beden."
	lp.icon = load("res://assets/icons/icon_lockpick.png")
	lp.weight = 0.3
	lp.noise_generation = 20.0
	item_db[lp.id] = lp
	
	var hk = InventoryItem.new()
	hk.id = "hacking_kit"
	hk.name = "Hacking Kit"
	hk.price = 1500
	hk.description = "Zvyšuje časový limit při hackování elektroniky."
	hk.icon = load("res://assets/icons/icon_hacking.png")
	hk.weight = 1.0
	hk.noise_generation = 10.0
	item_db[hk.id] = hk
	
	var taser = InventoryItem.new()
	taser.id = "taser"
	taser.name = "Taser"
	taser.price = 3000
	taser.description = "Umožňuje tiché omráčení strážného na blízko."
	taser.icon = load("res://assets/icons/icon_taser.png")
	taser.weight = 0.8
	taser.effect_type = "stun_npc"
	taser.effect_duration = 30.0
	taser.is_lethal = false
	taser.noise_generation = 40.0
	item_db[taser.id] = taser

	var knife = InventoryItem.new()
	knife.id = "combat_knife"
	knife.name = "Bojový nůž"
	knife.price = 1000
	knife.description = "Tichá, ale smrtící zbraň. Trvalé zneškodnění."
	knife.icon = load("res://assets/icons/icon_knife.png")
	knife.weight = 0.4
	knife.effect_type = "stun_npc"
	knife.is_lethal = true
	knife.noise_generation = 10.0
	item_db[knife.id] = knife

	var pistol = InventoryItem.new()
	pistol.id = "silenced_pistol"
	pistol.name = "Tlumená pistole"
	pistol.price = 8000
	pistol.description = "Zbraň na dálku. Vysoce smrtící, ale zvyšuje hledanost."
	pistol.icon = load("res://assets/icons/icon_pistol.png")
	pistol.weight = 1.5
	pistol.effect_type = "stun_npc"
	pistol.is_lethal = true
	pistol.noise_generation = 150.0 # High noise for firearm
	item_db[pistol.id] = pistol

	var crowbar = InventoryItem.new()
	crowbar.id = "crowbar"
	crowbar.name = "Páčidlo"
	crowbar.price = 300
	crowbar.description = "Hrubá síla. Otevírá rychle, ale dělá velký hluk."
	crowbar.icon = load("res://assets/icons/icon_crowbar.png")
	crowbar.weight = 2.0
	crowbar.noise_generation = 200.0 # Very loud
	item_db[crowbar.id] = crowbar

	# --- NEW GADGETS ---
	var emp = InventoryItem.new()
	emp.id = "emp_grenade"
	emp.name = "EMP Granát"
	emp.price = 1200
	emp.description = "Jednorázový pulz, který dočasně vyřadí kamery a senzory."
	emp.weight = 0.5
	emp.item_type = "consumable"
	emp.noise_generation = 4.0 # Slyšitelné lupnutí
	emp.effect_type = "disable_electronics"
	emp.effect_radius = 10.0 # Metrů
	emp.effect_duration = 15.0 # Sekund
	item_db[emp.id] = emp
	
	var jammer = InventoryItem.new()
	jammer.id = "signal_jammer"
	jammer.name = "Rušička signálu"
	jammer.price = 4500
	jammer.description = "Blokuje vysílačky strážných v okolí. Zabraňuje přivolání posil."
	jammer.weight = 1.2
	jammer.item_type = "tool"
	jammer.noise_generation = 0.0
	jammer.effect_type = "block_signal"
	jammer.effect_radius = 25.0
	item_db[jammer.id] = jammer
	
	var adv_pick = InventoryItem.new()
	adv_pick.id = "advanced_lockpick"
	adv_pick.name = "Titanová planžeta"
	adv_pick.price = 2500
	adv_pick.description = "Profesionální nástroj. O 50% rychlejší odemykání."
	adv_pick.weight = 0.2
	adv_pick.item_type = "tool"
	adv_pick.action_speed_modifier = 1.5
	item_db[adv_pick.id] = adv_pick

func purchase(item_id: String) -> bool:
	if not item_db.has(item_id): return false
	
	var item = item_db[item_id]
	if wallet >= item.price:
		if InventoryManager.add_item(item, 1):
			wallet -= item.price
			return true
	return false