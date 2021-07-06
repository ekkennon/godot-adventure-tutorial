extends CanvasLayer

onready var health_box : HBoxContainer = $MarginContainer/VBoxContainer/HealthIndicatorBox
var health_indicator : PackedScene = preload("res://scenes/gui/HealthIndicator.tscn")
var player : KinematicBody2D

func _ready():
	player = PlayerData.get_main_node().get_node("player")
	
	player.connect("initial_health_changed", self, "_on_player_initial_health_changed", [])
	player.connect("current_health_changed", self, "_on_player_current_health_changed", [])
	
	var initial_health = player.initial_health
	for i in range(0, initial_health):
		health_box.add_child(health_indicator.instance())
		


func _on_player_initial_health_changed(health):
	print("initial health " + str(health))


func _on_player_current_health_changed(health):
	var total_health = health_box.get_child_count()
	if health < total_health and health >= 0:
		var hearts = health_box.get_children()
		var difference = total_health - health
		for i in range(difference):
			hearts[hearts.size() - 1 - i].set_empty_sprite()
