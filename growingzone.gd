extends StaticBody2D

var plant = Global.plantselect
var plantgrowing= false
var plant_grown = false

func _physics_process(delta):
	print(Global.plantselect)
	if plantgrowing==false:
		plant=Global.plantselect

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not plantgrowing:
		if plant==1:
			plantgrowing==true	
			$carrotgrowtimer.start()
			$plant.play("carrotwroging")
		if plant==2:
			plantgrowing=true	
			$carrotgrowtimer.start()
			$plant.play("onionwroging")
	else:
		print("listo para plantar aca!!!")

func _on_oniongrowtimer_timeout():
	var onion_plant= $plant
	if onion_plant.frame==0:
		onion_plant.frame=1
		$oniongrowtimer.start()
	elif onion_plant.frame==1:
		onion_plant.frame=2
		plant_grown=true	


func _on_carrotgrowtimer_timeout():
	var carrot_plant= $plant
	if carrot_plant.frame == 0:
		carrot_plant.frame=1
		$carrotgrowtimer.start()
	elif carrot_plant.frame==1:
		carrot_plant.frame=2
		plant_grown=true	


func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		if plant_grown:
			if plant == 1: 
				Global.numofcarrots +=1
				plantgrowing=false
				plant_grown=false
				$plant.play("none")
			if plant == 2:
				Global.numofonion +=1
				plantgrowing=false
				plant_grown=false
				$plant.play("none")
			else: 
				pass
