class_name Shop extends MenuContent

signal pressed_accept(shop_money:int,shop_items:Array,player_money:int,inventory_items:Array)
signal finished_menu
signal finished_table

const operation_text := {
	OpStatus.SELECT:"↑↓：移動　　←→：購入/解除　　Shift+←→：タブ切替　　Esc：決定/キャンセル",
	OpStatus.MENU:"↑↓：移動　　Esc：アイテム選択に戻る　　『決定』：購入確定　　『キャンセル』：取引終了"
}

@export_group("Trade Setting")
@export_subgroup("Shop")
@export var shop_name:String
@export var shop_money:int
@export var shop_items:Array[ShopItem]
@export_subgroup("Player")
@export var player_name:String
@export var player_money:int
@export var inventory_items:Array[ShopItem]
@export_group("Layout Setting")
@export var shop_table:ItemCSel
@export var inventory_table:ItemCSel
@export var tab:TabContainer
@export var menu:LabelCSel
@export var operation:Label
@export var p_name:RichTextLabel
@export var p_ledge:RichTextLabel
@export var p_sum:RichTextLabel
@export var s_name:RichTextLabel
@export var s_ledge:RichTextLabel
@export var s_sum:RichTextLabel
@export var description:RichTextLabel
@export var iteminfo:RichTextLabel
@export_group("Input Setting")
@export var tab_next:="tab_next"
@export var tab_prev:="tab_prev"
@export var count_add:="right"
@export var count_sub:="left"

enum OpStatus{SELECT,MENU}
var op_status:OpStatus

enum TableState{BUY,SELL}
var table_status:TableState

func _ready():
	super._ready()
	menu.connect("pressed_accept",func(i):
		if i==0:finish_shop()
		else:
			emit_signal("finished_menu")
			close())
	menu.connect("pressed_cancel",return_table)
	shop_table.connect("changed_index",update_infomation)
	shop_table.connect("pressed_accept",add_cart_item)
	shop_table.connect("pressed_cancel",table_cancel)
	inventory_table.connect("changed_index",update_infomation)
	inventory_table.connect("pressed_accept",add_cart_item)
	inventory_table.connect("pressed_cancel",table_cancel)

func _input(event):
	if event is InputEventKey:
		if !tab_next.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(tab_next) and event.is_action(tab_next):
			change_tab(1)
		elif !tab_prev.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(tab_prev) and event.is_action(tab_prev):
			change_tab(-1)
		elif !count_add.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(count_add) and event.is_action(count_add):
			add_cart_item(get_current_table().index)
		elif !count_sub.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(count_sub) and event.is_action(count_sub):
			sub_cart_item(get_current_table().index)

func open():
	update()
	op_status = OpStatus.SELECT
	table_status = TableState.BUY
	menu.index = 0
	update_operation()
	update_transaction()
	start_table()
	super.open()

func close():
	menu.disable()
	shop_table.disable()
	inventory_table.disable()
	super.disable()

func start_menu():
	menu.enable()
	await finished_menu
	menu.disable()

func start_table():
	get_current_table().enable()
	await finished_table
	get_current_table().disable()

func update():
	if !shop_items.is_empty():
		var arr := []
		for entry in shop_items:
			arr.append(entry.item)
		shop_table.set_items(arr)
		await shop_table.setted_rows
	
	if !inventory_items.is_empty():
		var arr := []
		for entry in inventory_items:
			arr.append(entry.item)
		inventory_table.set_items(arr)
		await inventory_table.setted_rows

func update_operation():
	operation.text = operation_text[op_status]

func update_infomation(before_index,after_index):
	description.text = get_current_item().item.description

