class_name Character extends CharacterBody2D

const balloon_icon_res  := preload("res://project/01_parts/balloon/IconBalloon.tscn")
const balloon_image_res := preload("res://project/01_parts/balloon/ImageBalloon.tscn")
const balloon_text_res  := preload("res://project/01_parts/balloon/TextBalloon.tscn")

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
# アニメ速度
var anim_speed := 0.5
# 攻撃時のアニメ速度（乗算値）
var anim_speed_attack_multiple := 20.0
# ナビターゲット
var navi_target := Vector2.ZERO :
	set(val):
		navi_target = val
		if navigation != null: navigation.target_position = navi_target
	get:
		return navi_target

# 初期化処理
func _ready():
	Menu.connect("open_menu",disable)
	Menu.connect("finished_close",enable)
	navigation.target_position = navi_target
	attack_effect.visible = false
	attack_area.visible = false
	attack_collision.disabled = true
	start_anim()

# プロセス処理
func _process(_delta):
	# velocity反映
	velocity = get_velocity_direction()
	if velocity != Vector2.ZERO and !move_turn:
		move_and_slide()
	update_anim()

# velocity計算
func get_velocity_direction():
	return data.direction.normalized()*move_speed

# アニメーション再生
func start_anim():
	anim_state.start("Idle")

# アニメーション更新
func update_anim():
	anim_tree.set("parameters/Move/BlendSpace2D/blend_position",data.direction)
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",data.direction)
	anim_tree.set("parameters/Attack/BlendSpace2D/blend_position",data.direction)
	anim_tree.set("parameters/Move/TimeScale/scale",anim_speed)
	anim_tree.set("parameters/Idle/TimeScale/scale",anim_speed)
	anim_tree.set("parameters/Attack/TimeScale/scale",anim_speed*anim_speed_attack_multiple)

# 立ち
func change_anim_idle(reset:=false):
	anim_state.travel("Idle",reset)

# 移動
func change_anim_move(reset:=false):
	anim_state.travel("Move",reset)

# 攻撃
func change_anim_attack(reset:=false):
	anim_state.travel("Attack",reset)

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
	if look.is_colliding():
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

# 有効化
func enable():
	set_process(true)
	set_process_input(is_main)
	anim_tree.set("parameters/"+str(anim_state.get_current_node())+"/TimeSeek/seek_request",anim_state.get_current_play_position())
	anim_tree.active = true
	
# 無効化
func disable():
	set_process(false)
	set_process_input(false)
	anim_tree.active = false
