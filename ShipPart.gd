extends Area2D

var energy = 0
var oxygen = 0
var weight = 0

var moving = false

var broken = false
var style = -1
export var type = "Null"

export(Texture) var texture

signal click

func _ready():
	init()

func init():
	$Sprite.texture = texture
	var rekt = texture.get_size()
	var collider = RectangleShape2D.new()
	collider.extents = (Vector2(rekt.x * .5, rekt.y * .5))
	$Shape.shape = collider
	
	$D/Description.visible = false
	update_desc()

func update_desc():
	var isbroken = ""
	if broken:
		isbroken = " (broken)"
	$D/Description.text = self.type + isbroken + "\nEnergy: " + str(energy) + "\nOxygen: " + str(oxygen) + "\nWeight: " + str(weight)

func _on_ShipPart_mouse_entered():
	$Sprite.modulate = Color(1.5,1.5,1.5)
	$D/Description.visible = true

func _on_ShipPart_mouse_exited():
	$Sprite.modulate = Color(1,1,1)
	$D/Description.visible = false

func _on_ShipPart_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("click", self)
