extends Area2D
class_name InteractiveObject

# Текст подсказки для интеракции
var hint_text: String = "текст подсказки"
# Показывать ли текст подсказки когда мы подходим к интерактивному объекту
var show_hint_text: bool = true

func when_player_in(_player_body: Node2D) -> void:
	pass

func when_player_out() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if show_hint_text:
		Globals.show_hint(hint_text)
	$InteractivityIcon.hide()
	when_player_in(body)

func _on_body_exited(_body: Node2D) -> void:
	if show_hint_text:
		Globals.hide_hint()
	$InteractivityIcon.show()
	when_player_out()
