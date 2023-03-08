extends CanvasLayer

# Openするためのシグナル
signal open_menu
# Closeを通知するためのシグナル
signal finished_close

@export var input_cancel := "cancel"
@export_group("Control Settings")
@export var inventory:Inventory
@export var logging:Logging

@onready var contents := {
	$frame/margin/container/button_area/select/inventory : inventory,
	$frame/margin/container/button_area/select/log       : logging
}
@onready var modals   := {
	$frame/margin/container/button_area/select/option    : "open_modal_option",
	$frame/margin/container/button_area/select/quit      : "open_modal_quit"
}
@onready var grab_first := $frame/margin/container/button_area/select/inventory

func _ready():
	if logging!=null:DialogSystem.connect("log_message",_add_message)
	for btn in contents.keys():
		btn.connect("pressed",_open_contents.bind(btn))
	for btn in modals.keys():
		btn.connect("pressed",_open_modals.bind(btn))
	connect("open_menu", open)
	close()

func _input(event):
	if event is InputEventKey:
		if !input_cancel.is_empty() and !event.is_action_released(input_cancel) and event.is_action_pressed(input_cancel):close()

func _open_contents(btn):
	set_process_input(false)
	var focus = get_viewport().gui_get_focus_owner()
	focus.release_focus()
	
	var control:MenuControl = contents[btn]
	control.open()
	await control.finished_close
	
	focus.grab_focus()
	set_process_input(true)

func _open_modals(btn):
	set_process_input(false)
	var focus = get_viewport().gui_get_focus_owner()
	focus.release_focus()
	
	var funcname:String = modals[btn]
	var modal:Modal = ModalSystem.call(funcname,0.45)
	await modal.finished_close
	
	focus.grab_focus()
	set_process_input(true)

func _add_message(_name,_msg):
	logging.append(
		Utility.create_label(_name,0,0,0,false,0,false,null),
		Utility.create_label(_msg,0,0,0,false,0,true,null))

func open():
	enable()
	visible = true

func close():
	disable()
	visible = false
	emit_signal("finished_close")

func enable():
	grab_first.grab_focus()
	set_process_input(true)

func disable():
	var focus = get_viewport().gui_get_focus_owner()
	if focus!=null:focus.release_focus()
	set_process_input(false)
