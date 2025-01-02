extends CanvasLayer

# Происходит ли сейчас диалог
var dialogue: bool = false

# НПС, с которым сейчас происходит диалог
var npc

# Текущий диалог
var current_dialogue: Dictionary

# Получить и обработать следующую фразу с номером phrase_number
func next_phrase(phrase_number:int) -> void:
	# Получаем следующую фразу
	var current_phrase = current_dialogue[phrase_number]
	
	# Показываем текст фразы
	$ColorRect/ColorRect/Phrase.text = current_phrase["phrase_text"]
	
	# Показываем выборы 
	
	# Удаляем все кнопки из предыдущей фразы
	for button in $ColorRect/HBoxContainer.get_children():
		button.queue_free()
	
	# Проходимся по всем выборам фразы
	for choice in current_phrase["choices"]:
		# Создаём кнопку для нового выбора
		var choice_button: Button = Button.new()
		# Даём кнопке текст выбора
		choice_button.text = choice["choice_text"]
		# Добавляем кнопку в HBoxContainer
		$ColorRect/HBoxContainer.add_child(choice_button)
		# Связываем событие нажатия кнопки с вызовом функции
		# Передаём этой функции номер фразы, на к-ю нужно перейти и функцию к-ю нужно вызвать
		choice_button.connect("pressed", choice_button_pressed.bind(choice["next_phrase_number"], choice["function"]))

# Кнопка выбора нажата
func choice_button_pressed(next_phrase_number:int, function:String) -> void:
	if function != "":
		DialogueStorage.call(function) # Вызываем функцию если она есть в выборе
	next_phrase(next_phrase_number)

# Начинается диалог
func dialogue_start(npc_link) -> void:
	dialogue = true
	npc = npc_link     # сохраняем ссылку на НПС, с к-м ведётся диалог
	self.show()        # Показываем диалоговое окно
	
	Globals.player_can_move = false   # Во время диалога игрок не может двигаться
	Globals.switch_ui_mode()          # включается режим "Кино" в ui
	
	npc.dialogue = true  # Сообщаем НПС, что с ним ведётся диалог
	$ColorRect/CenterContainer/NpcName.text = npc.npc_name
	
	# Получаем от НПС номер его диалога и берём этот диалог из DialogueStorage
	current_dialogue = DialogueStorage.dialogues[npc.dialogue_number]
	
	# Начинаем с первой фразы
	next_phrase(0)
	

# Диалог заканчивается
func dialogue_finish() -> void:
	dialogue = false
	self.hide()
	
	Globals.player_can_move = true
	Globals.switch_ui_mode()
	
	npc.dialogue = false
