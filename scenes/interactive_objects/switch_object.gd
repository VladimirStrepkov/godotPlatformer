extends InteractiveObject
class_name SwitchObject

# Объекты, у которых мы будем вызывать функции при включении/выключении переключателя
@export var objects: Array[Node2D] 

# i-ый элемент - Название функции i-ого объекта, к-я срабатывает при включении переключателя
@export var on_functions: Array[String]

# i-ый элемент - название функции i-ого объекта, к-я срабатывает при выключении переключателя
@export var off_functions: Array[String]

# Активация переключателя
func activate() -> void:
	print(objects)
	print("из за того что у всех рычагов общий родитель (switch object) они имеют общий массив переключаемых объектов, поэтому каждый рычаг активирует объекты других рычагов. Надо исправлять")
	for i in range(len(objects)):
		objects[i].call(on_functions[i])

# Выключение переключателя
func deactivate() -> void:
	for i in range(len(objects)):
		objects[i].call(off_functions[i])
