class_name Selectable extends Scrollable

signal changed_index(_before_index,_after_index)
signal pressed_accept(_index)

@export_group("Index")
@export var index:=0:
	set(val):
		var before:=int(index)
		index = posmod(val,index_max) if 0<index_max else 0
		emit_signal("changed_index",before,index)
	get:
		return index
@export_group("Input Settings")
@export var is_increment_updown:bool=false
@export_subgroup("Mapping")
@export var input_accept:String = "accept"
@export var input_left:String="left"
@export var input_right:String="right"

var scroll_tween:Tween
var index_max:=0

func _input(event):
	if event is InputEventKey:
		if !input_left.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(input_left) and event.is_action(input_left):
			index-=1
		elif !input_right.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(input_right) and event.is_action(input_right):
			index+=1
		if !input_up.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(input_up) and event.is_action(input_up):
			index-=1 if is_increment_updown else column_size
		elif !input_down.is_empty() and (event.is_pressed or event.is_echo()) and !event.is_action_released(input_down) and event.is_action(input_down):
			index+=1 if is_increment_updown else column_size
		
		if !input_accept.is_empty() and event.is_action_released(input_accept):
			emit_signal("pressed_accept",index)
		if !input_accept.is_empty() and event.is_action_released(input_cancel):
			emit_signal("pressed_cancel")

func _set_rows(_rows:Array):
	await super._set_rows(_rows)
	index_max=rows.size()
	index=index

func _move_scroll(next_value:int):
	# スクロール開始
	if 0<scroll_speed:
		if scroll_tween!=null and scroll_tween.is_running(): scroll_tween.stop()
		scroll_tween=create_tween()
		scroll_tween.set_ease(Tween.EASE_OUT)
		scroll_tween.set_trans(Tween.TRANS_CUBIC)
		scroll_tween.tween_property($margin/scroll, "scroll_vertical", next_value, scroll_speed)
		scroll_tween.play()
		await scroll_tween.finished
	else:
		$margin/scroll.scroll_vertical = next_value
