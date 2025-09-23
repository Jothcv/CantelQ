extends StaticBody2D

var selected =false 
var seet_type = 2 #onion

func _ready():
	$AnimatedSprite2D.play("default")
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("click"):
		Global.plantselect=seet_type
		selected=true	
		
func  _physics_process(delta):
	if selected:
		global_position=lerp(global_position,get_global_mouse_position(),25*delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
