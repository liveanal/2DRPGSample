class_name Loading extends CanvasLayer

@onready var prog := $progress

func clear():
	prog.value = 0

func update(progress):
	prog.value = progress
