class_name MoveCharacter extends Character

@export_category("Self Control")
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
@export_group("Random Setting")
@export var random_wait_range_min:float = 0.7
@export var random_wait_range_max:float = 7.0
@export var random_wait_rate:float = 0.6:
	set(val):
		random_wait_rate = clampf(val,0.0, 1.0)
	get:
		return random_wait_rate
# ランダム移動用
var vec_arr := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP, Vector2.UP+Vector2.RIGHT, Vector2.RIGHT+Vector2.DOWN, Vector2.DOWN+Vector2.LEFT, Vector2.LEFT+Vector2.UP]

# 初期化
func _ready():
	super._ready()

# プロセス処理
func _process(_delta):
	if !is_moving and !is_waiting and move_mode == MOVE_MODE.RANDOM:
		_process_random(_delta)
	elif move_mode == MOVE_MODE.NAV:
		_process_nav(_delta)
	elif move_mode == MOVE_MODE.ASTAR:
		_process_astar(_delta)
	elif is_input and move_mode == MOVE_MODE.SELF:
		_process_self(_delta)
	super._process(_delta)

# 手動操作プロセス
func _process_self(_delta):
	var input_vector = Vector2.ZERO
	# 移動入力
	if is_move:
		input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
		input_vector.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
		is_running = Input.is_action_pressed(input_run)
	
	# 移動入力反映
	if input_vector != Vector2.ZERO:
		data.direction = input_vector
		if !is_moving: move()
	elif is_moving:
		idle()

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
		navigate()
	# 移動処理
	var next_position:Vector2 = navigation.get_next_path_position()
	data.direction = next_position - global_position
	# 完了処理
	if navigation.is_navigation_finished():
		move_mode = MOVE_MODE.NONE
		idle()

# AStar移動プロセス
func _process_astar(_delta):
	# 開始処理
	if !is_navigate:
		get_astar_path(navi_target)
		astar_path_index = 1
		navigate()
	# AStarパスが取得出来ていれば処理
	if !astar_path.is_empty() :
		# 移動処理
		navigation.target_position = astar_path[astar_path_index]
		data.direction = navigation.target_position - global_position
		# 完了処理
		if navigation.is_navigation_finished():
			astar_path_index = astar_path_index + 1
			if astar_path_index == astar_path.size() :
				move_mode = MOVE_MODE.NONE
				idle()
	# 未取得であればNAVに変更
	else:
		move_mode = MOVE_MODE.NAV
