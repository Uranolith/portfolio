extends Control

@export var _health_bar : ProgressBar
@onready var health_bar : ProgressBar = _health_bar

@export var _mana_bar : ProgressBar
@onready var mana_bar : ProgressBar = _mana_bar

@export var _stamina_bar : ProgressBar
@onready var stamina_bar : ProgressBar = _stamina_bar

@export var Testschalter : Node

func _ready():
	SignalManager.update_health_bar.connect(_on_update_health_bar)
	SignalManager.update_mana_bar.connect(_on_update_mana_bar)
	SignalManager.update_stamina_bar.connect(_on_update_stamina_bar)
	
	## Testumgebung ANFANG
	Testschalter.find_child("TestSliderHealth").value_changed.connect(_on_test_slider_health_value_changed)
	Testschalter.find_child("TestSliderMana").value_changed.connect(_on_test_slider_mana_value_changed)
	Testschalter.find_child("TestSliderStamina").value_changed.connect(_on_test_slider_stamina_value_changed)
	## Testumgebung ENDE

func _on_update_health_bar(health_value: int, new_max_health: int = -1):
	health_bar.value = health_bar.max_value - health_value

func _on_update_mana_bar(mana_value, new_max_mana: int = -1):
	mana_bar.value = mana_bar.max_value - mana_value

func _on_update_stamina_bar(stamina_value, new_max_stamina: int = -1):
	stamina_bar.value = stamina_bar.max_value - stamina_value


## Testumgebung
func _on_test_slider_mana_value_changed(value):
	SignalManager.update_mana_bar.emit(value)

func _on_test_slider_health_value_changed(value):
	SignalManager.update_health_bar.emit(value)

func _on_test_slider_stamina_value_changed(value):
	SignalManager.update_stamina_bar.emit(value)
