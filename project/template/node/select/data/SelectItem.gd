class_name SelectItem extends Resource

@export var item:ItemData
@export var name:String
@export var texture:Texture2D
@export_group("Multiple")
@export var is_multiple:bool
@export var count:int=1:
	set(val):
		count = val if 0<val else 1
	get:
		return count
@export_group("Description")
@export_multiline var description:String
