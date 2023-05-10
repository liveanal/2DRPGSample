class_name ItemOSel extends OverlapSelectable

@export var row_res:PackedScene
@export var items:Array[SelectItem]

func _ready():
	super._ready()
	set_items(items)

func set_items(_items):
	super.set_items(mapping_items(_items))

func mapping_items(_items:Array)->Array:
	var res := []
	for item in _items : 
		res.append(mapping_item(item))
	return res

func mapping_item(item)->Node:
	var row := row_res.instantiate()
	row.data = item
	return row
