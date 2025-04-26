extends Node

# Global variables
const map_width: int = 3*35
const map_height: int = 3*8
var rng_seed: int = 529088871
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
