class_name CharEffect extends Node2D

@onready var anim := $anim

func entry(target:Character):
	target.add_child(self)
