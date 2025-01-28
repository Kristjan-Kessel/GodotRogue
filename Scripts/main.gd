extends Node2D

func _ready():
	Globals.initialize_randomness()
	print("Using seed: ", Globals.rng_seed)  
