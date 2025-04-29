extends Item
class_name Armor

var armor_class: int

func _init(_label: String, _description: String, _armor_class: int):
    label = _label
    description = _description
    armor_class = _armor_class
    type = Type.ARMOR
    ascii = Constants.ARMOR
