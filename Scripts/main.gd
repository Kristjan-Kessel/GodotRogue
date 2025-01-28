extends Node2D

func _ready():
	Globals.initialize_randomness()
	print("Using seed: ", Globals.rng_seed)  
	var test_random_1 = Globals.rng.randi_range(1, 100)
	var test_random_2 = Globals.rng.randi_range(1, 100)
	print("Random number 1: ", test_random_1)
	print("Random number 2: ", test_random_2)
