extends Node

# Global variables
var map_width: int = 3*32
var map_height: int = 3*7
var rng_seed: int = -1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var level_rng: RandomNumberGenerator = RandomNumberGenerator.new()

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
