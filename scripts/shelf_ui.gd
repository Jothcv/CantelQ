extends Control

signal product_selected(item: ItemData, add_to_inventory: bool)
signal ui_closed

@onready var shelf_title = $ProductPanel/VBox/ShelfTitle
@onready var products_vbox = $ProductPanel/VBox/ProductsScroll/ProductsVBox
@onready var close_button = $ProductPanel/VBox/ButtonsHBox/CloseButton

var current_products: Array[ItemData] = []

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Añadir esta línea
	close_button.pressed.connect(_on_close_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()

func setup_shelf(name: String, products: Array[ItemData]):
	shelf_title.text = name
	current_products = products
	display_products()

func display_products():
	# Limpiar productos anteriores
	for child in products_vbox.get_children():
		child.queue_free()
	
	# Crear botones para cada producto
	for i in range(current_products.size()):
		var item = current_products[i]
		if item == null:
			continue
		
		var product_container = VBoxContainer.new()
		product_container.add_theme_constant_override("separation", 5)
		
		# Label del producto
		var product_label = Label.new()
		product_label.text = item.item_name + " - $" + str(item.price)
		product_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		product_container.add_child(product_label)
		
		# Botones de acción
		var buttons_hbox = HBoxContainer.new()
		buttons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Botón para inventario
		var inventory_button = Button.new()
		inventory_button.text = "Al Inventario"
		inventory_button.pressed.connect(_on_inventory_button_pressed.bind(item))
		buttons_hbox.add_child(inventory_button)
		
		# Botón para venta (futuro)
		var sell_button = Button.new()
		sell_button.text = "Listo para Vender"
		sell_button.pressed.connect(_on_sell_button_pressed.bind(item))
		buttons_hbox.add_child(sell_button)
		
		product_container.add_child(buttons_hbox)
		
		# Separador
		var separator = HSeparator.new()
		product_container.add_child(separator)
		
		products_vbox.add_child(product_container)

func _on_inventory_button_pressed(item: ItemData):
	product_selected.emit(item, true)  # true = añadir a inventario
	_on_close_pressed()

func _on_sell_button_pressed(item: ItemData):
	product_selected.emit(item, false)  # false = listo para vender
	_on_close_pressed()

func _on_close_pressed():
	ui_closed.emit()
	queue_free()
