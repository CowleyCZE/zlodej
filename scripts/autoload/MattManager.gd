# MattManager.gd (Autoload)
extends Node

signal thought_emitted(text: String)

var general_thoughts = [
	"Mělník... v noci to tu smrdí rybinou a starým betonem.",
	"Musím se soustředit. Jedna chyba a smyčka mě sežere.",
	"Honza vypadá, že ví víc, než říká. Jako vždycky.",
	"Kronos. To jméno mi zní v hlavě jako zaseknutá deska.",
	"Zase prší. Aspoň to utlumí kroky."
]

var planning_thoughts = [
	"Ten půdorys vypadá podezřele jednoduše. Kde je háček?",
	"Petra říkala, že tyhle kamery mají slepý úhel v rohu.",
	"Pokud Josef zaparkuje u zadního vchodu, máme to za minutu hotové.",
	"Čas je v tomhle plánu můj nepřítel i spojenec."
]

var action_thoughts = [
	"Ticho. Jen tlukot srdce a digitální šum.",
	"Doufám, že Bohouš zase zapomněl zamknout ty druhý dveře.",
	"Rychle dovnitř, rychle ven. Žádný hrdinství."
]

func _ready():
	# Initial delay reduced to show text immediately after start
	get_tree().create_timer(2.0).timeout.connect(_on_thought_timer)

func _on_thought_timer():
	if GameManager.current_state == GameManager.State.MENU:
		emit_thought("Zírám na menu... jako bych věděl, co přijde.")
	elif GameManager.current_state == GameManager.State.ADVENTURE:
		emit_thought(general_thoughts.pick_random())
	elif GameManager.current_state == GameManager.State.PLANNING:
		emit_thought(planning_thoughts.pick_random())
	
	# Schedule next thought (faster for first few, then normal)
	var delay = randf_range(20.0, 45.0)
	get_tree().create_timer(delay).timeout.connect(_on_thought_timer)

func emit_thought(text: String):
	thought_emitted.emit("Matt: \"" + text + "\"")
	print("MATT THOUGHT: ", text)

func get_object_comment(obj_name: String) -> String:
	# Add some "pro" commentary to objects
	if "Door" in obj_name:
		return "Klasický mechanický zámek. Stačí trocha tlaku a cvakne."
	if "Terminal" in obj_name:
		return "Tohle svítí jako vánoční stromek. Petra bude mít radost."
	if "Camera" in obj_name:
		return "Čočka se hýbe v pravidelným rytmu. Musím počkat na mezeru."
	return "Vypadá to jako součást systému. Musím si dát bacha."
