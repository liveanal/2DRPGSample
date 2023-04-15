class_name Character extends CharacterBody2D

const balloon_icon_res  := preload("res://project/01_parts/balloon/IconBalloon.tscn")
const balloon_image_res := preload("res://project/01_parts/balloon/ImageBalloon.tscn")
const balloon_text_res  := preload("res://project/01_parts/balloon/TextBalloon.tscn")

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
	get:
		return is_main

# ノード
@onready var balloon := $balloon
@onready var shadow := $shadow
@onready var texture := $texture
@onready var collision := $collision
@onready var body := $body
@onready var body_collision := $body/collision
@onready var look := $look/_ray
@onready var navigation := $navigation
@onready var smenu1 := $smenu1
@onready var smenu2 := $smenu2
@onready var smenu3 := $smenu3
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
	Logging.assert_error("E_001", [name], data==null, func():data = CharData.new())
	# HPが0の場合は削除
	if data.hp <= 0: queue_free()
	# ショートカット復元
	for i in range(8):
		entry_smenu1(i,data.smenu1[i])
		entry_smenu2(i,data.smenu2[i])
		entry_smenu3(i,data.smenu3[i])
	
	# 共通シグナル処理
	System.connect("pause",_on_receive_system_pause)
	System.connect("play",_on_receive_system_play)
	System.connect("disable",_on_receive_system_disable)
	System.connect("disable_all",_on_receive_system_disable_all)
	System.connect("enable",_on_receive_system_enable)
	Menu.connect("open_menu",_on_receive_menu_open)
	Menu.connect("finished_close",_on_receive_menu_finish)
	# 攻撃シグナル処理
	attack_area.connect("area_entered", func(area):
		var parent = area.get_parent()
		if parent.has_signal("damaged") and parent!=self:
			parent.emit_signal("damaged", _get_attack_data()))
	
	navigation.target_position = navi_target
	attack_effect.visible = false
	attack_area.visible = false
	attack_collision.disabled = true

# プロセス処理
func _process(_delta):
	# velocity反映
	velocity = get_velocity_direction()
	if velocity != Vector2.ZERO and !move_turn:
		move_and_slide()

# velocity計算
func get_velocity_direction():
	return data.direction.normalized()*move_speed

# バルーン表示（アイコン）
func balloon_icon(anim_name:String,iscale:float=1.0,_scale:float=1.0,speed_scale:float=1.0,auto_close:bool=true,anim_time:=0.65,wait_time:=1.5)->IconBalloon:
	var obj := balloon_icon_res.instantiate()
	obj.anim_name=anim_name
	obj.speed_scale=speed_scale
	obj.pos_offset=balloon.position
	obj.icon_scale=iscale
	obj.scale=Vector2(_scale,_scale)
	obj.anim_time=anim_time
	obj.wait_time=wait_time
	obj.auto_close=auto_close
	obj.auto_play=true
	add_child(obj)
	return obj

# バルーン表示（画像）
func balloon_img(anim_name:String,_scale:float=1.0,speed_scale:float=1.0,auto_close:bool=true,anim_time:=0.65,wait_time:=1.5)->ImageBalloon:
	var obj := balloon_image_res.instantiate()
	obj.anim_name=anim_name
	obj.speed_scale=speed_scale
	obj.pos_offset=balloon.position
	obj.scale=Vector2(_scale,_scale)
	obj.anim_time=anim_time
	obj.wait_time=wait_time
	obj.auto_close=auto_close
	obj.auto_play=true
	add_child(obj)
	return obj

# バルーン表示（テキスト）
func balloon_text(text:String,font_size:=16,_scale:float=1.0,auto_close:bool=true,anim_time:=0.65,wait_time:=1.5)->TextBalloon:
	var obj:TextBalloon = balloon_text_res.instantiate()
	obj.text=text
	obj.pos_offset=balloon.position
	obj.font_size=font_size
	obj.scale=Vector2(_scale,_scale)
	obj.anim_time=anim_time
	obj.wait_time=wait_time
	obj.auto_close=auto_close
	obj.auto_play=true
	add_child(obj)
	return obj

# 会話ダイアログ表示
func open_dialog(_data:DialogData):
	disable()
	DialogSystem.open_dialog(self,_data,0.5)
	await DialogSystem.finished
	enable()

# メニュー表示
func open_menu():
	Menu.emit_signal("open_menu")
	Menu.open()
	await Menu.finished_close

# lay先オブジェクト取得
func get_raycast_object():
	if look.is_colliding() and look.get_collider()!=null:
		return look.get_collider().get_parent()

# インベントリにアイテム追加
func add_item(item:ItemBase):
	var idx := has_item(item)
	if -1<idx and item.is_multiple:
		data.inventory[idx].count += item.count
	else:
		data.inventory.append(item)

# インベントリからアイテム削除
func del_item(idx:int,count:int=1):
	data.inventory[idx].count -= count
	if data.inventory[idx].count<1:
		data.inventory.remove_at(idx)

# インベントリから同一IDのアイテム番号取得
func has_item(item:ItemBase)->int:
	for target in data.inventory:
		if target.item_id == item.item_id:
			return data.inventory.find(target)
	return -1

# ショートカット1を登録
func entry_smenu1(i:int, entry:SMenuEntry):
	data.smenu1[i] = entry
	smenu1.entry_select(i,entry)

# ショートカット2を登録
func entry_smenu2(i:int, entry:SMenuEntry):
	data.smenu2[i] = entry
	smenu2.entry_select(i,entry)

# ショートカット3を登録
func entry_smenu3(i:int, entry:SMenuEntry):
	data.smenu3[i] = entry
	smenu3.entry_select(i,entry)

# ショートカット1を削除
func remove_smenu1(i:int):
	data.smenu1[i] = null
	smenu1.entry_select(i,null)

# ショートカット2を登録
func remove_smenu2(i:int):
	data.smenu2[i] = null
	smenu2.entry_select(i,null)

# ショートカット3を登録
func remove_smenu3(i:int):
	data.smenu3[i] = null
	smenu3.entry_select(i,null)

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
	if is_main: disable()

# System.disable_allシグナル受信処理
func _on_receive_system_disable_all():
	disable()

# System.enableシグナル受信処理
func _on_receive_system_enable():
	enable()

# Menu.open_menuシグナル受信処理
func _on_receive_menu_open():
	_on_receive_system_pause()

# Menu.finished_closeシグナル受信処理
func _on_receive_menu_finish():
	_on_receive_system_play()

# 攻撃情報取得
func _get_attack_data()->AttackData:
	var atk := AttackData.new()
	atk.char_name = data.name
	return atk
