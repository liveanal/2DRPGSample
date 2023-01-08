class_name Dialog extends CanvasLayer

enum DialogStatus{INIT,WAIT_SCROLLING,WAIT_PAGENATION,WAIT_SELECT}

signal finished_open
signal finished_close
signal finished_message
signal pressed_next
signal pressed_select(index:int,select:DialogSelect)
signal updated(data:DialogData)

@export_group("Target Setting")
@export var t_name:Label
@export var t_face:TextureRect
@export var t_dialog:RichTextLabel
@export var t_pagenation:TextureRect
@export var t_selectable:Selectable
@export_group("Pagenation Setting")
@export var pagenation_texture:Texture2D
@export var pagenation_time:float=1.0
@export_group("Dialog Setting")
@export var close_offset_position:Vector2=Vector2(0,500)
@export var anim_time:float=0.40
@export var data:DialogData:
	set(val):
		data = val
		update()
	get:
		return data
@export_subgroup("Scroll Default")
@export var scroll_time_default:float=0.1
@export var scroll_nums_default:int=1
@export_subgroup("Scroll Fast")
@export var scroll_time_fast:=0.001
@export var scroll_nums_fast:=10
@export_group("Input Settings")
@export var input_next:String = "ui_accept"
@export var input_skip:String = "ui_accept"
@export var input_hide:String = "ui_cancel"

var scroll_timer:Timer
var pagenation_timer:Timer
var dialog_status:DialogStatus
var scroll_char_nums:int

func _ready():
	offset=close_offset_position
	_ready_pagenation()
	_ready_scroll()
	_ready_selectable()
	clear()
	disable()

func _ready_pagenation():
	if t_pagenation != null:
		t_pagenation.texture=pagenation_texture
	pagenation_timer=Timer.new()
	pagenation_timer.wait_time=pagenation_time
	pagenation_timer.connect("timeout",func(): if t_pagenation!=null:t_pagenation.visible=!t_pagenation.visible)
	add_child(pagenation_timer)

func _ready_scroll():
	scroll_char_nums=scroll_nums_default
	scroll_timer=Timer.new()
	scroll_timer.wait_time=scroll_time_default
	scroll_timer.one_shot=true
	scroll_timer.connect("timeout",func():if t_dialog!=null:scroll())
	add_child(scroll_timer)

func _ready_selectable():
	if t_selectable!=null:
		t_selectable.connect("pressed_accept",func(index):
			emit_signal("pressed_select",index,get_select_item())
			emit_signal("finished_message"))

func _process(delta):
	if visible :
		match(dialog_status):
			DialogStatus.WAIT_SCROLLING:
				if Input.is_action_pressed(input_skip):
					scroll_timer.wait_time = scroll_time_fast
					scroll_char_nums = scroll_nums_fast
				else:
					scroll_timer.wait_time = scroll_time_default
					scroll_char_nums = scroll_nums_default
			DialogStatus.WAIT_PAGENATION:
				if Input.is_action_just_pressed(input_next):
					emit_signal("pressed_next")
					emit_signal("finished_message")

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed(input_hide):
			visible = !visible

func open(time:=anim_time):
	if 0<time :
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "offset", Vector2.ZERO, time)
		tween.play()
		await tween.finished
	else :
		offset = Vector2.ZERO
		await get_tree().process_frame
	
	update()
	enable()
	emit_signal("finished_open")

func close(time:=anim_time):
	disable()
	clear()
	if 0<time :
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "offset", close_offset_position, time)
		tween.play()
		await tween.finished
	else :
		offset = close_offset_position
		await get_tree().process_frame
	
	emit_signal("finished_close")

func enable():
	set_process(true)
	set_process_input(true)

func disable():
	set_process(false)
	set_process_input(false)

func update():
	clear()
	if data != null:
		if t_name != null:
			t_name.text = data.name
		if t_face != null:
			t_face.texture = data.face
		if t_dialog != null:
			t_dialog.text = data.dialog
			t_dialog.visible_ratio = 0.0
			t_dialog.visible_characters = 1
			dialog_status = DialogStatus.WAIT_SCROLLING
			scroll_timer.start()
		if t_selectable != null:
			t_selectable.set_items(data.get_selectable_text())
			t_selectable.is_input = false
			t_selectable.visible = false
		if t_pagenation != null:
			pagenation_stop()
		emit_signal("updated",data)

func clear():
	enable()
	dialog_status = DialogStatus.INIT
	if scroll_timer!=null :
		scroll_timer.wait_time = scroll_time_default
		scroll_char_nums = scroll_nums_default
	if t_name != null:
		t_name.text = ""
	if t_face != null:
		t_face.texture = null
	if t_dialog != null:
		t_dialog.text = ""
	if t_selectable != null :
		t_selectable.is_input = false
		t_selectable.visible = false
	if t_pagenation != null:
		pagenation_stop()

func scroll():
	if t_dialog.visible_ratio<1.0:
		t_dialog.visible_characters += scroll_char_nums
		scroll_timer.start()
	else:
		if is_selectable() :
			dialog_status = DialogStatus.WAIT_SELECT
			disable()
			selectable_start()
		else:
			dialog_status = DialogStatus.WAIT_PAGENATION
			pagenation_start()

func pagenation_start():
	pagenation_timer.start()

func pagenation_stop():
	pagenation_timer.stop()
	if t_pagenation!=null: 
		t_pagenation.visible = false

func selectable_start():
	t_selectable.is_input = true
	t_selectable.visible = true
	await get_tree().process_frame
	t_selectable.index = 0

func selectable_stop():
	t_selectable.is_input = false
	t_selectable.visible = false

func is_selectable()->bool:
	return !data.selectable.is_empty()

func get_select_item()->DialogSelect:
	return data.selectable[t_selectable.index]
