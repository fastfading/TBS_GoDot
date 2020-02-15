extends CanvasLayer

# Shop UI
# Inventory for the shop
const item_shop = {}

# Current index
var current_index = 0

# Scroll bar p value
var previous_scroll_value = 0

# State machine for the shop
enum SHOP_STATE {BUY, SELL, CONFIRM_BUY, CONFIRM_SELL}
var current_state = null

# Default starting position for the hand
const STARTING_HAND_POSITION = Vector2(42, 75)
const HAND_Y_INCREASE = Vector2(0, 12)

# Confirm hand variables
const YES_POSITION = Vector2(76,27)
const NO_POSITION = Vector2(135,27)
const OFF_SCREEN = Vector2(-300,-300)

# Confirm buy variables
var confirm_buy_index = 0

# Confirm sell variables
var confirm_sell_index = 0

# Various Nodes
onready var shop_list = $"Shop UI/ShopList"
onready var shop_list_price = $"Shop UI/ShopListPrice"
onready var hand_selector = $"Hand Selector"
onready var scroll_bar = $"Shop UI/ShopList".get_v_scroll()
onready var scroll_bar2 = $"Shop UI/ShopListPrice".get_v_scroll()
onready var shop_text = $"Shop UI/Shop Keeper Text Info"
onready var anim = $Anim
onready var hand_confirm = $"Shop UI/Hand Confirm"

# Shop text strings
const welcome_msg = "いらっしゃいませ！/nWelcome!"
const confirm = "Is that the one?こちらいいですか？\n        Yes/はい     No/いいえ"
const browsing = "Anything you like?\nお手伝いしましょうか？"
const not_enough_money = "You don't have enough money!\n足りないみたいです。"
const inventory_full = "Your inventory is full!\nインベントリーが一杯ですね"
const thank_you = "Thank you for your patronage!\n毎度ありがとうございました！"

# Debug Test variables
var unit_inventory_space = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set selected item to the first one in the list
	current_index = 0
	shop_list.select(current_index)
	shop_list_price.select(current_index)
	shop_list.grab_focus()
	
	# Reset all other variables
	reset()
	
	# Disable scroll bar with mouse
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	scroll_bar2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Signal for bar
	shop_list.get_v_scroll().connect("value_changed", self, "_adjust_hand_value")
	
	# Set Hand
	hand_selector.rect_position = STARTING_HAND_POSITION
	
	# Play Fade in
	$"Shop UI/Shop Music".play()
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	
	# Play Welcome!
	$"Shop UI/Shop Greeting JPN".play()
	# $"Shop UI/Shop Greeting".play()
	
	# Set text anim
	shop_text.percent_visible = 0
	anim.play("Text Anim")
	
	# Start
	start(SHOP_STATE.BUY)

func sell_item():
	# Remove item from the unit's inventory
	
	# Increase gold amount by item's worth
	pass

func buy_item(index):
	# Set confirm buy back to 0
	confirm_buy_index = 0
	
	# Check if there is enough money
	var price = int(shop_list_price.get_item_text(current_index).substr(0, shop_list_price.get_item_text(current_index).length() - 1))
	if BattlefieldInfo.money >= price:
		# Check if we have inventory space
		if unit_inventory_space > 0:
			# Remove inventory space
			unit_inventory_space -= 1
			
			# Create the item and add it to the unit inventory
			print("Created this item: ", shop_list.get_item_text(current_index))
			
			# Remove amount
			BattlefieldInfo.money -= price
			
			# Move Hand off
			hand_confirm.rect_position = OFF_SCREEN
			
			# Update amount left
			$"Shop UI/Money".text = str(BattlefieldInfo.money)
			
			# Thanks for buying!
			$"Shop UI/Shop Exit JPN Patronage".play()
			
			# Set Text
			shop_text.percent_visible = 0
			shop_text.text = thank_you
			anim.play("Text Anim")
			
			# Wait two seconds then back to buy
			set_process_input(false)
			yield(get_tree().create_timer(2),"timeout")
			
			# Back to browsing
			back_to_browing()
		else:
			# Play can't do that
			$"Shop UI/Shop Can't do that".play()
			
			# Move Hand off
			hand_confirm.rect_position = OFF_SCREEN
			
			# Show text
			shop_text.percent_visible = 0
			shop_text.text = inventory_full
			anim.play("Text Anim")
			
			# Wait two seconds then back to buy
			set_process_input(false)
			yield(get_tree().create_timer(2),"timeout")
			
			# Back to browsing
			back_to_browing()
	else:
		# Cancel here
		$"Shop UI/Shop Not enough money".play()
		
		# Show text
		shop_text.percent_visible = 0
		shop_text.text = not_enough_money
		anim.play("Text Anim")
		
		# Move hand off
		hand_confirm.rect_position = OFF_SCREEN
		
		# Wait two seconds then back to buy
		set_process_input(false)
		yield(get_tree().create_timer(2),"timeout")
		
		# Back to browsing
		back_to_browing()

