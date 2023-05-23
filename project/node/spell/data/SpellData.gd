class_name SpellData extends Resource

# スペルID
@export var spell_id:String:
	set(val):
		spell_id=val
		resource_name=spell_id
	get:
		return spell_id
# スペルアイコン
@export var icon:Texture2D
# スペル名
@export var name:String
# 使用コスト
@export var cost:int
# スキル説明
@export_multiline var description:String

func _process(_parent:Character,_target:Array):
	pass

# 使用処理
func cast(_parent:Character,_target:Array):
	_process(_parent,_target)
	_parent.data.mp-=cost
