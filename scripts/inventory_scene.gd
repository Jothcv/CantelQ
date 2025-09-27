extends Control

@onready var items_vbox = $MainPanel/VBox/ItemsList/ItemsVBox
@onready var close_button = $MainPanel/VBox/ButtonsHBox/CloseButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Añadir esta línea
	close_button.pressed.connect(_on_close_pressed)
	update_display()

func _input(event):
	if event.is_action_pressed("open_inventory") or event.is_action_pressed("ui_cancel"):
		_on_close_pressed()

func _on_close_pressed():
	InventoryManager.close_inventory()

func update_display():
	# Limpiar items anteriores
	for child in items_vbox.get_children():
		child.queue_free()
	
	var items = InventoryManager.get_inventory_items()
	
	if items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventario vacío"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		items_vbox.add_child(empty_label)
		return
	
	# Agrupar items iguales
	var item_counts = {}
	for item in items:
		if item in item_counts:
			item_counts[item] += 1
		else:
			item_counts[item] = 1
	
	# Mostrar items
	for item in item_counts.keys():
		var item_container = HBoxContainer.new()
		
		var item_label = Label.new()
		var count_text = " x" + str(item_counts[item]) if item_counts[item] > 1 else ""
		item_label.text = item.item_name + count_text + " - $" + str(item.price)
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		item_container.add_child(item_label)
		items_vbox.add_child(item_container)
