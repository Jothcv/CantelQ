extends Node

var shopping_list_scene: PackedScene
var current_shopping_list: Array[ShoppingItem] = []
var all_available_items: Array[ItemData] = []
var current_list_instance: Node = null

# Productos base con precios reales (ocultos al usuario)
var base_products = {
	"banano": 16,
	"fresa": 5,
	"limon": 25,
	"PanIntegral": 25,
	"panMolde": 1,
	"panPeruano": 12,
	"XECA": 4,
	"frijol": 50,
	"zanahoria": 15
}

# Clase para items de la lista con precio falso
class ShoppingItem:
	var item_data: ItemData
	var fake_price: int
	var real_price: int
	var is_collected: bool = false
	
	func _init(item: ItemData, fake: int):
		item_data = item
		fake_price = fake
		real_price = item.price
		is_collected = false

func _ready():
	shopping_list_scene = preload("res://scenes/ShoppingListScene.tscn")
	load_available_items()
	generate_random_list()
	
	# Conectar señal de inventario para actualizar automáticamente
	InventoryManager.inventory_updated.connect(_on_inventory_updated)

func _input(event):
	if event.is_action_pressed("open_shopping_list "):
		toggle_shopping_list()

func load_available_items():
	# Cargar todos los productos base
	for product_name in base_products.keys():
		var item_path = "res://items/" + product_name + ".tres"
		if ResourceLoader.exists(item_path):
			var item = load(item_path) as ItemData
			if item:
				all_available_items.append(item)
				print("Producto cargado: ", item.item_name, " - $", item.price)
		else:
			print("ADVERTENCIA: No se encontró ", item_path)

func generate_random_list():
	current_shopping_list.clear()
	
	if all_available_items.is_empty():
		print("No hay items disponibles para la lista")
		return
	
	# Generar entre 4 y 7 items aleatorios
	var list_size = randi_range(4, 7)
	var selected_items = []
	
	# Seleccionar items únicos aleatoriamente
	while selected_items.size() < list_size and selected_items.size() < all_available_items.size():
		var random_item = all_available_items[randi() % all_available_items.size()]
		if not selected_items.has(random_item):
			selected_items.append(random_item)
	
	# Crear items de lista con precios falsos
	for item in selected_items:
		var fake_price = generate_fake_price(item.price)
		var shopping_item = ShoppingItem.new(item, fake_price)
		current_shopping_list.append(shopping_item)
		
		print("Lista: ", item.item_name, " - Precio falso: $", fake_price)

func generate_fake_price(real_price: int) -> int:
	# Generar precio falso entre 1 y 100, pero diferente al real
	var fake_price = randi_range(1, 100)
	
	# Asegurar que no sea igual al precio real
	while fake_price == real_price:
		fake_price = randi_range(1, 100)
	
	return fake_price

func _on_inventory_updated():
	# Actualizar estado de items recolectados
	for shopping_item in current_shopping_list:
		shopping_item.is_collected = InventoryManager.inventory_items.has(shopping_item.item_data)
	
	# Actualizar la interfaz si está abierta
	if current_list_instance and current_list_instance.has_method("update_display"):
		current_list_instance.update_display()

func get_shopping_list() -> Array[ShoppingItem]:
	return current_shopping_list

func calculate_fake_total() -> float:
	var total = 0.0
	for shopping_item in current_shopping_list:
		total += shopping_item.fake_price
	return total

func get_collected_count() -> int:
	var count = 0
	for shopping_item in current_shopping_list:
		if shopping_item.is_collected:
			count += 1
	return count

func toggle_shopping_list():
	if current_list_instance:
		close_shopping_list()
	else:
		open_shopping_list()

func open_shopping_list():
	if shopping_list_scene == null:
		return
	
	current_list_instance = shopping_list_scene.instantiate()
	get_tree().root.add_child(current_list_instance)

func close_shopping_list():
	if current_list_instance:
		current_list_instance.queue_free()
		current_list_instance = null
