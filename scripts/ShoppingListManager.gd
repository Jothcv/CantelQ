extends Node

var shopping_list_scene: PackedScene
var current_shopping_list: Array[ItemData] = []
var all_available_items: Array[ItemData] = []
var current_list_instance: Node = null

func _ready():
	shopping_list_scene = preload("res://scenes/ShoppingListScene.tscn")

func _input(event):
	if event.is_action_pressed("open_shopping_list "):
		toggle_shopping_list()

func set_available_items(items: Array[ItemData]):
	all_available_items = items
	generate_random_list()

func generate_random_list():
	current_shopping_list.clear()
	if all_available_items.is_empty():
		return
	
	var list_size = randi_range(3, 8)
	for i in range(list_size):
		var random_item = all_available_items[randi() % all_available_items.size()]
		current_shopping_list.append(random_item)

func get_shopping_list() -> Array[ItemData]:
	return current_shopping_list

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
	get_tree().paused = false

func close_shopping_list():
	if current_list_instance:
		current_list_instance.queue_free()
		current_list_instance = null
		get_tree().paused = false
