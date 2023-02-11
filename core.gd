extends RefCounted

const PRELOAD_SCENE = 20

class Controller:
	var error_handler: Callable
	
	var stage: Stage
	var action_list: Array[Action] = []
	var is_end = false
	
	func _init(_error_handler: Callable = func(): printerr("load")):
		error_handler = _error_handler

	func load(script_path: String, action_id = "", state = {}):
		var parent_path = script_path.get_base_dir()
		if is_vaild_load_params(script_path, action_id):
			load_script(script_path, state)
			return
		var file_list = DirAccess.get_files_at(parent_path)
		for name in file_list:
			if name == "stage.gd":
				continue
			var path = parent_path + "/" + name
			if is_vaild_load_params(path, action_id):
				load_script(path, state)
				return
		if error_handler:
			error_handler.call()
		
	func is_vaild_load_params(script_path: String, action_id: String):
		if !FileAccess.file_exists(script_path):
			return false
		var instance = load(script_path).new()
		if !instance.action_id_list.has(action_id):
			return false
		return true
		
	func load_script(script_path: String, state: Dictionary):
		stage = Stage.new(script_path, state)
		load_action(script_path)
		run()
		
	func run():
		for i in range(PRELOAD_SCENE):
			next()
		
	func next():
		if is_end:
			return
		check_action()
		run_action()
		
	func check_action():
		if action_list.size() > 0:
			return
		var script_path = stage.get_next_script_path()
		load_action(script_path)

	func load_action(script_path: String):
		var script = load(script_path).new()
		action_list.append_array(script.action_list)
		
	func run_action():
		var action = action_list.pop_front()
		if action is End:
			is_end = true
		action.run(stage)
		
class Action:
	var handler: Callable
	
	func _init(_handler: Callable):
		handler = _handler
		
	func run(stage: Stage):
		stage.load_scene(handler)
		
class End extends Action:
	func _init():
		super(func(s): print("end"))
		
class Stage:
	var script_path: String
#	var go_to_map
	var character_map
	
	var state: Dictionary
	
	var scene_list: Array[Scene] = []
	
	func _init(_script_path: String, _state: Dictionary):
		script_path = _script_path
		var parent_path = script_path.get_base_dir()
		var stage_path = parent_path + "/stage.gd"
		var stage_data = load(stage_path).new()
#		go_to_map = _go_to_map
		character_map = stage_data.character_map
		state = _state
		
	func get_next_script_path():
		var regex = RegEx.new()
		regex.compile("(\\d+).gd")
		var result = regex.search(script_path)
		var script_index = int(result.get_string(1))
		return script_path.replace(str(script_index), str(script_index + 1))
		
	func load_scene(handler: Callable):
		var scene= Scene.new()
		handler.call(scene)
		scene_list.append(scene)
		remove_surplus_scene()
		
	func remove_surplus_scene():
		var need_remove = scene_list.size() > PRELOAD_SCENE
		if !need_remove:
			return
		scene_list.pop_front()

		
class Scene:
	var speaker_list: Array[Character] = []
	var text_list: Array[Text] = []
	var tachie_list: Array[Character] = []
	
	func speak(text):
		print(text)
	
#	func speak(_text_list, _speaker_list):
#		if _text_list is Array:
#			text_list = _text_list
#		else:
#			text_list = [_text_list]
#		if _speaker_list is Array:
#			speaker_list = _speaker_list
#		else:
#			speaker_list = [_speaker_list]
#
#	func show_character(character):
#		tachie_list = [character]
#
#	func push_character(character):
#		tachie_list.append(character)
#
#	func remove_character(character):
#		for i in tachie_list.size():
#			if tachie_list[i].is_same(character):
#				tachie_list.remove_at(i)
#				break
#
#	func clear_character(scene: Scene):
#		scene.tachie_list.clear()

class Text:
	var content
	
	func _init(_content = ""):
		content = _content
		

class Character:
	var id
	var name
	
	func _init(_id: String, _name: String):
		id = _id
		name = _name
		
	func is_same(c: Character):
		return id == c.id		

#class Util:
#	static func is_vaild_array_index(arr: Array, index: int):
#		return index >= 0 && index < arr.size()
