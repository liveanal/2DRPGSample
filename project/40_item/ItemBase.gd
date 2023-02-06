class_name ItemBase extends Resource

enum MENUSET{ORGANIC,EQUIP,ESSENCE}

@export var item_id:String:
	set(val):
		item_id=val
		resource_name=item_id
	get:
		return item_id
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
@export_group("MenuOption")
@export var menu_type:MENUSET
@export var menu:Array[InventoryMenu]

func to_inventory_item()->InventoryItem:
	var item := InventoryItem.new()
	item.name = name
	item.texture = texture
	item.is_multiple = is_multiple
	item.count = count
	item.description = description
	item.menu = menu
	return item

func to_shop_item(type:int=0,cost:int=0)->ShopItem:
	var item := ShopItem.new()
	item.name = name
	item.texture = texture
	item.is_multiple = is_multiple
	item.count = count
	item.description = description
	item.cost=cost
	item.type = type
	return item

func _get_menuset()->Array[InventoryMenu]:
	var arr := menu.duplicate()
	match(menu_type):
		MENUSET.ORGANIC:
			arr.append(_get_menu_use())
		MENUSET.EQUIP:
			arr.append(_get_menu_equip())
		MENUSET.ESSENCE:
			arr.append(_get_menu_essence())
	arr.append(_get_menu_throw())
	arr.append(_get_menu_put())
	return arr

func _get_menu_use()->InventoryMenu:
	var m := InventoryMenu.new()
	m.label = "使う"
	return m

func _get_menu_equip()->InventoryMenu:
	var m := InventoryMenu.new()
	m.label = "装備する"
	return m

func _get_menu_essence()->InventoryMenu:
	var m := InventoryMenu.new()
	m.label = "付与する"
	return m

func _get_menu_throw()->InventoryMenu:
	var m := InventoryMenu.new()
	m.label = "投げる"
	return m

func _get_menu_put()->InventoryMenu:
	var m := InventoryMenu.new()
	m.label = "置く"
	return m
