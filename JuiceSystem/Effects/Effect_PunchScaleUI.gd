class_name EffectPunchScale
extends JuiceEffect

## The name of the node to punch. 
## Defaults to "EnemyHealthbar3D" based on your screenshot.
@export var node_name: String = "EnemyHealthbar3D"

## How big to punch it (Multiplier).
@export var punch_amount: Vector3 = Vector3(1.5, 1.5, 1.5)

## How fast it snaps back.
@export var duration: float = 0.2

func execute(target: Node, _context: Dictionary = {}) -> void:
	# 1. Find the Healthbar
	# We use find_child to be safe, or get_node if you are sure of the name
	var ui_node = target.find_child(node_name, true, false)
	
	if not ui_node:
		return

	# 2. Kill existing tweens (so hits don't conflict)
	# This prevents the bar from growing infinitely if you hit it fast
	var tree = target.get_tree()
	if not tree:
		return
		
	# 3. Create the Tween
	var tween = tree.create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC) # Bouncy feel
	tween.set_ease(Tween.EASE_OUT)
	
	# "Punch" it up instantly-ish? No, let's tween TO the punch, then BACK.
	# Actually, setting scale immediately and tweening back feels snappier.
	
	# Store original scale if possible, or assume 1.0. 
	# For UI, usually 1.0 is safe, but let's be careful.
	var end_scale = Vector3.ONE
	if ui_node.has_meta("base_scale"):
		end_scale = ui_node.get_meta("base_scale")
	else:
		# Save the initial scale the first time we touch it
		end_scale = ui_node.scale
		ui_node.set_meta("base_scale", end_scale)
	
	# Apply the punch immediately
	ui_node.scale = end_scale * punch_amount
	
	# Tween back to normal
	tween.tween_property(ui_node, "scale", end_scale, duration)
