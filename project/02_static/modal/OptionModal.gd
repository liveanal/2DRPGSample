class_name OptionModal extends Modal

signal pressed_cancel
signal pressed_ok(values:Dictionary)

@onready var contents := $panel/margin/contents/margin/scroller/contents
@onready var scroller := $panel/margin/contents/margin/scroller

@onready var window_mode := [
	$panel/margin/contents/margin/scroller/contents/window_mode/small,
	$panel/margin/contents/margin/scroller/contents/window_mode/midium,
	$panel/margin/contents/margin/scroller/contents/window_mode/big,
	$panel/margin/contents/margin/scroller/contents/window_mode/fullscreen]
@onready var bgm_volume := $panel/margin/contents/margin/scroller/contents/bgm_volume/slider
@onready var se_volume := $panel/margin/contents/margin/scroller/contents/se_volume/slider
@onready var text_speed := [
	$panel/margin/contents/margin/scroller/contents/text_speed/contents/slow,
	$panel/margin/contents/margin/scroller/contents/text_speed/contents/normal,
	$panel/margin/contents/margin/scroller/contents/text_speed/contents/high,
	$panel/margin/contents/margin/scroller/contents/text_speed/contents/nowait]
@onready var move_type := [
	$panel/margin/contents/margin/scroller/contents/move_type/contents/default_walk,
	$panel/margin/contents/margin/scroller/contents/move_type/contents/default_run]

const default_values := {
		"window_mode":1,
		"bgm_volume":100,
		"se_volume":100,
		"text_speed":2,
		"move_type":1
	}

func _ready():
	super._ready()
	connect("pressed_button1",_on_pressed_default)
	connect("pressed_button2",_on_pressed_cancel)
	connect("pressed_button3",_on_pressed_ok)
	set_values(default_values)

func _on_pressed_default():
	set_values(default_values)

func _on_pressed_cancel():
	emit_signal("pressed_cancel")
	await close(anim_time)

func _on_pressed_ok():
	emit_signal("pressed_ok", get_values())
	await close(anim_time)

func get_values() -> Dictionary :
	var result := {}
	result["window_mode"] = Utility.get_radios_idx_checked(window_mode)
	result["bgm_volume"]  = bgm_volume.value
	result["se_volume"]   = se_volume.value
	result["text_speed"]  = Utility.get_radios_idx_checked(text_speed)
	result["move_type"]   = Utility.get_radios_idx_checked(move_type)
	return result

func set_values(values:Dictionary) :
	window_mode[values["window_mode"]].button_pressed = true
	bgm_volume.value = values["bgm_volume"]
	se_volume.value  = values["se_volume"]
	text_speed[values["text_speed"]].button_pressed = true
	move_type[values["move_type"]].button_pressed = true

func open(time:=anim_time):
	await super.open(time)
	window_mode[0].grab_focus()
