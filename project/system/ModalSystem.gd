extends Node

# Quitモーダル
const modal_quit_res := preload("res://project/02_static/modal/QuitModal.tscn")
# Optionモーダル
const modal_option_res := preload("res://project/02_static/modal/OptionModal.tscn")

# Quitモーダル生成
func open_modal_quit(time:float=0.0)->QuitModal:
	var modal := modal_quit_res.instantiate()
	modal.anim_time=time
	modal.finished_close.connect(func():modal.queue_free())
	add_child(modal)
	modal.open()
	return modal

# Optionモーダル生成
func open_modal_option(time:float=0.0)->OptionModal:
	var modal := modal_option_res.instantiate()
	modal.anim_time = time
	modal.pressed_ok.connect(func(values):
		System.option = values
		Utility.save_file(System.option_path, System.option)
		System.update_window())
	modal.finished_close.connect(func():modal.queue_free())
	add_child(modal)
	modal.set_values(System.option)
	modal.open()
	return modal
