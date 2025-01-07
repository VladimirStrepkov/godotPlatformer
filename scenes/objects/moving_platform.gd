extends Path2D

# максимальная скорость движения платформы
const MAX_SPEED:float = 300

# Скорость двигающейся платформы
# Не выходит за рамки максимального и минимального значения (@export_range)
@export_range(0, MAX_SPEED) var speed: float = 30

func _ready() -> void:
	# Платформа будет двигаться циклично по пути
	$PathFollow2D.loop = true

func _physics_process(delta: float) -> void:
	$PathFollow2D.progress += speed * delta
