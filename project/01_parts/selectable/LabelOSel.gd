class_name LabelOSel extends OverlapSelectable

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
@export_enum(Left,Center,Right) var horizontal_alignment:int=0:
	set(val):
		match(val):
			0: horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
			1: horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			2: horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
			3: horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	get:
		return horizontal_alignment
@export_enum(Top,Center,Bottom) var vertical_alignment:int=1:
	set(val):
		match(val):
			0: vertical_alignment=VERTICAL_ALIGNMENT_TOP
			1: vertical_alignment=VERTICAL_ALIGNMENT_CENTER
			2: vertical_alignment=VERTICAL_ALIGNMENT_BOTTOM
			3: vertical_alignment=VERTICAL_ALIGNMENT_FILL
	get:
		return vertical_alignment

func _ready():
	super._ready()
	set_items(mapping_items(select))

func mapping_items(select)->Array:
	var items := []
	for val in select : 
		items.append(Utility.create_label(val,horizontal_alignment,vertical_alignment,0,true,size_vertical,expand,label_settings))
	return items
