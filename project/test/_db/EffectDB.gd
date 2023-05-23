class_name EffectDB

static func Heal(target:Character):
	var effect = load("res://project/test/effect/Heal.tscn").instantiate()
	
	effect.entry(target)
	return effect

static func Fireball(parent:Character,data:AttackData):
	var effect = load("res://project/test/effect/Fireball.tscn").instantiate()
	
	effect.parent = parent
	effect.damage = data
	effect.rotation = parent.data.direction.angle()
	effect.position = parent.position + Vector2(16,0).rotated(parent.data.direction.angle())
	if parent.data.direction==Vector2.LEFT or parent.data.direction==Vector2.RIGHT:
		effect.position += Vector2(0,-10)
	
	effect.entry()
	return effect
