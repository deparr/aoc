extends Node2D

const dot = ord(".")
const ex = ord("x")

var input: PackedStringArray
var grid: Array[PackedByteArray] = []

@onready var visual: Node2D = %Grid


func _ready() -> void:
	var f := FileAccess.get_file_as_string("res://input/4")
	if f == "":
		push_error("unable to open file:", error_string(FileAccess.get_open_error()))
		return
	f = f.strip_edges()
	input = f.split("\n", false)

	%Solve.pressed.connect(_on_solve_pressed)


func _on_solve_pressed() -> void:
	grid.resize(input.size())
	for i in grid.size():
		grid[i] = input[i].strip_edges().to_ascii_buffer()

	visual.grid = grid
	visual.grid_size = get_viewport_rect().size / Vector2(float(grid[0].size()), float(grid.size()))
	visual.solved = false

	var res := await solve()
	print(res)


func count_accessible() -> int:
	var accessible := 0
	for i in grid.size():
		var row := grid[i]
		for j in row.size():
			var b := row[j]
			if b == dot:
				continue

			var blocked := 0

			if j > 0 and row[j - 1] != dot:
				blocked += 1;
			
			if j < row.size() - 1 and row[j + 1] != dot:
				blocked += 1;
			
			if i > 0 and grid[i - 1][j] != dot:
				blocked += 1;
			
			if i < grid.size() - 1 and grid[i + 1][j] != dot:
				blocked += 1;
			
			if j > 0 and i > 0 and grid[i - 1][j - 1] != dot:
				blocked += 1;
			
			if j > 0 and i < grid.size() - 1 and grid[i + 1][j - 1] != dot:
				blocked += 1;
			
			if j < row.size() - 1 and i > 0 and grid[i - 1][j + 1] != dot:
				blocked += 1;
			
			if j < row.size() - 1 and i < grid.size() - 1 and grid[i + 1][j + 1] != dot:
				blocked += 1;
						

			if blocked <= 3:
				accessible += 1
				grid[i][j] = ex


	return accessible


func clear_marked() -> void:
	for row in grid:
		for i in row.size():
			if row[i] == ex:
				row[i] = dot


func dump_grid() -> void:
	for row in grid:
		print(row.get_string_from_ascii())


func update_visual() -> void:
	visual.queue_redraw()


func solve() -> int:
	var accessible := 0
	var wait_time := 0.25
	while true:
		var newly_accessible = count_accessible()
		accessible += newly_accessible
		update_visual()
		await get_tree().create_timer(wait_time).timeout
		clear_marked()
		await get_tree().create_timer(wait_time).timeout
		if newly_accessible == 0:
			visual.solved = true
		update_visual()

		%Removed.text = "removed paper rolls: %d" % accessible
		wait_time = maxf(wait_time * 0.9, 0.08)

		if newly_accessible == 0:
			break
	
	%Done.text = "done!"
	return accessible
