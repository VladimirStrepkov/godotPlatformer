extends SwitchObject

# Включён ли рычаг
var is_lever_active = false

func _ready() -> void:
	hint_text = "E - переключить рычаг"
	Globals.connect("switch_lever", switch_lever)

# Переключаем рычаг
func switch_lever() -> void:
	# Не переключаем рычаг если игрок переключил другой рычаг
	if Globals.lever_path != self.get_path():
		return
	is_lever_active = not is_lever_active
	if is_lever_active:
		$AnimatedSprite2D.play("on")
		self.activate()
	else:
		$AnimatedSprite2D.play("off")
		self.deactivate()

func when_player_in(_player_body: Node2D) -> void:
	Globals.player_can_switch_lever = true
	Globals.lever_path = self.get_path()

func when_player_out() -> void:
	Globals.player_can_switch_lever = false
	Globals.lever_path = self.get_path()
