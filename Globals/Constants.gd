extends Node

# Constant variables
const INVENTORY_CHARS = "abcdeghijklmnopqrstuvxyz" # Some letters are used for commands so skip them. Check later to make sure no commands overlap with item assignment letters

# ASCII characters
const PLAYER = "@"
const FLOOR = "."
const CORRIDOR = "#"
const WALL = "|"
const CEILING = "-"
const DOOR = "+"
const ITEM = "*"
const MONSTER = "%"
const GOLD = "$"
const TRAP = "&"
const EMPTY = " "
