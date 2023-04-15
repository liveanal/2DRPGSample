class_name CharData extends Resource

# キャラ名
@export var name:String
# 向き
@export var direction:Vector2 = Vector2(0,1)
# 所持金
@export var money:int
# 所持アイテム
@export var inventory:Array[ItemBase]
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
@export var smenu1:Array[SMenuEntry] = [null,null,null,null,null,null,null,null]
@export var smenu2:Array[SMenuEntry] = [null,null,null,null,null,null,null,null]
@export var smenu3:Array[SMenuEntry] = [null,null,null,null,null,null,null,null]
