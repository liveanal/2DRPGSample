class_name CharData extends Resource

# キャラ名
@export var name:String
# 向き
@export var direction:Vector2 = Vector2(0,1)
# 所持金
@export var money:int
# 所持アイテム
@export var inventory:Array[ItemBase]
