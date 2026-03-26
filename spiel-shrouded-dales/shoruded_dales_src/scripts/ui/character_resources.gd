extends Control

@export var _health_bar : ProgressBar
@onready var health_bar : ProgressBar = _health_bar

@export var _mana_bar : ProgressBar
@onready var mana_bar : ProgressBar = _mana_bar

@export var _stamina_bar : ProgressBar
@onready var stamina_bar : ProgressBar = _stamina_bar

func _ready():
	SignalManager.update_health_bar.connect(_on_update_health_bar)
	SignalManager.update_mana_bar.connect(_on_update_mana_bar)
	SignalManager.update_stamina_bar.connect(_on_update_stamina_bar)


func _on_update_health_bar(health_value: int):
	if health_bar:
		health_bar.value = health_bar.max_value - health_value

func _on_update_mana_bar(mana_value):
	if mana_bar:
		mana_bar.value = mana_bar.max_value - mana_value

func _on_update_stamina_bar(stamina_value):
	if stamina_bar:
		stamina_bar.value = stamina_bar.max_value - stamina_value
