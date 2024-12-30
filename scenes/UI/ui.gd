extends CanvasLayer

func _ready() -> void:
	Globals.connect("ui_stat_change", stat_change)
	Globals.connect("ui_show_hint", show_hint)
	Globals.connect("ui_hide_hint", hide_hint)
	Globals.connect("ui_show_message", show_message)
	stat_change()

# Обновление статов в интерфейсе
func stat_change() -> void:
	$HBoxContainer/CenterContainer/TextureProgressBar.value = 100 * (Globals.player_health / Globals.max_player_health)
	$HBoxContainer/CenterContainer2/Label.text = str(Globals.player_health) + "/" + str(Globals.max_player_health)

# Показываем подсказку с определённым текстом
func show_hint(hint_text : String) -> void:
	$Hint.show()
	$Hint.text = hint_text

func  hide_hint() -> void:
	$Hint.hide()

# Показываем сообщение с определённым текстом
func show_message(message_text:String) -> void:
	$Message.text = message_text
	$Message.show()
	$Message/MessageLifeTimer.start()

func _on_message_life_timer_timeout() -> void:
	$Message.hide()
