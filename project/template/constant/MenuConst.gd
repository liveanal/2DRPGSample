class_name MenuConst

enum MENU_CONTENT {Logger,Inventory,Option,Quit}

static func Logger():
	var con:Logger = load("res://project/template/system/menu/parts/general/log/Logger.tscn").instantiate()
	return con

static func Inventory():
	var con:Inventory = load("res://project/template/system/menu/parts/general/inventory/Inventory.tscn").instantiate()
	for item in System.get_player_items():
		con.append(item)
	return con

static func Option():
	System.open_modal("OptionModal",0.5)

static func Quit():
	System.open_modal("QuitModal",0.5)
