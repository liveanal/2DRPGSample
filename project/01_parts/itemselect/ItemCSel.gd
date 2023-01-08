class_name ItemCSel extends CursorSelectable

@export var row_res:PackedScene
@export var items:Array[SelectItem]

func _ready():
	super._ready()
	set_items(items)

func set_items(items):
	super.set_items(mapping_items(items))

func mapping_items(items)->Array:
	var res := []
	for item in items : 
		res.append(mapping_item(item))
	return res

func mapping_item(item)->Node:
	var row := row_res.instantiate()
	row.data = item
	return row
