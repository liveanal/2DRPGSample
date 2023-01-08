class_name Inventory extends Control

signal pressed_accept(item:SelectItem,select:InventoryMenu)
signal pressed_cancel
signal finished_inventory_menu

@export var items:Array[InventoryItem]
@export var list:ItemCSel
@export var menu:LabelCSel
@export var desc:RichTextLabel

func _ready():
	menu.disable()
	list.connect("pressed_accept",func(i):
		list.disable()
		await start_menu(items[i])
		list.enable())
	list.connect("pressed_cancel",func():
		emit_signal("pressed_cancel")
		queue_free())
	list.connect("changed_index",func(before_idx,after_idx):
		desc.text = items[after_idx].description)
	if !items.is_empty():
		list.set_items(items)
	close()
	open()

func open():
	list.enable()
	visible = true

func close():
	list.disable()
	visible = false

func start_menu(item):
	var accept := func(i):
		emit_signal("pressed_accept", item, item.menu[i])
		emit_signal("finished_inventory_menu")
	var cancel := func():
		emit_signal("finished_inventory_menu")
	
	menu.connect("pressed_accept",accept)
	menu.connect("pressed_cancel",cancel)
	
	await menu.set_items(item.get_menu_labels())
	menu.enable()
	await finished_inventory_menu
	menu.clear()
	menu.disable()
	
	menu.disconnect("pressed_accept",accept)
	menu.disconnect("pressed_cancel",cancel)
