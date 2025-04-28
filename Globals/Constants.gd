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
