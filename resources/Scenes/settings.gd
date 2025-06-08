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

# store AA settings cos they need to be altered when 
# upscaling is set
class QualitySettings:
	var shadow_quality:int
	var aa_method:int
	var upscaling_method:int
	var resolution_scale:int

func _ready():
	# TODO: this will need to live somewhere else
	# 	we're getting dangerously close to needing to save a file here
	#var quality_settings:QualitySettings = QualitySettings.new()
	
	var popup_shadow_quality = $TabContainer/graphics/shadows/menubutton_shadow_quality.get_popup()
	popup_shadow_quality.add_item("really low", 1)
	popup_shadow_quality.add_item("low", 2)
	popup_shadow_quality.add_item("less low", 3)
	popup_shadow_quality.id_pressed.connect(_on_popup_shadow_menu_item_pressed)
	
	var popup_aa = $TabContainer/graphics/antialiasing/menubutton_aa.get_popup()
	popup_aa.add_item("temporal", 0) 		# viewport_set_use_taa
	popup_aa.add_item("screen space", 1) 	# viewport_set_screen_space_aa
	popup_aa.add_item("msaa", 2)			# viewport_set_msaa_3d
	popup_aa.id_pressed.connect(_on_popup_aa_menu_item_pressed)
	
	
	var popup_upscaler = $TabContainer/graphics/upscaler/menubutton_resolution_scaler.get_popup()
	popup_upscaler.add_item("normal", 0)
	popup_upscaler.add_item("fsr1", 1)
	popup_upscaler.add_item("fsr2", 2)
	popup_upscaler.id_pressed.connect(_on_popup_upscaler_menu_item_pressed)

	var popup_upscaling = $TabContainer/graphics/upscaling/menubutton_resolution_scaling.get_popup()
	popup_upscaling.add_item("100%", 0)
	popup_upscaling.add_item("75%", 1)
	popup_upscaling.add_item("50%", 2)
	popup_upscaling.add_item("25%", 3)
	
	popup_upscaling.id_pressed.connect(_on_popup_upscaling_menu_item_pressed)
	
func _on_popup_aa_menu_item_pressed(pressed_id):
	# antialiasing method
	var rid:RID = get_viewport().get_viewport_rid()	
	if pressed_id == 0:
		RenderingServer.viewport_set_use_taa(rid, true)
		RenderingServer.viewport_set_screen_space_aa(rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
		RenderingServer.viewport_set_msaa_3d(rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
	elif pressed_id == 1:
		RenderingServer.viewport_set_use_taa(rid, false)
		RenderingServer.viewport_set_screen_space_aa(rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
		RenderingServer.viewport_set_msaa_3d(rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
	elif pressed_id == 2:
		RenderingServer.viewport_set_use_taa(rid, false)
		RenderingServer.viewport_set_screen_space_aa(rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
		RenderingServer.viewport_set_msaa_3d(rid, RenderingServer.VIEWPORT_MSAA_4X)
		
		
func _on_popup_upscaling_menu_item_pressed(pressed_id):
	# viewport scaling
	var rid:RID = get_viewport().get_viewport_rid()	
	if pressed_id == 0:
		RenderingServer.viewport_set_scaling_3d_scale(rid, 1.0)
	elif pressed_id == 1:
		RenderingServer.viewport_set_scaling_3d_scale(rid, 0.75)
	elif pressed_id == 2:
		RenderingServer.viewport_set_scaling_3d_scale(rid, 0.5)
	elif pressed_id == 3:
		RenderingServer.viewport_set_scaling_3d_scale(rid, 0.25)
	
	
	
func _on_popup_upscaler_menu_item_pressed(pressed_id):
	# upscaler selection
	var rid:RID = get_viewport().get_viewport_rid()	
	if pressed_id == 0:
		RenderingServer.viewport_set_scaling_3d_mode(rid, RenderingServer.VIEWPORT_SCALING_3D_MODE_BILINEAR)
	elif pressed_id == 1:
		RenderingServer.viewport_set_scaling_3d_mode(rid, RenderingServer.VIEWPORT_SCALING_3D_MODE_FSR)
	elif pressed_id == 2:
		RenderingServer.viewport_set_scaling_3d_mode(rid, RenderingServer.VIEWPORT_SCALING_3D_MODE_FSR2)
		# FSR2 comes with a TAA implementation so we should remove any other AA
		RenderingServer.viewport_set_use_taa(rid, false)
		RenderingServer.viewport_set_msaa_3d(rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		RenderingServer.viewport_set_screen_space_aa(rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
	# TODO: 
	#	Metal support one day?
		
func _on_popup_shadow_menu_item_pressed(pressed_id):
	# shadow quality
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
