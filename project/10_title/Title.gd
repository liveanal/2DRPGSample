class_name Title extends Control

signal start_newgame

@onready var btn_newgame  := $select/Button1
@onready var btn_loadgame := $select/Button2
@onready var btn_option   := $select/Button3
@onready var btn_exit     := $select/Button4
@onready var video := $video

func _ready():
	# シグナル接続
	btn_newgame.connect("pressed",_on_pressed_NewGame)
	btn_loadgame.connect("pressed",_on_pressed_LoadGame)
	btn_option.connect("pressed",_on_pressed_Option)
	btn_exit.connect("pressed",_on_pressed_Exit)

func _on_pressed_NewGame():
	btn_newgame.release_focus()
	emit_signal("start_newgame")

func _on_pressed_LoadGame():
	pass

func _on_pressed_Option():
	btn_option.release_focus()
	var modal:Modal = ModalSystem.open_modal_option(0.5)
	await modal.finished_close
	btn_option.grab_focus()

func _on_pressed_Exit():
	btn_exit.release_focus()
	var modal:Modal = ModalSystem.open_modal_quit(0.5)
	await modal.finished_close
	btn_exit.grab_focus()

func start():
	video.refresh()
	# ボタンフォーカス
	btn_newgame.grab_focus()
