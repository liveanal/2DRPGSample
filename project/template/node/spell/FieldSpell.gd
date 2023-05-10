class_name FieldSpell extends Node2D

signal entered_target(target)
signal exited_target(target)

@export var data:SpellData
@onready var texture := $texture
@onready var collision := $collision

# 呼出元
var parent:Character
# 対象
var target_list:Array = []

# 初期化
func _ready():
	# 衝突時target_listに追加
	connect("area_entered", func(area):
		var target = area.get_parent()
		# 対象であればtarget_listに追加
		if _check_target(target):
			target_list.append(target)
			emit_signal("entered_target",target))
	# 退避時target_listから排除
	connect("area_exited", func(area):
		var target = area.get_parent()
		var idx:int = target_list.find(target)
		# targetがリストにいれば除外
		if -1<idx:
			target_list.remove_at(idx)
			emit_signal("exited_target",target))

# 衝突対象絞り込み
func _check_target(target) -> bool:
	return target != self
