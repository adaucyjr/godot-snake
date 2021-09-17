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
	var ref_front
	for i in snake_body.size():
		if i == 0:
			ref_front = snake_direction
			if ref_front.x > 0:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(2,0))
			elif ref_front.x < 0:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(3,1))
			elif ref_front.y > 0:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(3,0))
			elif ref_front.y < 0:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(2,1))
		elif i == snake_body.size() - 1:
			ref_front = snake_body[i - 1]
			if ref_front.x > snake_body[i].x:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(0,0))
			elif ref_front.x < snake_body[i].x:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(1,0))
			elif ref_front.y > snake_body[i].y:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(0,1))
			elif ref_front.y < snake_body[i].y:
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(1,1))
		else:
			ref_front = ref_location(snake_body[i],snake_body[i - 1])
			var ref_back = ref_location(snake_body[i],snake_body[i + 1])
			if (ref_front == "right" && ref_back == "left") || (ref_front == "left" && ref_back == "right"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(4,0))
			if (ref_front == "up" && ref_back == "down") || (ref_front == "down" && ref_back == "up"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(4,1))
			if (ref_front == "right" && ref_back == "down") || (ref_front == "down" && ref_back == "right"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(5,0))
			if (ref_front == "right" && ref_back == "up") || (ref_front == "up" && ref_back == "right"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(5,1))
			if (ref_front == "down" && ref_back == "left") || (ref_front == "left" && ref_back == "down"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(6,0))
			if (ref_front == "up" && ref_back == "left") || (ref_front == "left" && ref_back == "up"):
				$TileMap.set_cell(snake_body[i].x,snake_body[i].y,SNAKE,false,false,false,Vector2(6,1))


func ref_location(blcok:Vector2,ref_position:Vector2):
	if blcok.x > ref_position.x: return "left"
	elif blcok.x < ref_position.x: return "right"
	elif blcok.y > ref_position.y: return "up"
	elif blcok.y < ref_position.y: return "down"

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
		$ScoreLabel.text = "Score: " + str(score)

func snake_die():
	var head = snake_body[0]
	var tail = snake_body.slice(1,snake_body.size() - 1)
	if tail.has(head):
		reset()
	elif head.x < 0 || head.x > 19 || head.y < 0 || head.y > 19:
		reset()

func reset():
	snake_body = [Vector2(5,10),Vector2(4,10),Vector2(3,10)]
	snake_direction = Vector2(1,0)
	if score > hi_score: hi_score = score
	$HiscoreLabel.text = "Hi-score: " + str(hi_score)
	score = 0
	$ScoreLabel.text = "Score: " + str(score)

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
	snake_die()
	draw_apple()
	draw_snake()
	eat_apple()
