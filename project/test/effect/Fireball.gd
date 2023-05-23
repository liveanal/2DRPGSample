class_name Fireball extends RemoteEffect

@export var parent:Character
@export var speed:float = 150.0
@export var time_limit:float = 3.0
@export_group("MetaData")
@export var damage:AttackData
@export var no_target:Array[Character]

var direction:Vector2
var velocity:Vector2

func _ready():
	# キャラクターとの衝突判定
	connect("area_entered", func(area):
		if !no_target.has(area.get_parent()):
			collided_character(area.get_parent())
	)
	# マップ障壁との衝突判定
	connect("body_entered", func(body):
		if body is TileMap:
			collided_tilemap(body)
	)
	
	# アニメーション切り替え処理
	anim.connect("animation_finished", func():
		if anim.animation == "start":
			anim.play("fly")
	)
	# 時間制限
	get_tree().create_timer(time_limit).connect("timeout", queue_free)
	
	# 初期化
	no_target.append(parent)
	damage.char_name = parent.name
	# 移動計算
	direction = Vector2.RIGHT.rotated(rotation).normalized()
	velocity = direction * speed

func _process(_delta):
	position += velocity * _delta

func collided_character(_target:Character):
	_target.emit_signal("damaged", damage)

func collided_tilemap(_tilemap:TileMap):
	print("collided wall")
	queue_free()
