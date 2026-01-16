extends Control

@onready var lbl_loot = $VBoxContainer/LootInfo
@onready var lbl_rep = $VBoxContainer/RepInfo
@onready var lbl_heat = $VBoxContainer/HeatInfo
@onready var lbl_rank = $VBoxContainer/RankInfo # Ensure this node exists in .tscn or add manually
@onready var btn_continue = $VBoxContainer/Btn_ReturnToMap

func _ready():
	btn_continue.pressed.connect(_on_continue_pressed)
	
	# Initial UI Reset
	lbl_loot.text = "Výpočet..."
	if has_node("VBoxContainer/RankInfo"):
		lbl_rank.text = ""
	
	_calculate_and_apply_results()

func _calculate_and_apply_results():
	var results = GameManager.last_mission_results
	var mission = GameManager.current_mission
	
	if not results or not mission:
		lbl_loot.text = "Chyba dat mise."
		return
		
	# 1. Success Check
	if not results["success"]:
		lbl_loot.text = "MISE NEÚSPĚŠNÁ\nZisk: 0 CZK"
		lbl_rank.text = "RANK: SELHÁNÍ"
		lbl_rank.modulate = Color.RED
		return

	# 2. Financial Breakdown
	var gross_loot = results["loot_collected"]
	var admin_fee = int(gross_loot * 0.15)
	
	var team_shares_total = 0
	var shares_details = ""
	
	for member in results["team_members"]:
		var share = int(gross_loot * (member.loot_share_percent / 100.0))
		team_shares_total += share
		shares_details += "\n- %s (%d%%): %d CZK" % [member.name, member.loot_share_percent, share]
	
	var net_profit = gross_loot - admin_fee - team_shares_total
	
	# Apply to economy
	EconomyManager.wallet += net_profit
	
	# 3. Apply XP to Team (Point 7)
	for member in results["team_members"]:
		member.gain_experience(2) # 2 skill points per mission
	
	# 4. Rank Evaluation
	var rank = "PROFESIONÁL"
	var rank_color = Color.CYAN
	
	if results["guards_killed"] > 0:
		rank = "ŘEZNÍK (BUTCHER)"
		rank_color = Color.RED
	elif results["times_spotted"] == 0 and results["guards_stunned"] == 0:
		rank = "DUCH (GHOST)"
		rank_color = Color.GOLD
	elif results["times_spotted"] == 0:
		rank = "INFILTRÁTOR"
		rank_color = Color.GREEN
	elif results["times_spotted"] > 3:
		rank = "AMATÉR"
		rank_color = Color.ORANGE
		
	# 4. Update UI
	lbl_rank.text = "HODNOCENÍ: " + rank
	lbl_rank.modulate = rank_color
	
	lbl_loot.text = "CELKOVÝ LUP: %d CZK\n" % gross_loot
	lbl_loot.text += "Administrace (15%%): -%d CZK\n" % admin_fee
	lbl_loot.text += "Podíly týmu: -%d CZK%s\n" % [team_shares_total, shares_details]
	lbl_loot.text += "\nČISTÝ ZISK: %d CZK" % net_profit
	
	# 5. Reputation & Heat
	var rep_gain = mission.reputation_gain
	if rank == "GHOST": rep_gain *= 1.5
	if rank == "BUTCHER": rep_gain *= 0.5
	
	GameManager.add_reputation(int(rep_gain))
	lbl_rep.text = "Reputace: +%d" % rep_gain
	
	var current_heat = GameManager.heat_levels.get(mission.region_id, 0.0)
	lbl_heat.text = "Aktuální Heat: %.0f%%" % current_heat
	
	# Reset session
	GameManager.current_mission_loot = 0
	GameManager.main_loot_collected = false
	
	SaveManager.save_game()

func _on_continue_pressed():
	# Return to Adventure Mode (World Map)
	GameManager.change_state(GameManager.State.ADVENTURE)
