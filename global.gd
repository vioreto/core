extends Node

const Config = preload("res://addons/vioreto/config.gd")

var config = Config.new()

func get_config(id: String):
	return config.get_config(id)
