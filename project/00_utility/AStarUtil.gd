class_name AStarUtil

# ワールド座標vをグリッド座標系に変換する
static func _world_to_point(v:Vector2,cell_size:int) -> Vector2i:
	var x = (v.x)/float(cell_size) + (-1 if v.x<0 else 0)
	var y = (v.y)/float(cell_size) + (-1 if v.y<0 else 0)
	return Vector2i(x,y)

# ワールド座標vをインデックスに変換する
static func _world_to_index(v:Vector2,cells_info:Dictionary,cell_size:int) -> int:
	return _point_to_index(_world_to_point(v,cell_size),cells_info)

# グリッド座標pをインデックスに変換する
static func _point_to_index(p:Vector2i,cells_info:Dictionary) -> int:
	var px = p.x + abs(cells_info["min"].x)
	var py = p.y + abs(cells_info["min"].y)
	return int(px + (py * cells_info["size"].x))

# インデックスindexをワールド座標に変換する
static func _index_to_world_position(index:int,cells_info:Dictionary,cell_size:int) -> Vector2:
	var i = index % int(cells_info["size"].x)
	var j = int(float(index)/cells_info["size"].x)
	var x = i*cell_size-abs(cells_info["min"].x)*cell_size+cell_size/2
	var y = j*cell_size-abs(cells_info["min"].y)*cell_size+cell_size/2
	return Vector2(x,y)

# ワールド座標vのセルが歩行可能であればグリッド座標を返却
static func _get_walkable_position(v:Vector2,cells_list:Array,cells_info:Dictionary,cell_size:int):
	# グリッド座標系に変換する
	var p := _world_to_point(v,cell_size)
	# 歩行可能座標であれば返却
	if cells_list.has(p) and !_is_outside_map_bounds(p,cells_info):
		return p
	else:
		return

# グリッド座標pがマップの領域外か判定
static func _is_outside_map_bounds(p:Vector2i,cells_info:Dictionary) -> bool:
	if p < cells_info["min"] or cells_info["max"] <= p:
		return true # 領域外
	# 有効なマップの範囲内
	return false

# AStarにノード同士の接続情報を登録する
static func _astar_connect_walkable_cells(astar:AStar2D,points_array:Array,cells_info:Dictionary) -> void:
	for p in points_array:
		# インデックスに変換する
		var index = _point_to_index(p,cells_info)
		# 上下左右に接続する
		var points_ralative := Array([
			Vector2(p.x + 1, p.y), # 右
			Vector2(p.x - 1, p.y), # 左
			Vector2(p.x, p.y + 1), # 下
			Vector2(p.x, p.y - 1)]) # 上
		
		# 上下左右を調べる
		for p_relative in points_ralative:
			# インデックスに変換
			var relative_index = _point_to_index(p_relative,cells_info)
			if _is_outside_map_bounds(p_relative,cells_info):
				continue # 領域外なので接続できない
			if not astar.has_point(relative_index):
				continue # 移動不可なので接続できない
			# インデックス同士を接続する
			# 第3引数がfalseなので、index -> relative_index への一方通行を許可
			astar.connect_points(index,relative_index,false)

# AStarにノード同士の接続情報を登録する (斜め移動を許可する)
static func _astar_connect_walkable_cells_diagonal(astar:AStar2D,points_array:Array,cells_info:Dictionary) -> void:
	for p in points_array:
		var index = _point_to_index(p,cells_info)
		# 3x3の9方向探索
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(p.x + local_x - 1, p.y + local_y - 1)
				var relative_index = _point_to_index(point_relative,cells_info)

				if point_relative == Vector2(p.x,p.y) or _is_outside_map_bounds(point_relative,cells_info):
					continue # 領域外
				if not astar.has_point(relative_index):
					continue # 障害物
				astar.connect_points(index,relative_index,true)

# TileMapからcustom_data_listに指定の値がtrueのセル座標(Vector2i)を取得
# @param world ワールド情報
# @param custom_data_list custom_data_layer名のリスト
static func create_walkable_cells_list(world:TileMap,custom_data_list:Array=[]) -> Array:
	var array := []
	# レイヤー分ループ
	for layer_idx in world.get_layers_count():
		# resultに抽出したcellを追加
		array.append_array(
			# custom_data_list[i]=trueのcellでかつ座標が重複していないcellを抽出
			world.get_used_cells(layer_idx).filter(func(cell:Vector2i): 
				var tiledata := world.get_cell_tile_data(layer_idx,cell)
				for data in custom_data_list :
					if !tiledata.get_custom_data(data) or array.has(cell) :
						return false
				return true
		))
	return array

# 歩行可能座標から"min","max","size"(Vector2i)情報を計算
static func create_walkable_cells_info(cells_list:Array) -> Dictionary :
	var x_arr := []
	var y_arr := []
	for cell in cells_list :
		x_arr.append(cell.x)
		y_arr.append(cell.y)
	var min := Vector2i(x_arr.min(),y_arr.min())
	var max := Vector2i(x_arr.max(),y_arr.max())
	return {"min":min,"max":max,"size":max-min}

# AStar2Dインスタンス取得
static func create_AStar2D(cells_list:Array,cells_info:Dictionary,diagonal:bool=false) -> AStar2D:
	var astar:AStar2D = AStar2D.new()
	
	#AStar設定
	for p in cells_list:
		# 位置をインデックスに変換しAStarに登録
		var index = _point_to_index(p,cells_info)
		astar.add_point(index,p)
	
	# AStarにノード同士の接続情報を登録する
	if diagonal :
		_astar_connect_walkable_cells_diagonal(astar,cells_list,cells_info)
	else :
		_astar_connect_walkable_cells(astar,cells_list,cells_info)

	return astar

# AStarによる経路探索を実行する
static func recalculate_path(start:Vector2, end:Vector2, astar:AStar2D, cells_list:Array, cells_info:Dictionary, cell_size:int) -> PackedVector2Array:
	var start_point = _get_walkable_position(start, cells_list, cells_info, cell_size)
	var end_point = _get_walkable_position(end, cells_list, cells_info, cell_size)

	if(start_point!=null && end_point!=null):
		var start_index = _point_to_index(start_point, cells_info)
		var end_index = _point_to_index(end_point, cells_info)
		# AStar2Dからパス情報取得
		var point_list = astar.get_point_path(start_index, end_index)
		# ワールド座標に変換する
		for i in range(point_list.size()):
			point_list[i].x = point_list[i].x*cell_size+cell_size/2
			point_list[i].y = point_list[i].y*cell_size+cell_size/2
		# パス情報返却
		return point_list
	else:
		# 計算不可であれば空のパス情報返却
		return PackedVector2Array()
