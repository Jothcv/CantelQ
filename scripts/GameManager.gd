extends Node

signal game_won
signal game_lost

var player_total_calculation: float = 0.0
var player_overcharge_calculation: float = 0.0
var is_confrontation_active: bool = false

func _ready():
	# Conectar señales del diálogo
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# Funciones para que el diálogo pueda acceder a datos reales
func get_fake_total() -> int:
	return int(ShoppingListManager.calculate_fake_total())

func get_items_count() -> int:
	return get_collected_items_count()

func get_fake_total_float() -> float:
	return ShoppingListManager.calculate_fake_total()

func get_real_total_with_iva() -> float:
	var totals = calculate_correct_totals()
	return totals.real_total_with_iva
	
func get_real_total_with_iva_int() -> int:
	var totals = calculate_correct_totals()
	return int(totals.real_total_with_iva)

func get_overcharge_amount_int() -> int:
	var totals = calculate_correct_totals()
	return int(totals.overcharge)
	
func get_overcharge_amount() -> float:
	var totals = calculate_correct_totals()
	return totals.overcharge

func calculate_correct_totals() -> Dictionary:
	var shopping_list = ShoppingListManager.get_shopping_list()
	var real_total = 0.0
	var fake_total = 0.0
	
	# Calcular solo productos recolectados
	for shopping_item in shopping_list:
		if shopping_item.is_collected:
			real_total += shopping_item.real_price
			fake_total += shopping_item.fake_price
	
	var real_total_with_iva = real_total * 1.12
	var overcharge = fake_total - real_total_with_iva
	
	return {
		"real_total": real_total,
		"real_total_with_iva": real_total_with_iva,
		"fake_total": fake_total,
		"overcharge": overcharge,
		"items_count": get_collected_items_count()
	}

func get_collected_items_count() -> int:
	var count = 0
	for shopping_item in ShoppingListManager.get_shopping_list():
		if shopping_item.is_collected:
			count += 1
	return count

func start_confrontation():
	is_confrontation_active = true
	var totals = calculate_correct_totals()
	
	print("=== CONFRONTACIÓN INICIADA ===")
	print("Total real con IVA: $", snappedf(totals.real_total_with_iva, 0.01))
	print("Total falso: $", totals.fake_total)
	print("Estafa: $", snappedf(totals.overcharge, 0.01))

func check_player_answer(player_total: float, player_overcharge: float) -> bool:
	var totals = calculate_correct_totals()
	var correct_total = totals.real_total_with_iva
	var correct_overcharge = totals.overcharge
	
	# Tolerancia de ±0.50 para cálculos
	var total_tolerance = 0.50
	var overcharge_tolerance = 0.50
	
	var total_correct = abs(player_total - correct_total) <= total_tolerance
	var overcharge_correct = abs(player_overcharge - correct_overcharge) <= overcharge_tolerance
	
	print("=== VERIFICACIÓN DE RESPUESTA ===")
	print("Jugador dice total: $", player_total, " | Correcto: $", snappedf(correct_total, 0.01))
	print("Jugador dice estafa: $", player_overcharge, " | Correcto: $", snappedf(correct_overcharge, 0.01))
	print("Total correcto: ", total_correct, " | Estafa correcta: ", overcharge_correct)
	
	return total_correct and overcharge_correct

func player_wins():
	print("¡JUGADOR GANÓ!")
	game_won.emit()
	# Aquí puedes añadir efectos de victoria, cambio de escena, etc.

func player_loses():
	print("¡JUGADOR PERDIÓ!")
	game_lost.emit()
	reset_game()

func reset_game():
	# Limpiar inventario
	InventoryManager.inventory_items.clear()
	InventoryManager.inventory_updated.emit()
	
	# Generar nueva lista
	ShoppingListManager.generate_random_list()
	
	# Resetear estado
	is_confrontation_active = false
	player_total_calculation = 0.0
	player_overcharge_calculation = 0.0
	
	print("Juego reiniciado - ¡Intenta de nuevo!")

func _on_dialogue_ended(resource):
	if is_confrontation_active:
		is_confrontation_active = false
