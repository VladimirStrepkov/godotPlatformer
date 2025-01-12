extends Area2D

var is_player_near: bool = false

@export var damage: float = 80

func _on_body_entered(_body: Node2D) -> void:
	is_player_near = true

func _on_body_exited(_body: Node2D) -> void:
	is_player_near = false

func _process(_delta: float) -> void:
	if is_player_near:
		Globals.player_health -= damage
