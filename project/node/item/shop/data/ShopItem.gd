class_name ShopItem extends Resource

@export var item:ItemData
@export_group("SaleSetting")
@export_enum("BUY","SELL") var type
@export var cost:int
var trade_count:int=0:
	set(val):
		trade_count = posmod(val,item.count+1)
	get:
		return trade_count
