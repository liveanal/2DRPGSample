class_name Food extends ItemData

@export var heal_point := 2

# 使用処理
func _process(_parent:Character,_target:Array):
	var effect = EffectDB.Heal(_parent)
	_parent.data.hp += heal_point
	System.menu.close(false)
	effect.anim.connect("animation_finished", System.menu.emit_signal.bind("finished_close"))
