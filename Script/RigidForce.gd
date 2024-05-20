
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

func apply_forces():
	if not targetA :
		print(targetB.node_name)
		return
	if not targetB :
		print(targetA.node_name)
		return
	var direction = targetB.position - targetA.position
	var dist = direction.length ()
	direction = direction.normalized()
	
	var vf
	if force > 0 :
		# friends
		vf = direction * force * pow(dist/friend_dist_factor, 2)
	else :
		# foes
		vf = direction * force / pow(dist/foe_dist_factor, 2)
	if vf.x > MAX_FORCE :
		vf.x = MAX_FORCE
	if vf.y > MAX_FORCE :
		vf.y = MAX_FORCE
	if vf.x < -MAX_FORCE :
		vf.x = -MAX_FORCE
	if vf.y < -MAX_FORCE :
		vf.y = -MAX_FORCE
	
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
