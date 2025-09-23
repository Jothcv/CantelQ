# Script del Node2D (extends Node2D)
extends Node2D

var panel_calculadora_instance: Panel = null

func _physics_process(delta):
	$carrottext.text = ("= " + str(Global.numofcarrots))
	$oniontext.text = ("= " + str(Global.numofonion))
	$cointext.text = ("= " + str(Global.coins))

func _input(event):
	if event.is_action_pressed("calculadora"):
		print("Tecla T presionada")
		print("panel_calculadora_instance actual: ", panel_calculadora_instance)
		
		if panel_calculadora_instance == null:
			print("Creando nuevo panel")
			panel_calculadora_instance = preload("res://img/productos/panel_calculadora.tscn").instantiate()
			add_child(panel_calculadora_instance)
			panel_calculadora_instance.panel_cerrado.connect(_on_panel_cerrado)
			print("Panel creado y conectado")
		else:
			print("Panel ya existe, no creando uno nuevo")

func _on_panel_cerrado():
	print("Señal de panel cerrado recibida")
	panel_calculadora_instance = null
	print("Referencia resetada a null")
