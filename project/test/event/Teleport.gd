class_name Teleport extends Event

@export var map_res_path:String

func _ready():
	System.assert_error("E_201",[name],Utility.is_empty(map_res_path))
	super._ready()

func _on_event_process(_parent):
	await System.change_scene(map_res_path,0.5,false)
