extends Node

const SNAKE = 0
const APPLE = 1
var apple_pos
var snake_body = [Vector2(5,10),Vector2(4,10),Vector2(3,10)]
var snake_direction = Vector2(1,0)
var score = 0
var hi_score = 0

func _ready():
	apple_pos = place_apple()
	draw_apple()

func place_apple():
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	return Vector2(x,y)

func draw_apple():
	$TileMap.set_cell(apple_pos.x,apple_pos.y,APPLE)

func draw_snake():
	for block in snake_body:
		$TileMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(8,0))

func move_snake():
	delete_tiles(SNAKE)
	var body_copy = snake_body.slice(0, snake_body.size() -2)
	var new_head = body_copy[0] + snake_direction
	body_copy.insert(0,new_head)
	snake_body = body_copy

func delete_tiles(id:int):
	var cells = $TileMap.get_used_cells_by_id(id)
	for cell in cells:
		$TileMap.set_cell(cell.x,cell.y,-1)

func eat_apple():
	if apple_pos == snake_body[0]:
		$Crunch.play()
		apple_pos = place_apple()
		var new_tail = snake_body[snake_body.size() - 1] - snake_direction
		snake_body.append(new_tail)
		score += 1

func snake_die():
	var head = snake_body[0]
	var tail = snake_body.slice(1,snake_body.size() - 1)
	if tail.has(head):
		reset()
	elif head < Vector2(0,0) || head > Vector2(20,20):
		reset()

func reset():
	snake_body = [Vector2(5,10),Vector2(4,10),Vector2(3,10)]
	snake_direction = Vector2(1,0)
	score = 0

func _input(event):
	if Input.is_action_just_pressed("ui_up") && snake_direction.y == 0:
		snake_direction = Vector2(0,-1)
	if Input.is_action_just_pressed("ui_down") && snake_direction.y == 0:
		snake_direction = Vector2(0,1)
	if Input.is_action_just_pressed("ui_left") && snake_direction.x == 0:
		snake_direction = Vector2(-1,0)
	if Input.is_action_just_pressed("ui_right") && snake_direction.x == 0:
		snake_direction = Vector2(1,0)

func _on_GameTick_timeout():
	move_snake()
	draw_apple()
	draw_snake()
	eat_apple()
	snake_die()
