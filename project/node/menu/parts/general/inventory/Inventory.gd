class_name Inventory extends MenuContent

signal finished_inventory_menu

enum USE_OPTION{USE,THROW,ESTIMATE}
const options := {
	USE_OPTION.USE      : "使う",
	USE_OPTION.THROW    : "投げる",
	USE_OPTION.ESTIMATE : "鑑定する"}

@export var member_index:int=0:
	set(val):
		member_index = posmod(val, self.party_member.size()) if not self.party_member.is_empty() else 0
	get:
		return member_index
@export var no_item_text:String = "アイテムがない。"
@export var list:ItemCSel
@export var menu:LabelCSel
@export var desc:RichTextLabel

func _ready():
	# 反映するアイテムリスト
	var items = party_member[member_index].data.inventory
	# 入力処理登録
	list.connect("pressed_accept",func(i):
		if !items.is_empty():
			list.disable()
			await _start_menu(items[i])
			list.enable())
	list.connect("pressed_cancel",func():close())
	list.connect("changed_index",func(_bi:int,_ai:int):
		if !items.is_empty():
			desc.text = items[_ai].description)
	# リスト初期化
	if !items.is_empty():
		list.set_items(items)
	
	close()

func _start_menu(item):
	menu.connect("pressed_accept",_accept.bind(item))
	menu.connect("pressed_cancel",_cancel)
	
	var labels = _get_menu_labels(item.menu)
	menu.set_items(labels)
	menu.enable()
	await finished_inventory_menu
	if item.count < 1:
		list.remove(item)
	else:
		list.update(item)
	menu.clear()
	menu.disable()
	
	menu.disconnect("pressed_accept",_accept)
	menu.disconnect("pressed_cancel",_cancel)

func _get_menu_labels(_menu:Array[Inventory.USE_OPTION]):
	var arr := []
	for s in _menu : arr.append(options[s])
	return arr

func _accept(index,item):
	match(item.menu[index]):
		USE_OPTION.USE:
			item.use(System.current_character,[System.current_character])
		USE_OPTION.THROW:
			item.throw(System.current_character)
		USE_OPTION.ESTIMATE:
			item.estimate(System.current_character)
	emit_signal("finished_inventory_menu")

func _cancel():
	emit_signal("finished_inventory_menu")

func open():
	var items = party_member[member_index].data.inventory
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
