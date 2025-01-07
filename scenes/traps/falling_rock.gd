extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	$AnimationPlayer.play("fall")

func delete_rigin_body() -> void:
	$RigidBody2D.queue_free()
