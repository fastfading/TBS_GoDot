extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load events for this level
	BattlefieldInfo.event_system.add_event(L2_Event_Part1.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part2.new())
	
	# Start Level
	BattlefieldInfo.event_system.start_events_queue()