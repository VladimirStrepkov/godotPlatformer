extends Path2D

# максимальная скорость движения платформы
const MAX_SPEED:float = 300

# Скорость двигающейся платформы
# Не выходит за рамки максимального и минимального значения (@export_range)
@export_range(0, MAX_SPEED) var speed: float = 30

# Платформа двигается сама, или переключается рычагом
@export var switches: bool = false
# Направление движения платформы (-1, 1)
var direction: int = -1

func _ready() -> void:
	# Если платформа переключается, то она двигается не циклично, в ином
	# случае циклично
	$PathFollow2D.loop = not switches
	
func _physics_process(delta: float) -> void:
	$PathFollow2D.progress += speed * delta * direction

# Функции включения и выключения
func on_function() -> void:
	direction = 1

func off_function() -> void:
	direction = -1
