
class_name RigidForce

var targetA : Node
var targetB : Node
var force : int = 1

@export var friend_dist_factor = 1000
@export var foe_dist_factor = 100
const MAX_FORCE = 100

func _init(t1=null, t2=null, new_force = 1):
	# Target A
	if t1 is Vector2 :
		var n = Node2D.new()
		n.position = t1
		targetA = n
	else:
		targetA = t1
	
	# Target B
	if t2 is Vector2 :
		var n = Node2D.new()
		n.position = t2
		targetB = n
	else:
		targetB = t2
	
	# Force
	force = new_force
	targetA.forces.append(self)
	targetB.forces.append(self)

func other(node_model) :
	if targetA == node_model :
		return targetB
	return targetA

func center_force() :
	return targetA.node_name == "CENTER" or targetB.node_name == "CENTER"

func change(prev_target, new_target) :
	if targetA == prev_target :
		targetA.forces.remove_at(targetA.forces.find(self))
		targetA = new_target
		targetA.forces.append(self)
	else :
		targetB.forces.remove_at(targetB.forces.find(self))
		targetB = new_target
		targetB.forces.append(self)

func apply_forces():
	# Check nodes exist
	if not targetA :
		print(targetB.node_name)
		return
	if not targetB :
		print(targetA.node_name)
		return
	
	# get force vector
	var direction = targetB.position - targetA.position
	var dist = direction.length ()
	direction = direction.normalized()
	
	# Get force direction and strenght
	var vf
	if force > 0 :
		# friends
		vf = direction * force * pow(dist/friend_dist_factor, 2)
	else :
		# foes
		vf = direction * force / pow(dist/foe_dist_factor, 2)
	# limit max forces
	if vf.x > MAX_FORCE :
		vf.x = MAX_FORCE
	if vf.y > MAX_FORCE :
		vf.y = MAX_FORCE
	if vf.x < -MAX_FORCE :
		vf.x = -MAX_FORCE
	if vf.y < -MAX_FORCE :
		vf.y = -MAX_FORCE
	
	# apply forces on both nodes A and B
	var node = targetA as RigidBody2D
	if not node:
		print("should be")
	else:
		node.apply_impulse(vf, Vector2.ZERO)
	
	node = targetB as RigidBody2D
	if not node:
		print("should be")
	else:
		node.apply_impulse(-1 * vf, Vector2.ZERO)

func save() :
	var save_dict = {
		"force" : force,
		"targetA" : targetA.node_name,
		"targetB" : targetB.node_name,
	}
	return save_dict
