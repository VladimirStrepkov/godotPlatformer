extends CanvasLayer

# "режим кино" - когда все статы скрыты, и появляются чёрные полоски
var movie_mode: bool = false

func _ready() -> void:
	Globals.connect("ui_stat_change", stat_change)
	Globals.connect("ui_show_hint", show_hint)
	Globals.connect("ui_hide_hint", hide_hint)
	Globals.connect("ui_show_message", show_message)
	Globals.connect("ui_mode_switch", ui_mode_switch)
	stat_change()
	# Интерфейс всегда плавно появляется из темноты
	var tween = get_tree().create_tween()
	tween.tween_property($BlackScreen, "color:a", 0, 4)

# Переключаем режим UI (normal_mode/movie_mode)
func ui_mode_switch() -> void:
	movie_mode = not movie_mode
	if movie_mode:
		$NormalMode.hide()
		$MovieMode.show()
	else:
		$NormalMode.show()
		$MovieMode.hide()

# Обновление статов в интерфейсе
func stat_change() -> void:
	$NormalMode/HBoxContainer/CenterContainer/TextureProgressBar.value = 100 * (Globals.player_health / Globals.max_player_health)
	$NormalMode/HBoxContainer/CenterContainer2/Label.text = str(Globals.player_health) + "/" + str(Globals.max_player_health)

# Показываем подсказку с определённым текстом
func show_hint(hint_text : String) -> void:
	$NormalMode/Hint.show()
	$NormalMode/Hint.text = hint_text

func  hide_hint() -> void:
	$NormalMode/Hint.hide()

# Показываем сообщение с определённым текстом
func show_message(message_text:String) -> void:
	$NormalMode/Message.text = message_text
	$NormalMode/Message.show()
	$NormalMode/Message/MessageLifeTimer.start()

func _on_message_life_timer_timeout() -> void:
	$NormalMode/Message.hide()
