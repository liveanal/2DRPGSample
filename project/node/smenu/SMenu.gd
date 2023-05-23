class_name SMenu extends Control

signal finished_open
signal finished_close
signal accept(data:Resource)

@export var anim_time:float = 0.25
@export var open_scale:float = 1.0

@onready var name_panel:Panel = $name
@onready var name_label:Label = $name/margin/label
@onready var desc_panel:Panel = $description
@onready var desc_label:RichTextLabel = $description/margin/label

@onready var panel:Array = [$item1,$item2,$item3,$item4,$item5,$item6,$item7,$item8]
var index := -1 :
	set(val):
		index = clamp(val,-1,panel.size())
	get:
		return index

# 初期化
func _ready():
	visible = false
	scale = Vector2.ZERO
	name_panel.visible = true
	desc_panel.visible = true

# メニュー展開
func open(default:int=-1):
	visible = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE * open_scale, anim_time)
	tween.tween_callback(emit_signal.bind("finished_open"))
	tween.play()
	if -1<default: change_cursor(default)

# メニュー閉塞
func close():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, anim_time)
	tween.tween_callback(func():
		emit_signal("finished_close")
		visible = false)
	tween.play()
	# 選択処理
	if -1<index and panel[index].data!=null and !Utility.is_empty(panel[index].data.call_func):
		var select := index
		change_cursor(-1)
		await finished_close
		emit_signal("accept", panel[select].sdata.data)

# カーソル移動
func change_cursor(_index:int):
	# カーソルが変更された場合のみ処理
	if index != _index:
		# セレクト縮小
		panel[index].close()
		# セレクト拡大
		if -1<_index:
			panel[_index].open()
		
		# カーソル変更
		index = _index
		# ラベル変更
		if -1<index and panel[index].data!=null:
			name_label.text = panel[_index].data.name
			desc_label.text = panel[_index].data.description
		else:
			name_label.text = ""
			desc_label.text = ""

# selectセット
func entry_select(i:int, data):
	panel[i].data = data
	if data != null:
		panel[i].set_icon(data.icon)
	else:
		panel[i].clear_icon()

# Vector2をindexに変換
static func vector_to_index(vec:Vector2) -> int:
	var result:int = -1
	
	match vec:
		Vector2(0,-1):
			result = 0
		Vector2(1,-1):
			result = 1
		Vector2(1,0):
			result = 2
		Vector2(1,1):
			result = 3
		Vector2(0,1):
			result = 4
		Vector2(-1,1):
			result = 5
		Vector2(-1,0):
			result = 6
		Vector2(-1,-1):
			result = 7
	
	return result
