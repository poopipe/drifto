extends Control

# TODO:  THERE IS PROBABLY A BUG WHEN SWITCHING FSR ON AND OFF BUT I CANT BE ARSED 
#		 CHECKING ATM
# 		 TEST IT  AT SOME POINT



@onready
var button_main_menu = $VBoxContainer/button_exit

@onready
var menu_window_mode = $VBoxContainer/TabContainer/graphics/window_mode/menubutton_window_mode
@onready
var menu_shadow_quality = $VBoxContainer/TabContainer/graphics/shadows/menubutton_shadow_quality
@onready
var menu_aa = $VBoxContainer/TabContainer/graphics/antialiasing/menubutton_aa
@onready
var menu_upscaler = $VBoxContainer/TabContainer/graphics/upscaler/menubutton_resolution_scaler
@onready
var menu_upscaling = $VBoxContainer/TabContainer/graphics/upscaling/menubutton_resolution_scaling


@onready
var popup_window_mode = menu_window_mode.get_popup()
@onready
var popup_shadow_quality = menu_shadow_quality.get_popup()
@onready
var popup_aa = menu_aa.get_popup()
@onready
var popup_upscaler = menu_upscaler.get_popup()
@onready
var popup_upscaling = menu_upscaling.get_popup()

func _ready():
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
	
	# connect buttons to handlers
	button_main_menu.pressed.connect(_on_button_main_menu_pressed)

	# init the menus
	popup_window_mode.add_item("fullscreen",0)
	popup_window_mode.add_item("windowed",1)
	popup_window_mode.id_pressed.connect(_on_popup_window_mode_pressed)
	var window_mode_id = int(SimpleSettings.get_value('game', 'graphics/window_mode', true))
	popup_window_mode.set_focused_item(window_mode_id)
	
	popup_shadow_quality.add_item("really low", 1)
	popup_shadow_quality.add_item("low", 2)
	popup_shadow_quality.add_item("less low", 3)
	popup_shadow_quality.id_pressed.connect(_on_popup_shadow_menu_item_pressed)
	var shadow_id = int(SimpleSettings.get_value('game','graphics/shadows',true))
	popup_shadow_quality.set_focused_item(shadow_id)
	var shadow_index = popup_shadow_quality.get_item_index(shadow_id)
	menu_shadow_quality.text = str(popup_shadow_quality.get_item_text(shadow_index))
	
	popup_aa.add_item("temporal", 0) 		# viewport_set_use_taa
	popup_aa.add_item("screen space", 1) 	# viewport_set_screen_space_aa
	popup_aa.add_item("msaa", 2)			# viewport_set_msaa_3d
	popup_aa.id_pressed.connect(_on_popup_aa_menu_item_pressed)
	var aa_id = int(SimpleSettings.get_value('game','graphics/antialiasing',true))
	popup_aa.set_focused_item(aa_id)		
	var aa_index = popup_aa.get_item_index(aa_id)
	menu_aa.text = str(popup_aa.get_item_text(aa_index))
	
	popup_upscaler.add_item("normal", 0)
	popup_upscaler.add_item("fsr1", 1)
	popup_upscaler.add_item("fsr2", 2)
	popup_upscaler.id_pressed.connect(_on_popup_upscaler_menu_item_pressed)
	var upscaler_id = int(SimpleSettings.get_value('game','graphics/upscaler',true))
	popup_upscaler.set_focused_item(upscaler_id)
	var upscaler_index = popup_upscaler.get_item_index(upscaler_id)
	menu_upscaler.text = str(popup_upscaler.get_item_text(upscaler_index))
	
	popup_upscaling.add_item("100%", 0)
	popup_upscaling.add_item("75%", 1)
	popup_upscaling.add_item("50%", 2)
	popup_upscaling.add_item("25%", 3)
	popup_upscaling.id_pressed.connect(_on_popup_upscaling_menu_item_pressed)
	var upscaling_id = int(SimpleSettings.get_value('game','graphics/upscaling',true))
	popup_upscaling.set_focused_item(upscaling_id)
	var upscaling_index = popup_upscaling.get_item_index(upscaling_id)
	menu_upscaling.text = str(popup_upscaling.get_item_text(upscaling_index))
	
func _on_popup_window_mode_pressed(pressed_id):
	if pressed_id == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if pressed_id == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	SimpleSettings.set_value('game', 'graphics/window_mode', pressed_id)
	var index = popup_window_mode.get_item_index(pressed_id)
	menu_window_mode.text = str(popup_window_mode.get_item_text(index))
	
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
	var index = popup_aa.get_item_index(pressed_id)
	menu_aa.text = str(popup_aa.get_item_text(index))
			
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
	var index = popup_upscaling.get_item_index(pressed_id)
	menu_upscaling.text = str(popup_upscaling.get_item_text(index))
	
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
	var index = popup_upscaler.get_item_index(pressed_id)
	menu_upscaler.text = str(popup_upscaler.get_item_text(index))
		
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
	var index = popup_shadow_quality.get_item_index(pressed_id)
	menu_shadow_quality.text = str(popup_shadow_quality.get_item_text(index))

func _on_button_main_menu_pressed():
	get_tree().change_scene_to_file("res://resources/Scenes/ui/main_menu.tscn")
	
func _input(event: InputEvent) -> void:
	# this smells 
	var in_main_menu: bool  = false
	if get_tree().get_current_scene().name == "Settings":
		in_main_menu = true
		print("Only the UI scene is loaded.")
		
	if event.is_action_pressed("action_menu"):
		if in_main_menu:
			_on_button_main_menu_pressed()
		else:
			# hide or unhide settings menu
			if self.visible:
				self.visible = false
				get_tree().paused = false
			else:
				self.visible = true
				get_tree().paused = true
