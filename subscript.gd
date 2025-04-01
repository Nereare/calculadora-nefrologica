@tool
class_name RichTextSubscript
extends RichTextEffect

var bbcode = "sub"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.offset = Vector2(0, char_fx.env.offset_y if char_fx.env.has("offset_y") else +5)
	return true
