class_name ImageBalloon extends Balloon

@export var anim_name:String
@export var pos_offset:Vector2 = Vector2.ZERO
@export var speed_scale:float=1.0

@onready var sprites := $sprites

func open():
	sprites.animation = anim_name
	sprites.speed_scale = speed_scale
	sprites.position = -Vector2(0,sprites.frames.get_frame(anim_name,0).get_height()/2)
	position += pos_offset
	super.open()
