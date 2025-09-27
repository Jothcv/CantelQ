# NPC_Interaction.gd
# Script para el Area2D de tu tienda

extends Area2D

# INSTRUCCIONES DE CONFIGURACIÓN:
# 1. En Project Settings > Input Map, crear una acción llamada "interact" y asignar la tecla E
# 2. Asegúrate de que tu jugador esté en el grupo "player" o tenga un método is_player()
# 3. En el inspector, arrastra tu archivo .dialogue a dialogue_resource
# 4. Cambia dialogue_start al título de tu diálogo (ej: "tienda_dialogo")

@export var dialogue_resource: DialogueResource  # Arrastra tu archivo .dialogue aquí
@export var dialogue_start: String = "start"  # El título de tu diálogo en el archivo

var can_interact: bool = false
var player_in_area: bool = false
var interact_ui: Control
var player_reference: Node

func _ready():
	# Conectar las señales del Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Crear la UI de interacción (la "E")
	create_interact_ui()

func _input(event):
	# Detectar cuando se presiona la tecla E
	if event.is_action_pressed("interact") and can_interact and player_in_area:
		start_dialogue()

func create_interact_ui():
	# Crear un Control node para mostrar la "E"
	interact_ui = Control.new()
	interact_ui.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Crear el label con la "E"
	var label = Label.new()
	label.text = "E"
	label.add_theme_font_size_override("font_size", 44)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	
	# Centrar el texto
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	interact_ui.add_child(label)
	add_child(interact_ui)
	
	# Posicionar la UI encima del NPC
	interact_ui.position = Vector2(0, -50)  # Ajusta según necesites
	interact_ui.visible = false

func _on_body_entered(body):
	# Verificar si el que entró es el jugador
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = true
		player_reference = body
		show_interact_prompt()

func _on_body_exited(body):
	# Verificar si el que salió es el jugador
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = false
		player_reference = null
		hide_interact_prompt()

func show_interact_prompt():
	can_interact = true
	interact_ui.visible = true
	# Opcional: animación de aparición
	var tween = create_tween()
	interact_ui.modulate.a = 0.0
	tween.tween_property(interact_ui, "modulate:a", 1.0, 0.3)

func hide_interact_prompt():
	can_interact = false
	# Opcional: animación de desaparición
	var tween = create_tween()
	tween.tween_property(interact_ui, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): interact_ui.visible = false)

func start_dialogue():
	if dialogue_resource == null:
		print("No hay diálogo asignado!")
		return
	
	# Pausar el juego (opcional)
	# get_tree().paused = true
	
	# Iniciar el diálogo con Dialogue Manager v3
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	
	# Ocultar el prompt mientras está en diálogo
	hide_interact_prompt()
	
	# Conectar señal para cuando termine el diálogo
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(resource):
	# Reactivar el juego si lo pausaste
	# get_tree().paused = false
	
	# Mostrar el prompt de nuevo si el jugador sigue en el área
	if player_in_area:
		show_interact_prompt()
