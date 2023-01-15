class_name Inventory extends MenuControl

signal pressed_accept(item:SelectItem,select:InventoryMenu)
signal pressed_cancel
signal finished_inventory_menu

@export var no_item_text:String = "アイテムがない。"
@export var items:Array[InventoryItem]
@export var list:ItemCSel
@export var menu:LabelCSel
@export var desc:RichTextLabel

func _ready():
	list.connect("pressed_accept",func(i):
		if !items.is_empty():
			list.disable()
			await _start_menu(items[i])
			list.enable())
	list.connect("pressed_cancel",func():close())
	list.connect("changed_index",func(_bi:int,_ai:int):
		if !items.is_empty():
			desc.text = items[_ai].description)
	
	if !items.is_empty():
		list.set_items(items)
	
	close()

func _start_menu(item):
	var accept := func(i):
		emit_signal("pressed_accept", item, item.menu[i])
		emit_signal("finished_inventory_menu")
	var cancel := func():
		emit_signal("finished_inventory_menu")
	
	menu.connect("pressed_accept",accept)
	menu.connect("pressed_cancel",cancel)
	
	var labels = item.get_menu_labels()
	menu.set_items(labels)
	menu.enable()
	await finished_inventory_menu
	menu.clear()
	menu.disable()
	
	menu.disconnect("pressed_accept",accept)
	menu.disconnect("pressed_cancel",cancel)

func open():
	super.open()
	if !items.is_empty():
		list.enable()
	else:
		desc.text = no_item_text
		list.is_input = true

func close():
	menu.disable()
	list.disable()
	super.close()

func append(item):
	list.add_item(list.mapping_item(item))
