class_name ButtonCSel extends CursorSelectable

@export var select:PackedStringArray
@export var flat:=false
@export var clip_text:=false
@export_enum("Left","Center","Right") var alignment=1:
	set(val):
		match(val):
			0: alignment=HORIZONTAL_ALIGNMENT_LEFT
			1: alignment=HORIZONTAL_ALIGNMENT_CENTER
			2: alignment=HORIZONTAL_ALIGNMENT_RIGHT
	get:
		return alignment
@export_group("Item Layout")
@export_enum("Fill","Begin","Center","End") var h_size:int=0:
	set(val):
		match(val):
			0: h_size=Control.SIZE_FILL if !h_expand else Control.SIZE_EXPAND_FILL
			1: h_size=Control.SIZE_SHRINK_BEGIN
			2: h_size=Control.SIZE_SHRINK_CENTER if !h_expand else Control.SIZE_SHRINK_CENTER+Control.SIZE_EXPAND
			3: h_size=Control.SIZE_SHRINK_END if !h_expand else Control.SIZE_SHRINK_END+Control.SIZE_EXPAND
	get:
		return h_size
@export var h_expand:bool=true:
	set(val):
		h_expand = val
	get:
		return h_expand
@export_enum("Fill","Begin","Center","End") var v_size:int=0:
	set(val):
		match(val):
			0: v_size=Control.SIZE_FILL if !v_expand else Control.SIZE_EXPAND_FILL
			1: v_size=Control.SIZE_SHRINK_BEGIN
			2: v_size=Control.SIZE_SHRINK_CENTER if !v_expand else Control.SIZE_SHRINK_CENTER+Control.SIZE_EXPAND
			3: v_size=Control.SIZE_SHRINK_END if !v_expand else Control.SIZE_SHRINK_END+Control.SIZE_EXPAND
	get:
		return v_size
@export var v_expand:bool=true:
	set(val):
		v_expand = val
	get:
		return v_expand
@export_group("Button Layout")
@export var normal:StyleBox
@export var pressed:StyleBox

func _ready():
	super._ready()
	set_items(select)
	connect("pressed_accept",func(i):_pressed_animation(get_row_item(i)))

func set_items(_items):
	super.set_items(mapping_items(_items))

func mapping_items(_items)->Array:
	var res := []
	for val in _items :
		var button:=Button.new()
		button.text = val
		button.flat = flat
		button.clip_text = flat
		button.alignment = alignment
		button.size_flags_horizontal = h_size
		button.size_flags_vertical = v_size
		button.set("theme_override_styles/normal",normal)
		button.set("theme_override_styles/pressed",pressed)
		button.button_mask = 0
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		res.append(button)
	return res

func _pressed_animation(btn:Button):
	btn.set("theme_override_styles/normal",pressed)
	await get_tree().create_timer(0.05).timeout
	btn.set("theme_override_styles/normal",normal)
