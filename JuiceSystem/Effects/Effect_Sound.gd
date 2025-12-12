class_name EffectSound
extends JuiceEffect

@export_group("Audio Settings")
@export var stream: AudioStream
@export_range(-80, 24) var volume_db: float = 0.0
@export_range(0.1, 4.0) var pitch_scale: float = 1.0
@export var pitch_randomness: float = 0.0 ## Randomizes pitch slightly (e.g. 0.1 means +/- 10%)

func execute(target: Node, context: Dictionary = {}) -> void:
	if stream == null:
		return
		
	# Create a temporary AudioPlayer
	# Note: In a large game, you would use an Object Pool here instead of new().
	# But for now, new() is fine and decoupled.
	var player = AudioStreamPlayer2D.new() # Or AudioStreamPlayer for non-positional
	
	# Configure
	player.stream = stream
	player.volume_db = volume_db
	
	# Apply Pitch Randomness
	if pitch_randomness > 0:
		player.pitch_scale = pitch_scale + randf_range(-pitch_randomness, pitch_randomness)
	else:
		player.pitch_scale = pitch_scale
		
	# Handle Position (2D or 3D)
	if "position" in context:
		player.global_position = context["position"]
	elif target is Node2D:
		player.global_position = target.global_position
		
	# Add to the scene tree so it can play
	# We add it to the root so it doesn't get deleted if the Enemy dies immediately
	target.get_tree().root.add_child(player)
	
	player.play()
	
	# Clean up after the sound is done
	player.finished.connect(player.queue_free)
