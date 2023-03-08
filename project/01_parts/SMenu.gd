class_name SMenu extends Control

signal finished_open
signal finished_close

@export var target:Character
@export var anim_time:float = 0.25
@export var open_scale:float = 1.0
@export var panel_resource:PackedScene
@export var select:Array[SMenuEntry]

@onready var name_panel:Panel = $name
@onready var name_label:Label = $name/margin/label
@onready var desc_panel:Panel = $description
@onready var desc_label:RichTextLabel = $description/margin/label


var panel:Array[SMenuPanel]
var index := -1 :
	set(val):
		index = clamp(val,-1,select.size())
	get:
		return index

# 初期化
func _ready():
	scale = Vector2.ZERO
	name_panel.visible = true
	desc_panel.visible = true
	
	# select初期化
	for i in range(select.size()):
		panel.append(panel_resource.instantiate())
		panel[i].position = select[i].position - panel[i].size/2
		panel[i].pivot_offset = select[i].get_pivot_offset(panel[i].size)
		add_child(panel[i])
		
		entry_select(i, select[i].data)

# メニュー展開
func open(default:int=-1):
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
	tween.tween_callback(emit_signal.bind("finished_close"))
	tween.play()
	change_cursor(-1)

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
		if -1<index and select[index].data!=null:
			name_label.text = select[_index].data.name
			desc_label.text = select[_index].data.description
		else:
			name_label.text = ""
			desc_label.text = ""

# selectセット
func entry_select(i:int, data):
	select[i].data = data
	if data != null:
		panel[i].set_icon(data.icon)
	else:
		panel[i].clear_icon()

# 選択(関数呼出し)
func accept():
	if -1<index and select[index].data!=null and !Utility.is_empty(select[index].data.call_func):
		target.callv(select[index].data.call_func, select[index].data.call_args)

# Vector2をindexに変換
static func vector_to_index(vec:Vector2, empty_of_zero:bool=true) -> int:
	var result:int = -1
	
	match vec:
		Vector2(-1,-1):
			result = 0
		Vector2(0,-1):
			result = 1
		Vector2(1,-1):
			result = 2
		Vector2(-1, 0):
			result = 3
		Vector2(1, 0):
			result = 4
		Vector2(-1, 1):
			result = 5
		Vector2(0, 1):
			result = 6
		Vector2(1, 1):
			result = 7
	
	return result + (0 if empty_of_zero else 1)
