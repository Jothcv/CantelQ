extends CharacterBody2D

@export var speed: float = 50.0
@export var run_speed: float = 100.0

var animated_sprite: AnimatedSprite2D

func _ready() -> void:
	animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	# Movimiento
	input_vector.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	input_vector.y = Input.get_action_strength("bajar") - Input.get_action_strength("subir")
	input_vector = input_vector.normalized()

	# Velocidad normal o corriendo
	var current_speed = speed
	if Input.is_action_pressed("correr"):
		current_speed = run_speed

	velocity = input_vector * current_speed
	move_and_slide()

	# --- Animaciones ---
	if input_vector == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			# Movimiento horizontal
			if input_vector.x > 0:
				animated_sprite.play("sidewalk")
				animated_sprite.flip_h=true
			
			else:
				animated_sprite.play("sidewalk")
				animated_sprite.flip_h=false

		elif input_vector.y > 0:
			animated_sprite.play("downwalk")
		elif input_vector.y < 0:
			animated_sprite.play("upwalk")
			
func player_sell_method():
	pass
