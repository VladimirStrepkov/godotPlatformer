shader_type canvas_item;

// Внешняя переменная (uniform) типа vec3 (означающего source_color)
uniform vec3 color: source_color = vec3(1);
// float значение от 0.0 до 1.0 с шагом 0.1, сейчас равно 0
uniform float progress: hint_range(0.0, 1.0, 0.1) = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Получаю альфа-канал пикселя
	float current_a = texture(TEXTURE, UV).a;
	// создаю цвет, в котором rgb-каналы делаю единицами, альфа-канал оставляю прежним
	vec4 target_color = mix(texture(TEXTURE, UV), vec4(color, current_a), progress);
	// Меняю цвет пикселя на созданный
	COLOR = target_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
