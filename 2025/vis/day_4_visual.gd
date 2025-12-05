extends Node2D

const mark_byte = ord('x')
const open_byte = ord('.')
const avil_byte = ord('@')

@export var marked := Color(0.9, 0.3, 0.2)
@export var open := Color(0.1, 0.1, 0.1)
@export var available := Color(0.4, 0.8, 0.4)
@export var done := Color(0.2, 0.2, 0.7)


@export var grid_size := Vector2i(32, 32)

var grid: Array[PackedByteArray]
var solved := false

func _draw() -> void:
	if not grid or grid.size() == 0:
		return
	var m := grid.size()
	var n := grid[0].size()

	for i in m:
		for j in n:
			var color: Color
			match grid[i][j]:
				mark_byte:
					color = marked
				open_byte:
					color = open
				avil_byte:
					color = done if solved else available

			var rect := Rect2(grid_size * Vector2i(j, i), grid_size)
			draw_rect(rect, color)
