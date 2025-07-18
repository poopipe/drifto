extends Control

func _ready()->void:
	# define and load settings	
	SimpleSettings.config_files = {
		game = {
			path = "user://game.ini",
		},
		player = {
			path = "user://player.ini",
		},
	}
	# load settings library
	SimpleSettings.load();
	
	var popup_shadow_quality = $graphics/shadows/menubutton_shadow_quality.get_popup()
	var popup_aa = $graphics/antialiasing/menubutton_aa.get_popup()
	var popup_upscaler = $graphics/upscaler/menubutton_resolution_scaler.get_popup()
	var popup_upscaling = $graphics/upscaling/menubutton_resolution_scaling.get_popup()
	
	populate_shadow_quality(popup_shadow_quality)
	populate_aa(popup_aa)
	populate_upscaler(popup_upscaler)
	populate_upscaling(popup_upscaling)

func populate_shadow_quality(popup_shadow_quality)->void:
	popup_shadow_quality.add_item("really low", 1)
	popup_shadow_quality.add_item("low", 2)
	popup_shadow_quality.add_item("less low", 3)
	popup_shadow_quality.id_pressed.connect(_on_popup_shadow_menu_item_pressed)
	popup_shadow_quality.set_focused_item(int(SimpleSettings.get_value('game','graphics/shadows',true)))
	
func populate_aa(popup_aa)->void:
	popup_aa.add_item("temporal", 0) 		# viewport_set_use_taa
	popup_aa.add_item("screen space", 1) 	# viewport_set_screen_space_aa
	popup_aa.add_item("msaa", 2)			# viewport_set_msaa_3d
	popup_aa.id_pressed.connect(_on_popup_aa_menu_item_pressed)
	popup_aa.set_focused_item(int(SimpleSettings.get_value('game','graphics/antialiasing',true)))

func populate_upscaler(popup_upscaler)->void:
	popup_upscaler.add_item("normal", 0)
	popup_upscaler.add_item("fsr1", 1)
	popup_upscaler.add_item("fsr2", 2)
	popup_upscaler.id_pressed.connect(_on_popup_upscaler_menu_item_pressed)
	popup_upscaler.set_focused_item(int(SimpleSettings.get_value('game','graphics/upscaler',true)))

func populate_upscaling(popup_upscaling)->void:
	popup_upscaling.add_item("100%", 0)
	popup_upscaling.add_item("75%", 1)
	popup_upscaling.add_item("50%", 2)
	popup_upscaling.add_item("25%", 3)
	popup_upscaling.id_pressed.connect(_on_popup_upscaling_menu_item_pressed)
	popup_upscaling.set_focused_item(int(SimpleSettings.get_value('game','graphics/upscaling',true)))

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
	SimpleSettings.set_value('game', 'graphics/shadows', pressed_id)

func _on_popup_aa_menu_item_pressed(pressed_id):
	# antialiasing method
	# TODO: we need to handle cases where fsr is enabled
	#		all other aa methods should be disabled when fsr is enabled
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
	SimpleSettings.set_value('game', 'graphics/antialiasing', pressed_id)
	
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
	SimpleSettings.set_value('game', 'graphics/upscaling', pressed_id)
	
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
	SimpleSettings.set_value('game', 'graphics/upscaler', pressed_id)
