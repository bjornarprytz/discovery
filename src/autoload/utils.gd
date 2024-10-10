extends Node

# Function to calculate relative luminance of an RGB color
func get_luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b

# Function to get contrast color (either black or white) based on luminance
func get_contrast_color(color: Color) -> Color:
	var luminance = get_luminance(color)
	
	# If luminance is higher than 0.5, return black, otherwise return white
	if luminance > 0.5:
		return Color(0, 0, 0) # Black
	else:
		return Color(1, 1, 1) # White

func random_color() -> Color:
	return Color(
		randf_range(0, 1),
		randf_range(0, 1),
		randf_range(0, 1)
	)
