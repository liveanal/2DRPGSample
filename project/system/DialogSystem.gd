extends Node

# ログウィンドウへの書き込みシグナル
signal log_message(name:String,msg:String)
# ウィンドウ終了シグナル
signal finished

# Fullダイアログ
const dialog_full_res := preload("res://project/02_static/dialog/FullDialog.tscn")
# NoFaceダイアログ
const dialog_noface_res := preload("res://project/02_static/dialog/NoFaceDialog.tscn")
# Infoダイアログ
const dialog_info_res := preload("res://project/02_static/dialog/InfoDialog.tscn")

@export var default_anim_time:float=0.0
var message_log := []

func _ready():
	connect("log_message",func(_name,_message):message_log.append({"name":_name,"message":_message}))

# fullダイアログ生成
func _create_full_dialog(time:float=0.0)->Dialog:
	var dialog:Dialog = dialog_full_res.instantiate()
	dialog.anim_time=time
	dialog.updated.connect(func(data):emit_signal("log_message",data.name,data.dialog))
	dialog.pressed_select.connect(func(i,sd):emit_signal("log_message","選択","(%d)%s"%[i,sd.text]))
	dialog.finished_close.connect(func():dialog.queue_free())
	add_child(dialog)
	return dialog

# nofaceダイアログ生成
func _create_noface_dialog(time:float=0.0)->Dialog:
	var dialog:Dialog = dialog_noface_res.instantiate()
	dialog.anim_time=time
	dialog.updated.connect(func(data):emit_signal("log_message",data.name, data.dialog))
	dialog.pressed_select.connect(func(i,sd):emit_signal("log_message","選択","(%d)%s"%[i,sd.text]))
	dialog.finished_close.connect(func():dialog.queue_free())
	add_child(dialog)
	return dialog

# infoダイアログ生成
func _create_info_dialog(time:float=0.0)->Dialog:
	var dialog:Dialog = dialog_info_res.instantiate()
	dialog.anim_time=time
	dialog.updated.connect(func(data):emit_signal("log_message","INFO", data.dialog))
	dialog.pressed_select.connect(func(i,sd):emit_signal("log_message","選択","(%d)%s"%[i,sd.text]))
	dialog.finished_close.connect(func():dialog.queue_free())
	add_child(dialog)
	return dialog

# ダイアログスイッチ
func _switch_dialog(data:DialogData, anim_time:float, dialog)->Dialog:
	var new_dialog:Dialog = dialog
	
	# ダイアログの切り替え
	if Utility.is_empty(data.name) and Utility.is_empty(data.face) and not dialog is InfoDialog:
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = _create_info_dialog(anim_time)
	elif !Utility.is_empty(data.name) and Utility.is_empty(data.face) and not dialog is NoFaceDialog:
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = _create_noface_dialog(anim_time)
	elif !Utility.is_empty(data.name) and !Utility.is_empty(data.face) and not dialog is FullDialog:
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = _create_full_dialog(anim_time)
	
	# 新ダイアログの準備
	if new_dialog!=dialog:
		new_dialog.open()
		await new_dialog.finished_open
	
	new_dialog.data = data
	return new_dialog
 
# dataに応じた適切なダイアログの表示
func open_dialog(caller:Node, data:DialogData, anim_time:=default_anim_time, auto_close:=true, dialog=null):
	var d = dialog
	
	# ダイアログを表示
	d = await _switch_dialog(data, anim_time, d)
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
			emit_signal("finished")
	else:
		return d
