class_name SkillMod extends Node2D

# 呼出者
@export var parent:Character
# スキルアイコン
@export var icon:Texture2D
# スキル名
@export var skill_name:String
# スキル説明
@export_multiline var description:String
# 攻撃情報
@export var data:AttackData
# ループ時間
@export var time:float = 2.0

@onready var texture := $texture

# 初期化
func _ready():
	# 衝突処理登録
	connect("area_entered", func(area):
		_on_area_entered(area.get_parent())
	)
	# アニメーション制御
	texture.connect("animation_finished", func():
		match(texture.animation):
			"open" :
				texture.play("loop")
			"close":
				queue_free()
	)
	# 時間処理
	get_tree().create_timer(time).connect("timeout",texture.play.bind("close"))

# SMenuEntry生成
static func create_smenu_entry() -> SMenuEntry:
	return null

# 衝突処理
func _on_area_entered(_parent):
	pass
