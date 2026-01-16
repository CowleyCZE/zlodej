extends Control

@onready var title_label = $Panel/Title
@onready var char_container = $Panel/Scroll/CharContainer
@onready var btn_close = $Panel/Btn_Close

var current_location_id: String
var recruitment_row_scene = preload("res://scenes/ui/RecruitmentRow.tscn")

func _ready():
	btn_close.pressed.connect(hide)
	# Time update logic moved to specific update usage to avoid overhead when hidden logic
	hide()

func open(location_id: String, location_name: String):
	current_location_id = location_id
	title_label.text = location_name
	
	# Load Location Background (Optional polish)
	var bg_path = "res://assets/locations/" + location_id.to_snake_case() + "_bg.png"
	if ResourceLoader.exists(bg_path):
		var bg_texture = load(bg_path)
		var bg_node = get_node_or_null("Background")
		if bg_node and bg_node is TextureRect:
			bg_node.texture = bg_texture
	
	_refresh_list()
	show()

func _refresh_list() -> void:
	for child in char_container.get_children():
		child.queue_free()
		
	var characters = AdventureManager.get_characters_in_location(current_location_id)
	
	if characters.is_empty():
		var label = Label.new()
		label.text = "Nikdo tu zrovna není."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		char_container.add_child(label)
		return
	
	for character in characters:
		var row = recruitment_row_scene.instantiate()
		char_container.add_child(row)
		row.setup(character)
