class_name MenuConst

enum MENU_CONTENT {Logger,Inventory,SpellBook,Option,Quit}

static func Logger():
	var con:Logger = load("res://project/node/menu/parts/general/log/Logger.tscn").instantiate()
	return con

static func Inventory():
	var con:Inventory = load("res://project/node/menu/parts/general/inventory/Inventory.tscn").instantiate()
	return con

static func SpellBook():
	var con:SpellBook = load("res://project/node/menu/parts/general/spellbook/SpellBook.tscn").instantiate()
	return con

static func Option():
	System.open_modal("OptionModal",0.5)

static func Quit():
	System.open_modal("QuitModal",0.5)
