class_name JuiceEffect
extends Resource

## The base class for all juice effects (Sound, Shake, Particles, etc.)

## We use this function to execute the effect.
## target: The node that caused the effect or is the center of it (e.g., the Enemy).
## context: A flexible dictionary for extra data (position, normal, damage_amount).
func execute(_target: Node, _context: Dictionary = {}) -> void:
	# This is a placeholder. Children will override this.
	pass
