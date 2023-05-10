class_name CharData extends Resource

# キャラ名
@export var name:String
# 向き
@export var direction:Vector2 = Vector2(0,1)
# 所持金
@export var money:int
# 所持アイテム
@export var inventory:Array[ItemData]
# 所持スキル
@export var spells:Array[SpellData]
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

# ショートカット設定
@export_group("SMenu Setting")
@export var smenu1:Array[SMenuData] = [null,null,null,null,null,null,null,null]
@export var smenu2:Array[SMenuData] = [null,null,null,null,null,null,null,null]
@export var smenu3:Array[SMenuData] = [null,null,null,null,null,null,null,null]
