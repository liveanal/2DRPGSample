class_name LogConst

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
# Systemに関するメッセージ文
static func E_S01(path:String,error:Error): return "シーンが読み込めませんでした：%s\n%s" % [path, error]
static func E_S02(path:String): return "シーン読込中にエラーが発生しました：%s" % [path]
# ItemData使用時のデフォルトメッセージ
static func W_I01(name): return "使用アイテムのuse動作が未設定です。：%s" % [name]
