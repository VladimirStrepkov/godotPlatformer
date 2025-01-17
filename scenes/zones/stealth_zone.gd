extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	if Globals.count_enemies_sees_player == 0:
		Globals.player_stealth = true

func _on_body_exited(_body: Node2D) -> void:
	Globals.player_stealth = false
