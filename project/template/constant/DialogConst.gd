class_name DialogConst

const INFO_LOGNAME := "INFO"

# fullダイアログ
static func FullDialog():
	var dialog:Dialog = load("res://project/template/system/dialog/general/FullDialog.tscn").instantiate()
	dialog.finished_close.connect(dialog.queue_free)
	return dialog

# nofaceダイアログ
static func NoFaceDialog():
	var dialog:Dialog = load("res://project/template/system/dialog/general/NoFaceDialog.tscn").instantiate()
	dialog.finished_close.connect(dialog.queue_free)
	return dialog

# infoダイアログ
static func InfoDialog():
	var dialog:Dialog = load("res://project/template/system/dialog/general/InfoDialog.tscn").instantiate()
	dialog.finished_close.connect(dialog.queue_free)
	return dialog

# ダイアログスイッチ
static func switch_dialog(data:DialogData, dialog:Dialog, anim_time:float):
	var new_dialog:Dialog = dialog
	# ダイアログの切り替え
	if Utility.is_empty(data.name) and Utility.is_empty(data.face) and (dialog == null or not dialog.name == "InfoDialog"):
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = DialogConst.InfoDialog()
	elif !Utility.is_empty(data.name) and Utility.is_empty(data.face) and (dialog == null or not dialog.name == "NoFaceDialog"):
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = DialogConst.NoFaceDialog()
	elif !Utility.is_empty(data.name) and !Utility.is_empty(data.face) and (dialog == null or not dialog.name == "FullDialog"):
		if dialog != null:
			dialog.close()
			await dialog.finished_close
		new_dialog = DialogConst.FullDialog()
	# 初期化
	if new_dialog != dialog:
		new_dialog.anim_time = anim_time
		new_dialog.updated.connect(func(data):
			System.message_log.append({"name":data.name if !Utility.is_empty(data.name) else INFO_LOGNAME,"msg":data.dialog})
		)
		new_dialog.pressed_select.connect(func(i,sd):
			System.message_log.append({"name":"選択","msg":"(%d)%s"%[i,sd.text]})
		)
	# 次のメッセージを設定
	new_dialog.data = data
	return new_dialog
