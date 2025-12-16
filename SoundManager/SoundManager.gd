# SoundManager.gd
extends Node

# --- Configuration ---
const POOL_SIZE_2D = 12
const POOL_SIZE_3D = 32
const MAX_SAME_SOUND_CONCURRENCY = 5 # Don't play the exact same clip more than 5 times at once

# --- State ---
var _pool_2d: Array[AudioStreamPlayer] = []
var _pool_3d: Array[AudioStreamPlayer3D] = []
var _active_sounds: Dictionary = {} # Maps Stream -> Count (for concurrency limiting)

# --- Music State ---
var _music_player_1: AudioStreamPlayer
var _music_player_2: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer = null

func _ready() -> void:
	# 1. Initialize Pools
	_init_pool_2d()
	_init_pool_3d()
	
	# 2. Initialize Music System (Dual players for crossfading)
	_music_player_1 = AudioStreamPlayer.new()
	_music_player_1.bus = "Music"
	add_child(_music_player_1)
	
	_music_player_2 = AudioStreamPlayer.new()
	_music_player_2.bus = "Music"
	add_child(_music_player_2)

# ==============================================================================
# 1. SFX SYSTEM (The "Fire and Forget" API)
# ==============================================================================

## The main entry point. Call this from your Juice System.
## Context keys: "position" (Vector3), "volume_db", "pitch_scale", "pitch_randomness", "max_distance"
func play_sfx(stream: AudioStream, context: Dictionary = {}) -> void:
	if not stream:
		return
		
	# A. Concurrency Check (Prevent spam)
	var stream_id = stream.get_instance_id()
	var current_count = _active_sounds.get(stream_id, 0)
	if current_count >= MAX_SAME_SOUND_CONCURRENCY:
		return # Skip this sound, too many playing already
		
	# B. Increment Count
	_active_sounds[stream_id] = current_count + 1
	
	# C. Decide 2D vs 3D
	if "position" in context and context["position"] is Vector3:
		_play_3d(stream, context, stream_id)
	else:
		_play_2d(stream, context, stream_id)

func _play_3d(stream: AudioStream, context: Dictionary, id: int) -> void:
	if _pool_3d.is_empty():
		# In a real production game, we might steal the oldest sound here.
		# For now, we just skip.
		_active_sounds[id] -= 1
		return

	var player = _pool_3d.pop_back()
	
	# Setup
	player.stream = stream
	player.global_position = context["position"]
	player.max_distance = context.get("max_distance", 25.0) # Default 25 meters
	player.unit_size = context.get("unit_size", 10.0)
	
	_apply_common_settings(player, context)
	player.play()
	
	# Cleanup callback
	if not player.finished.is_connected(_on_sfx_finished):
		player.finished.connect(_on_sfx_finished.bind(player, id, true))

func _play_2d(stream: AudioStream, context: Dictionary, id: int) -> void:
	if _pool_2d.is_empty():
		_active_sounds[id] -= 1
		return

	var player = _pool_2d.pop_back()
	
	player.stream = stream
	_apply_common_settings(player, context)
	player.play()
	
	if not player.finished.is_connected(_on_sfx_finished):
		player.finished.connect(_on_sfx_finished.bind(player, id, false))

func _apply_common_settings(player: Node, context: Dictionary):
	var base_pitch = context.get("pitch_scale", 1.0)
	var randomness = context.get("pitch_randomness", 0.0)
	
	if randomness > 0:
		player.pitch_scale = base_pitch + randf_range(-randomness, randomness)
	else:
		player.pitch_scale = base_pitch
		
	player.volume_db = context.get("volume_db", 0.0)

# ==============================================================================
# 2. MUSIC SYSTEM (Crossfading)
# ==============================================================================

func play_music(stream: AudioStream, fade_duration: float = 2.0):
	# Don't restart if already playing
	if _active_music_player and _active_music_player.stream == stream and _active_music_player.playing:
		return
		
	var new_player = _music_player_1 if _active_music_player != _music_player_1 else _music_player_2
	var old_player = _active_music_player
	
	# Setup New
	new_player.stream = stream
	new_player.volume_db = -80 # Start silent
	new_player.play()
	
	var tween = create_tween()
	
	# Fade In New
	tween.parallel().tween_property(new_player, "volume_db", 0.0, fade_duration)
	
	# Fade Out Old
	if old_player and old_player.playing:
		tween.parallel().tween_property(old_player, "volume_db", -80.0, fade_duration)
		tween.chain().tween_callback(old_player.stop)
		
	_active_music_player = new_player

# ==============================================================================
# 3. INTERNALS & POOLING
# ==============================================================================

func _init_pool_2d():
	for i in POOL_SIZE_2D:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool_2d.append(p)

func _init_pool_3d():
	for i in POOL_SIZE_3D:
		var p = AudioStreamPlayer3D.new()
		p.bus = "SFX"
		# Optional: Set attenuation model to something realistic
		p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		add_child(p)
		_pool_3d.append(p)

func _on_sfx_finished(player: Node, stream_id: int, is_3d: bool):
	# Decrement concurrency counter
	if stream_id in _active_sounds:
		_active_sounds[stream_id] = max(0, _active_sounds[stream_id] - 1)
	
	# Return to pool
	# IMPORTANT: We disconnect signals to prevent duplicate calls if reused quickly
	player.finished.disconnect(_on_sfx_finished)
	
	if is_3d:
		_pool_3d.append(player)
	else:
		_pool_2d.append(player)

# ==============================================================================
# 4. VOLUME CONTROL (Call from Options Menu)
# ==============================================================================

func set_bus_volume(bus_name: String, linear_value: float):
	# linear_value should be 0.0 to 1.0
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1: return
	
	var db = linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(bus_index, db)
