class_name EffectSound
extends JuiceEffect

@export_group("Audio Settings")
@export var stream: AudioStream
@export_range(-80, 24) var volume_db: float = 0.0
@export_range(0.1, 4.0) var pitch_scale: float = 1.0
@export var pitch_randomness: float = 0.0
## The maximum distance (in meters) at which this sound is audible.
@export var max_distance: float = 25.0 

func execute(target: Node, context: Dictionary = {}) -> void:
	if stream == null:
		return
	
	# 1. Prepare the Audio Context
	# We take the incoming context (which might have hit position)
	# and we add our specific sound settings to it.
	var audio_context = context.duplicate()
	
	audio_context["volume_db"] = volume_db
	audio_context["pitch_scale"] = pitch_scale
	audio_context["pitch_randomness"] = pitch_randomness
	audio_context["max_distance"] = max_distance
	
	# 2. Determine Position Fallback
	# If the bullet didn't tell us where it hit, we assume the sound comes 
	# from the target's center (e.g., the enemy's feet/origin).
	if not "position" in audio_context:
		if target is Node3D:
			audio_context["position"] = target.global_position
		# If target is Node2D, we skip adding "position", which tells 
		# SoundManager to play it as a 2D sound (perfect for UI/2D games).

	# 3. Delegate execution to the Manager
	# This keeps this script lightweight and decoupled.
	SoundManager.play_sfx(stream, audio_context)
#Why this is Future-Proof for Steam P2P
#
#When you add multiplayer later, you won't touch SoundManager. You will touch the Trigger.
#
#Example Future Scenario:
#
	#Player A shoots.
#
	#Player A sends a Steam P2P packet: PacketType.SHOOT, Position(10, 0, 10), WeaponID.SHOTGUN.
#
	#Player B receives packet.
#
	#Player B's network code finds the shotgun resource.
#
	#Player B's network code calls SoundManager.play_sfx(shotgun_sound, {"position": received_pos}).
#
#The SoundManager stays purely local, which is exactly how robust networking architectures work.
#
#Action Item: Implement the SoundManager script, set it as an Autoload, and setup your Audio Buses. Once done, test your Donyatsu hit one more time. It should sound exactly the same, but now it's running on a professional, scalable architecture.
