# res://_Systems/JuiceSystem/JuiceManager.gd
extends Node

# Autoload name: JuiceManager

func play_profile(profile: JuiceProfile, target: Node, context: Dictionary = {}) -> void:
	if profile:
		profile.play(target, context)

func play_profile_by_path(path: String, target: Node, context: Dictionary = {}) -> void:
	var profile = load(path) as JuiceProfile
	if profile:
		profile.play(target, context)
