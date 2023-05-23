@tool
class_name Menu extends CanvasLayer

signal finished_open
signal finished_close

# パーティメンバー
@export var party_member:Array[Character]
# メニューラベル
@export var labels:Array[MenuLabel]:
	set(val):
		labels = val
		_init_label()
	get:
		return labels
# ラベルテーマ
@export var theme:Theme:
	set(val):
		theme = val
		_init_label()
	get:
		return theme
# ボタンエリア
@export var select:Control
# コンテンツエリア
@export var content:Control

# コンテンツフレーム
@export_group("Content Setting")
@export var frame:PanelContainer

var current_focus:Node
var current_content:MenuContent

func _ready():
	_init_label()
	disable()
	visible = false
	
	if frame!=null :
		frame.visible = false

func _input(event):
	if event is InputEventKey:
		if !event.is_action_released("cancel") and event.is_action_pressed("cancel"):
			close()

func _init_label():
	if select!=null:
		for child in select.get_children():
			child.queue_free()
		for data in labels:
			if data != null:
				var btn := Button.new()
				btn.text = data.label
				btn.theme = theme
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
				btn.connect("pressed",_pressed.bind(data))
				select.add_child(btn)

func _pressed(data:MenuLabel):
	disable()
	current_content = data.get_menu_content()
	if current_content == null:
		await System.finished_modal
	else:
		current_content.party_member = party_member
		content.add_child(current_content)
		if frame!=null : frame.visible = true
		current_content.open()
		await current_content.finished_close
		current_content.queue_free()
		if frame!=null : frame.visible = false
	enable()

func open():
	enable()
	visible = true
	if frame!=null :
		frame.visible = false
	emit_signal("finished_open")

func close(signal_emitable:=true):
	if current_content != null:
		current_content.close()
	disable()
	visible = false
	if signal_emitable :
		emit_signal("finished_close")

func enable():
	if current_focus!=null:
		current_focus.grab_focus()
	else:
		select.get_child(0).grab_focus()
	set_process_input(true)

func disable():
	current_focus = get_viewport().gui_get_focus_owner()
	if current_focus!=null:
		current_focus.release_focus()
	set_process_input(false)
