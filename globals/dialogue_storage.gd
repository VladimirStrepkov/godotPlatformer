extends Node
# В этом скрипте хранятся диалоги

# Словарь диалогов
var dialogues: Dictionary = Dictionary()

# Какой диалог мы сейчас редактируем
var current_dialogue: int

# Какую фразу мы сейчас редактируем
var current_phrase: int

# Создать новый диалог с номером _dialogue_number
func create_dialog(_dialogue_number:int) -> void:
	dialogues[_dialogue_number] = Dictionary()
	current_dialogue = _dialogue_number

# Создать новую фразу 
# "phrase_number - номер фразы в диалоге с номером current_dialogue
# phrase_text - текст этой фразы
func create_phrase(phrase_number: int, phrase_text: String) -> void:
	dialogues[current_dialogue][phrase_number] = {
		"phrase_text" : phrase_text,
		"choices" : Array()
	}
	current_phrase = phrase_number

# Добавить выбор для последней фразы
# choice_text - Текст выбора (текст кнопки)
#  phrase_number - Номер фразы, на которую перенесёт этот выбор
# function - название функции, которая вызовется после нажатия на кнопку выбора
func create_choice(choice_text:String, next_phrase_number:int, function: String = "") -> void:
	var new_choice = {
		"choice_text" : choice_text,
		"next_phrase_number" : next_phrase_number,
		"function" : function
	}
	dialogues[current_dialogue][current_phrase]["choices"].append(new_choice)

# Инструкция по созданию диалогов:
# 1) Создаём новый диалог, выбираем для него номер (который потом назначим НПС)
# 2) Создаём вступительную фразу для этого диалога, её номер должен быть 0
# 3) Добавляем для неё выборы, к-е будут переносить на фразы с другими номерами
# 4) Создаём эти фразы с другими номерами
# 5) Cоздаём для каждой из них выборы
# и т.д.
# Каждый выбор также может вызывать любую функцию из этого скрипта, например
# функция exit_from_dialogue выходит из диалога

# Создаём диалоги
func _ready() -> void:
	# Первый диалог
	create_dialog(1)
	
	create_phrase(0, "Приветствую тебя")
	create_choice("Привет", 1)
	create_choice("Как дела?", 2)
	create_choice("Пока", 0, "exit_from_dialogue")
	
	create_phrase(1, "Слушай, не хочешь ли ты мне помочь?")
	create_choice("Да", 3)
	create_choice("Нет", 0, "exit_from_dialogue")
	
	create_phrase(2, "У меня дела хорошо, но мне нужна помочь, не хочешь помочь?")
	create_choice("Да", 3)
	create_choice("Нет", 0, "exit_from_dialogue")
	
	create_phrase(3, "Мне нужно чтобы ты протестировал новую систему диалогов")
	create_choice("Как мне это сделать?", 4)
	
	create_phrase(4, "Тебе нужно поговорить с чуваком, который ходит на другой стороне острова")
	create_choice("Хорошо", 0, "exit_from_dialogue")
	
	# Второй диалог
	create_dialog(2)
	create_phrase(0, "Ты от Джека?")
	create_choice("Да", 1)
	create_choice("Нет", 2)
	
	create_phrase(1, "Отлично, значит ты знаешь что нам нужно протестировать новую систему диалогов")
	create_choice("Далее", 3)
	
	var t =  """Сейчас я попробую рассказать тебе большую историю о том как я стал таким 
				какой я есть. Всё началось с детства, я очень много читал,
				поэтому сейчас знаю о мире куда больше любого человека. Вот
				так вот. Я могу многое тебе поведать.
	"""
	create_phrase(3, t)
	create_choice("Далее", 4)
	
	t =  """Например я умею делать отступы в твоём диалоговом окне
			Не веришь?
			Проверь.
			Это довольно удобно.
		"""
	create_phrase(4, t)
	create_choice("Далее", 5)
	
	t =  """Но это не самое отпадное. Самое отпадное то,
			что я могу перенести тебя абсолютно на любую
			свою реплику, давай проверим?	
	"""
	create_phrase(5, t)
	create_choice("Давай", 3)
	
	create_phrase(2, "Тогда иди сначала поговори с Джеком, он на другой стороне острова")
	create_choice("Ок", 0, "exit_from_dialogue")
	
# Далее идут функции вызываемые кнопками выбора

# Выйти из диалога
func exit_from_dialogue() -> void:
	DialogueController.dialogue_finish()