func update_transaction_player(buy:int, sell:int):
	var name_text  := "[center][b]{name}[/b][/center]"
	var ledge_text := "[table=3]"
	ledge_text += "[cell]所持金[/cell][cell]　[/cell][cell]{money}[/cell]\n"
	ledge_text += "[cell]購　入[/cell][cell]　[/cell][cell]{buy}[/cell]\n"
	ledge_text += "[cell]売　却[/cell][cell]　[/cell][cell]{sell}[/cell]\n"
	ledge_text += "[/table]"
	var sum_text := "[table=3][cell]残　金[/cell][cell]　[/cell][cell]{sum}[/cell][/table]"
	
	var sum = (player_money+sell-buy) if 0<shop_money-sell+buy else player_money+shop_money
	var sumstr = Utility.comma_sep(sum)
	if player_money<sum: sumstr = "[color=green]"+Utility.comma_sep(sum)+"[/color]"
	elif sum<0: sumstr = "[color=red]"+Utility.comma_sep(sum)+"[/color]"
	
	p_name.text  = name_text.format({"name" :player_name})
	p_ledge.text = ledge_text.format({"money":Utility.comma_sep(player_money), "buy":Utility.comma_sep(buy), "sell":Utility.comma_sep(sell), "trade":Utility.comma_sep(sell-buy)})
	p_sum.text   = sum_text.format({"sum":sumstr})

func update_transaction_shop(buy:int, sell:int):
	var name_text  := "[center][b]{name}[/b][/center]"
	var ledge_text := "[table=3]"
	ledge_text += "[cell]所持金[/cell][cell]　[/cell][cell]{money}[/cell]\n"
	ledge_text += "[cell]差　引[/cell][cell]　[/cell][cell]{trade}[/cell]\n"
	ledge_text += "[cell][/cell][cell]　[/cell][cell][/cell]\n"
	ledge_text += "[/table]"
	var sum_text := "[table=3][cell]残　金[/cell][cell]　[/cell][cell]{sum}[/cell][/table]"
	
	var sum = (shop_money+buy-sell) if 0<player_money-buy+sell else shop_money+player_money
	var sumstr = Utility.comma_sep(sum)
	if shop_money<sum: sumstr = "[color=green]"+Utility.comma_sep(sum)+"[/color]"
	elif sum<0: sumstr = "[color=red]"+Utility.comma_sep(sum)+"[/color]"
	
	s_name.text  = name_text.format({"name" :shop_name})
	s_ledge.text = ledge_text.format({"money":Utility.comma_sep(player_money), "buy":Utility.comma_sep(buy), "sell":Utility.comma_sep(sell), "trade":Utility.comma_sep(sell-buy)})
	s_sum.text   = sum_text.format({"sum":sumstr})

func update_transaction():
	var buy  := get_cost_sum(shop_items)
	var sell := get_cost_sum(inventory_items)
	update_transaction_player(buy,sell)
	update_transaction_shop(buy,sell)

func add_cart_item(i:int):
	get_current_item().trade_count+=1
	get_current_table().get_row_item(i).update()
	update_transaction()

func sub_cart_item(i:int):
	get_current_item().trade_count-=1
	get_current_table().get_row_item(i).update()
	update_transaction()

func table_cancel():
	emit_signal("finished_table")
	description.text = ""
	disable()
	op_status = OpStatus.MENU
	start_menu()
	update_operation()

func change_tab(i:int):
	tab.current_tab+=i
	emit_signal("finished_table")
	table_status = TableState.values()[tab.current_tab]
	start_table()
	
	await get_tree().process_frame
	get_current_table().index = 0

func return_table():
	emit_signal("finished_menu")
	op_status = OpStatus.SELECT
	start_table()
	enable()
	update_operation()
	update_infomation(0,0)

func finish_shop():
	emit_signal("pressed_accept",shop_money,shop_items,player_money,inventory_items)
	emit_signal("finished_menu")

func get_current_table()->ItemCSel:
	if table_status == TableState.BUY:
		return shop_table
	else:
		return inventory_table

func get_current_item()->ShopItem:
	if table_status == TableState.BUY:
		return shop_items[shop_table.index]
	else:
		return inventory_items[inventory_table.index]

func get_cost_sum(items:Array[ShopItem])->int:
	var sum:=0
	for item in items:
		if 0<item.trade_count:
			sum+=item.cost*item.trade_count
	return sum

func get_trade_items(items:Array[ShopItem])->Array[ShopItem]:
	var res:=[]
	for item in items:
		if 0<item.trade_count:
			res.append(item)
	return res
