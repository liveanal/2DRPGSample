class_name Event extends Area2D

# メインにのみ発動
@export var on_main:bool
# 発動後に表示
@export var on_unvisible:bool
# 発動後に停止
@export var on_disable:bool
# 発動後に除去
@export var on_remove:bool

@onready var collision := $collision
@onready var texture := $texture

func _ready():
	# 非表示設定
	if on_unvisible :
		texture.visible = false
	
	# シグナル受信
	connect("area_entered",func(area):
		var parent = area.get_parent()
		# mainのみ起動でmainが起動したか、main以外が起動したか判定
		if on_main and parent.get("is_main") or !on_main:
			# texture表示
			texture.visible = true
			# イベント処理
			_on_event_process(parent)
			# 起動後無効化
			if on_disable: 
				collision.set_deferred("disabled",true)
			# 起動後除去
			if on_remove:
				queue_free()
	)

# イベント処理
func _on_event_process(_parent):
	pass
