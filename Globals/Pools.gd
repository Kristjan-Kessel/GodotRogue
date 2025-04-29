extends Node

# Item loot pools
static var low_tier_loot = [
    Weapon.new("Shortsword", "a short sword with a damage dice of 8", 1, 8),
    Weapon.new("Dagger +2", "Grants +2 to attacks with a damage dice of 6", 2, 6),  
    Armor.new("Chainmail","Has an armor class of 6",6),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    StrengthPotion.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Scroll.new(),
    Scroll.new()
    ]
static var mid_tier_loot = [
    Weapon.new("Longsword +1", "Grants +1 to attacks with a damage dice of 10", 1, 10), 
    Armor.new("Plate armor","Has an armor class of 8",8),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    StrengthPotion.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Scroll.new(),
    Scroll.new()
    ]
static var high_tier_loot = [
    Weapon.new("Greatsword +2", "Grants +2 to attacks with a damage dice of 12", 2, 12), 
    Armor.new("Heavyplate armor","Has an armor class of 10",10),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Scroll.new(),
    Scroll.new()
    ]
static var fallback_pool = [
    Potion.new(),
    Gold.new(),
    Gold.new()
    ]

const min_loot = 5
const max_loot = 12

# Enemy spawning pools
static var low_tier_enemies = ["goblin","snake","emu"]
static var mid_tier_enemies = ["orc","centaur","icemonster"]
static var high_tier_enemies = ["drake","troll","banshee"]

# chance for enemies to be sleeping when spawned, 1/sleep_chance
const sleep_chance = 10
const min_enemies = 5
const max_enemies = 9
