extends InteractiveObject

# Файловый путь сцены, на которую перейдёт игрок после взаимодействия с transition
@export var level_path: String

func _ready() -> void:
	# Пишем название уровня, на который может перейти игрок
	hint_text = "E - перейти в \"" + Globals.level_names[level_path] + "\""

func when_player_in():
	Globals.player_can_go_next_level = true
	Globals.next_level_path = level_path

func when_player_out():
	Globals.player_can_go_next_level = false
