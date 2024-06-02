extends MeshInstance3D

var angular_speed = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var toggle = 0
	if Input.is_action_pressed("rotate_world"):
		toggle = 1
	
	rotation = Vector3(0.0, (toggle * delta * angular_speed), 0.0)
	
	
