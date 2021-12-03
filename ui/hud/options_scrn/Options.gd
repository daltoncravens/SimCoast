extends Control

# TODO: Pause passage of in-game time
# TODO: Add background music

func _ready():
	pass

func _on_SettingsButton_pressed():
	$OptionsPopup.popup()


func _on_FullScreenToggle_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_MasterVolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_MasterMute_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !button_pressed)


func _on_MusicVolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_MusicMute_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !button_pressed)


func _on_SFXVolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)


func _on_SFXMute_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), !button_pressed)
