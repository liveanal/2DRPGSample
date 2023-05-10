class_name SelectRow extends HBoxContainer

@export var data:SelectItem

@onready var texture := $texture
@onready var label := $label
@onready var count := $count

func _ready():
	update()

func update():
	texture.texture = data.texture
	label.text = data.name
	count.text = str(data.count) if data.is_multiple else ""
