class_name MenuLabel extends Resource

@export var label:String
@export var menu_type:MenuConst.MENU_CONTENT

func get_menu_content():
	var key:String = MenuConst.MENU_CONTENT.keys()[menu_type]
	var content = Callable(MenuConst,key).call()
	return content
