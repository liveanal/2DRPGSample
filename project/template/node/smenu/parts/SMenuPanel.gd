class_name SMenuPanel extends PanelContainer

@export var empty_icon:Texture2D
@export var anim_time:float = 0.25
@export var scale_select:float = 1.5
@export var data:SMenuData

@onready var texture := $margin/texture

func _ready():
	if data != null:
		set_icon(data.icon)
	else:
		clear_icon()

# アイコン設定
func set_icon(icon:Texture2D):
	texture.texture = icon

# アイコン初期化
func clear_icon():
	texture.texture = empty_icon

# セレクト拡大
func open():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE * scale_select, anim_time)
	tween.play()

# セレクト縮小
func close():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, anim_time)
	tween.play()
