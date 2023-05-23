class_name Heal extends CharEffect

func _ready():
	anim.connect("animation_finished",func():
		queue_free()
	)
