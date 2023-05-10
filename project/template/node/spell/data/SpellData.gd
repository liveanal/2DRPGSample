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
@export var spell_name:String
# 使用コスト
@export var use_cost:int
# スキル説明
@export_multiline var description:String
