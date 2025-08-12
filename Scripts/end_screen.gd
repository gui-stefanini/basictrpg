extends CanvasLayer

signal restart_requested

@export var MessageLabel : Label
@export var RestartButton : Button

func ShowEndScreen(is_victory: bool):
	if is_victory:
		MessageLabel.text = "You Win!"
	else:
		MessageLabel.text = "Game Over"
	show()

func _on_restart_button_pressed():
	restart_requested.emit()
