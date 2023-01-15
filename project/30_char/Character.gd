class_name Character extends CharacterBody2D

const balloon_icon_res  := preload("res://project/01_parts/balloon/IconBalloon.tscn")
const balloon_image_res := preload("res://project/01_parts/balloon/ImageBalloon.tscn")
const balloon_text_res  := preload("res://project/01_parts/balloon/TextBalloon.tscn")

# 基準速度
@export var speed := 32.0
# アニメ速度
@export var anim_speed := 0.5
# 基本情報
@export var data:CharData

@export_group("Input Setting")
@export var is_input:bool = true
@export var is_attack:bool = true
@export var is_move:bool = true
@export_subgroup("Mapping")
@export var input_left:String = "left"
@export var input_right:String = "right"
@export var input_up:String = "up"
@export var input_down:String = "down"
@export var input_attack:String = "attack"
@export var input_run:String = "run"
@export var input_turn:String = "turn"
@export var input_menu:String = "cancel"
@export var input_smenu_skill:String = "smenu1"
@export var input_smenu_item:String = "smenu2"
@export var input_smenu_stance:String = "smenu3"

@onready var balloon := $balloon
@onready var shadow := $shadow
@onready var texture := $texture
@onready var collision := $collision
@onready var look := $look/_ray
@onready var navigation := $navigation
@onready var anim_tree := $anim_tree

func _ready():
	state_idle()
	walk_to_time(3.0)

# アニメーション変更(歩行)
func state_move():
	anim_tree.set("parameters/Move/BlendSpace2D/blend_position",data.direction)
	anim_tree.get("parameters/playback").travel("Move")
	change_anim_speed()

# アニメーション変更(立ち)
func state_idle():
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",data.direction)
	anim_tree.get("parameters/playback").travel("Idle")
	change_anim_speed()

# アニメ速度変更
func change_anim_speed():
	anim_tree.set("parameters/Idle/TimeScale/scale",anim_speed)
	anim_tree.set("parameters/Move/TimeScale/scale",anim_speed)

# 歩行
func walk():
	state_move()
	velocity=data.direction.normalized()*speed
	move_and_slide()

# 停止
func idle():
	state_idle()
	velocity=Vector2.ZERO

# 時間分歩行
func walk_to_time(time:float):
	walk()
	await get_tree().create_timer(time).timeout
	idle()

# 指定時間内にlength分歩行
func walk_to_length(scalar:float,time:float=1.0):
	var pos := position + data.direction.normalized()*scalar
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"position",pos,time)
	state_move()
	await tween.finished
	state_idle()

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

# lay先オブジェクト取得
func get_raycast_object():
	if look.is_colliding():
		return look.get_collider().get_parent()

