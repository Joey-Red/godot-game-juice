class_name EffectSound
extends JuiceEffect

@export_group("Audio Settings")
@export var stream: AudioStream
@export_range(-80, 24) var volume_db: float = 0.0
@export_range(0.1, 4.0) var pitch_scale: float = 1.0
@export var pitch_randomness: float = 0.0 

func execute(target: Node, context: Dictionary = {}) -> void:
	if stream == null:
		return
		
	# FIX: Use AudioStreamPlayer3D for 3D games
	var player = AudioStreamPlayer3D.new() 
	
	# Configure
	player.stream = stream
	player.volume_db = volume_db
	player.unit_size = 10.0 # Optional: Adjusts how far away sound can be heard
	player.max_db = 3.0     # Optional: Prevents it from being too loud close up
	
	# Apply Pitch Randomness
	if pitch_randomness > 0:
		player.pitch_scale = pitch_scale + randf_range(-pitch_randomness, pitch_randomness)
	else:
		player.pitch_scale = pitch_scale
		
	# 1. IMPORTANT: Add to the scene tree FIRST so it has a valid transform space
	target.get_tree().root.add_child(player)

	# 2. THEN set the position safely
	if "position" in context and context["position"] is Vector3:
		player.global_position = context["position"]
	elif target is Node3D:
		player.global_position = target.global_position
	
	player.play()
	
	# Clean up
	player.finished.connect(player.queue_free)
