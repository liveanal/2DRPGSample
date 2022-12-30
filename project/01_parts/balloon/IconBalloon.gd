class_name IconBalloon extends Balloon

@export var anim_name:String
@export var speed_scale:float=1.0

@onready var frame := $frame
@onready var sprites := $frame/sprites

func open(anim_name:String=self.anim_name,speed_scale:float=self.speed_scale,size:Vector2=frame.size,pos:=Vector2.ZERO):
	frame.size = size
	frame.position += pos
	sprites.animation = anim_name
	sprites.speed_scale = speed_scale
	sprites.position = frame.position + frame.size / 2
	super.open()
