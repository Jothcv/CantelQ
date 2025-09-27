extends Resource
class_name ItemData

@export var item_name: String = ""
@export var price: int = 0
@export var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.CONSUMABLE

enum ItemType {
	CONSUMABLE,
	EQUIPMENT,
	MATERIAL,
	QUEST_ITEM
}
