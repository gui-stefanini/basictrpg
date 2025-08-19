class_name Level1Manager
extends LevelManager

func _on_unit_died(unit: Unit):
	if unit in PlayerUnits:
		PlayerUnits.erase(unit)
	elif unit in EnemyUnits:
		EnemyUnits.erase(unit)
	
	print("%s has been defeated!" % unit.name)
	
	var remaining_players = 0
	for player in PlayerUnits:
		if not player.IsDead:
			remaining_players += 1
	
	var remaining_enemies = 0
	for enemy in EnemyUnits:
		if not enemy.IsDead:
			remaining_enemies += 1
	if remaining_players == 0:
		print("All player units defeated!")
		defeat.emit()
	elif remaining_enemies == 0:
		print("All enemies defeated!")
		victory.emit()
