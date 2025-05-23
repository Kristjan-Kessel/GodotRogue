extends Node

# Variables for end screens
var player_name = ""
var cause_of_death = ""
var final_gold = 0

var rng_seed: int = -1
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
