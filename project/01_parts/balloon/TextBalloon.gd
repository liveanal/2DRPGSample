class_name TextBalloon extends Balloon

@export_multiline var text:String

@onready var frame := $frame
@onready var margin := $frame/margin
@onready var label := $frame/margin/text

func open(text:=self.text,size:Vector2=frame.size,pos:=Vector2.ZERO):
	label.text = "[center]" + text + "[/center]"
	frame.size = size
	frame.position += pos
	margin.set("theme_override_constants/margin_left",frame.patch_margin_left)
	margin.set("theme_override_constants/margin_top",frame.patch_margin_top)
	margin.set("theme_override_constants/margin_right",frame.patch_margin_right)
	margin.set("theme_override_constants/margin_bottom",frame.patch_margin_bottom)
	super.open()
