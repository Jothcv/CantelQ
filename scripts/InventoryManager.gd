extends Node

signal inventory_updated

var inventory_items: Array[ItemData] = []
var inventory_scene: PackedScene
var current_inventory_instance: Node = null

func _ready():
	inventory_scene = preload("res://scenes/InventoryScene.tscn")

func _input(event):
	if event.is_action_pressed("open_inventory "):
		toggle_inventory()

func add_item(item: ItemData):
	if item == null:
		return
	inventory_items.append(item)
	inventory_updated.emit()
	print("Item añadido: " + item.item_name)

func remove_item(item: ItemData):
	var index = inventory_items.find(item)
	if index != -1:
		inventory_items.remove_at(index)
		inventory_updated.emit()

func get_inventory_items() -> Array[ItemData]:
	return inventory_items

func toggle_inventory():
	if current_inventory_instance:
		close_inventory()
	else:
		open_inventory()

func open_inventory():
	if inventory_scene == null:
		return
	
	current_inventory_instance = inventory_scene.instantiate()
	get_tree().root.add_child(current_inventory_instance)
	get_tree().paused = false

func close_inventory():
	if current_inventory_instance:
		current_inventory_instance.queue_free()
		current_inventory_instance = null
		get_tree().paused = false
