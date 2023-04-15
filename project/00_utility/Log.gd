class_name Logging

# エラー呼び出し
static func assert_error(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[ERROR]"+Callable(Logging,msgcode).callv(args))
		callback.call()

# 警告出力
static func assert_warn(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[WARN]"+Callable(Logging,msgcode).callv(args))
		print_stack()
		callback.call()

# デバッグ出力
static func assert_debug(msgcode:String, args:Array, test:bool=true, callback:Callable=func():pass):
	if test : 
		printerr("[DEBUG]"+Callable(Logging,msgcode).callv(args))
		print_stack()
		callback.call()

# ログ出力
static func assert_info(msgcode:String, args:Array, test:bool=true):
	if test : 
		printerr("[INFO]"+Callable(Logging,msgcode).callv(args))

# Characterに関するメッセージ文
static func E_001(name): return "%s：CharDataがNullの状態です。インスペクターからCharDataを設定してください。" % [name]
static func E_002(name): return "%s：WorldDataがNullの状態です。インスペクターからWorldを設定してください。" % [name]
static func E_003(name): return "%s：AStarの歩行設定が設定されていません。WalkableCustomDataを設定してください。" % [name]
# DialogSystemに関するメッセージ文
static func E_101(name): return "%s：DialogDataがNullの状態です。インスペクターからDialogDataを設定してください。" % [name]
# Eventに関するメッセージ文
static func E_201(name): return "%s：テレポート先のパスがNullの状態です。インスペクターからMapResPathを設定してください。" % [name]
# CameraManagerに関するメッセージ文
static func E_C01(name): return "%s：CameraManagerのminとmaxが設定されていません。子を開きminとmaxのpositionを設定してください。" % [name]
