class_name DeathPitArea
extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_fallen_into_pit)
	
func _on_body_fallen_into_pit(body: PhysicsBody3D) -> void:
	if body is Player:
		(body as Player).kill()
	elif body.has_method(&"kill"):
		body.call(&"kill")
	else:
		pass # body.queue_free() # not safe
	
	# animate particles ?
