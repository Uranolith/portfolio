extends ProgressBar

@export var show_bar_label: bool = true
@export var _bar_label: HBoxContainer
@onready var bar_label: HBoxContainer = _bar_label 


func _ready():
	if not show_bar_label:
		bar_label.hide()
	update_lable(value)
	

func update_lable(current_value: float):
	var inverted_value = max_value - current_value
	bar_label.find_child("CurrentLabel").set_text("%d" % [inverted_value])
	

func set_max_value(new_max_value: int = 100):
	max_value = new_max_value
	bar_label.find_child("MaxLabel").set_text("%d" % [new_max_value])

func _on_value_changed(current_value):
	update_lable(current_value)

