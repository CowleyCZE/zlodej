extends Control

func _ready():
	# Initial setup for loading screen, can be hidden by default
	hide()
	# Set some default texts
	$Content/TitleLabel.text = "Načítání..."
	$Content/TipLabel.text = "Věděli jste? Zloději preferují noc."
	$Content/ProgressBar.min_value = 0
	$Content/ProgressBar.max_value = 100
	$Content/ProgressBar.value = 0


func set_loading_text(text):
	$Content/TitleLabel.text = text

func set_tip_text(text):
	$Content/TipLabel.text = text

func set_progress(value):
	$Content/ProgressBar.value = value
