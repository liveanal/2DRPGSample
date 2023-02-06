class_name DialogData extends Resource

@export_subgroup("Character Info")
@export var name:String
@export var face:Texture2D
@export_subgroup("Message")
@export_multiline var dialog:String
@export_subgroup("Next Message")
@export var selectable:Array[DialogSelect]
@export var next:DialogData
@export_subgroup("Callback Method")
@export var call_func:StringName

func get_selectable_text()->Array[String]:
	var textarr:Array[String]=[]
	for text in selectable:
		textarr.append(text.text)
	return textarr
