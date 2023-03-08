class_name SMenuEntry extends Resource

@export var position:Vector2
@export_enum("CENTER","LEFT_UP","UP","RIGHT_UP","LEFT","RIGHT","LEFT_DOWN","DOWN","RIGHT_DOWN") var pivot_offset:String = "CENTER"
@export var data:SMenuPanelData

func get_pivot_offset(size:Vector2) -> Vector2 :
	match pivot_offset:
		"CENTER":
			return size/2
		"LEFT_UP":
			return Vector2.ZERO
		"UP":
			return Vector2(size.x/2, 0)
		"RIGHT_UP":
			return Vector2(size.x, 0)
		"LEFT":
			return Vector2(0, size.y/2)
		"RIGHT":
			return Vector2(size.x, size.y/2)
		"LEFT_DOWN":
			return Vector2(0, size.y)
		"DOWN":
			return Vector2(size.x/2, size.y)
		"RIGHT_DOWN":
			return size
		_:
			return Vector2.ZERO
