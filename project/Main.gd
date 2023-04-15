class_name Main extends Node

@onready var splash := $splash
@onready var title := $title

func _init():
	System.is_start_main = true

func _ready():
	var fade:Fade = System.create_fade(true)
	# フェードアウト
	fade.start_out(0.85)
	await fade.finished
	# 数秒停止
	await get_tree().create_timer(2.0).timeout
	# フェードイン
	fade.start_in(0.85)
	await fade.finished
	# 画面切りかえ
	splash.visible = false
	title.visible = true
	# フェードアウト
	fade.start_out(1.5)
	await fade.finished
	fade.queue_free()
	title.start()
