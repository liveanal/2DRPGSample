class_name InventoryItem extends SelectItem

@export_group("SelectMenu")
@export var menu:Array[InventoryMenu]

func get_menu_labels():
	var arr := []
	for s in menu : arr.append(s.label)
	return arr
