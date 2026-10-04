class_name UiStyles
extends RefCounted

const INK: Color = Color("233344")
const PINK: Color = Color("ff8bb1")
const MINT: Color = Color("80ded2")
const PURPLE: Color = Color("c5b4fb")
const YELLOW: Color = Color("ffe785")
const GREEN: Color = Color("a5e58b")
const ORANGE: Color = Color("ffc780")
const COLORS: Array[Color] = [PINK, MINT, YELLOW]


static func panel(color: Color, radius: int = 22, border: Color = Color.WHITE) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.14, 0.2, 0.27, 0.09)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 4)
	style.set_content_margin_all(8.0)
	return style


static func label(text: String, font_size: int = 20) -> Label:
	var control: Label = Label.new()
	control.text = text
	control.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	control.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	control.add_theme_color_override("font_color", INK)
	control.add_theme_font_size_override("font_size", font_size)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return control


static func button(text: String, color: Color, font_size: int = 24) -> Button:
	var control: Button = Button.new()
	control.text = text
	control.custom_minimum_size = Vector2(48, 48)
	control.add_theme_font_size_override("font_size", font_size)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		control.add_theme_color_override(state, INK)
	control.add_theme_color_override("font_disabled_color", Color("66717d"))
	control.add_theme_stylebox_override("normal", panel(color, 16))
	control.add_theme_stylebox_override("hover", panel(color.lightened(0.08), 16))
	control.add_theme_stylebox_override("pressed", panel(color.darkened(0.05), 16))
	control.add_theme_stylebox_override("disabled", panel(Color("e5e9ec"), 16, Color("c9d2db")))
	var focus: StyleBoxFlat = panel(Color.TRANSPARENT, 16, Color("6637b7"))
	focus.set_border_width_all(3)
	control.add_theme_stylebox_override("focus", focus)
	return control


static func image(texture: Texture2D, dimensions: Vector2) -> TextureRect:
	var control: TextureRect = TextureRect.new()
	control.texture = texture
	control.custom_minimum_size = dimensions
	control.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	control.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return control


static func letter_button(text: String, color: Color, font_size: int = 28) -> Button:
	var control: Button = button(text, color, font_size)
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var style: StyleBoxFlat = control.get_theme_stylebox(state) as StyleBoxFlat
		style.content_margin_top = 20.0
		style.content_margin_bottom = 2.0
	control.add_child(LetterFace.new())
	return control
