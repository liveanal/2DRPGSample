class_name Enemy extends CharacterMove

@onready var find_area := $find_area
@onready var find_timer := Timer.new()

var find_player:Character

func _ready():
	super._ready()
	connect("damaged",_on_damaged)
	
	find_timer.wait_time = 0.5
	find_timer.connect("timeout",_on_update_navigate)
	add_child(find_timer)
	
	find_area.connect("area_entered",_on_find_player)
	find_area.connect("area_exited",_on_lost_player)

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

# Player発見処理
func _on_find_player(_area):
	var parent = _area.get_parent()
	if parent.get("is_main"):
		find_player = parent
		navigate_point = find_player.position
		move_mode = MOVE_MODE.NAV
		find_timer.start()
		balloon_img("default")

# Navigate更新処理
func _on_update_navigate():
	navigate_point = find_player.position

# Player消失処理
func _on_lost_player(_area):
	find_player = null
	move_mode = MOVE_MODE.RANDOM
	find_timer.stop()
 
