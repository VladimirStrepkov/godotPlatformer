extends InteractiveObject

# текст таблички
# Для перевода строки нужно писать в инспекторе feed
@export var table_text: String

func _ready() -> void:
	# Разбиваю строку на подстроки по ключ-слову "feed" и записываю эти подстроки
	# через перевод строки в текст подсказки
	hint_text = ""
	var lines = table_text.split("feed")
	for line in lines:
		hint_text = hint_text + line + "\n"
