extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Globals.show_hint("E - сохраниться")
	Globals.player_can_save = true

func _on_body_exited(_body: Node2D) -> void:
	Globals.hide_hint()
	Globals.player_can_save = false
