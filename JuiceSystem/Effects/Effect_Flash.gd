class_name EffectFlash
extends JuiceEffect

@export var flash_material: Material
@export var duration: float = 0.1
## OPTIONAL: If set, we only search inside this node name. 
## If empty, we search the ENTIRE enemy hierarchy.
@export var visuals_path: String = "" 

func execute(target: Node, _context: Dictionary = {}) -> void:
	if not flash_material:
		push_warning("EffectFlash: No flash material assigned!")
		return

	# 1. Determine where to start searching
	var start_node = target
	if visuals_path != "":
		var specific_node = target.get_node_or_null(visuals_path)
		if specific_node:
			start_node = specific_node
	
	# 2. Find ALL meshes anywhere inside
	var meshes = _find_all_meshes_recursive(start_node)
	
	# --- DEBUGGING DONYATSU ---
	#print("DEBUG FLASH: Target is '", start_node.name, "'. Found ", meshes.size(), " meshes.") 
	#for m in meshes:
		#print(" - Found Mesh: ", m.name, " | Path: ", m.get_path())
	# --------------------------

	if meshes.is_empty():
		return

	# 3. Apply the override
	for mesh in meshes:
		mesh.material_override = flash_material
	
	# 4. Wait and Remove
	var tree = target.get_tree()
	if tree:
		await tree.create_timer(duration).timeout
		
		if is_instance_valid(target):
			for mesh in meshes:
				if is_instance_valid(mesh):
					mesh.material_override = null

func _find_all_meshes_recursive(node: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	
	# Check if the node itself is a MeshInstance3D
	if node is MeshInstance3D:
		results.append(node)
		
	# Recurse through children
	for child in node.get_children():
		results.append_array(_find_all_meshes_recursive(child))
		
	return results
