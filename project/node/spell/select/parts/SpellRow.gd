class_name SpellRow extends HBoxContainer

@export var texture:Texture2D
@export var label:String
@export var cost:int

func _ready():
	update()

func update():
	$texture.texture = texture
	$label.text = label
	$cost.text = str(cost) + "MP"
