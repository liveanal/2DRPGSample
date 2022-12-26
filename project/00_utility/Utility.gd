class_name Utility

# レイヤー情報
const _layers:Dictionary = {}

# 初期化
func _init():
	# レイヤー情報を{レイヤー名：bit値}で管理
	for i in range(0, 32, 1):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i + 1))
		_layers[layer] = pow(2, i)

# レイヤー名からbit値を取得
static func get_layerbit(name:String):
	return _layers[name]

# Dictionaryの複製
static func clone_dict(source) -> Dictionary:
	var target = {}
	for key in source:
		target[key] = source[key]
	return target

# dataから値取得（pathは各階層のkeyを"/"で連結　例："player/position/x"）
static func get_data(data:Dictionary, path:String, default=null):
	# 取得
	for key in path.split("/") :
		data = data.get(key)
		if data == null:
			return default

	return data

# dataに該当するキーが存在するか確認（pathは各階層のkeyを"/"で連結　例："player/position/x"）
static func has_data(data:Dictionary,path:String) -> bool:
	return get_data(data,path) != null

# dataにvalを設定（pathは各階層のkeyを"/"で連結　例："player/position/x"）
static func set_data(data:Dictionary,path:String,val):
	var keys = path.split("/")
	for i in keys.size() :
		# keyが最後の要素の場合
		if i == keys.size()-1 :
			data[keys[i]] = val
		# keyが途中の要素の場合
		else :
			# 途中要素のkeyが存在しない場合
			if data.get(keys[i]) == null:
				data[keys[i]] = {}
			# dictを取得
			data = data[keys[i]]

# dataの値を削除（pathは各階層のkeyを"/"で連結　例："player/position/x"）
static func del_data(data:Dictionary,path:String):
	var keys = path.split("/")
	for i in keys.size() :
		# keyが最後の要素の場合
		if i == keys.size()-1 :
			data.erase(keys[i])
		# keyが途中の要素の場合
		else :
			# 途中要素のkeyが存在しない場合
			if data.get(keys[i]) == null:
				return
			# dictを取得
			data = data[keys[i]]

# ファイル書き出し
static func save_file(path:String, content:Dictionary):
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.new().stringify(content))

# ファイル読み込み
static func load_file(path:String):
	var json = JSON.new()
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		json.parse(file.get_as_text())
		return json.get_data()

# 指定ノードの全階層分の子ノードを取得
static func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

# process及びinputメソッドの処理制御
static func change_container(obj,process:bool,input:bool):
	# process及びphysics_processの処理制御
	obj.set_process(process)
	obj.set_physics_process(process)
	# input関係の処理制御
	obj.set_process_input(input)
	obj.set_process_shortcut_input(input)
	obj.set_process_unhandled_input(input)
	obj.set_process_unhandled_key_input(input)

# enumからランダム取得
static func get_random_enumkey(enums):
	return enums.keys()[randi() % enums.size()]

# リソース生成
static func create_resource(script_path) -> Resource:
	var data = Resource.new()
	data.script = load(script_path)
	return data

# リソース読み込み（存在しない場合は作成）
static func load_resource(path:String, script:String) -> Resource:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path)
	else:
		return create_resource(script)

# リソースセーブ
static func save_resource(res, path:String):
	ResourceSaver.save(res, path)

# お金形式でカンマ区切り
static func comma_sep(n:int) -> String:
	var result := ""
	var i: int = abs(n)
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	return "%s%s%s" % ["-" if n < 0 else "", i, result]

# 画像の一部をTextureとして取得
static func get_atlas_texture(texture:Texture2D, hframes:int, vframes:int, frame:int):
	var texture_size := texture.get_size()
	var chip_width_size   := texture_size.x / hframes
	var chip_height_size  := texture_size.y / vframes
	var region_x = chip_width_size * (frame % hframes)
	var region_y = chip_height_size * (frame / hframes)
	
	var img_tex = ImageTexture.new();
	return img_tex.create_from_image(texture.get_image().get_rect(Rect2(region_x, region_y, chip_width_size, chip_height_size)))

# ラジオボタンから選択済みの番号を取得
static func get_radios_idx_checked(radios:Array) -> int:
	var result := -1
	for i in radios.size():
		if radios[i].button_pressed:
			result = i
			break
	return result

# ラベル生成
static func create_label(text,horizontal_alignment:=0,vertical_alignment:=1,size_horizontal:=0,expand_horizontal:=true,size_vertical:=0,expand_vertical:=false,label_settings=null)->Label:
	var label := Label.new()
	label.text = text
	label.label_settings=label_settings
	label.horizontal_alignment=horizontal_alignment
	label.vertical_alignment=vertical_alignment
	match(size_horizontal):
		0: label.size_flags_horizontal=Control.SIZE_FILL if !expand_horizontal else Control.SIZE_EXPAND_FILL
		1: label.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
		2: label.size_flags_horizontal=Control.SIZE_SHRINK_CENTER if !expand_horizontal else Control.SIZE_SHRINK_CENTER+Control.SIZE_EXPAND
		3: label.size_flags_horizontal=Control.SIZE_SHRINK_END if !expand_horizontal else Control.SIZE_SHRINK_END+Control.SIZE_EXPAND
	match(size_vertical):
		0: label.size_flags_vertical=Control.SIZE_FILL if !expand_vertical else Control.SIZE_EXPAND_FILL
		1: label.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
		2: label.size_flags_vertical=Control.SIZE_SHRINK_CENTER if !expand_vertical else Control.SIZE_SHRINK_CENTER+Control.SIZE_EXPAND
		3: label.size_flags_vertical=Control.SIZE_SHRINK_END if !expand_vertical else Control.SIZE_SHRINK_END+Control.SIZE_EXPAND
	return label

# nullまたは空か確認
static func is_empty(value):
	if value == null :
		return true
	elif typeof(value) == TYPE_STRING:
		return value.is_empty()
	elif typeof(value) == TYPE_STRING_NAME:
		return value == null or value == ""
	elif value.has_method("is_empty"):
		return value.is_empty()
	
	return false
