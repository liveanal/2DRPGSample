class_name CharacterAnim extends Character

# アニメ速度
var anim_speed := 0.5
# 攻撃時のアニメ速度（乗算値）
var anim_speed_attack_multiple := 20.0

# 初期化
func _ready():
	super._ready()

# 更新
func _process(delta):
	super._process(delta)
	update_anim()

# 有効化
func enable():
	anim_tree.set("parameters/"+str(anim_state.get_current_node())+"/TimeSeek/seek_request",anim_state.get_current_play_position())
	super.enable()

# アニメーション更新
func update_anim(direction:Vector2=data.direction):
	anim_tree.set("parameters/Move/BlendSpace2D/blend_position",direction)
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",direction)
	anim_tree.set("parameters/Attack/BlendSpace2D/blend_position",direction)
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
