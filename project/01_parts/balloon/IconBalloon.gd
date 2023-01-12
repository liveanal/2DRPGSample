class_name IconBalloon extends Balloon

@export var anim_name:String
@export var pos_offset:Vector2 = Vector2.ZERO
@export var speed_scale:float=1.0
@export var icon_scale:float=1.0

@onready var frame := $frame
@onready var sprites := $frame/sprites

func open():
	frame.size = Vector2(sprites.frames.get_frame(anim_name,0).get_width()+frame.patch_margin_left+frame.patch_margin_right, sprites.frames.get_frame(anim_name,0).get_height()+frame.patch_margin_top+frame.patch_margin_bottom)
	frame.pivot_offset = Vector2(frame.size.x/2,frame.size.y)
	frame.position = -Vector2(frame.size.x/2, frame.size.y)
	
	sprites.animation = anim_name
	sprites.speed_scale = speed_scale
	sprites.scale = Vector2(icon_scale,icon_scale)
	sprites.position = Vector2(frame.size.x/2,frame.patch_margin_top+sprites.frames.get_frame(anim_name,0).get_height()/2)
	
	position += pos_offset
	super.open()

func anim_stop():
	sprites.stop()
