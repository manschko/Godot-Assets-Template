@tool
extends Node

var registered_components: Array[BaseSetting] = []
var config_file: ConfigFile
var settings_file_path: String = "user://settings.cfg"

func _ready():
	config_file = ConfigFile.new()
	load_settings()

func register_component(component: BaseSetting):
	if component not in registered_components:
		registered_components.append(component)
		# Connect to value changes
		if not component.value_changed.is_connected(_on_component_value_changed):
			component.value_changed.connect(_on_component_value_changed)

func unregister_component(component: BaseSetting):
	if component in registered_components:
		registered_components.erase(component)
		if component.value_changed.is_connected(_on_component_value_changed):
			component.value_changed.disconnect(_on_component_value_changed)
			
func _on_component_value_changed(key: String, value):
	set_setting(key, value)
	
func set_setting(key: String, value):
	if key == "":
		return		
	config_file.set_value("settings", key, value)
	save_settings()

func get_setting(key: String, default_value = null):
	return config_file.get_value("settings", key, default_value)

func load_settings():
	var error = config_file.load(settings_file_path)
	if error != OK:
		# File doesn't exist or couldn't be loaded, that's fine for first run
		print("Settings file not found or couldn't be loaded. Using defaults.")

func save_settings():
	var error = config_file.save(settings_file_path)
	if error != OK:
		print("Error saving settings: ", error)

func reset_settings():
	config_file.clear()
	save_settings()
	# Notify all registered components to reset to defaults
	for component in registered_components:
		if component.has_method("reset_to_default"):
			component.reset_to_default()

func get_all_settings() -> Dictionary:
	var settings = {}
	if config_file.has_section("settings"):
		for key in config_file.get_section_keys("settings"):
			settings[key] = config_file.get_value("settings", key)
	return settings