func start(shop_state):
	# Set shop State
	current_state = shop_state
	
	# Set previous scroll value
	previous_scroll_value = 0
	
	# Set money
	$"Shop UI/Money".text = str(BattlefieldInfo.money)

func exit():
	# Play Goodbye
	pass

func _input(event):
	# Get State
	match current_state:
		SHOP_STATE.BUY:
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				# Play are you sure?
				$"Shop UI/Shop Select your weapon".play()
				# Set new text
				set_process_input(false)
				shop_text.percent_visible = 0
				shop_text.text = confirm
				anim.play("Text Anim")
				
				# Allow Movement again
				yield(anim, "animation_finished")
				
				# Remove Focus
				shop_list.release_focus()
				# Move hand to where it should be
				hand_confirm.rect_position = YES_POSITION
				set_process_input(true)
				
				# Set new state
				current_state = SHOP_STATE.CONFIRM_BUY
		SHOP_STATE.SELL:
			pass
		SHOP_STATE.CONFIRM_BUY:
			# Left and Right
			if Input.is_action_just_pressed("ui_left"):
				if confirm_buy_index == 1:
					confirm_buy_index = 0
					hand_confirm.rect_position = YES_POSITION
					hand_confirm.get_node("Move").play()
			elif Input.is_action_just_pressed("ui_right"):
				if confirm_buy_index == 0:
					confirm_buy_index = 1
					hand_confirm.rect_position = NO_POSITION
					hand_confirm.get_node("Move").play()
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				hand_confirm.get_node("Accept").play()
				# Are we on no?
				if confirm_buy_index == 1:
					# Cancel and go back
					$"Shop UI/Shop dissapointed".play()
					# Disable input
					set_process_input(false)
					
					# Send the hand back
					hand_confirm.rect_position = Vector2(-300,-300)
					# back to the Buy state
					current_state = SHOP_STATE.BUY
					# Back to browsing
					back_to_browing()
				else:
					buy_item(current_index)
			
			# Return button
			if Input.is_action_just_pressed("ui_cancel"):
				hand_confirm.get_node("Cancel").play()
				# Cancel and go back
				$"Shop UI/Shop take your time".play()
				# Send the hand back
				hand_confirm.rect_position = Vector2(-300,-300)
				# back to the Buy state
				current_state = SHOP_STATE.BUY
				# Back to browsing
				back_to_browing()
		SHOP_STATE.CONFIRM_SELL:
			pass
	
	# Test for exit
	if Input.is_action_just_pressed("debug"):
		#$"Shop UI/Shop Exit".play()
		$"Shop UI/Shop Exit".play()
		shop_list.grab_focus()

# Back to browsing
func back_to_browing():
	# Reset
	confirm_buy_index = 0
	confirm_sell_index = 0
	
	# Set text back
	shop_text.percent_visible = 0
	shop_text.text = browsing
	anim.play("Text Anim")
	
	# Wait
	yield(anim, "animation_finished")
	
	# Set state back
	current_state = SHOP_STATE.BUY
	
	# Move Hand away
	hand_confirm.rect_position = OFF_SCREEN
	
	# Set focus back on the first list
	shop_list.grab_focus()
	
	# Allow input again
	set_process_input(true)

# Whenever an item is selected
func _on_ShopList_item_selected(index):
	# Set current index
	current_index = index
	
	# Select the other side
	shop_list_price.select(index)
	
	# Move hand
	if Input.is_action_pressed("ui_up"):
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	if Input.is_action_pressed("ui_down"):
		hand_selector.rect_position += HAND_Y_INCREASE
	
	# Play cursor sound
	hand_selector.get_node("Move").play()

# Adjust hand value when the scroll changes
func _adjust_hand_value(value):
	# Set the second scroll bar value to the first one
	scroll_bar2.value = scroll_bar.value
	
	# Did the Value go up?
	if previous_scroll_value > value:
		hand_selector.rect_position += HAND_Y_INCREASE
	else:
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	# Set new previous value
	previous_scroll_value = value

func reset():
	confirm_buy_index = 0
	confirm_sell_index = 0
	current_index = 0
