extends Item
class_name Scroll

const MAX_NAME_LENGTH = 10
const MIN_NAME_LENGTH = 4
const MAX_WORD_LENGTH = 12
const MIN_WORD_LENGTH = 3
const MAX_SENTENCE_LENGTH = 7
const MIN_SENTENCE_LENGTH = 4

func _init():
    label = "Scroll of "
    for i in range(Globals.rng.randi_range(MIN_NAME_LENGTH,MAX_NAME_LENGTH)):
        label += char(Globals.rng.randi_range(97, 122))
    description = "It reads: "
    for i in range(Globals.rng.randi_range(MIN_SENTENCE_LENGTH,MAX_SENTENCE_LENGTH)):
        var word = ""
        for j in range(Globals.rng.randi_range(MIN_WORD_LENGTH,MAX_WORD_LENGTH)):
            word += char(Globals.rng.randi_range(97, 122))
        word += " "
        description += word
    ascii = Constants.SCROLL
