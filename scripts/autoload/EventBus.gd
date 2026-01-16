extends Node

# Global Event Bus
# Central hub for signals to decouple systems

# --- V3 Core Signals (Melnik 2025) ---
@warning_ignore("unused_signal")
signal adventure_started(mission: MissionData)
@warning_ignore("unused_signal")
signal planning_activated(mission: MissionData)
@warning_ignore("unused_signal")
signal action_phase_started(plan: PlanningData)
@warning_ignore("unused_signal")
signal character_hired(character: CharacterData)

# Legacy / UI Signals
@warning_ignore("unused_signal")
signal inventory_changed
@warning_ignore("unused_signal")
signal wallet_changed(new_amount: int)
@warning_ignore("unused_signal")
signal mission_loot_changed(total: int)
@warning_ignore("unused_signal")
signal reputation_changed(new_value)
@warning_ignore("unused_signal")
signal heat_level_changed(new_value)
@warning_ignore("unused_signal")
signal mission_started(mission_id)
@warning_ignore("unused_signal")
signal mission_completed(mission_id)
@warning_ignore("unused_signal")
signal mission_failed(mission_id)
@warning_ignore("unused_signal")
signal game_state_changed(new_state)

# Stealth Signals
@warning_ignore("unused_signal")
signal player_spotted(player_node)
@warning_ignore("unused_signal")
signal guard_stunned(guard_node)
@warning_ignore("unused_signal")
signal guard_killed(guard_node)

# UI Requests
@warning_ignore("unused_signal")
signal security_shutdown_requested(source_id: String)
@warning_ignore("unused_signal")
signal request_open_inventory
@warning_ignore("unused_signal")
signal request_open_shop
@warning_ignore("unused_signal")
signal request_open_mission_select
@warning_ignore("unused_signal")
signal request_open_pause_menu
@warning_ignore("unused_signal")
signal request_start_dialogue(character_name, text, portrait_path, choices, character_data)
@warning_ignore("unused_signal")
signal request_start_game
@warning_ignore("unused_signal")
signal request_quit_game
@warning_ignore("unused_signal")
signal request_lockpick_minigame(difficulty: float, callback: Callable)
@warning_ignore("unused_signal")
signal request_hacking_minigame(difficulty: float, callback: Callable)
@warning_ignore("unused_signal")
signal request_remote_unlock(group_id: String)
