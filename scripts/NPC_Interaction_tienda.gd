extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

var can_interact: bool = false
var player_in_area: bool = false
var interact_ui: Control
var player_reference: Node
var confrontation_ui: Control

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	create_interact_ui()
	
	# Conectar señales del GameManager
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)

func _input(event):
	if event.is_action_pressed("interact") and can_interact and player_in_area:
		# Verificar si el jugador tiene productos
		if InventoryManager.inventory_items.is_empty():
			print("¡Necesitas productos para vender!")
			return
		
		start_dialogue()

func create_interact_ui():
	interact_ui = Control.new()
	
	var label = Label.new()
	label.text = "E"
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	interact_ui.add_child(label)
	add_child(interact_ui)
	interact_ui.position = Vector2(0, -50)
	interact_ui.visible = false

func start_dialogue():
	if dialogue_resource == null:
		print("No hay diálogo asignado!")
		return
	
	# Establecer variables del diálogo
	setup_dialogue_variables()
	
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	hide_interact_prompt()
	
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func setup_dialogue_variables():
	# Calcular totales para el diálogo
	var totals = GameManager.calculate_correct_totals()
	var items_count = GameManager.get_collected_items_count()
	
	get_tree().set_meta("dialogue_items_count", items_count)
	get_tree().set_meta("dialogue_fake_total", totals.fake_total)
	
func show_confrontation_ui():
	if confrontation_ui:
		return  # Ya existe
	
	GameManager.start_confrontation()
	
	confrontation_ui = Panel.new()
	confrontation_ui.size = Vector2(500, 300)
	confrontation_ui.position = get_viewport().size / 2 - confrontation_ui.size / 2
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	
	# Título
	var title = Label.new()
	title.text = "¡MOMENTO DE LA VERDAD!"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(title)
	
	# Instrucciones
	var instructions = Label.new()
	instructions.text = "Ingresa tus cálculos para confrontar al vendedor:"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instructions)
	
	# Input para total con IVA
	var total_label = Label.new()
	total_label.text = "Total real con IVA que deberías pagar:"
	vbox.add_child(total_label)
	
	var total_input = LineEdit.new()
	total_input.name = "TotalInput"
	total_input.placeholder_text = "Ej: 45.67"
	vbox.add_child(total_input)
	
	# Input para estafa
	var overcharge_label = Label.new()
	overcharge_label.text = "Dinero que intentó estafarte:"
	vbox.add_child(overcharge_label)
	
	var overcharge_input = LineEdit.new()
	overcharge_input.name = "OverchargeInput"
	overcharge_input.placeholder_text = "Ej: 15.32"
	vbox.add_child(overcharge_input)
	
	# Botones
	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var confront_button = Button.new()
	confront_button.text = "¡CONFRONTAR!"
	confront_button.pressed.connect(_on_confront_pressed)
	button_hbox.add_child(confront_button)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	cancel_button.pressed.connect(_on_cancel_confrontation)
	button_hbox.add_child(cancel_button)
	
	vbox.add_child(button_hbox)
	confrontation_ui.add_child(vbox)
	get_tree().root.add_child(confrontation_ui)

func _on_confront_pressed():
	var total_input = confrontation_ui.find_child("TotalInput") as LineEdit
	var overcharge_input = confrontation_ui.find_child("OverchargeInput") as LineEdit
	
	var player_total = total_input.text.to_float()
	var player_overcharge = overcharge_input.text.to_float()
	
	if player_total <= 0 or player_overcharge < 0:
		print("Ingresa valores válidos")
		return
	
	var is_correct = GameManager.check_player_answer(player_total, player_overcharge)
	
	hide_confrontation_ui()
	
	if is_correct:
		show_victory_dialogue()
	else:
		show_defeat_dialogue()

func _on_cancel_confrontation():
	hide_confrontation_ui()

func hide_confrontation_ui():
	if confrontation_ui:
		confrontation_ui.queue_free()
		confrontation_ui = null

func show_victory_dialogue():
	# Mostrar diálogo de victoria
	DialogueManager.show_dialogue_balloon(dialogue_resource, "victory")

func show_defeat_dialogue():
	# Mostrar diálogo de derrota
	DialogueManager.show_dialogue_balloon(dialogue_resource, "defeat")

func _on_game_won():
	print("¡Felicitaciones! ¡Desenmascaraste al estafador!")

func _on_game_lost():
	print("¡Mejor suerte la próxima vez!")

func _on_body_entered(body):
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = true
		player_reference = body
		show_interact_prompt()

func _on_body_exited(body):
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = false
		player_reference = null
		hide_interact_prompt()

func show_interact_prompt():
	can_interact = true
	interact_ui.visible = true

func hide_interact_prompt():
	can_interact = false
	interact_ui.visible = false

func _on_dialogue_ended(resource):
	if player_in_area:
		show_interact_prompt()

# Funciones que el diálogo puede llamar
func start_confrontation_from_dialogue():
	show_confrontation_ui()

func restart_game_from_dialogue():
	GameManager.reset_game()
