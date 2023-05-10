class_name ModalConst

# Quitモーダル
static func QuitModal():
	var modal:Modal = load("res://project/template/system/modal/general/QuitModal.tscn").instantiate()
	modal.finished_close.connect(func():modal.queue_free())
	return modal

# Optionモーダル
static func OptionModal():
	var modal:Modal = load("res://project/template/system/modal/general/OptionModal.tscn").instantiate()
	modal.pressed_ok.connect(func(values):
		System.option = values
		Utility.save_file(System.option_path, System.option)
		System.update_window())
	modal.finished_close.connect(func():modal.queue_free())
	modal.current_values = System.option
	return modal
