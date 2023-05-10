extends Node

# フェード完了シグナル
signal finished_fadeout
# フェード裏処理完了シグナル
signal finished_fade_backprocess
# フェード完了シグナル
signal finished_fadein
# フェード完了シグナル
signal finished_fadeflash
# モーダル完了シグナル
signal finished_modal
# ダイアログ完了シグナル
signal finished_dialog
# メニュー完了シグナル
signal finished_menu
# ロード完了シグナル
signal finished_load

# ポーズシグナル
signal pause
# 再開シグナル
signal play
# 処理停止シグナル
signal disable
# 処理再開シグナル
signal enable

# オプションパス
var option_path := "res://savedata/option.conf"
# オプションデータ
var option := {}
# メッセージログ
var message_log := []
# 事前読込リソース
var resources := {}

@onready var camera:CameraManager = $CameraManager
@onready var load:Loading = $Loading
@onready var fade:Fade = $Fade
@onready var menu:Menu = $Menu

# 初期化
func _ready():
	# 入力キー初期化
	_init_inputmap()
	# オプション初期化
	_init_option()
	# ウィンドウ初期化
	update_window()
	
	fade.visible = false

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

# エラー呼び出し
func assert_error(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[ERROR]"+Callable(LogConst,msgcode).callv(args))
		callback.call()

# 警告出力
func assert_warn(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[WARN]"+Callable(LogConst,msgcode).callv(args))
		print_stack()
		callback.call()

# デバッグ出力
func assert_debug(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[DEBUG]"+Callable(LogConst,msgcode).callv(args))
		print_stack()
		callback.call()

# ログ出力
func assert_info(msgcode:String, args:Array, test:bool=true):
	if test : 
		printerr("[INFO]"+Callable(LogConst,msgcode).callv(args))

# フェード初期化
func fadeinit(color:Color=fade.color, layer:=120):
	# 前処理
	fade.layer = layer
	fade.visible = true
	fade.init(color)

# フェードイン
func fadein(time:float):
	fade.start_in(time)
	await fade.finished
	emit_signal("finished_fadein")

# フェードアウト
func fadeout(time:float):
	fade.start_out(time)
	await fade.finished
	emit_signal("finished_fadeout")

# フェードクリア
func fadeclear():
	fade.visible = false

# フェードインアウト
func fadeinout(time:float, callable:Callable, color:Color=fade.color, layer:=120):
	# 前処理
	fadeinit(Color(color,0.0),layer)
	# フェードイン
	fadein(time)
	await finished_fadein
	# 裏処理
	callable.call()
	await finished_fade_backprocess
	# フェードアウト
	fadeout(time)
	await finished_fadeout
	# 後処理
	fadeclear()

# フェードアウトイン
func fadeoutin(time:float, callable:Callable, color:Color=fade.color, layer:=120):
	# 前処理
	fadeinit(Color(color,1.0),layer)
	# フェードアウト
	fadeout(time)
	await finished_fadeout
	# 裏処理
	callable.call()
	await finished_fade_backprocess
	# フェードイン
	fadein(time)
	await finished_fadein

# フェード点滅
func fadeflash(time:float, num:int, color:Color=fade.color, layer:=120):
	# 前処理
	fadeinit(color,layer)
	# 点滅
	for i in range(num):
		fadein(time)
		await finished_fadein
		fadeout(time)
		await finished_fadeout
	# 後処理
	emit_signal("finished_fadeflash")
	fadeclear()

# CameraManager制御
func get_camera_manager()->CameraManager:
	return camera

# ロード画面付きシーン変更
func change_scene(next_world_path:String, fade_time:=0.5, show_loading:=true):
	# 処理停止
	emit_signal("disable")
	# フェード後にマップ変更
	fadeinout(fade_time,func():
		# ロード画面表示
		load.clear()
		load.visible = show_loading
		# 現在のシーンを終了
		get_tree().current_scene.queue_free()
		# シーン読み込み準備
		Utility.load_to_thread_entry([next_world_path])
		# シーンロード
		await Utility.load_to_thread_start(
			finished_load,
			func(error):
				if error == ResourceLoader.THREAD_LOAD_FAILED:
					assert_error("E_S02", [next_world_path])
				else:
					assert_error("E_S01", [next_world_path,error]),
			func(progress):
				load.update(progress))
		# シーン切り替え
		var scene = Utility.load_to_thread_pop()[next_world_path].instantiate()
		get_tree().get_root().add_child(scene)
		get_tree().current_scene = scene
		# 完了
		load.visible = false
		emit_signal("finished_fade_backprocess")
	,Color.BLACK)
	# フェード終了待機
	await finished_fadeout
	# 処理開始
	emit_signal("enable")

# 操作中キャラクターの所持アイテムを取得
func get_player_items():
	return []

# モーダル表示
func open_modal(modalname:String, time:float=0.0):
	var modal:Modal = Callable(ModalConst,modalname).call()
	modal.anim_time=time
	add_child(modal)
	modal.open()
	await modal.finished_close
	emit_signal("finished_modal")

# ダイアログ表示
func open_dialog(caller:Node,data:DialogData,anim_time:float=0.5,auto_close:=true,dialog=null):
	var d = dialog
	
	if data==null:
		assert_error("E_101",[caller.name])
		if dialog==null:
			emit_signal("finished_dialog")
		return
	else:
		# ダイアログ設定
		d = await DialogConst.switch_dialog(data,d,anim_time)
		# 新ダイアログの場合登録とオープン
		if dialog!=d:
			add_child(d)
			d.open()
		else:
			d.update()
		# 入力が終わるまで待機
		await d.finished_message
		# 選択肢がある場合
		if d.is_selectable():
			# 選択を取得
			var selected:DialogSelect = d.get_select_item()
			# 選択後のcall_funcを呼出し
			if !Utility.is_empty(selected.call_func):
				caller.call(selected.call_func)
			# 選択肢のnextを呼び出し
			if selected.next != null:
				d = await open_dialog(caller, selected.next, anim_time, false, d)
		# call_funcがある場合
		if !Utility.is_empty(data.call_func):
			# 選択後のcall_funcを呼出し
			caller.call(data.call_func)
		# nextがある場合
		if data.next != null:
			# 選択肢のnextを呼び出し
			d = await open_dialog(caller, data.next, anim_time, false, d)
	
	# ダイアログ終了
	if auto_close:
		d.close()
		await d.finished_close
		# ダイアログ終了検知
		if dialog == null:
			emit_signal("finished_dialog")
	else:
		return d

# メニュー表示
func open_menu():
	menu.open()
	await menu.finished_close
	emit_signal("finished_menu")
