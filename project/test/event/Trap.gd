class_name Trap extends Event

@export var damage:int = 2

func _ready():
	super._ready()

func _on_event_process(parent):
	# 処理停止
	parent.disable()
	parent.collision.set_deferred("disabled",true)
	parent.change_anim_idle()
	# ダメージ処理
	parent.damaged_calc(get_damage_data())
	# メッセージ表示
	await System.open_dialog(self,get_message_data(parent),0.4)
	# 処理再開
	if parent!=null:
		parent.collision.set_deferred("disabled",false)
		parent.enable()

func get_damage_data() -> AttackData:
	var data := AttackData.new()
	data.char_name = "トラップ"
	data.force = damage
	return data

func get_message_data(parent) -> DialogData:
	var data := DialogData.new()
	data.dialog = "トラップ！%sは%dのダメージを受けた。" % [parent.data.name,damage]
	return data
