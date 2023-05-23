class_name Brear extends SpellData

@export var damage:AttackData

func _process(_parent:Character,_target:Array):
	var _effect = EffectDB.Fireball(_parent,damage)
	System.menu.close()
