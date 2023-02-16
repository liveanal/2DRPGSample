class_name AStarUtil2

# ワールド座標をグリッド座標系に変換する
static func world_to_grid(pos:Vector2,cell_size:Vector2i) -> Vector2i:
	var x = (pos.x)/float(cell_size.x) + (-1 if pos.x<0 else 0)
	var y = (pos.y)/float(cell_size.y) + (-1 if pos.y<0 else 0)
	return Vector2i(int(x),int(y))

# ワールド座標をインデックスに変換する
static func world_to_index(pos:Vector2,world_info:Dictionary,cell_size:Vector2i) -> int:
	return grid_to_index(world_to_grid(pos,cell_size),world_info)

# グリッド座標をインデックスに変換する
static func grid_to_index(grid:Vector2i,world_info:Dictionary) -> int:
	var px = grid.x + abs(world_info["min"].x)
	var py = grid.y + abs(world_info["min"].y)
	return int(px + (py * world_info["size"].x))

# グリッド座標をワールド座標に変換する
static func grid_to_world(grid:Vector2i,world_info:Dictionary,cell_size:Vector2i) -> Vector2:
	return index_to_world(grid_to_index(grid,world_info),world_info,cell_size)

# インデックスをワールド座標に変換する
static func index_to_world(index:int,world_info:Dictionary,cell_size:Vector2i) -> Vector2:
	var i = index % int(world_info["size"].x)
	var j = int(float(index)/world_info["size"].x)
	var x = i*cell_size-abs(world_info["min"].x)*cell_size+cell_size/2.0
	var y = j*cell_size-abs(world_info["min"].y)*cell_size+cell_size/2.0
	return Vector2(x,y)

# インデックスをグリッド座標に変換する
static func index_to_grid(index:int,world_info:Dictionary,cell_size:Vector2i) -> Vector2:
	return world_to_grid(index_to_world(index,world_info,cell_size),cell_size)

# TileMapからcustom_data_listに指定の値がtrueのタイル情報を取得
static func create_world_info(world:TileMap,custom_data_list:Array=[]) -> Dictionary:
	var _array := {}
	var _min = null
	var _max = null
	
	# レイヤー分ループ
	for layer_idx in world.get_layers_count():
		# グリッド分ループ
		for grid in world.get_used_cells(layer_idx):
			# 指定カスタムデータ分ループ
			for data in custom_data_list:
				# グリッドのカスタムデータを取得
				var tiledata := world.get_cell_tile_data(layer_idx,grid)
				# 指定カスタムデータを持つグリッドで重複していなければ登録
				if tiledata.get_custom_data(data) and !_array.has(grid):
					_array[grid] = {
						"world": Rect2(grid*world.tile_set.tile_size, (grid+Vector2i.ONE)*world.tile_set.tile_size)
					}
					# 最小・最大を保持
					if _min == null : _min = Vector2i(grid)
					if _max == null : _max = Vector2i(grid)
					if grid.x < _min.x : _min.x = grid.x
					if grid.y < _min.y : _min.y = grid.y
					if grid.x > _max.x : _max.x = grid.x
					if grid.y > _max.y : _max.y = grid.y
					break
	# size計算
	var _size = (_max-_min)+Vector2i.ONE
	# グリッド分ループ
	for grid in _array.keys():
		# index計算
		var px = grid.x + abs(_min.x)
		var py = grid.y + abs(_min.y)
		var idx = int(px+(py*_size.x))
		_array[grid]["index"] = idx
	
	return {
		"min":_min,
		"max":_max,
		"size":_size,
		"cell_list":_array}

# ワールド座標のセルが歩行可能であればグリッド座標を返却
static func get_walkable_position(pos:Vector2,world_info:Dictionary,cell_size:Vector2i):
	# グリッド座標系に変換する
	var cell := world_to_grid(pos,cell_size)
	# 歩行可能座標であれば返却
	if world_info["cell_list"].keys().has(cell) and !is_outside_map_bounds(cell,world_info):
		return cell
	else:
		return

# グリッド座標がマップの領域外か判定
static func is_outside_map_bounds(grid:Vector2i,world_info:Dictionary) -> bool:
	if grid < world_info["min"] or world_info["max"] <= grid:
		return true # 領域外
	# 有効なマップの範囲内
	return false

# AStarにノード同士の接続情報を登録する
static func astar_connect_walkable_cells(astar:AStar2D,world_info:Dictionary) -> void:
	for grid in world_info["cell_list"].keys():
		# 上下左右に接続する
		var grid_ralative := [
			Vector2i(grid.x + 1, grid.y), # 右
			Vector2i(grid.x - 1, grid.y), # 左
			Vector2i(grid.x, grid.y + 1), # 下
			Vector2i(grid.x, grid.y - 1)] # 上
		# 上下左右を調べる
		for relative in grid_ralative:
			if is_outside_map_bounds(relative,world_info):
				continue # 領域外なので接続できない
			if !world_info["cell_list"].keys().has(relative):
				continue # 移動不可なので登録出来ない
			# インデックス同士を接続する
			# 第3引数がfalseなので、index -> relative_index への一方通行を許可
			astar.connect_points(world_info["cell_list"][grid]["index"], world_info["cell_list"][relative]["index"], false)

# AStarにノード同士の接続情報を登録する (斜め移動を許可する)
static func astar_connect_walkable_cells_diagonal(astar:AStar2D,world_info:Dictionary) -> void:
	for grid in world_info["cell_list"].keys():
		# 3x3の9方向探索
		for local_y in range(3):
			for local_x in range(3):
				var relative = Vector2i(grid.x + local_x - 1, grid.y + local_y - 1)
				if grid == relative:
					continue # 自分同士なので接続出来ない
				if is_outside_map_bounds(relative,world_info):
					continue # 領域外なので接続できない
				if !world_info["cell_list"].keys().has(relative):
					continue # 移動不可なので登録出来ない
				# インデックス同士を接続する
				astar.connect_points(world_info["cell_list"][grid]["index"], world_info["cell_list"][relative]["index"], true)

# AStar2Dインスタンス取得
static func create_AStar2D(world_info:Dictionary,diagonal:bool=false) -> AStar2D:
	var astar:AStar2D = AStar2D.new()
	#AStar設定
	for grid in world_info["cell_list"].keys():
		# print("%s : %s" % [str(grid), str(world_info["cell_list"][grid]["index"])])
		astar.add_point(world_info["cell_list"][grid]["index"], grid)
	# AStarにノード同士の接続情報を登録する
	if diagonal :
		astar_connect_walkable_cells_diagonal(astar,world_info)
	else :
		astar_connect_walkable_cells(astar,world_info)
	return astar

# AStarによる経路探索を実行する
static func recalculate_path(start:Vector2, end:Vector2, astar:AStar2D, world_info:Dictionary, cell_size:Vector2i) -> PackedVector2Array:
	var start_grid = get_walkable_position(start, world_info, cell_size)
	var end_grid = get_walkable_position(end, world_info, cell_size)

	if(start_grid!=null && end_grid!=null):
		var start_index = world_info["cell_list"][start_grid]["index"]
		var end_index   = world_info["cell_list"][end_grid]["index"]
		# AStar2Dからパス情報取得
		var point_list = astar.get_point_path(start_index, end_index)
		# ワールド座標に変換する
		for i in range(point_list.size()):
			point_list[i].x = point_list[i].x*cell_size.x+cell_size.x/2.0
			point_list[i].y = point_list[i].y*cell_size.y+cell_size.y/2.0
		# パス情報返却
		return point_list
	else:
		# 計算不可であれば空のパス情報返却
		return PackedVector2Array()

