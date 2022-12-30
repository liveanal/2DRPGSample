class_name ImageBalloon extends Balloon

@export var anim_name:String
@export var speed_scale:float=1.0

@onready var sprites := $sprites

func open(anim_name:String=self.anim_name,speed_scale:float=self.speed_scale):
	sprites.animation = anim_name
	sprites.speed_scale = speed_scale
	super.open()
