extends Node

# Feedシーン
const fade_res := preload("res://project/02_static/Fade.tscn")

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

# Fade生成
func create_fade(reverse:=false, layer:=120) -> Fade:
	var fade := fade_res.instantiate()
	fade.layer = layer
	if reverse :
		fade.color = Color(fade.color,1.0)
	add_child(fade)
	return fade

# Fade生成
func fade_inout(time:float, callable:Callable, layer:=120):
	# 前処理
	var fade := create_fade(layer)
	# フェードイン
	fade.start_in(time)
	await fade.finished
	# 裏処理
	await callable.call()
	# フェードアウト
	fade.start_out(time)
	await fade.finished
	# 後処理
	fade.queue_free()

# Fade生成
func fade_outin(time:float, callable:Callable, layer:=120):
	# 前処理
	var fade := create_fade(true, layer)
	# フェードイン
	fade.start_out(time)
	await fade.finished
	# 裏処理
	await callable.call()
	# フェードアウト
	fade.start_in(time)
	await fade.finished
	# 後処理
	fade.queue_free()

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

# シーン切り替え等のフェード退避
func reft_fade(fade:Fade):
	current_fade = fade

# シーン切り替え後のフェード再取得
func pop_fade():
	return current_fade
