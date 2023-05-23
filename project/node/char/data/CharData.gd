class_name CharData extends Resource

# キャラ名
@export var name:String
# 向き
@export var direction:Vector2 = Vector2(0,1)
# 所持金
@export var money:int
# MAXHP
@export var max_hp:int:
	set(val):
		max_hp = val if 0<=val else 0
	get:
		return max_hp
# NOWHP
@export var hp:int:
	set(val):
		hp = clamp(val,0,max_hp)
	get:
		return hp
# MPMAX
@export var max_mp:int:
	set(val):
		max_mp = val if 0<=val else 0
	get:
		return max_mp
# NOWMP
@export var mp:int:
	set(val):
		mp = clamp(val,0,max_mp)
	get:
		return mp

# 所持アイテム
@export var inventory:Array[ItemData]
# 所持スキル
@export var spellbook:Array[SpellData]
