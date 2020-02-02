extends Sprite

var ejected = false
var moving = false
var changing = false

var type = "Null"
var next_contents
var parts = []
onready var locs = [$Loc1, $Loc2, $Loc3]

func _ready():
	pass

func eject():
	if moving:
		return
	moving = true
	var dir_vector = Vector2(200, 0)
	if ejected:
		dir_vector = Vector2(-200, 0)
		ejected = false
	else:
		ejected = true
		
	$Tween.interpolate_property(self, "position", position, position + dir_vector, 0.5, Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()


func _on_Tween_tween_completed(_object, _key):
	moving = false
	if changing:
		set_parts(next_contents)
		changing = false
		eject()

func change(new_parts):
	next_contents = new_parts
	eject()
	changing = true

func set_parts(new_parts):
	empty_tray()
	for i in range(len(new_parts)):
		var new = new_parts[i]
		new.position = locs[i].position
		new.z_index = i
		parts.append(new)
		add_child(new)

func empty_tray():
	for p in parts:
		remove_child(p)
	parts = []
