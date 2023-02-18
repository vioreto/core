extends RefCounted

class_name NodeManager

var scene_node_list: Array[Core.Scene] = []

var text_container: Node

func _init(_text_container: Node):
	text_container = _text_container

func build(scene: Core.Scene):
	scene_node_list.append(scene)

func add_to_tree():
	var scene = scene_node_list.pop_front()
	if !scene:
		return
	set_text(scene)
	if scene.is_end():
		return

func set_text(scene: Core.Scene):
	if scene.text_list.size() == 0:
		return
	var text: Array[String] = []
	text.assign(scene.text_list.map(func (s): return s.content))
	text_container.play(text)
