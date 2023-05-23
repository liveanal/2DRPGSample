class_name ItemData extends Resource

# アイテムID
@export var item_id:String:
	set(val):
		item_id=val
		resource_name=item_id
	get:
		return item_id
# アイテムアイコン
@export var icon:Texture2D
# アイテム名
@export var name:String
# 重ね持ち許可
@export var stackable:bool
# 重ね個数
@export var count:int=1:
	set(val):
		count = val if 0<=val else 0
	get:
		return count
# アイテム説明
@export_multiline var description:String
# オプション
@export var menu:Array[Inventory.USE_OPTION]

func _process(_parent:Character,_target:Array):
	System.assert_warn("W_I01",[name])

# 使用処理
func use(_parent:Character,_target:Array):
	_process(_parent,_target)
	count-=1
	if count<1:
		_parent.data.inventory.erase(self)

# 投擲処理
func throw(_parent:Character):
	pass

# 鑑定処理
func estimate(_parent:Character):
	pass
