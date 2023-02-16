class_name MoveCharacter extends Character

signal finish_velocity_computed

# 移動ステート
enum MOVE_MODE {RANDOM,NAV,ASTAR,SELF,NONE}
# 移動モード
@export var move_mode:MOVE_MODE = MOVE_MODE.NONE:
	set(val):
		move_mode = val
		_update_move_mode()
	get:
		return move_mode

# 歩行速度
@export var move_speed_walk := 32.0
# 走行速度
@export var move_speed_run  := 128.0
# 立ちアニメ速度
@export var anim_speed_idle := 0.5
# 歩行アニメ速度
@export var anim_speed_walk := 1.0
# 走行アニメ速度
@export var anim_speed_run := 1.5
# 入力制御
@export_group("Input Setting")
@export var is_input:bool = true
@export var is_attack:bool = true
@export var is_move:bool = true
# キーマッピング
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
@export_group("Random Setting")
# ランダム停止最小時間
@export var random_wait_range_min:float = 0.7
# ランダム停止最大時間
@export var random_wait_range_max:float = 7.0
# ランダム停止確率
@export var random_wait_rate:float = 0.6:
	set(val):
		random_wait_rate = clampf(val,0.0, 1.0)
	get:
		return random_wait_rate
@export_group("Navigation Setting")
# ゴールポイント
@export var navigate_point:Vector2i :
	set(val):
		navigate_point = val
		navi_target = val
	get:
		return navigate_point
# NAV時のパス脱線許容
@export var nav_desired_distance := 16.0
# ASTAR時のパス脱線許容
@export var astar_desired_distance := 5.0
@export_group("AStar Setting")
# 移動設定
@export var world:TileMap
# AStar計算時の斜め歩行許可
@export var is_diagonal:bool = false
# AStar計算時の歩行許可レイヤ名
@export var walkable_custom_data:PackedStringArray :
	set(val):
		walkable_custom_data = val
		if walkable_custom_data != null : walkable_custom_data.sort()

# ランダム移動用
var vec_arr := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP, Vector2.UP+Vector2.RIGHT, Vector2.RIGHT+Vector2.DOWN, Vector2.DOWN+Vector2.LEFT, Vector2.LEFT+Vector2.UP]
# AStar用
var astar:AStar2D
var astar_path:PackedVector2Array
var astar_path_index:int
var world_info:Dictionary
# 移動フラグ
var is_moving:bool = false
var is_waiting:bool = false
var is_running:bool = false
var is_navigate:bool = false
var is_attacked:bool = false
var is_menu:bool = false

# 初期化
func _ready():
	super._ready()
	navigation.connect("velocity_computed", _velocity_computed)
	Menu.connect("open_menu",change_anim_idle)
	Menu.connect("finish_closed",func():if is_moving and !is_waiting: change_anim_move())
	_update_move_mode()

# 移動モード変更時の初期化処理
func _update_move_mode():
	if anim_tree!=null:
		idle()
	if navigation!=null:
		navigation.path_desired_distance = astar_desired_distance if move_mode==MOVE_MODE.ASTAR else nav_desired_distance
	if world!=null and !walkable_custom_data.is_empty() and move_mode == MOVE_MODE.ASTAR:
		reload_world_info()
		get_astar_path(navi_target)

# プロセス処理
func _process(_delta):
	# 方向計算
	if !is_moving and !is_waiting and move_mode == MOVE_MODE.RANDOM:
		_process_random(_delta)
	elif move_mode == MOVE_MODE.NAV:
		_process_nav(_delta)
	elif move_mode == MOVE_MODE.ASTAR:
		_process_astar(_delta)
	elif is_input and move_mode == MOVE_MODE.SELF:
		_process_self(_delta)
	
	# 速度計算
	if !is_waiting and is_moving:
		move_speed = move_speed_walk if !is_running else move_speed_run
		anim_speed = anim_speed_walk if !is_running else anim_speed_run
	else:
		move_speed = 0.0
		anim_speed = anim_speed_idle
	
	# ナビゲート補完
	if !is_waiting and is_navigate and navigation.avoidance_enabled:
		navigation.set_velocity(get_velocity_direction())
		await finish_velocity_computed
	elif !is_waiting and is_navigate and !navigation.avoidance_enabled:
		_velocity_computed(get_velocity_direction())
	
	# アニメーション更新
	if is_moving and !is_waiting:
		change_anim_move()
	elif !is_attacked:
		change_anim_idle()
	
	# 描画反映
	super._process(_delta)

# 手動操作プロセス
func _process_self(_delta):
	# 入力制御
	if is_input:
		var input_vector = Vector2.ZERO
		# 移動入力
		if is_move:
			input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
			input_vector.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
			is_running = Input.is_action_pressed(input_run)
		
		# 移動入力反映
		if input_vector != Vector2.ZERO:
			data.direction = input_vector
			move()
		elif is_moving:
			idle()
	
	# メニュー制御
	if !is_menu && Input.is_action_just_pressed("menu"):
		Menu.emit_signal("open_menu")
		is_menu = true
	elif is_menu:
		is_menu = false

# 単純ランダム移動プロセス
func _process_random(_delta):
	# 方向選択
	var input_vector:Vector2 = vec_arr[randi_range(0, vec_arr.size() if is_diagonal else int(vec_arr.size()/2.0) - 1)]
	data.direction = input_vector
	# 移動・停止選択
	if 0.0<random_wait_rate and randi_range(0,100)<=int(random_wait_rate*100.0):
		wait_to_time(randf_range(random_wait_range_min,random_wait_range_max))
	else:
		move_to_time(1.0)

# Navigation移動プロセス
func _process_nav(_delta):
	# 開始処理
	if !is_navigate:
		move()
		navigate()
	# 完了処理
	if navigation.is_navigation_finished():
		move_mode = MOVE_MODE.NONE
		return
	# 移動処理
	var next_position:Vector2 = navigation.get_next_path_position()
	data.direction = (next_position - global_position).normalized()

# AStar移動プロセス
func _process_astar(_delta):
	# 開始処理
	if !is_navigate:
		astar_path_index = 1
		move()
		navigate()
	# AStarパスが取得出来ていれば処理
	if !astar_path.is_empty() :
		# 完了処理
		if navigation.is_navigation_finished():
			astar_path_index = astar_path_index + 1
			if astar_path_index == astar_path.size() :
				move_mode = MOVE_MODE.NONE
				return
		# 移動処理
		navigation.target_position = astar_path[astar_path_index]
		data.direction = (navigation.target_position - global_position).normalized()
	# 未取得であればNAVに変更
	else:
		move_mode = MOVE_MODE.NAV

# ナビゲート処理
func _velocity_computed(_val):
	data.direction = _val
	emit_signal("finish_velocity_computed")

# 立ち
func idle():
	is_moving = false
	is_waiting = false
	is_navigate = false

# 移動
func move():
	is_moving = true
	is_waiting = false
	is_navigate = false

# 停止
func wait():
	is_waiting = true

# ナビゲート
func navigate():
	is_moving = true
	is_navigate = true

# 攻撃
func attack():
	is_waiting = true
	is_attacked = true
	change_anim_attack()
	await anim_tree.animation_finished
	is_waiting = false
	is_attacked = false

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

# ASTAR情報リロード（worldチップ変更後などに）
func reload_world_info():
	world_info = AStarUtil2.create_world_info(world,walkable_custom_data)
	astar = AStarUtil2.create_AStar2D(world_info,is_diagonal)

# AStarパス取得
func get_astar_path(target:Vector2):
	astar_path = AStarUtil2.recalculate_path(position,target,astar,world_info,world.tile_set.tile_size)
