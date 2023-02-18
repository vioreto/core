extends RefCounted

class_name Config

var data = {
	"locale": "zh-CN"
}

func get_config(id: String):
	var _data = data
	for key in id.split("."):
		_data = _data[key]
	return _data
