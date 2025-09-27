extends Area2D
class_name Shelf

@export var shelf_products: Array[ItemData] = []
@export var shelf_name: String = "Estante"

var can_interact: bool = false
var player_in_area: bool = false
var interact_ui: Control
var shelf_ui_scene: PackedScene
var current_ui_instance: Node = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	create_interact_ui()
	shelf_ui_scene = preload("res://scenes/shelf_ui.tscn")

func _input(event):
	if event.is_action_pressed("interact") and can_interact and player_in_area:
		show_product_selection()

func create_interact_ui():
	interact_ui = Control.new()
	interact_ui.set_anchors_and_offsets_preset(Control.PRESET_CENTER) # centra la UI en su parent
	interact_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE # que no bloquee clicks
	var label = Label.new()
	label.text = "E"
	label.add_theme_font_size_override("font_size", 100)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	interact_ui.add_child(label)
	add_child(interact_ui)
	
	interact_ui.position = Vector2(0, -50)  # Tamaño más pequeño
	interact_ui.size = Vector2(20, 20)
	interact_ui.visible = false

func show_product_selection():
	if shelf_products.is_empty():	
		print("Este estante está vacío!")
		return
	
	if shelf_ui_scene == null:
		print("No se pudo cargar la interfaz del estante")
		return
	
	current_ui_instance = shelf_ui_scene.instantiate()
	get_tree().root.add_child(current_ui_instance)
	
	# Configurar la interfaz
	current_ui_instance.setup_shelf(shelf_name, shelf_products)
	current_ui_instance.product_selected.connect(_on_product_selected)
	current_ui_instance.ui_closed.connect(_on_ui_closed)
	
	hide_interact_prompt()
	get_tree().paused = true

func _on_product_selected(item: ItemData, add_to_inventory: bool):
	if add_to_inventory:
		InventoryManager.add_item(item)
		print("Producto añadido al inventario: " + item.item_name)
	else:
		# Aquí irá la lógica de "listo para vender" más adelante
		print("Producto marcado para vender: " + item.item_name)

func _on_ui_closed():
	current_ui_instance = null
	get_tree().paused = false
	if player_in_area:
		show_interact_prompt()

func _on_body_entered(body):
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = true
		show_interact_prompt()

func _on_body_exited(body):
	if body.has_method("is_player") or body.is_in_group("player"):
		player_in_area = false
		hide_interact_prompt()
		if current_ui_instance:
			current_ui_instance.queue_free()
			current_ui_instance = null
			get_tree().paused = false

func show_interact_prompt():
	can_interact = true
	interact_ui.visible = true

func hide_interact_prompt():
	can_interact = false
	interact_ui.visible = false
