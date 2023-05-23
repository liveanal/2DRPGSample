class_name RemoteEffect extends Area2D

@onready var anim := $anim
@onready var collision := $collision

func entry():
	System.get_scene().add_child(self)
