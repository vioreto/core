extends ScrollContainer

@onready var player = $AnimationPlayer
@onready var primary_label = $VBoxContainer/Primary
@onready var secondary_label = $VBoxContainer/Secondary

var animation_time = -1

const PRIMARY_LABEL_VISIBLE_CHARACTERS = "VBoxContainer/Primary:visible_characters"
const SECONDARY_LABEL_VISIBLE_CHARACTERS = "VBoxContainer/Secondary:visible_characters"
const SCROLL_VERTICAL = ".:scroll_vertical"

func _ready():
	primary_label.text = ""
	secondary_label.text = ""

func play(text_list: Array[String]):
	reset()
	set_text(text_list)
	set_animation()
	
func reset():
	if animation_time == -1:
		return
	player.stop()
	var flow_animation = player.get_animation("flow")
	var primary_label_track_index = flow_animation.find_track(PRIMARY_LABEL_VISIBLE_CHARACTERS, Animation.TYPE_VALUE)
	flow_animation.track_remove_key_at_time(primary_label_track_index, animation_time)
	if secondary_label.text.length() > 0:
		var secondary_label_track_index = flow_animation.find_track(SECONDARY_LABEL_VISIBLE_CHARACTERS, Animation.TYPE_VALUE)
		flow_animation.track_remove_key_at_time(secondary_label_track_index, animation_time)
	var scroll_track_index = flow_animation.find_track(SCROLL_VERTICAL, Animation.TYPE_VALUE)
	flow_animation.track_remove_key_at_time(scroll_track_index, animation_time)
		

func set_text(text_list: Array[String]):
	primary_label.text = text_list[0]
	if text_list.size() > 1:
		secondary_label.text = text_list[1]

func set_animation():
	var text_total = max(primary_label.text.length(), secondary_label.text.length())
	animation_time = min(text_total * 0.02, 3)
	var flow_animation = player.get_animation("flow")
	var primary_label_track_index = flow_animation.find_track(PRIMARY_LABEL_VISIBLE_CHARACTERS, Animation.TYPE_VALUE)
	flow_animation.track_insert_key(primary_label_track_index, animation_time, text_total)
	if secondary_label.text.length() > 0:
		var secondary_label_track_index = flow_animation.find_track(SECONDARY_LABEL_VISIBLE_CHARACTERS, Animation.TYPE_VALUE)
		flow_animation.track_insert_key(secondary_label_track_index, animation_time, text_total)
	var scroll_track_index = flow_animation.find_track(SCROLL_VERTICAL, Animation.TYPE_VALUE)
	flow_animation.track_insert_key(scroll_track_index, animation_time, 9999)
	player.play("flow")
