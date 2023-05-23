class_name ItemOSel extends OverlapSelectable

@export var row_res:PackedScene
@export var items:Array[ItemData]

var item_rows := {}

func _ready():
	super._ready()
	set_items(items)

func set_items(_items):
	super.set_items(mapping_items(_items))

func mapping_items(_items:Array)->Array:
	var res := []
	for item in _items : 
		var row := mapping_item(item)
		item_rows[item] = row
		res.append(row)
	return res

func mapping_item(item)->Node:
	var row := row_res.instantiate()
	row.texture = item.icon
	row.label = item.name
	row.count = item.count
	row.stackable = item.stackable
	return row

func remove(item):
	item_rows[item].queue_free()
	item_rows.erase(item)
	index_max -=1
	index +=1

func update(item):
	item_rows[item].texture = item.icon
	item_rows[item].label = item.name
	item_rows[item].count = item.count
	item_rows[item].stackable = item.stackable
