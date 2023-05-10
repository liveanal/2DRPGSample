class_name LabelCSel extends CursorSelectable

@export var select:=PackedStringArray():
	set(val):
		select = val
	get:
		return select
@export var label_settings:LabelSettings:
	set(val):
		label_settings = val
	get:
		return label_settings
@export_enum("Left","Center","Right") var text_h_alignment:int=0:
	set(val):
		match(val):
			0: text_h_alignment=HORIZONTAL_ALIGNMENT_LEFT
			1: text_h_alignment=HORIZONTAL_ALIGNMENT_CENTER
			2: text_h_alignment=HORIZONTAL_ALIGNMENT_RIGHT
			3: text_h_alignment=HORIZONTAL_ALIGNMENT_FILL
	get:
		return text_h_alignment
@export_enum("Top","Center","Bottom") var text_v_alignment:int=1:
	set(val):
		match(val):
			0: text_v_alignment=VERTICAL_ALIGNMENT_TOP
			1: text_v_alignment=VERTICAL_ALIGNMENT_CENTER
			2: text_v_alignment=VERTICAL_ALIGNMENT_BOTTOM
			3: text_v_alignment=VERTICAL_ALIGNMENT_FILL
	get:
		return text_v_alignment
@export_group("Item Layout")
@export_enum("Fill","Begin","Center","End") var label_h_size:int=0:
	set(val):
		label_h_size = val
	get:
		return label_h_size
@export var label_h_expand:bool=true:
	set(val):
		label_h_expand = val
	get:
		return label_h_expand
@export_enum("Fill","Begin","Center","End") var label_v_size:int=0:
	set(val):
		label_v_size = val
	get:
		return label_v_size
@export var label_v_expand:bool=true:
	set(val):
		label_v_expand = val
	get:
		return label_v_expand

func _ready():
	super._ready()
	set_items(select)

func set_items(_items):
	super.set_items(mapping_items(_items))

func mapping_items(_items)->Array:
	var res := []
	for val in _items :
		res.append(Utility.create_label(val,text_h_alignment,text_v_alignment,label_h_size,label_h_expand,label_v_size,label_v_expand,label_settings))
	return res
