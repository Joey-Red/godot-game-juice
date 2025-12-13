class_name EffectSpawnScene
extends JuiceEffect

@export var prefab: PackedScene
@export var parent_to_target: bool = false
@export_range(0.0, 5.0) var random_offset_radius: float = 0.0

## NEW: Randomizes the Y rotation (spins the effect around)
@export var random_rotation_y: bool = true 

# for some reason Emitting keeps turning itself off,
# so I am going to force it on at the beginning
#set_emitting(value)


func execute(target: Node, context: Dictionary = {}) -> void:
	if not prefab:
		return
		
	var instance = prefab.instantiate()
	
	if instance is GPUParticles3D or instance is CPUParticles3D:
		instance.emitting = true
	
	var parent = target.get_tree().root
	if parent_to_target:
		parent = target
		
	parent.add_child(instance)
	
	# 1. Basic Positioning (Your existing logic)
	if "position" in context and context["position"] is Vector3:
		instance.global_position = context["position"]
	elif target is Node3D:
		instance.global_position = target.global_position

	# 2. Apply Random Offset (Your existing logic)
	if random_offset_radius > 0:
		var offset = Vector3(randf(), randf(), randf()).normalized() * randf_range(0, random_offset_radius)
		instance.global_position += offset

	# --- NEW: Random Rotation ---
	if random_rotation_y:
		# Rotate randomly around the Up axis (0 to 360 degrees)
		instance.rotate_y(randf_range(0, TAU))
