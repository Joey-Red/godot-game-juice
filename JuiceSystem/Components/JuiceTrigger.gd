# res://_Systems/JuiceSystem/Components/JuiceTrigger.gd
class_name JuiceTrigger
extends Node

## The profile to play when the signal fires
@export var profile: JuiceProfile

## The node that emits the signal (e.g., HealthComponent).
## If empty, it defaults to the parent node.
@export var target_node: Node

## The exact name of the signal to listen for (e.g., "died" or "health_changed")
@export var signal_name: String = ""

func _ready() -> void:
	# 1. Find the target node (default to parent if not assigned)
	var target = target_node if target_node else get_parent()
	
	# 2. Safety check
	if not target:
		return
		
	# 3. Connect to the signal dynamically
	if target.has_signal(signal_name):
		# We bind the target to the callback so we can access it later if needed
		target.connect(signal_name, _on_signal_emitted.bind(target))
	else:
		push_warning("JuiceTrigger: Target " + target.name + " has no signal '" + signal_name + "'")

## The Callback
## We use *args to accept any number of arguments the signal might send 
## (e.g., health_changed might send (new_hp, old_hp), died might send nothing)
func _on_signal_emitted(_arg1 = null, _arg2 = null, _arg3 = null, _arg4 = null) -> void:
	# Note: Godot 4 connect binding passes bound args at the END.
	# However, for simplicity, we just trigger the profile here.
	
	# Create a basic context. 
	# If the signal passed arguments (like damage amount), you could parse them here.
	var context = {}
	
	trigger_juice(context)

func trigger_juice(context: Dictionary = {}) -> void:
	if profile:
		profile.play(get_parent(), context)
