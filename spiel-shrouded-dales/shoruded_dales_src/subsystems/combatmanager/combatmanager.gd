extends Node

@export var _player: PlayerCharacter
@onready var player: PlayerCharacter = _player

func _ready():
	SignalManager.use_item.connect(use_inventory_slot_item)
	SignalManager.take_damage.connect(calculate_damage_with_stats)
	

func calculate_damage_with_stats(target: Node2D, agressor: Node2D):
	var damage : int
	if (target is PlayerCharacter and agressor is BaseEnemy) \
	or (target is BaseEnemy and agressor is PlayerCharacter):
		damage = agressor.details.base_attack

	elif target is BaseEnemy and agressor is MagicProjectile:
		damage = agressor.base_attack

	target.details.current_health = target.details.current_health - damage
	print("%s took damage from %s for %d, current health: %d" % [target, agressor, damage, target.details.current_health])
	if target is PlayerCharacter:
		SignalManager.update_health_bar.emit(target.details.current_health)
	else:
		SignalManager.update_enemy_health_bar.emit(target)
	
	if target.details.current_health <= 0:
		SignalManager.kill_target.emit(target)

func use_inventory_slot_item(slot_data: InventorySlot):
	var consumable_item = slot_data.content
	if player:
		match [slot_data.content.effect]:
			["HEALTHREG"]: 
				add_health(consumable_item)
			["MANAREG"]:
				add_mana(consumable_item)
			["STAMINAREG"]:
				regenerate_stamina(consumable_item)
			["MAGICSPELL"]:
				activate_spell_effect(consumable_item)
			[_]:
				return

func activate_spell_effect(magic_spell: MagicalSpell):
	if magic_spell is MagicalSpell: # Change to something like if magic_spell is MagicProjectile
			create_magic_projectile(magic_spell)

#	if magic_spell is MagicProjectile:
#		create_magic_projectile(magic_spell)
#	elif magic_spell is MagicAura:
#		create_magic_aura(magic_spell)
 
func create_magic_projectile(magic_spell: MagicalSpell):
	if player.details.current_mana - magic_spell.mana_cost >= 0:
		var mana_cost = -magic_spell.mana_cost
		var new_projectile = magic_spell.magic_spell_scene.instantiate()
		new_projectile.player = player
		new_projectile.wait_time = magic_spell.duration
		new_projectile.animation = magic_spell.effect_animation

		new_projectile.base_attack = magic_spell.base_attack
		add_child(new_projectile)
		consume_mana(mana_cost)
		SignalManager.change_audio.emit("magic_projectile","SFX")


func add_health(consumable_item):
	var current_health = player.details.current_health
	var max_health = player.details.max_health
	var restore_value = consumable_item.effect_value
	
	player.details.current_health = edit_resources(current_health, max_health, restore_value)
	SignalManager.update_health_bar.emit(player.details.current_health)


func add_mana(consumable_item):
	var current_mana = player.details.current_mana
	var max_mana = player.details.max_mana
	var restore_value = consumable_item.effect_value
	
	player.details.current_mana = edit_resources(current_mana, max_mana, restore_value)
	SignalManager.update_mana_bar.emit(player.details.current_mana)

func consume_mana(mana_cost):
	var current_mana = player.details.current_mana
	var max_mana = player.details.max_mana
	player.details.current_mana = edit_resources(current_mana, max_mana, mana_cost)
	SignalManager.update_mana_bar.emit(player.details.current_mana)

func regenerate_stamina(consumable_item):
	var current_stamina = player.details.current_stamina
	var max_stamina = player.details.max_stamina
	var restore_value = consumable_item.effect_stamina
	
	player.details.current_stamina = edit_resources(current_stamina, max_stamina, restore_value)
	SignalManager.update_stamina_bar.emit(player.details.current_stamina)
	

func edit_resources(current_value, max_value, restore_value) -> int:
	current_value += restore_value
	if current_value >= max_value:
		current_value = max_value
	return current_value
	
	
