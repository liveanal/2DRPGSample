class_name NPC extends CharacterMove

@export_group("Check Setting")
@export var talk_data:Array[DialogData]

func _ready():
	super._ready()
	connect("damaged",_on_damaged)
	connect("checked",_on_checked)

# 攻撃情報
func _get_attack_data():
	var atk := super._get_attack_data()
	atk.force = 1
	return atk

# 被ダメ処理
func _on_damaged(atk:AttackData):
	# ポーズ
	_on_receive_system_pause()
	# 当たり判定無効
	body_collision.set_deferred("disabled",true)
	
	# ダメージ処理
	await damaged_calc(atk)
	
	# 再開
	_on_receive_system_play()
	# 当たり判定有効
	body_collision.set_deferred("disabled",false)

# 被ダメ計算
func damaged_calc(atk:AttackData):
	print("%sから%dのダメージ！"%[atk.char_name,atk.force])
	data.hp -= atk.force
	# エフェクト
	await damaged_effect()
	# 削除処理
	if data.hp == 0:
		print("%sのHPは0になった。"%data.name)
		queue_free()

# 被ダメエフェクト
func damaged_effect():
	# 点滅
	for i in range(8):
		visible = !visible
		await get_tree().create_timer(0.05).timeout
	visible = true

# チェックされたときの処理
func _on_checked(_char):
	# それぞれ処理を止める
	_char.disable()
	disable()
	# それぞれIdleアニメーションにする
	_char.change_anim_idle()
	change_anim_idle()
	# それぞれ向きを変更する
	update_anim((_char.position - position).normalized())
	# 会話開始
	await DialogSystem.open_dialog(self,talk_data[0],0.4)
	# 処理再開
	enable()
	_char.enable()
