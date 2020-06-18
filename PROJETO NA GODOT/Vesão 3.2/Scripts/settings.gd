extends Node

enum GIQuality {
	DISABLED = 0
	LOW = 1
	HIGH = 2
}

enum AAQuality {
	DISABLED = 0
	AA_2X = 1
	AA_4X = 2
	AA_8X = 3
}

enum SSAOQuality {
	DISABLED = 0
	LOW = 1
	HIGH = 2
}



var resolutions=[Vector2(1280,720),Vector2(1366,768),Vector2(1600,900),Vector2(1920,1080),Vector2(2560,1440),Vector2(3840,2160)]
var gi_quality = GIQuality.LOW
var aa_quality = AAQuality.AA_2X
var ssao_quality = SSAOQuality.DISABLED
var fullscreen = true

var resolution 

func _ready():
	load_settings()


func load_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.READ)
	if error:
		print("There are no settings to load.")
		return
	
	var d = parse_json(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return
	
	if "gi" in d:
		gi_quality = int(d.gi)
	
	if "aa" in d:
		aa_quality = int(d.aa)
	
	if "ssao" in d:
		ssao_quality = int(d.ssao)
	
	if "resolution" in d:
		resolution = int(d.resolution)

	if "fullscreen" in d:
		fullscreen = bool(d.fullscreen)

func save_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.WRITE)
	assert(not error)

	var d = { "gi":gi_quality, "aa":aa_quality, "ssao":ssao_quality, "resolution":resolution, "fullscreen":fullscreen }
	f.store_line(to_json(d))

func set_resolution(id):
	resolution=resolutions[id ]
	var minsize = Vector2(OS.window_size.x * resolutions[id].y / OS.window_size.y, resolutions[id].y)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
