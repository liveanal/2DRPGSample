class_name Character extends CharacterBody2D

# 非ダメージシグナル
signal damaged(atk:AttackData)
# チェックシグナル
signal checked(char:Character)

# 基本情報
@export var data:CharData
# メインキャラ設定
@export var is_main:bool=false:
	set(val):
		is_main = val
		set_process_input(is_main)
		# Mainキャラにカメラを設定
		if is_main:
			_set_main_character()
	get:
		return is_main

# ノード
@onready var shadow := $shadow
@onready var texture := $texture
@onready var collision := $collision
@onready var body := $body
@onready var body_collision := $body/collision
@onready var look := $look/_ray
@onready var navigation := $navigation
@onready var anim_tree := $anim_tree
@onready var anim_state:AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
@onready var anim_player := $anim_player
@onready var attack_effect := $attack_effect
@onready var attack_area := $attack
@onready var attack_collision := $attack/collision

# 基準速度
var move_speed := 32.0
# 向き変更フラグ（移動反映なし）
var move_turn := false
# ナビターゲット
var navi_target := Vector2.ZERO :
	set(val):
		navi_target = val
		if navigation != null: navigation.target_position = navi_target
	get:
		return navi_target

# 初期化処理
func _ready():
	# data未設定確認
	System.assert_error("E_001", [name], data==null, func():data = CharData.new())
	# HPが0の場合は削除
	if data.hp <= 0: queue_free()
	# is_main初期化
	if is_main:
		_set_main_character()
	
	# 共通シグナル処理
	System.connect("pause",_on_receive_system_pause)
	System.connect("play",_on_receive_system_play)
	System.connect("disable",_on_receive_system_disable)
	System.connect("enable",_on_receive_system_enable)
	# 攻撃シグナル処理
	attack_area.connect("area_entered", func(area):
		var target = area.get_parent()
		if target.has_signal("damaged") and target!=self:
			target.emit_signal("damaged", get_attack_data()))
	
	navigation.target_position = navi_target
	attack_effect.visible = false
	attack_area.visible = false
	attack_collision.disabled = true

# is_main設定時処理
func _set_main_character():
	System.current_character = self
	if System.get_camera_manager() != null:
		System.get_camera_manager().target = self

# プロセス処理
func _process(_delta):
	# velocity反映
	velocity = get_velocity_direction()
	if velocity != Vector2.ZERO and !move_turn:
		move_and_slide()

# velocity計算
func get_velocity_direction():
	return data.direction.normalized()*move_speed

# 会話ダイアログ表示
func open_dialog(_data:DialogData):
	disable()
	System.open_dialog(self,_data,0.5)
	await System.finished_dialog
	enable()

# メニュー表示
func open_menu(party_member:Array[Character]):
	System.emit_signal("pause")
	System.open_menu(party_member)
	await System.finished_menu
	System.emit_signal("play")

# lay先オブジェクト取得
func get_raycast_object():
	if look.is_colliding() and look.get_collider()!=null:
		return look.get_collider().get_parent()

# 有効化
func enable():
	set_process(true)
	set_process_input(is_main)

# 無効化
func disable():
	set_process(false)
	set_process_input(false)

# System.pauseシグナル受信処理
func _on_receive_system_pause():
	disable()
	anim_tree.active = false

# System.playシグナル受信処理
func _on_receive_system_play():
	enable()
	anim_tree.active = true

# System.disableシグナル受信処理
func _on_receive_system_disable():
	disable()

# System.enableシグナル受信処理
func _on_receive_system_enable():
	enable()

# 攻撃情報取得
func get_attack_data()->AttackData:
	var atk := AttackData.new()
	atk.char_name = data.name
	return atk

# アイテム追加
func add_item(item:ItemData):
	var idx := has_item(item)
	if -1<idx and item.is_multiple:
		data.inventory[idx].count += item.count
	else:
		data.inventory.append(item)

# アイテム削除
func del_item(idx:int,count:int=1):
	data.inventory[idx].count -= count
	if data.inventory[idx].count<1:
		data.inventory.remove_at(idx)

# 同一IDのアイテム番号取得
func has_item(item:ItemData)->int:
	for target in data.inventory:
		if target.item_id == item.item_id:
			return data.inventory.find(target)
	return -1

# アイテム使用
func get_item(idx:int)->ItemData:
	return data.inventory[idx]

# スペル追加
func add_spell(spell:SpellData):
	data.spells.append(spell)

# スペル削除
func del_spell(idx:int):
	data.spells.remove_at(idx)

# 同一IDのスペル番号取得
func has_spell(spell:SpellData)->int:
	for target in data.spells:
		if target.spell_id == spell.spell_id:
			return data.spells.find(target)
	return -1

# アイテム使用
func get_spell(idx:int)->SpellData:
	return data.spells[idx]
