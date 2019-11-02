extends Node2D

#########
#SYSTEMS#
#########

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator
var turn_manager

# Start battlefield game
func _ready():
	# Movement Calculator
	movement_calculator = MovementCalculator.new(self)
	
	# Movement System
	unit_movement_system = Unit_Movement_System.new()

# Run Systems
func _process(delta):
	unit_movement_system.process_movement(delta)

#######################
#BATTLEFIELD VARIABLES#
#######################

# Current Unit Selected
var current_Unit_Selected: Node2D

# Map Info
var grid = []
var map_height
var map_width

# Camera Values
var camera_limit_bottom
var camera_limit_

# Battlefield Unit Info
var ally_units = {}
var enemy_units = {}