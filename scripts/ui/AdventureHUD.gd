extends Control

@onready var lbl_name = $HBox/PlayerName
@onready var lbl_reputation = $HBox/Reputation
@onready var lbl_wallet = $HBox/Wallet
@onready var lbl_heat = $HBox/Heat
@onready var lbl_time = $HBox/TimeLabel
@onready var btn_wait = $HBox/Btn_Wait

func _ready():
	# Initial sync
	lbl_name.text = GameManager.player_name
	_update_wallet(EconomyManager.wallet)
	_update_reputation(GameManager.reputation)
	_update_heat(GameManager.heat_levels["melnik"])
	_update_time(TimeManager.current_slot)
	
	# Connect signals for reactivity
	EventBus.wallet_changed.connect(_update_wallet)
	EventBus.reputation_changed.connect(_update_reputation)
	EventBus.heat_level_changed.connect(_update_heat)
	TimeManager.time_changed.connect(_update_time)
	
	btn_wait.pressed.connect(func(): TimeManager.advance_time())

func _update_time(slot: TimeManager.TimeSlot):
	lbl_time.text = "DEN" if slot == TimeManager.TimeSlot.DAY else "NOC"
	
	# Visual color shift for time
	if slot == TimeManager.TimeSlot.NIGHT:
		lbl_time.modulate = Color(0.5, 0.5, 1.0)
	else:
		lbl_time.modulate = Color(1.0, 1.0, 0.8)

func _update_wallet(amount: int):
	lbl_wallet.text = "Peníze: %d CZK" % amount
	# Flash effect could be added here
	var tween = create_tween()
	tween.tween_property(lbl_wallet, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(lbl_wallet, "scale", Vector2(1.0, 1.0), 0.1)

func _update_reputation(amount: int):
	lbl_reputation.text = "Reputace: %d" % amount

func _update_heat(amount: float):
	lbl_heat.text = "Hledanost: %d%%" % int(amount)
	
	# Visual feedback based on heat level
	if amount > 80:
		lbl_heat.add_theme_color_override("font_color", Color.RED)
	elif amount > 50:
		lbl_heat.add_theme_color_override("font_color", Color.ORANGE)
	else:
		lbl_heat.add_theme_color_override("font_color", Color.html("#ff3333"))
