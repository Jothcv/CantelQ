extends Control

@onready var list_vbox = $MainPanel/VBox/ListScroll/ListVBox
@onready var new_list_button = $MainPanel/VBox/ButtonsHBox/NewListButton
@onready var close_button = $MainPanel/VBox/ButtonsHBox/CloseButton

func _ready():
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Añadir esta línea
	new_list_button.pressed.connect(_on_new_list_pressed)
	close_button.pressed.connect(_on_close_pressed)
	update_display()

func _input(event):
	if event.is_action_pressed("open_shopping_list") or event.is_action_pressed("ui_cancel"):
		_on_close_pressed()

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
		return
	
	# Mostrar items
	for i in range(shopping_list.size()):
		var item = shopping_list[i]
		
		var item_container = HBoxContainer.new()
		
		var checkbox = CheckBox.new()
		var item_label = Label.new()
		item_label.text = str(i + 1) + ". " + item.item_name + " - $" + str(item.price)
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		item_container.add_child(checkbox)
		item_container.add_child(item_label)
		
		# Verificar si está en inventario
		if InventoryManager.inventory_items.has(item):
			var check_label = Label.new()
			check_label.text = "✓ En inventario"
			check_label.add_theme_color_override("font_color", Color.GREEN)
			item_container.add_child(check_label)
			checkbox.button_pressed = true
			checkbox.disabled = true
		
		list_vbox.add_child(item_container)
