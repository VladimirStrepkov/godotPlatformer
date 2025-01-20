extends InteractiveObject

# Другой телепорт
@export var other_teleport: InteractiveObject

var player

func _ready() -> void:
	$PointLight2D.energy = 0
	hint_text = "E - телепортироваться"

func when_player_in(player_body: Node2D) -> void:
	player = player_body
	player.on_player_can_teleport(other_teleport.global_position)
	$AnimatedSprite2D.play("start")
	$AnimatedSprite2D.show()
	var tween = create_tween()
	tween.tween_property($PointLight2D, "energy", 1, 1)

func when_player_out() -> void:
	$AnimatedSprite2D.play("end")
	player.off_player_can_teleport()
	var tween = create_tween()
	tween.tween_property($PointLight2D, "energy", 0, 1)

func _process(_delta: float) -> void:
	if $AnimatedSprite2D.animation == "start" and not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("loop")
	if $AnimatedSprite2D.animation == "end" and not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.hide()
