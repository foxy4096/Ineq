extends Camera2D

# Set minimum and maximum zoom levels
var min_zoom = Vector2(0.5, 0.5)
var max_zoom = Vector2(2.4, 2.4)
var zoom_step = 0.1  # Amount to zoom in/out with each scroll

func _ready():
	# Set initial zoom level if needed
	zoom = Vector2(1, 1)

func _input(event):
	# Detect mouse wheel scrolling
	if event is InputEventMouseButton:
		# Zoom in when scrolling up
		if event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
			zoom -= Vector2(zoom_step, zoom_step)
			zoom.x = max(zoom.x, min_zoom.x)  # Clamp to minimum zoom
			zoom.y = max(zoom.y, min_zoom.y)

		# Zoom out when scrolling down
		elif event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
			zoom += Vector2(zoom_step, zoom_step)
			zoom.x = min(zoom.x, max_zoom.x)  # Clamp to maximum zoom
			zoom.y = min(zoom.y, max_zoom.y)
