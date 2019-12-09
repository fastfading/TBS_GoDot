extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.current_animation = "Idle"
	UnitMovementStats.is_ally = false
	
	# Portrait
	#unit_portrait_path = preload("res://assets/units/enemyPortrait/normalSoldierPortrait.png")
	unit_portrait_path = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	
	# Mug shot
	unit_mugshot = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	
	# Add Lance
	var lance = preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance()
	UnitInventory.add_item(lance)
	
	# Combat sprite
	combat_node = preload("res://Scenes/Units/Enemy_Units/Black Soldier Combat.tscn")