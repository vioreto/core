extends RefCounted

const Core = preload("res://addons/vioreto/core.gd")

var scene_node_list = []

var text_container: Node

func _init(_text_container: Node):
	text_container = _text_container

func build(scene: Core.Scene):
	var vBoxContainer = VBoxContainer.new()
	vBoxContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label = RichTextLabel.new()
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if scene.text_list.is_empty():
		label.text = "end"
	else:
		label.text = scene.text_list[0].content
	vBoxContainer.add_child(label)
	scene_node_list.append(vBoxContainer)

func add_to_tree():
	if text_container.get_child_count() > 0:
		var last = text_container.get_child(0)
		text_container.remove_child(last)
	var node = scene_node_list.pop_front()
	if node:
		text_container.add_child(node)
