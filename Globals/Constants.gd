extends Node

# Map Variables
const map_width: int = 3*35
const map_height: int = 3*8

# Constant variables
const INVENTORY_CHARS = "abcfghijklmnoprstuvxyz" # Chars to select an item in the inventory. some chars overlap with commands so remove those.

# ASCII characters
const PLAYER = "[color=ba7322]@[/color]"
const FLOOR = "."
const CORRIDOR = "#"
const WALL = "|"
const CEILING = "-"
const DOOR = "+"
const ITEM = "*"
const GOLD = "[color=FFD700]$[/color]"
const EMPTY = " "
const STAIRS = "^"
const ARTIFACT = "[color=ffcc00]☼[/color]"
const EMU = "[color=#c9ab79]e[/color]"
const GOBLIN = "[color=#1f7d00]g[/color]"
const SNAKE = "[color=#41a61f]s[/color]"
const ORC = "[color=#196301]o[/color]"
const ICE_MONSTER = "[color=#00d1ca]i[/color]"
const CENTAUR = "[color=#632d01]c[/color]"
const DRAKE = "[color=#a11702]d[/color]"
const TROLL = "[color=#00ad5f]t[/color]"
const BANSHEE = "[color=#adffff]b[/color]"

# ASCII for reading data from a text file
const TXT_PLAYER = "@"
const TXT_FLOOR = "."
const TXT_CORRIDOR = "#"
const TXT_WALL = "|"
const TXT_CEILING = "-"
const TXT_DOOR = "+"
const TXT_GOLD = "$"
const TXT_EMPTY = " "
const TXT_STAIRS = "^"
const TXT_ARTIFACT = "☼"
