extends CanvasLayer

func _ready():
	$HealthProgress.min_value = 0
	$HealthProgress.max_value = 5
	$HealthProgress.step = 1


func _on_player_current_health_changed(health):
	$HealthProgress.value = health
