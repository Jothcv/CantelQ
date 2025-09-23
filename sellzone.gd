extends StaticBody2D

 

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("player_sell_method"):
		var carrots =Global.numofcarrots
		var  onions= Global.numofonion
		var coins = Global.coins
		
		#zanaora = 50 con iva segun la tienda 
		coins += carrots *50
		coins += onions*80
		
		carrots =0
		onions = 0
		
		Global.coins=coins
		Global.numofcarrots=carrots
		Global.numofonion=onions
