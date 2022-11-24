extends Node

# Feedシーン
const fade_res := preload("res://project/01_static/Fade.tscn")
# Quitモーダル
const modal_quit_res := preload("res://project/01_static/modal/QuitModal.tscn")
# Optionモーダル
const modal_option_res := preload("res://project/01_static/modal/OptionModal.tscn")

# オプションパス
var option_path := "res://savedata/option.conf"
# オプションデータ
var option := {}

# 初期化
func _init():
	_init_option()

# オプション初期化
func _init_option():
	if FileAccess.file_exists(option_path):
		option = Utility.load_file(option_path)
	else:
		option = OptionModal.default_values

# Fade生成
func fade_inout(fadetime:float, callable:Callable, layer:=120):
	# 前処理
	var fade := fade_res.instantiate()
	fade.layer = layer
	add_child(fade)
	# フェードイン
	fade.start_in(fadetime)
	await fade.finished
	# 裏処理
	await callable.call()
	# フェードアウト
	fade.start_out(fadetime)
	await fade.finished
	# 後処理
	fade.queue_free()

# Quitモーダル生成
func open_modal_quit()->QuitModal:
	var modal := modal_quit_res.instantiate()
	modal.pressed_cansel.connect(func():
		modal.queue_free())
	add_child(modal)
	modal.open()
	return modal

# Optionモーダル生成
func open_modal_option()->OptionModal:
	var modal := modal_option_res.instantiate()
	modal.pressed_cansel.connect(func():
		modal.queue_free())
	modal.pressed_ok.connect(func(values):
		option = values
		Utility.save_file(option_path, option)
		modal.queue_free())
	add_child(modal)
	
	modal.set_values(option)
	modal.open()
	return modal
