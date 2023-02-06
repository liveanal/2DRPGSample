class_name Character extends CharacterBody2D

const balloon_icon_res  := preload("res://project/01_parts/balloon/IconBalloon.tscn")
const balloon_image_res := preload("res://project/01_parts/balloon/ImageBalloon.tscn")
const balloon_text_res  := preload("res://project/01_parts/balloon/TextBalloon.tscn")

# 基準速度
@export var walk_speed := 32.0
@export var run_speed := 64.0
# アニメ速度
@export var anim_walk_speed := 1.0
@export var anim_run_speed := 1.5
# 基本情報
@export var data:CharData
# 移動設定
@export_category("Auto Control")
@export var world:TileMap
enum MOVE_MODE {RANDOM,NAV,ASTAR,SELF,NONE} # 移動モード
@export var move_mode:MOVE_MODE = MOVE_MODE.NONE:
	set(val):
		move_mode = val
		_update_move_mode()
	get:
		return move_mode
@export_group("Navi,AStar")
@export var navi_target:Vector2
@export_subgroup("AStar Setting")
@export var is_diagonal:bool = false # AStar計算時の斜め歩行許可
@export var walkable_custom_data:PackedStringArray : # AStar計算時の歩行許可レイヤ名
	set(val):
		walkable_custom_data = val
		if walkable_custom_data != null : walkable_custom_data.sort()

# ノード
@onready var balloon := $balloon
@onready var shadow := $shadow
@onready var texture := $texture
@onready var collision := $collision
@onready var body := $body
@onready var look := $look/_ray
@onready var navigation := $navigation
@onready var anim_tree := $anim_tree

# AStar情報
var astar:AStar2D
var cells_list:Array
var cells_info:Dictionary
# ASTAR用変数
var astar_path_index:int
var astar_path:PackedVector2Array
# Navigation用変数
@onready var default_desired_distance:int = navigation.path_desired_distance

# 移動フラグ
var is_moving:bool = false
# 停止フラグ
var is_waiting:bool = false
# 走りフラグ
var is_running:bool = false
# ナビゲートフラグ
var is_navigate:bool = false

# 初期化
func _ready():
	navigation.connect("velocity_computed", _velocity_computed)
	_update_move_mode()

# プロセス処理
func _process(_delta):
	if is_moving:
		velocity = get_velocity_by_direction()
		state_move()
		move_and_slide()
	elif is_navigate:
		if !navigation.avoidance_enabled:
			_velocity_computed(get_velocity_by_direction())
		else:
			navigation.set_velocity(get_velocity_by_direction())
	else:
		velocity = Vector2.ZERO
		state_idle()

# velocity計算
func get_velocity_by_direction():
	return data.direction.normalized()*(walk_speed if !is_running else run_speed)

# 移動モード変更
func _update_move_mode():
	if anim_tree!=null:
		idle()
	if navigation!=null:
		navigation.target_position = navi_target
		if move_mode == MOVE_MODE.ASTAR:
			navigation.path_desired_distance = 1
		else:
			navigation.path_desired_distance = default_desired_distance
	if world!=null and !walkable_custom_data.is_empty():
		reload_world_info()
		get_astar_path(navi_target)

# アニメーション変更(歩行)
func state_move():
	anim_tree.set("parameters/Move/BlendSpace2D/blend_position",data.direction)
	anim_tree.set("parameters/Move/TimeScale/scale",anim_walk_speed if !is_running else anim_run_speed)

# アニメーション変更(立ち)
func state_idle():
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",data.direction)
	anim_tree.set("parameters/Idle/TimeScale/scale",anim_walk_speed if !is_running else anim_run_speed)

# 立ち
func idle():
	anim_tree.get("parameters/playback").travel("Idle")
	is_moving = false
	is_waiting = false
	is_navigate = false

# 移動
func move():
	anim_tree.get("parameters/playback").travel("Move")
	is_moving = true
	is_waiting = false
	is_navigate = false

# 停止
func wait():
	anim_tree.get("parameters/playback").travel("Idle")
	is_moving = false
	is_waiting = true
	is_navigate = false

# ナビゲート
func navigate():
	anim_tree.get("parameters/playback").travel("Move")
	is_moving = false
	is_waiting = false
	is_navigate = true

# 時間分移動
func move_to_time(time:float):
	move()
	await get_tree().create_timer(time).timeout
	idle()

# 時間分停止
func wait_to_time(time:float):
	wait()
	await get_tree().create_timer(time).timeout
	idle()

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
	set_process_input(true)

# 無効化
func disable():
	set_process(false)
	set_process_input(false)

# ナビゲート処理
func _velocity_computed(_val):
	data.direction = _val
	velocity = _val
	state_move()
	move_and_slide()

# ASTAR情報リロード（worldチップ変更後などに）
func reload_world_info():
	cells_list = AStarUtil.create_walkable_cells_list(world,walkable_custom_data)
	cells_info = AStarUtil.create_walkable_cells_info(cells_list)
	astar = AStarUtil.create_AStar2D(cells_list,cells_info,is_diagonal)

# AStarパス取得
func get_astar_path(target:Vector2):
	astar_path = AStarUtil.recalculate_path(position,target,astar,cells_list,cells_info,world.cell_quadrant_size)
