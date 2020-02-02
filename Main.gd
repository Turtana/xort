extends Node2D

export (PackedScene) var Ship
export (PackedScene) var ShipPart
var ship
var on_platform = false
var can_takeoff = true

var shipcounter = 0
var totalships = 10
var ships_repaired = 0

var types = [0,1,2,3,4]
var catalogue = {
	"Hull": [],
	"Cockpit": [],
	"Gun": [],
	"Engine": [],
	"Landing": []
}

var names1 = [
	"Brave",
	"Yellow",
	"Red",
	"Speedy",
	"Happy",
	"Slow",
	"Old",
	"Dark",
	"Crazy",
	"Holy",
	"Galactic",
	"Eternal",
	"Humble",
	"Useless"
]
var names2 = [
	" Hawk",
	" Cowboy",
	" Falcon",
	" Turtle",
	" Cat",
	" Zeppelin",
	" Frigate",
	" Adventurer",
	" Frontier",
	" Miner",
	" Star",
	" Nerd",
	" Fireball",
	" Armstrong",
	" Gagarin",
	" Diplomacy"
]

func _ready():
	randomize()

func _process(delta):
	if weakref(ship).get_ref():
		if not ship.moving:
			if not on_platform: # eagle has landed
				on_platform = true
				for part in ship.parts:
					if len(part.get_signal_connection_list("click")) == 0:
						part.connect("click", self, "PartTray")
	$Background.rotate(0.1 * delta)

func SpawnShip():
	ship = Ship.instance()
	ship.position = $ShipSpawn.position
	ship.z_index = 1
	
	ship.title = names1[randi() % len(names1)] + names2[randi() % len(names2)]
	add_child(ship)
	shipcounter += 1
	
	# puzzle code
	ship.total_weight = int(floor(rand_range(50, 81))) * 1000 # all need
	ship.total_energy = int(floor(rand_range(15, 36))) * 1000 # all except landing need
	ship.total_oxygen = int(floor(rand_range(10, 16))) * 1000 # cockpit and motor need
	
	var w = ship.total_weight
	var e = ship.total_energy
	var o = ship.total_oxygen
	
	for part in ship.parts:
		var partweight = int(floor(rand_range(7500, ship.total_weight * .25)))
		if partweight < w:
			w -= partweight
			part.weight = partweight
		else:
			part.weight = w
		if part.type == "Landing":
			continue
		
		var partenergy = int(floor(rand_range(2000, ship.total_energy * .33)))
		if partenergy < e:
			e -= partenergy
			part.energy = partenergy
		else:
			part.energy = e
		if part.type == "Gun" or part.type == "Hull":
			continue
		
		var partoxygen = int(floor(rand_range(2000, ship.total_oxygen)))
		if partoxygen < o:
			o -= partoxygen
			part.oxygen = partoxygen
		else:
			part.oxygen = o
	
	for part in ship.parts:
		part.update_desc()
		var possibilities = types.duplicate()
		possibilities.erase(part.style)
		possibilities.remove(randi() % len(possibilities))
		possibilities.shuffle()
		
		catalogue[part.type] = []
		for p in possibilities:
			var new_part = ShipPart.instance()
			new_part.texture = load("res://parts/" + part.type.to_lower() + str(p) + ".png")
			new_part.type = part.type
			new_part.style = p
			new_part.connect("click", self, "change_parts")
			
			# code to generate puzzle
			# for starters, same parameters as normal ship parts, some repairs may be unsolvable
			new_part.weight = int(floor(rand_range(7000, ship.total_weight * .30)))
			if new_part.type != "Landing":
				new_part.energy = int(floor(rand_range(2000, ship.total_energy * .40)))
			if new_part.type == "Cockpit" or new_part.type == "Engine":
				new_part.oxygen = int(floor(rand_range(2000, ship.total_oxygen)))
			
			catalogue[part.type].append(new_part)
			new_part.update_desc()
	
	ship.goto($Platform.position)
	$Landing.play()
	update_data()

func GoShip():
	if $Tray.ejected:
		$Tray.eject()
	if ship.is_broken() or not can_takeoff:
		$Explosion.play()
		ship.explode()
	else:
		ships_repaired += 1
		ship.goto($TakeOff.position)

func _on_Button_button_up():
	if on_platform:
		GoShip()
		if shipcounter == totalships:
			$MainMenu.visible = true
			$HUD.visible = false
			$Animation.stop()
			$Congrats.text = "Congratulations!\nYou repaired " + str(ships_repaired) + " spaceships."
			$Congrats.visible = true
		else:
			SpawnShip()
		on_platform = false

func PartTray(part):
	if $Tray.ejected:
		if $Tray.type != part.type:
			$Tray.change(catalogue[part.type])
		else:
			$Tray.eject()
	else:
		$Tray.set_parts(catalogue[part.type])
		$Tray.eject()
	$Tray.type = part.type

func change_parts(part):
	var loc = Vector2()
	for l in $Tray.locs:
		if l.position == part.position:
			loc = l.position
			break
	
	var old_part = ship.get_node(part.type)
	part.position = old_part.position
	old_part.position = loc
	
	$Tray.remove_child(part)
	ship.add_child(part)
	ship.remove_child(old_part)
	$Tray.add_child(old_part)
	
	$Tray.parts.erase(part)
	$Tray.parts.append(old_part)
	ship.parts.erase(old_part)
	ship.parts.append(part)
	
	catalogue[part.type].erase(part)
	catalogue[part.type].append(old_part)
	
	old_part.connect("click", self, "change_parts")
	old_part.disconnect("click", self, "PartTray")
	part.connect("click", self, "PartTray")
	part.disconnect("click", self, "change_parts")
	
	part.name = part.type # naming stuffs in the ship
	update_data()

func update_data():
	$HUD/ShipData.bbcode_text = "[right]" + ship.title + \
	"\nEnergy usage: " + str(ship.get_energy()) + " / " + str(ship.total_energy) + \
	"\nOxygen usage: " + str(ship.get_oxygen()) + " / " + str(ship.total_oxygen) + \
	"\nWeight: " + str(ship.get_weight()) + " / " + str(ship.total_weight) + \
	"\n\nShip " + str(shipcounter) + " / " + str(totalships) + "[/right]"
	
	if ship.get_energy() > ship.total_energy \
	or ship.get_oxygen() > ship.total_oxygen \
	or ship.get_weight() > ship.total_weight:
		can_takeoff = false
	else:
		can_takeoff = true


func _on_PlayButton_button_up():
	$HUD.visible = true
	$MainMenu.visible = false
	$Congrats.visible = false
	ships_repaired = 0
	shipcounter = 0
	SpawnShip()
	$Animation.play("xort_idle", -1, 0.5)

func _on_QuitButton_button_up():
	get_tree().quit()
