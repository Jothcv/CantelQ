# Script del panel (extends Panel)
extends Panel

signal panel_cerrado

# Variables de la calculadora
@onready var display = $VBoxContainer/Display
var expresion = ""

# Variables para el movimiento del panel
var offset = Vector2.ZERO

func _ready():
	print("Panel creado")
	
	# Detectar automáticamente todos los botones y sus nombres
	var grid = $VBoxContainer/GridContainer
	print("Botones encontrados:")
	for child in grid.get_children():
		if child is Button:
			print("- ", child.name, " (texto: '", child.text, "')")
	
	# Conectar botones automáticamente basado en su TEXTO, no en su nombre
	for child in grid.get_children():
		if child is Button:
			var texto_boton = child.text
			child.pressed.connect(_on_button_pressed.bind(texto_boton))
			print("Conectado botón con texto: '", texto_boton, "'")
	
	# Conectar el botón de cerrar
	if $BotonCerrarCalc.pressed.connect(_on_boton_cerrar_pressed) != OK:
		print("Error conectando botón cerrar")
	
	# Inicializar display
	display.text = "0"

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				offset = get_global_mouse_position() - global_position
			else:
				offset = Vector2.ZERO
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			global_position = get_global_mouse_position() - offset

func _input(event):
	# Detectar Enter para calcular resultado
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_calcular_resultado()

func _on_button_pressed(texto):
	print("Botón presionado: '", texto, "'")
	
	# Normalizar el texto del botón
	var texto_normalizado = texto.strip_edges()
	
	match texto_normalizado:
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
			if display.text == "0":
				expresion = texto_normalizado
			else:
				expresion += texto_normalizado
			display.text = expresion
		
		".":
			# Verificar si ya hay un punto en el número actual
			var ultimo_numero = _obtener_ultimo_numero()
			if not "." in ultimo_numero:
				if expresion == "" or expresion[-1] in "+-×÷*/":
					expresion += "0."
				else:
					expresion += "."
				display.text = expresion
		
		"+":
			if expresion != "" and not expresion[-1] in "+-×÷*/":
				expresion += "+"
				display.text = expresion
		
		"-":
			if expresion != "" and not expresion[-1] in "+-×÷*/":
				expresion += "-"
				display.text = expresion
		
		"*", "×", "x", "X":  # Aceptar múltiples formas de multiplicación
			if expresion != "" and not expresion[-1] in "+-×÷*/":
				expresion += "×"
				display.text = expresion
		
		"/", "÷":  # Aceptar múltiples formas de división
			if expresion != "" and not expresion[-1] in "+-×÷*/":
				expresion += "÷"
				display.text = expresion
		
		"=":
			_calcular_resultado()
		
		"C", "CE", "Clear":  # Aceptar múltiples formas de limpiar
			expresion = ""
			display.text = "0"
		
		_:
			print("Botón no reconocido: '", texto_normalizado, "'")

func _obtener_ultimo_numero():
	var operadores = ["+", "-", "×", "÷", "*", "/"]
	var ultimo_operador = -1
	
	for i in range(expresion.length() - 1, -1, -1):
		if expresion[i] in operadores:
			ultimo_operador = i
			break
	
	if ultimo_operador == -1:
		return expresion
	else:
		return expresion.substr(ultimo_operador + 1)

func _calcular_resultado():
	if expresion == "":
		return
	
	# Reemplazar símbolos para evaluación
	var expr_eval = expresion
	expr_eval = expr_eval.replace("×", "*")
	expr_eval = expr_eval.replace("÷", "/")
	
	print("Evaluando: ", expr_eval)
	
	# Evaluar usando la función incorporada de Godot
	var expression = Expression.new()
	var error = expression.parse(expr_eval)
	
	if error != OK:
		print("Error de parsing: ", expression.get_error_text())
		display.text = "Error"
		expresion = ""
		return
	
	var resultado = expression.execute()
	
	if expression.has_execute_failed():
		print("Error de ejecución")
		display.text = "Error"
		expresion = ""
	else:
		print("Resultado: ", resultado)
		# Formatear el resultado
		if resultado is float and resultado == int(resultado):
			expresion = str(int(resultado))
		else:
			expresion = str(resultado)
		display.text = expresion

func _on_boton_cerrar_pressed():
	print("Cerrando panel")
	panel_cerrado.emit()
	queue_free()
