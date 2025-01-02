extends Area2D
class_name InteractiveObject

# Текст подсказки для интеракции
var hint_text: String = "текст подсказки"

func when_player_in(_player_body: Node2D) -> void:
	pass

func when_player_out() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	Globals.show_hint(hint_text)
	$InteractivityIcon.hide()
	when_player_in(body)

func _on_body_exited(_body: Node2D) -> void:
	Globals.hide_hint()
	$InteractivityIcon.show()
	when_player_out()
