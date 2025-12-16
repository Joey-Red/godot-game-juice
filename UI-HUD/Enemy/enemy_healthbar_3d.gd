#extends Sprite3D
#
#@onready var sub_viewport = $SubViewport
#@onready var progress_bar = $SubViewport/ProgressBar
#
#func _ready():
	#texture = sub_viewport.get_texture()
#
#func update_bar(current_hp, max_hp):
	#progress_bar.max_value = max_hp
	#progress_bar.value = current_hp
	#
	## Optional: Hide if full health or dead
	#visible = current_hp < max_hp and current_hp > 0
extends Sprite3D

@onready var sub_viewport = $SubViewport
@onready var health_bar = $SubViewport/HealthBar # The Red Bar (Foreground)
@onready var ghost_bar = $SubViewport/GhostBar   # The White Bar (Background)

## How long to wait before the ghost starts draining
@export var ghost_delay: float = 0.1 
## How fast the ghost catches up
@export var ghost_speed: float = 200.0 

var _ghost_timer: float = 0.0

func _ready():
	# Force the texture update
	texture = sub_viewport.get_texture()

func update_bar(current_hp, max_hp):
	# 1. Update the Instant Bar (Red)
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	# 2. Update the Ghost Bar Max (in case max HP changed)
	ghost_bar.max_value = max_hp
	
	# 3. Reset the timer so it pauses briefly before draining
	_ghost_timer = ghost_delay

	# Optional: Toggle visibility
	visible = current_hp < max_hp and current_hp > 0

func _process(delta):
	# Logic: If Ghost > Health, drain Ghost
	if ghost_bar.value > health_bar.value:
		_ghost_timer -= delta
		
		if _ghost_timer <= 0:
			# Drain the ghost towards the real health
			# We use move_toward for a linear consistent speed
			ghost_bar.value = move_toward(ghost_bar.value, health_bar.value, ghost_speed * delta)
			
	# Logic: If Ghost < Health (e.g. Healed), snap instantly
	elif ghost_bar.value < health_bar.value:
		ghost_bar.value = health_bar.value
