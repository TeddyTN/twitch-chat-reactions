class_name CharacterState
extends State


enum {
	DANCING,
	DEATH,
	IDLE,
	JUMPING,
	WALKING,
}

@export var animation_tree: AnimationTree


func _ready() -> void:
	set_animation(CharacterState.IDLE)


func set_animation(animation: int) -> void:
	if not animation_tree:
		push_error("AnimationTree not set for state: ", name)
		return

	animation_tree.set("parameters/conditions/dancing", animation == CharacterState.DANCING)
	animation_tree.set("parameters/conditions/death", animation == CharacterState.DEATH)
	animation_tree.set("parameters/conditions/idle", animation == CharacterState.IDLE)
	animation_tree.set("parameters/conditions/jumping", animation == CharacterState.JUMPING)
	animation_tree.set("parameters/conditions/walking", animation == CharacterState.WALKING)
