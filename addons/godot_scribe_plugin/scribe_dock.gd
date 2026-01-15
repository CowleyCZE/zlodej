@tool
extends Control

@onready var status_label = $VBoxContainer/StatusLabel
@onready var log_view = $VBoxContainer/LogView

var server_plugin

func _ready():
    log_view.clear()
    # add_log("Godot Scribe Dock inicializován.") # Deaktivováno pro prevenci chyby

func set_server(plugin):
    server_plugin = plugin

func add_log(message):
    var current_time = Time.get_time_string_from_system()
    var new_line = "[%s] %s\n" % [current_time, message]
    log_view.text += new_line
    call_deferred("_scroll_to_bottom")

func _scroll_to_bottom():
    var scroll_bar = log_view.get_v_scroll_bar()
    if scroll_bar:
        scroll_bar.value = scroll_bar.max_value

func set_status(text):
    status_label.text = "Stav: " + text
