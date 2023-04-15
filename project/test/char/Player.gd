class_name Player extends CharacterMove

func _ready():
	super._ready()
	connect("damaged",_on_damaged)

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

# ショートカットコールテスト
func call_test():
	# ポーズ
	disable()
	# 当たり判定無効
	body_collision.set_deferred("disabled",true)
	
	# 攻撃
	await attack()
	await attack()
	
	# 再開
	enable()
	# 当たり判定有効
	body_collision.set_deferred("disabled",false)
