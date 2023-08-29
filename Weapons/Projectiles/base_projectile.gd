extends CharacterBody3D

#Node References
@onready var timer = $DespawnTimer

#Variables
var damage: float = 0

#Setters

func set_damage(value:float) -> void:
	damage = value

#Functions

func _ready():
	timer.start(3)

func _physics_process(delta):
	move_and_slide()
	if get_last_slide_collision():
		handle_collision(get_last_slide_collision().get_collider())

func handle_collision(body:Node):
	if body.is_in_group("damageable"):
		body.take_damage(damage)
	call_deferred("queue_free")

func _on_despawn_timer_timeout():
	call_deferred("queue_free")


