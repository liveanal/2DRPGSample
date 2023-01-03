class_name ItemOSel extends OverlapSelectable

@export var row_res:PackedScene
@export var items:Array[SelectItem]

func _ready():
	super._ready()
	set_items(mapping_items(items))

func mapping_items(items)->Array:
	var res := []
	for val in items : 
		res.append(mapping_item(val))
	return res

func mapping_item(val)->Node:
	var row := row_res.instantiate()
	row.data = val
	return row
