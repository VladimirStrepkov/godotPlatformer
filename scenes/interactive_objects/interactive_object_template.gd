extends Area2D
class_name InteractiveObject

# Текст подсказки для интеракции
var hint_text: String = "текст подсказки"

func when_player_in() -> void:
	pass

func when_player_out() -> void:
	pass

func _on_body_entered(_body: Node2D) -> void:
	Globals.show_hint(hint_text)
	$InteractivityIcon.hide()
	when_player_in()

func _on_body_exited(_body: Node2D) -> void:
	Globals.hide_hint()
	$InteractivityIcon.show()
	when_player_out()
