class_name ItemRow extends HBoxContainer

@export var texture:Texture2D
@export var label:String
@export_group("stack setting")
@export var stackable:bool = false
@export var count:int

func _ready():
	update()

func update():
	$texture.texture = texture
	$label.text = label
	$count.text = str(count) if stackable else ""
