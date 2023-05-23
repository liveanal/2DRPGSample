class_name ShopRow extends Control

@export var data:ShopItem

@export_group("Layout Settings")
@export var texture_size:Vector2
@export var label_default:LabelSettings
@export var label_select:LabelSettings
@export var cost_buy:LabelSettings
@export var cost_sell:LabelSettings
@export_subgroup("Format Pattern")
@export var count_default_pattern:="({count})"
@export var count_select_pattern:="({trade_count}/{count})"
@export_group("Node Setting")
@export var texture:TextureRect
@export var label:Label
@export var count:Label
@export var cost:Label

func _ready():
	update()

func update():
	texture.texture = data.item.texture
	texture.custom_minimum_size = texture_size
	
	label.text = data.item.name
	if 0<data.trade_count :
		label.label_settings = label_select
	else:
		label.label_settings = label_default
	
	if data.item.stackable:
		if 0<data.trade_count:
			count.text = count_select_pattern.format({"count":str(data.item.count), "trade_count":str(data.trade_count)})
			count.label_settings = label_select
		else:
			count.text = count_default_pattern.format({"count":str(data.item.count), "trade_count":str(data.trade_count)})
			count.label_settings = label_default
	else:
		count.text = ""
	
	cost.text = str(data.cost)
	if data.type==0:
		cost.label_settings = cost_buy
	else:
		cost.label_settings = cost_sell
