@tool
extends Node
## Custom handlers for settings that require special logic

func _ready():
	# Wait for SettingsManager to be ready
	await get_tree().process_frame
	register_handlers()

func register_handlers():
	
	# Register resolution handler
	SettingsManager.register_setting_handler("resolution", _on_resolution_changed)
	
	# Register other custom handlers as needed
	SettingsManager.register_setting_handler("fullscreen", _on_fullscreen_changed)
	SettingsManager.register_setting_handler("vsync", _on_vsync_changed)
	SettingsManager.register_setting_handler("master_volume", _on_master_volume_changed)

func _on_resolution_changed(resolution_value):
	print("Resolution changed to: ", resolution_value)
	
	# Handle different resolution formats
	var resolution: Vector2i
	
	if resolution_value is String:
		# Parse string format like "1920x1080"
		var parts = resolution_value.split("x")
		if parts.size() == 2:
			resolution = Vector2i(int(parts[0]), int(parts[1]))
		else:
			push_error("Invalid resolution format: " + str(resolution_value))
			return
	elif resolution_value is Vector2i:
		resolution = resolution_value
	elif resolution_value is Vector2:
		resolution = Vector2i(resolution_value)
	else:
		push_error("Unsupported resolution type: " + str(typeof(resolution_value)))
		return
	
	# Apply the resolution change
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(resolution)
		# Center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - resolution) / 2
		DisplayServer.window_set_position(window_pos)
	else:
		# For fullscreen, we might need to change the display mode
		DisplayServer.window_set_size(resolution)

func _on_fullscreen_changed(fullscreen_enabled: bool):
	print("Fullscreen changed to: ", fullscreen_enabled)
	
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_changed(vsync_enabled: bool):
	print("VSync changed to: ", vsync_enabled)
	
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_master_volume_changed(volume: float):
	print("Master volume changed to: ", volume)
	
	# Convert to decibels if needed (assuming volume is 0.0 to 1.0)
	var db_volume = linear_to_db(volume)
	
	# Apply to audio bus
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, db_volume)
