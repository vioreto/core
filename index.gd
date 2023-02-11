@tool
extends EditorPlugin

const GLOBAL = "Vioreto"

func _enter_tree():
	add_autoload_singleton(GLOBAL, "res://addons/vioreto/global.gd")
	pass


func _exit_tree():
	remove_autoload_singleton(GLOBAL)
	pass
