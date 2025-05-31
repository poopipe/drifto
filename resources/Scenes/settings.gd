extends Control
'''
func _on_shadow_size_option_button_item_selected(index):
	if index == 0: # Minimum
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		# Adjust shadow bias according to shadow resolution.
		# Higher resultions can use a lower bias without suffering from shadow acne.
		directional_light.shadow_bias = 0.06

		# Disable positional (omni/spot) light shadows entirely to further improve performance.
		# These often don't contribute as much to a scene compared to directional light shadows.
		get_viewport().positional_shadow_atlas_size = 0
	if index == 1: # Very Low
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		directional_light.shadow_bias = 0.04
		get_viewport().positional_shadow_atlas_size = 1024
	if index == 2: # Low
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		directional_light.shadow_bias = 0.03
		get_viewport().positional_shadow_atlas_size = 2048
	if index == 3: # Medium (default)
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		directional_light.shadow_bias = 0.02
		get_viewport().positional_shadow_atlas_size = 4096
	if index == 4: # High
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		directional_light.shadow_bias = 0.01
		get_viewport().positional_shadow_atlas_size = 8192
	if index == 5: # Ultra
		RenderingServer.directional_shadow_atlas_set_size(16384, true)
		directional_light.shadow_bias = 0.005
		get_viewport().positional_shadow_atlas_size = 16384

'''


# MenuButton.gd



func _ready():
	var popup_shadow_quality = $VBoxContainer/HBoxContainer/menubutton_shadow_quality.get_popup()
	popup_shadow_quality.add_item("really low", 1)
	popup_shadow_quality.add_item("low", 2)
	popup_shadow_quality.add_item("less low", 3)
	popup_shadow_quality.id_pressed.connect(_on_menu_item_pressed)

func _on_menu_item_pressed(pressed_id):
	if pressed_id == 1:
		print("really low")
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		# directional_light.shadow_bias = 0.06
		get_viewport().positional_shadow_atlas_size = 512
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	elif pressed_id == 2:
		print("low")
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		#directional_light.shadow_bias = 0.02
		get_viewport().positional_shadow_atlas_size = 4096
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif pressed_id == 3:
		print('less low')
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		#directional_light.shadow_bias = 0.01
		get_viewport().positional_shadow_atlas_size = 8192
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
