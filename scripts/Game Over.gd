extends Control


func _on_Game_victory(winner):
	if(winner == 'X'):
		$"X Wins".visible = true
		$Buttons.visible = true
		get_tree().paused = true
	if(winner == 'O'):
		$"O Wins".visible = true
		$Buttons.visible = true
		get_tree().paused = true
	


func _on_Game_tie():
	$Draw.visible = true
	$Buttons.visible = true
	get_tree().paused = true
	
