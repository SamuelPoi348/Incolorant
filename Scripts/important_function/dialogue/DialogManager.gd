extends Node

signal dialog_finished
@onready var text_box_scene = preload("res://Scenes/important_function/dialogue/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false

var auto_continue_timer: Timer = null
const AUTO_CONTINUE_DELAY = 3.0

func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false
	
func _on_text_box_finished_displaying():
	can_advance_line = true
	# Start a timer to auto-continue after 3 seconds if auto-dialog is enabled
	var main = get_tree().root.get_node("Main")
	if main.option_auto_dialog:
		_start_auto_continue_timer()
	
func _unhandled_input(event: InputEvent):
	if (
		event.is_action_pressed("interagir") &&
		is_dialog_active &&
		can_advance_line
	):
		# Cancel auto-continue if player manually advances
		_cancel_auto_continue_timer()
		text_box.queue_free()
		
		current_line_index += 1
		
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			emit_signal("dialog_finished")
			return
		
		_show_text_box()

func _start_auto_continue_timer():
	# Create a new timer for auto-continue
	if auto_continue_timer != null:
		_cancel_auto_continue_timer()
	
	auto_continue_timer = Timer.new()
	auto_continue_timer.wait_time = AUTO_CONTINUE_DELAY
	auto_continue_timer.one_shot = true
	auto_continue_timer.timeout.connect(_on_auto_continue_timeout)
	add_child(auto_continue_timer)
	auto_continue_timer.start()

func _cancel_auto_continue_timer():
	if auto_continue_timer != null:
		auto_continue_timer.stop()
		auto_continue_timer.queue_free()
		auto_continue_timer = null

func _on_auto_continue_timeout():
	if is_dialog_active and can_advance_line:
		# Auto-advance to next line
		text_box.queue_free()
		
		current_line_index += 1
		
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			emit_signal("dialog_finished")
			return
		
		_show_text_box()
	
	auto_continue_timer = null
	
	
	
