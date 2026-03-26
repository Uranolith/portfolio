extends Node

## Head Up Display
signal update_health_bar
signal update_mana_bar
signal update_stamina_bar
signal update_enemy_health_bar

## Inventory system
signal toggle_inventory
signal interact_with
signal use_item

## StateMachine
signal change_to_next_state(state: State, new_state_name: String)

## Character Combat
signal body_hit(damage:float)
signal target_in_range(body:CharacterBody2D)
signal take_damage(target:Node2D, agressor:Node2D)
signal kill_target(target:Node2D)

## AudioControler
signal change_audio(filename:String, audioplayer:String)
signal change_audio_with_loop(filename:String, audioplayer:String, loop: bool)
signal play_audio(filename:String, audioplayer:String)
#signal stop_audio(filename:String, audioplayer:String)
signal play_audio_collection(collection:Array)
signal kill_sfx(filename: String)



## Menu
signal change_to_scene(menu: Control, new_s_name: String)
