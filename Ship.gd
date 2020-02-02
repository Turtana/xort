extends Node2D

var speed = 300
var moving = false
onready var parts = [$Landing, $Gun, $Engine, $Cockpit, $Hull]
var exploding = false

var total_energy = 0
var total_oxygen = 0
var total_weight = 0
var title = "Cowboy Hiphop"

func _ready():
	generate()

func _process(_delta):
	if position.x > 1500:
		queue_free()

func goto(goal):
	var dist = position.distance_to(goal)
	var time = dist / speed
	
	moving = true
	$Burst.visible = true
	$Tween.interpolate_property(self, "position", position, goal, time, Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()

func generate():
	for part in parts:
		var rnd = int(floor(rand_range(0, 5)))
		part.texture = load("res://parts/" + part.name.to_lower() + str(rnd) + ".png")
		part.style = rnd
		if randi() % 100 > 50:
			part.broken = true
			part.get_node("Smoke").emitting = true
			if part.type == "Hull":
				part.get_node("Smoke").position += Vector2(rand_range(-60,60), 0)
		part.init()

func _on_Tween_tween_completed(_object, _key):
	moving = false
	$Burst.visible = false
	if exploding:
		queue_free()

func is_broken():
	for part in parts:
		if part.broken:
			return true
	return false

func explode():
	for part in parts:
		var junkpos = part.position + Vector2(randi() % 1000 - 500, randi() % 1000 - 500)
		var junkrot = randf() * 12
		$Tween.interpolate_property(part, "position", part.position, junkpos, 1, Tween.TRANS_QUAD,Tween.EASE_OUT)
		$Tween.interpolate_property(part, "rotation", part.rotation, junkrot, 1)
	$Tween.start()
	exploding = true
	$Explosion.emitting = true

func get_energy():
	var sum = 0
	for part in parts:
		sum += part.energy
	return sum

func get_oxygen():
	var sum = 0
	for part in parts:
		sum += part.oxygen
	return sum

func get_weight():
	var sum = 0
	for part in parts:
		sum += part.weight
	return sum
