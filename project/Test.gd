class_name Test extends Node

@export var dialog_data:DialogData

func _ready():
	await start()
	# DialogTest
	await DialogSystem.open_dialog(self,dialog_data,0.4)
	# LoggingTest
	await DialogSystem.open_logging()

func start():
	var fade:Fade = System.pop_fade()
	if fade != null:
		fade.start_out()
		await fade.finished

func give_item():
	print("give item.")
