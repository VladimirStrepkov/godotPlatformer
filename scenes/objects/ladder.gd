extends Area2D
# Это область лестницы, когда игрок попадает в неё, он может ползти вверх.
# У сцены нет формы столкновения т.к. лестница может быть разного размера и
# высоту формы нужно настраивать вручную, она должна быть чуть ниже высоты лестницы
# Текстуры лестницы есть в LadderTilesLayer, а области хранятся в LadderAreas

func _on_body_entered(body: Node2D) -> void:
	body.player_can_climb = true

func _on_body_exited(body: Node2D) -> void:
	body.player_can_climb = false
