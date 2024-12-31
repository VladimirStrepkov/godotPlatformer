extends InteractiveObject

func _ready() -> void:
	hint_text = "E - сохраниться"

func when_player_in() -> void:
	Globals.player_can_save = true

func  when_player_out() -> void:
	Globals.player_can_save = false
