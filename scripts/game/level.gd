extends Node2D
## Satu hari pengiriman: Masbro membawa paket dari gudang (bawah) ke rumah pelanggan (atas).

const TILE := 48.0
const COLUMNS := 15
const HUD_HEIGHT := 48.0
## Area di luar layar tempat kendaraan "berputar" sebelum muncul lagi.
const LOOP_MARGIN_TILES := 4
const HIT_INVULNERABLE_TIME := 1.2

enum State { INTRO, PLAYING, FINISHED }

## Kosongkan untuk memakai hari aktif dari GameState. Isi untuk mengetes hari tertentu.
@export var day: DayData

var state := State.INTRO
var damage := 0
var collisions := 0
var elapsed := 0.0

var _rows := 0
var _invulnerable_left := 0.0
var _board: Node2D
var _player: Player
var _vehicles: Array[Vehicle] = []
var _hud: GameHud


func _ready() -> void:
	# Level tetap jalan saat pause supaya bisa menerima tombol unpause;
	# isi papan (kendaraan & Masbro) yang ikut berhenti.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if day == null:
		day = GameState.current_day()
	_rows = day.lanes.size()

	_board = Node2D.new()
	_board.name = "Board"
	_board.position = Vector2(0, HUD_HEIGHT)
	_board.process_mode = Node.PROCESS_MODE_PAUSABLE
	_board.draw.connect(_draw_board)
	add_child(_board)
	_spawn_vehicles()
	_spawn_player()

	_hud = GameHud.new()
	add_child(_hud)
	_hud.setup(day)
	_hud.start_requested.connect(_on_start_requested)
	_hud.resume_requested.connect(_set_paused.bind(false))
	_hud.retry_requested.connect(_on_retry_requested)
	_hud.next_requested.connect(_on_next_requested)
	_hud.menu_requested.connect(_on_menu_requested)
	_hud.show_intro()


func _process(delta: float) -> void:
	if state != State.PLAYING or get_tree().paused:
		return
	elapsed += delta
	_hud.update_timer(day.eta_seconds - elapsed)

	if _invulnerable_left > 0.0:
		_invulnerable_left -= delta
		if _invulnerable_left <= 0.0:
			_player.invulnerable = false
		return
	var player_box := _player.hitbox()
	for vehicle in _vehicles:
		if vehicle.hitbox().intersects(player_box):
			_on_hit(vehicle)
			return


func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAYING and event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _spawn_vehicles() -> void:
	var margin := LOOP_MARGIN_TILES * TILE
	var loop_length := COLUMNS * TILE + margin
	for row in _rows:
		var lane := day.lanes[row]
		if lane.kind != LaneData.Kind.ROAD or lane.vehicle_count <= 0:
			continue
		var spacing := loop_length / lane.vehicle_count
		for i in lane.vehicle_count:
			var vehicle := Vehicle.new()
			vehicle.setup(lane.vehicle, TILE, lane.speed, lane.direction, -margin, loop_length)
			vehicle.position = Vector2(-margin + fposmod(lane.offset + i * spacing, loop_length), row * TILE)
			_board.add_child(vehicle)
			_vehicles.append(vehicle)


func _spawn_player() -> void:
	_player = Player.new()
	_player.tile = TILE
	_player.grid_size = Vector2i(COLUMNS, _rows)
	_player.step_time = day.package.step_time
	_player.package_color = day.package.color
	_player.place(Vector2i(floori(COLUMNS / 2.0), _rows - 1))
	_player.moved.connect(_on_player_moved)
	_board.add_child(_player)


func _on_start_requested() -> void:
	_hud.hide_overlay()
	state = State.PLAYING
	_player.input_enabled = true


func _set_paused(value: bool) -> void:
	get_tree().paused = value
	if value:
		_hud.show_pause()
	else:
		_hud.hide_overlay()


func _on_player_moved(cell: Vector2i) -> void:
	if state == State.PLAYING and cell.y == 0:
		_deliver()


func _on_hit(vehicle: Vehicle) -> void:
	collisions += 1
	damage = mini(damage + vehicle.damage * day.package.fragility, day.package.max_damage)
	_hud.update_package(damage)
	_shake()
	if damage >= day.package.max_damage:
		_fail()
		return
	_invulnerable_left = HIT_INVULNERABLE_TIME
	_player.invulnerable = true
	_player.knock_back(Vector2i(_player.cell.x, mini(_player.cell.y + 1, _rows - 1)))


func _deliver() -> void:
	state = State.FINISHED
	_player.input_enabled = false
	var report := DeliveryReport.evaluate(day, damage, collisions, elapsed)
	GameState.record_delivery(day, report.wage)
	_hud.show_result(report, GameState.has_next_day())


func _fail() -> void:
	state = State.FINISHED
	_player.input_enabled = false
	_player.invulnerable = false
	GameState.record_delivery(day, 0)
	_hud.show_failed()


func _shake() -> void:
	var rest := Vector2(0, HUD_HEIGHT)
	var tween := _board.create_tween()
	for i in 6:
		tween.tween_property(_board, "position", rest + Vector2(randf_range(-6, 6), randf_range(-6, 6)), 0.03)
	tween.tween_property(_board, "position", rest, 0.03)


func _on_retry_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_next_requested() -> void:
	if GameState.advance_day():
		get_tree().reload_current_scene()
	else:
		_on_menu_requested()


func _on_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _draw_board() -> void:
	# Placeholder latar sampai tileset dari Illustrator siap.
	var width := COLUMNS * TILE
	for row in _rows:
		var kind := day.lanes[row].kind
		var y := row * TILE
		if kind == LaneData.Kind.SIDEWALK:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("c9c2b3"))
			for col in COLUMNS:
				_board.draw_rect(Rect2(col * TILE, y, TILE, TILE), Color("b5ad9c"), false, 1.0)
		elif kind == LaneData.Kind.MEDIAN:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("7fb069"))
		else:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("4a4a52"))
			if row + 1 < _rows and day.lanes[row + 1].kind == LaneData.Kind.ROAD:
				var x := 8.0
				while x < width:
					_board.draw_line(Vector2(x, y + TILE), Vector2(x + 20, y + TILE), Color("d8d8d8"), 2.0)
					x += 40.0

	var font := ThemeDB.fallback_font
	var ink := Color("3b2f2f")
	_board.draw_string(font, Vector2(10, 30), "Rumah %s" % day.customer_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)
	_board.draw_string(font, Vector2(10, (_rows - 1) * TILE + 30), "Gudang Ngacir Express",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)
