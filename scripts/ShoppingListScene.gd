extends Control

@onready var list_vbox = $MainPanel/VBox/ListScroll/ListVBox
@onready var new_list_button = $MainPanel/VBox/ButtonsHBox/NewListButton
@onready var close_button = $MainPanel/VBox/ButtonsHBox/CloseButton

var iva_info_label: Label
var total_info_label: Label

func _ready():
	new_list_button.pressed.connect(_on_new_list_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	setup_ui_elements()
	update_display()

func setup_ui_elements():
	var main_panel = $MainPanel
	var vbox = $MainPanel/VBox
	
	# Crear contenedor superior para información del IVA
	var top_container = VBoxContainer.new()
	top_container.add_theme_constant_override("separation", 2)
	
	# Info del IVA (esquina superior)
	iva_info_label = Label.new()
	iva_info_label.text = "IVA: 12%\nFórmula: Precio × 1.12"
	iva_info_label.add_theme_font_size_override("font_size", 10)
	iva_info_label.add_theme_color_override("font_color", Color.YELLOW)
	iva_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	top_container.add_child(iva_info_label)
	
	# Separador
	var separator = HSeparator.new()
	top_container.add_child(separator)
	
	# Insertar al inicio del VBox
	vbox.add_child(top_container)
	vbox.move_child(top_container, 1)  # Después del título
	
	# Crear label para total (antes de los botones)
	total_info_label = Label.new()
	total_info_label.add_theme_font_size_override("font_size", 12)
	total_info_label.add_theme_color_override("font_color", Color.CYAN)
	total_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var buttons = $MainPanel/VBox/ButtonsHBox
	vbox.add_child(total_info_label)
	vbox.move_child(total_info_label, buttons.get_index())

#func _input(event):
	#if event.is_action_pressed("open_shopping_list") or event.is_action_pressed("ui_cancel"):
		#_on_close_pressed()

func _on_new_list_pressed():
	ShoppingListManager.generate_random_list()
	update_display()

func _on_close_pressed():
	ShoppingListManager.close_shopping_list()

func update_display():
	# Limpiar lista anterior
	for child in list_vbox.get_children():
		child.queue_free()
	
	var shopping_list = ShoppingListManager.get_shopping_list()
	
	if shopping_list.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Lista vacía"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list_vbox.add_child(empty_label)
		update_totals()
		return
	
	# Mostrar items
	for i in range(shopping_list.size()):
		var shopping_item = shopping_list[i]
		var item_data = shopping_item.item_data
		
		var item_container = HBoxContainer.new()
		item_container.add_theme_constant_override("separation", 2)
		
		# Checkbox (solo marcable si está en inventario)
		var checkbox = CheckBox.new()
		checkbox.button_pressed = shopping_item.is_collected
		checkbox.disabled = not shopping_item.is_collected
		
		# Si no está en inventario, mostrar como deshabilitado
		if not shopping_item.is_collected:
			checkbox.modulate = Color.GRAY
		
		item_container.add_child(checkbox)
		
		# Nombre del item con precio falso
		var item_label = Label.new()
		item_label.text = str(i + 1) + ". " + item_data.item_name + " - $" + str(shopping_item.fake_price)
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Cambiar color según si está recolectado
		if shopping_item.is_collected:
			item_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			item_label.add_theme_color_override("font_color", Color.WHITE)
		
		item_container.add_child(item_label)
		
		# Indicador de recolectado
		if shopping_item.is_collected:
			var status_label = Label.new()
			status_label.text = "✓ RECOLECTADO"
			status_label.add_theme_color_override("font_color", Color.GREEN)
			status_label.add_theme_font_size_override("font_size", 10)
			item_container.add_child(status_label)
		else:
			var status_label = Label.new()
			status_label.text = "Buscar en estantes"
			status_label.add_theme_color_override("font_color", Color.ORANGE)
			status_label.add_theme_font_size_override("font_size", 8)
			item_container.add_child(status_label)
		
		list_vbox.add_child(item_container)
	
	update_totals()

func update_totals():
	if total_info_label:
		var fake_total = ShoppingListManager.calculate_fake_total()
		var collected_count = ShoppingListManager.get_collected_count()
		var total_items = ShoppingListManager.get_shopping_list().size()
		
		total_info_label.text = "TOTAL A PAGAR: $" + str(fake_total) + "\n(" + str(collected_count) + "/" + str(total_items) + " productos recolectados)"
