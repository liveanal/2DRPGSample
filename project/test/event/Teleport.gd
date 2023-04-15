class_name Teleport extends Event

@export var map_res_path:String

func _ready():
	Logging.assert_error("E_201",[name],Utility.is_empty(map_res_path))
	super._ready()

func _on_event_process(_parent):
	await System.change_world(map_res_path)
