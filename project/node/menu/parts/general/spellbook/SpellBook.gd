class_name SpellBook extends MenuContent

@export var member_index:int=0:
	set(val):
		member_index = posmod(val, self.party_member.size()) if not self.party_member.is_empty() else 0
	get:
		return member_index
@export var no_item_text:String = "魔法を覚えていない。"
@export var list:SpellCSel
@export var desc:RichTextLabel

func _ready():
	# 反映するスキルリスト
	var spells:Array[SpellData] = party_member[member_index].data.spellbook
	# 入力処理登録
	list.connect("pressed_accept",func(_i):
		if !spells.is_empty():
			if party_member[member_index].data.mp>=spells[_i].cost:
				spells[_i].cast(System.current_character,[System.current_character])
			else:
				_cannot_cast())
	list.connect("pressed_cancel",func():
		close())
	list.connect("changed_index",func(_bi:int,_ai:int):
		if !spells.is_empty():
			var next:SpellData = party_member[member_index].data.spellbook[_ai]
			desc.text = next.description.format(_get_desc_replacement(next)))
	# リスト初期化
	if !spells.is_empty():
		list.set_items(spells)
	
	close()

func open():
	var spells = party_member[member_index].data.spellbook
	super.open()
	if !spells.is_empty():
		list.enable()
	else:
		desc.text = no_item_text
		list.is_input = true

func close():
	list.disable()
	super.close()

func append(spell):
	list.add_item(list.mapping_item(spell))

func _get_desc_replacement(spell_data)->Dictionary:
	var args := {}
	
	if spell_data.damage!=null:
		args["dmg"] = spell_data.damage.force
	
	return args

func _cannot_cast():
	print("MPが足りない")
