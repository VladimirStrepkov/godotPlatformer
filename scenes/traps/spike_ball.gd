extends Path2D

# максимальная скорость движения пилы
const MAX_SPEED:float = 300

# Урон от пилы
@export var damage: float = 100 

var is_player_near: bool = false

# Скорость двигающейся пилы
# Не выходит за рамки максимального и минимального значения (@export_range)
@export_range(0, MAX_SPEED) var speed: float = 30

func _ready() -> void:
	# Платформа будет двигаться циклично по пути
	$PathFollow2D.loop = true

func _physics_process(delta: float) -> void:
	$PathFollow2D.progress += speed * delta

func _on_area_2d_body_entered(_body: Node2D) -> void:
	is_player_near = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	is_player_near = false

func _process(_delta: float) -> void:
	if is_player_near:
		Globals.player_health -= damage
