extends InteractiveObject

# Файловый путь сцены, на которую перейдёт игрок после взаимодействия с transition
@export var level_path: String

# Позиция, в которой появится игрок на след. уровне, если перейдёт на него
# через этот transition
@export var next_level_position: Vector2

func _ready() -> void:
	# Пишем название уровня, на который может перейти игрок
	hint_text = "E - перейти в \"" + Globals.level_names[level_path] + "\""

func when_player_in(_player_body):
	Globals.player_can_go_next_level = true
	Globals.next_level_path = level_path
	Globals.player_next_level_position = next_level_position

func when_player_out():
	Globals.player_can_go_next_level = false
