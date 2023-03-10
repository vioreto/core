extends RefCounted

class_name Core

const PRELOAD_SCENE = 20

static func run(options):
	var controller = Controller.new()
	var script_path = options.script_path
	var action_id = options.action_id
	controller.stage = Stage.new(script_path, {}, options.node)
	controller.load(script_path, action_id)
	controller.run()
	return controller

class Controller:
	var error_handler: Callable
	var stage: Stage
	var action_list: Array[Action] = []
	var is_end = false
	
	func _init(_error_handler: Callable = func(): printerr("load")):
		error_handler = _error_handler
		
	func load(script_path: String, action_id: String):
		var parent_path = script_path.get_base_dir()
		if is_vaild_load_params(script_path, action_id):
			prepare(script_path, action_id)
			return
		var file_list = DirAccess.get_files_at(parent_path)
		for name in file_list:
			if name == "stage.gd":
				continue
			var path = parent_path + "/" + name
			if is_vaild_load_params(path, action_id):
				prepare(path, action_id)
				return
		if error_handler:
			error_handler.call()
			
	func is_vaild_load_params(script_path: String, action_id: String):
		if !FileAccess.file_exists(script_path):
			return false
		var instance = load(script_path).new()
		return instance.action_id_list.has(action_id)
		
	func get_start_action_index(script_path: String, action_id: String):
		var instance = load(script_path).new()
		return instance.action_id_list.find(action_id)
		
	func prepare(script_path: String, action_id: String):
		load_resource(script_path)
		var index = get_start_action_index(script_path, action_id)
		action_list = action_list.slice(index)
		
	func run():
		for i in range(PRELOAD_SCENE):
			next()
		turn_page()
		
	func next():
		if is_end:
			return
		check_action()
		run_action()
		
	func turn_page():
		stage.refresh()
		next()		
		
	func check_action():
		if action_list.size() > 0:
			return
		var next_script_path = stage.get_next_script_path()
		load_resource(next_script_path)
		
	func load_resource(script_path: String):
		load_action(script_path)
		stage.load_locale_text(script_path)

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
		super(
			func(s): 
				s.type = "end"
				print("end")
		)
		
class Stage:
	var script_path: String
	var node: NodeManager
	
#	var go_to_map
	var character_map: Dictionary
	var text_map = {}
	
	var state: Dictionary
	
	func _init(_script_path: String, _state: Dictionary, nodeOptions: Dictionary):
		script_path = _script_path
		state = _state
		var text_container = nodeOptions.text_container
		node = NodeManager.new(text_container)
		load_stage_data()
		
	func load_stage_data():
		var parent_path = script_path.get_base_dir()
		var stage_path = parent_path + "/stage.gd"
		var stage_data = load(stage_path).new()
		character_map = stage_data.character_map

	func load_locale_text(_script_path: String):
		script_path = _script_path
		var index = script_path.find(".")
		var locale = Vioreto.get_config("locale")
		var get_text_path =  func(locale: String):
			return script_path.substr(0, index) + "." + locale + script_path.substr(index)
		text_map[locale] = load(get_text_path.call(locale)).new().text_map
		if Vioreto.get_config("multipleLanguageMode"):
			var secondaryLocale = Vioreto.get_config("secondaryLocale")
			text_map[secondaryLocale] = load(get_text_path.call(secondaryLocale)).new().text_map
			
		
	func get_next_script_path():
		var regex = RegEx.new()
		regex.compile("(\\d+).gd")
		var result = regex.search(script_path)
		var script_index = int(result.get_string(1))
		return script_path.replace(str(script_index), str(script_index + 1))
		
	func load_scene(handler: Callable):
		var scene= Scene.new(self)
		handler.call(scene)
		node.build(scene)
		
	func refresh():
		node.add_to_tree()
		
	
class Scene:
	var stage: Stage
	
	var type: String
	
	var speaker_list: Array[Character] = []
	var text_list: Array[Text] = []
	var tachie_list: Array[Character] = []
	
	func _init(_stage: Stage):
		stage = _stage
		
	func is_end():
		return type == "end"
	
	func speak(speaker_id, text_id):
		var speaker_id_list = []
		if speaker_id is Array:
			speaker_id_list = speaker_id
		else:
			speaker_id_list = [speaker_id]
			
		var locale = Vioreto.get_config("locale")
		speaker_list.assign(speaker_id_list.map(
			func (id):
				return Character.new(id, stage.character_map[id][locale])
		))
		text_list = [Text.new(stage.text_map[locale][text_id])]
		if Vioreto.get_config("multipleLanguageMode"):
			var secondaryLocale = Vioreto.get_config("secondaryLocale")
			text_list.append(Text.new(stage.text_map[secondaryLocale][text_id]))
			print(Util.array_to_string(speaker_list.map(func (s): return s.name)),":",Util.array_to_string(text_list.map(func (s): return s.content)))
		

	func show_character(character):
		tachie_list = [character]

	func push_character(character):
		tachie_list.append(character)

	func remove_character(character):
		for i in tachie_list.size():
			if tachie_list[i].is_same(character):
				tachie_list.remove_at(i)
				break

	func clear_character(scene: Scene):
		scene.tachie_list.clear()

class Text:
	var content: String
	
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

class Util:
	static func array_to_string(arr: Array):
		var s = ""
		for i in arr:
			s += str(i)
		return s
#	static func is_vaild_array_index(arr: Array, index: int):
#		return index >= 0 && index < arr.size()
