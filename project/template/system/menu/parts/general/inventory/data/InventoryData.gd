class_name InventoryData extends SelectItem

@export_group("SelectMenu")
@export var menu:Array[UseOption]

func get_menu_labels():
	var arr := []
	for s in menu : arr.append(s.label)
	return arr
