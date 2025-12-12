class_name JuiceProfile
extends Resource

## A container that holds a list of effects to play together.
## Example: A "ShotgunFire" profile might have a Sound, a Flash, and a ScreenShake.

@export var effects: Array[JuiceEffect] = []

func play(target: Node, context: Dictionary = {}) -> void:
	# If no position is provided in context, try to use target's position
	if not "position" in context and target is Node2D:
		context["position"] = target.global_position
	elif not "position" in context and target is Node3D:
		context["position"] = target.global_position

	for effect in effects:
		if effect:
			# execute the effect
			effect.execute(target, context)
