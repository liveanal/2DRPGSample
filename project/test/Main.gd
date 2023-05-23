class_name Main extends MainBase

@onready var splash := $splash
@onready var title := $title

func _ready():
	super._ready()
	
	# フェードアウト→イン
	await System.fadeoutin(0.85, func():
		await get_tree().create_timer(2.0).timeout
		System.emit_signal("finished_fade_backprocess")
	,Color.BLACK)
	# 画面切りかえ
	splash.visible = false
	title.visible = true
	# フェードアウト
	await System.fadeout(0.85)
	System.fadeclear()
	# タイトル開始
	title.start()
