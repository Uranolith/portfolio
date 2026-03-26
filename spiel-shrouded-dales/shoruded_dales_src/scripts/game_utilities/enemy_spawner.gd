class_name EnemySpawner
extends Node2D

#var skeleton_scene = preload("res://scenes/entities/enemies/enemy_normal.tscn")
# Dictionary of packed Enemy-Scenes
var enemies_normal:Dictionary = {"skeleton":preload("res://scenes/entities/enemies/enemy_normal.tscn")}
var spawn_locations:Array[Vector2] = [Vector2(1500,50), Vector2(4900,600),Vector2(8150,360), Vector2(10900,585)]

# add timer or use conditon to spawn
# func _on_condition:
#	spawn_enemy()

func spawn_enemy():
	var enemy = enemies_normal["skeleton"].instantiate()
	enemy.position = spawn_locations[randi() % spawn_locations.size()]
	add_child(enemy)

# add visibility notifier to despawn?
# on signal(child):
# child.queue_free()
