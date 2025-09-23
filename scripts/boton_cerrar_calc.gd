extends Button

# Script del botón (extends Button)
func _on_boton_cerrar_pressed():
	var panel = get_parent()  # obtiene el panel padre
	var main_node = panel.get_parent()  # obtiene el Node2D
	main_node.panel_calculadora_instance = null  # PRIMERO resetea la referencia
	panel.queue_free()  # DESPUÉS elimina el panellibera la referencia
