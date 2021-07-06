extends TextureRect

var full_sprite = preload("res://assets/resources/hearts/Heart Full.PNG")
var empty_sprite = preload("res://assets/resources/hearts/Heart Empty.PNG")


func set_empty_sprite():
	set_texture(empty_sprite)


func set_full_sprite():
	set_texture(full_sprite)
