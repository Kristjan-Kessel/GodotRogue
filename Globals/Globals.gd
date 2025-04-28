extends Node

# Global variables
const map_width: int = 3*35
const map_height: int = 3*8
var rng_seed: int = -1 #529088871
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var level_rng: RandomNumberGenerator = RandomNumberGenerator.new()

var early_loot_pool = []

# Set the randomness seed for reproducibility
func initialize_randomness():
    if rng_seed == -1:
        rng_seed = randi()
    rng.seed = rng_seed
    level_rng.seed = rng_seed

# Function to set a specific seed
func set_seed(new_seed: int):
    rng_seed = new_seed
    initialize_randomness()


# Item loot pools
static var low_tier_loot = [
    Weapon.new("Shortsword", "a short sword with a damage dice of 8", 1, 8),
    Weapon.new("Dagger +2", "Grants +2 to attacks with a damage dice of 6", 2, 6),  
    Armor.new("Chainmail","Has an armor class of 6",6),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    StrengthPotion.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new()
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
    Gold.new()
    ]
static var high_tier_loot = [
    Weapon.new("Greatsword +2", "Grants +2 to attacks with a damage dice of 12", 2, 12), 
    Armor.new("Heavyplate armor","Has an armor class of 10",10),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    Potion.new(),
    StrengthPotion.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new(),
    Gold.new()
    ]
static var fallback_pool = [
    Potion.new(),
    Gold.new(),
    Gold.new()
    ]

const min_loot = 5
const max_loot = 8

# Enemy spawning pools
static var low_tier_enemies = ["goblin"]
static var mid_tier_enemies = ["goblin"]
static var high_tier_enemies = ["goblin"]

const min_enemies = 3
const max_enemies = 7
