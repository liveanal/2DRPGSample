extends Node

# Feedシーン
const fade_res := preload("res://project/02_static/Fade.tscn")

# フェード中裏処理終了検知
signal finished_fade_backprocess
# フェード完了シグナル
signal finished_fade
# ポーズシグナル
signal pause
# ポーズシグナル
signal play
# 処理停止シグナル
signal disable
# 処理停止シグナル
signal disable_all
# 処理再開シグナル 
signal enable

# Mainからの開始変数
var is_start_main:bool = false
# シーン切り替え用フェード一時退避
var current_fade:Fade
# オプションパス
var option_path := "res://savedata/option.conf"
# オプションデータ
var option := {}

# 初期化
func _init():
	# 入力キー初期化
	_init_inputmap()
	# オプション初期化
	_init_option()
	# ウィンドウ初期化
	update_window()

# 入力キー初期化
func _init_inputmap():
	InputMap.action_erase_events("ui_left")
	for event in InputMap.action_get_events("left")   : InputMap.action_add_event("ui_left",event)
	InputMap.action_erase_events("ui_right")
	for event in InputMap.action_get_events("right")  : InputMap.action_add_event("ui_right",event)
	InputMap.action_erase_events("ui_up")
	for event in InputMap.action_get_events("up")     : InputMap.action_add_event("ui_up",event)
	InputMap.action_erase_events("ui_down")
	for event in InputMap.action_get_events("down")   : InputMap.action_add_event("ui_down",event)
	InputMap.action_erase_events("ui_accept")
	for event in InputMap.action_get_events("accept") : InputMap.action_add_event("ui_accept",event)
	InputMap.action_erase_events("ui_cancel")
	for event in InputMap.action_get_events("cancel") : InputMap.action_add_event("ui_cancel",event)

# オプション初期化
func _init_option():
	if FileAccess.file_exists(option_path):
		option = Utility.load_file(option_path)
	else:
		option = OptionModal.default_values

# ウィンドウモード変更
func update_window():
	var size := Vector2i(1280,800)
	var full := false
	
	if option["window_mode"] == 0 :
		size = Vector2i(960,600)
	elif option["window_mode"] == 1 :
		size = Vector2i(1280,800)
	elif option["window_mode"] == 2 :
		size = Vector2i(1440,960)
	elif option["window_mode"] == 3 :
		full = true
	
	if full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_position(DisplayServer.screen_get_size()/2 - size/2)

# Fade生成
func create_fade(reverse:=false, layer:=120) -> Fade:
	current_fade = fade_res.instantiate()
	current_fade.layer = layer
	if reverse :
		current_fade.color = Color(current_fade.color,1.0)
	add_child(current_fade)
	return current_fade

# Fade生成
func fade_inout(time:float, callable:Callable, layer:=120):
	# 前処理
	create_fade(layer)
	# フェードイン
	current_fade.start_in(time)
	await current_fade.finished
	emit_signal("finished_fade")
	# 裏処理
	callable.call()
	await finished_fade_backprocess
	# フェードアウト
	current_fade.start_out(time)
	await current_fade.finished
	emit_signal("finished_fade")
	# 後処理
	current_fade.queue_free()

# Fade生成
func fade_outin(time:float, callable:Callable, layer:=120):
	# 前処理
	create_fade(true, layer)
	# フェードイン
	current_fade.start_out(time)
	await current_fade.finished
	emit_signal("finished_fade")
	# 裏処理
	callable.call()
	await finished_fade_backprocess
	# フェードアウト
	current_fade.start_in(time)
	await current_fade.finished
	emit_signal("finished_fade")
	# 後処理
	current_fade.queue_free()

# シーン切り替え等のフェード退避
func reft_fade(fade:Fade):
	current_fade = fade

# シーン切り替え後のフェード再取得
func pop_fade():
	return current_fade

# インフェードの開放処理
func open_fadein():
	current_fade = System.pop_fade()
	if current_fade != null:
		current_fade.start_out()
		await current_fade.finished
		emit_signal("finished_fade")
		current_fade.queue_free()

# ワールド変更
func change_world(next_world_path:String, fade_time:=1.0):
	emit_signal("disable_all")
	create_fade(true)
	# フェードイン
	current_fade.start_in(fade_time)
	await current_fade.finished
	emit_signal("finished_fade")
	# シーンチェンジ
	get_tree().change_scene_to_file(next_world_path)
	# フェードアウト
	current_fade.start_out(fade_time)
	await current_fade.finished
	emit_signal("finished_fade")
	current_fade.queue_free()
