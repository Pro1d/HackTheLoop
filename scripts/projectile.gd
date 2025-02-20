class_name Projectile
extends CharacterBody3D

static func make(t: Transform3D, speed: float) -> Projectile:
	var p := preload("res://scenes/projectile.tscn").instantiate() as Projectile
	p.transform = t
	p.velocity = t.basis * Vector3.FORWARD * speed
	return p

func _ready() -> void:
	await ($AutoDestroyTimer as Timer).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	var col := move_and_collide(velocity * delta)
	if col != null:
		var body := col.get_collider()
		var player := body as Player
		if player != null:
			player.kill(Config.v3_to_v2(velocity))
		
		var audio := ($HitAudio3D as AudioStreamPlayer3D)
		audio.play()
		SoundFxManager.keep_audio_3d_until_finished(audio)
		queue_free()
