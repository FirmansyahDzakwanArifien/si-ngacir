extends Node2D
## Satu hari pengiriman: Masbro membawa paket dari gudang (bawah) ke rumah pelanggan (atas).

const TILE := 48.0
const COLUMNS := 15
const HUD_HEIGHT := 48.0
## Area di luar layar tempat kendaraan "berputar" sebelum muncul lagi.
const LOOP_MARGIN_TILES := 4
const HIT_INVULNERABLE_TIME := 1.2
const CAT_SPAWN_DELAY := Vector2(2.5, 5.0)
const POPUP_COOLDOWN := 0.6

enum State { INTRO, PLAYING, FINISHED }

## Kosongkan untuk memakai hari aktif dari GameState. Isi untuk mengetes hari tertentu.
@export var day: DayData

var state := State.INTRO
var damage := 0
var collisions := 0
var elapsed := 0.0

var _rows := 0
## Posisi diam papan (papan di tengah layar; layar bisa lebih lebar/tinggi di HP).
var _board_rest := Vector2(0, HUD_HEIGHT)
## Menutup area di kiri/kanan papan supaya kendaraan di luar papan tidak terlihat.
var _side_mask: Node2D
var _invulnerable_left := 0.0
var _board: Node2D
var _player: Player
var _vehicles: Array[Vehicle] = []
var _cats: Array[StreetCat] = []
var _cat_timer := 1.5
var _popup_cooldown := 0.0
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
	_board.process_mode = Node.PROCESS_MODE_PAUSABLE
	_board.draw.connect(_draw_board)
	add_child(_board)
	_side_mask = Node2D.new()
	_side_mask.z_index = 50
	_side_mask.draw.connect(_draw_side_mask)
	add_child(_side_mask)
	_spawn_vehicles()
	_spawn_player()
	_layout_board()
	get_viewport().size_changed.connect(_layout_board)
	if day.rainy:
		var rain := RainOverlay.new()
		rain.area = Vector2(COLUMNS * TILE, _rows * TILE)
		rain.visibility_radius = day.visibility_tiles * TILE
		rain.target = _player
		rain.z_index = 10
		_board.add_child(rain)

	_hud = GameHud.new()
	add_child(_hud)
	_hud.setup(day)
	_hud.start_requested.connect(_on_start_requested)
	_hud.resume_requested.connect(_set_paused.bind(false))
	_hud.retry_requested.connect(_on_retry_requested)
	_hud.next_requested.connect(_on_next_requested)
	_hud.menu_requested.connect(_on_menu_requested)
	_hud.show_intro()
	var touch := TouchControls.new()
	touch.player = _player
	touch.board_rect = Rect2(Vector2.ZERO, Vector2(COLUMNS * TILE, _rows * TILE))
	add_child(touch)
	_hud.pause_pressed.connect(_on_pause_pressed)
	AudioManager.play_music(&"gameplay")


func _process(delta: float) -> void:
	if state != State.PLAYING or get_tree().paused:
		return
	elapsed += delta
	_hud.update_timer(day.eta_seconds - elapsed)

	_popup_cooldown = maxf(0.0, _popup_cooldown - delta)
	_update_cats(delta)

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
	_player.package_id = day.package.id
	_player.package_color = day.package.color
	_player.place(Vector2i(floori(COLUMNS / 2.0), _rows - 1))
	_player.can_enter = _is_cell_free
	_player.moved.connect(_on_player_moved)
	_player.blocked.connect(_on_player_blocked)
	_board.add_child(_player)


func _update_cats(delta: float) -> void:
	for i in range(_cats.size() - 1, -1, -1):
		if not is_instance_valid(_cats[i]):
			_cats.remove_at(i)
	if day.cat_count > 0:
		_cat_timer -= delta
		if _cat_timer <= 0.0:
			_cat_timer = randf_range(CAT_SPAWN_DELAY.x, CAT_SPAWN_DELAY.y)
			if _cats.size() < day.cat_count:
				_spawn_cat()
	var player_box := _player.hitbox()
	for cat in _cats:
		if cat.hitbox().intersects(player_box) and cat.notice_player():
			_popup("Meong?", Color("f4a259"), cat.position)


func _spawn_cat() -> void:
	# Kucing hanya menyeberang di jalan dan median, tidak di trotoar gudang/rumah.
	var rows: Array[int] = []
	for row in range(1, _rows - 1):
		if row != _player.cell.y:
			rows.append(row)
	if rows.is_empty():
		return
	var cat := StreetCat.new()
	cat.tile = TILE
	cat.board_width = COLUMNS * TILE
	cat.direction = 1 if randf() < 0.5 else -1
	cat.speed = randf_range(30.0, 55.0)
	cat.position = Vector2(-TILE if cat.direction > 0 else COLUMNS * TILE, rows.pick_random() * TILE)
	_board.add_child(cat)
	# Kucing di bawah Masbro supaya Masbro tetap terlihat.
	_board.move_child(cat, _player.get_index())
	_cats.append(cat)


func _is_cell_free(cell: Vector2i) -> bool:
	var area := Rect2(Vector2(cell) * TILE + Vector2(6, 6), Vector2(TILE - 12, TILE - 12))
	for cat in _cats:
		if is_instance_valid(cat) and cat.hitbox().intersects(area):
			return false
	return true


func _on_player_blocked(_cell: Vector2i) -> void:
	if _popup_cooldown <= 0.0:
		_popup("Meong!", Color("f4a259"), _player.position)
		AudioManager.play_sfx(&"meow", 0.1)


func _popup(text: String, color: Color, at: Vector2) -> void:
	_popup_cooldown = POPUP_COOLDOWN
	var label := Label.new()
	label.text = text
	label.position = at + Vector2(0, -20)
	label.z_index = 20
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	_board.add_child(label)
	var tween := label.create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 24.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func _on_start_requested() -> void:
	_hud.hide_overlay()
	state = State.PLAYING
	_player.input_enabled = true
	AudioManager.play_sfx(&"pickup")


func _set_paused(value: bool) -> void:
	get_tree().paused = value
	if value:
		_hud.show_pause()
	else:
		_hud.hide_overlay()


func _on_player_moved(cell: Vector2i) -> void:
	if state != State.PLAYING:
		return
	if cell.y == 0:
		_deliver()
		return
	var on_wet_road := day.rainy and day.lanes[cell.y].kind == LaneData.Kind.ROAD
	if on_wet_road and not _player.last_move_was_slide and not _player.invulnerable 			and randf() < day.slip_chance and _player.slide():
		_popup("Licin!", Color("8ecae6"), _player.position)
		AudioManager.play_sfx(&"slip")


func _on_hit(vehicle: Vehicle) -> void:
	collisions += 1
	damage = mini(damage + vehicle.damage * day.package.fragility, day.package.max_damage)
	_hud.update_package(damage)
	_shake()
	Effects.burst(_board, _player.position + Vector2(TILE / 2.0, TILE / 2.0), day.package.color)
	AudioManager.play_sfx(&"hit", 0.1)
	if damage >= day.package.max_damage:
		_fail()
		return
	AudioManager.play_sfx(&"package_damage", 0.05)
	_invulnerable_left = HIT_INVULNERABLE_TIME
	_player.invulnerable = true
	_player.knock_back(Vector2i(_player.cell.x, mini(_player.cell.y + 1, _rows - 1)))


func _deliver() -> void:
	state = State.FINISHED
	_player.input_enabled = false
	var report := DeliveryReport.evaluate(day, damage, collisions, elapsed)
	GameState.record_delivery(day, report.wage)
	AudioManager.play_sfx(&"delivery")
	_player.celebrate()
	# Konfeti di lapisan HUD supaya jatuh di depan kartu hasil.
	var view := get_viewport().get_visible_rect().size
	Effects.confetti(_hud, Vector2(view.x / 2.0, 0), view.x)
	_hud.show_result(report, _next_button_text())


func _fail() -> void:
	state = State.FINISHED
	_player.input_enabled = false
	_player.invulnerable = false
	GameState.record_delivery(day, 0)
	AudioManager.play_sfx(&"fail")
	_hud.show_failed(GameState.is_replay)


func _layout_board() -> void:
	var view := get_viewport().get_visible_rect().size
	_board_rest = Vector2(floorf(maxf(0.0, view.x - COLUMNS * TILE) / 2.0), HUD_HEIGHT)
	_board.position = _board_rest
	_side_mask.queue_redraw()


func _draw_side_mask() -> void:
	var view := get_viewport().get_visible_rect().size
	var color := ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color") as Color
	var right := _board_rest.x + COLUMNS * TILE
	if _board_rest.x > 0.0:
		_side_mask.draw_rect(Rect2(0, HUD_HEIGHT, _board_rest.x, view.y), color)
	if right < view.x:
		_side_mask.draw_rect(Rect2(right, HUD_HEIGHT, view.x - right, view.y), color)


func _on_pause_pressed() -> void:
	if state == State.PLAYING and not get_tree().paused:
		_set_paused(true)


func _shake() -> void:
	var rest := _board_rest
	var tween := _board.create_tween()
	for i in 6:
		tween.tween_property(_board, "position", rest + Vector2(randf_range(-6, 6), randf_range(-6, 6)), 0.03)
	tween.tween_property(_board, "position", rest, 0.03)


func _on_retry_requested() -> void:
	get_tree().paused = false
	Transition.reload()


func _next_button_text() -> String:
	if GameState.is_replay:
		return "Kembali ke Rekap"
	if GameState.has_next_day():
		return "Hari Berikutnya"
	return "Lihat Hasil Masa Percobaan"


func _on_next_requested() -> void:
	get_tree().paused = false
	if GameState.advance_day():
		GameState.play_story(GameState.current_day().story, GameState.LEVEL_SCENE)
	elif GameState.is_replay:
		Transition.change_scene(GameState.ENDING_SCENE)
	else:
		GameState.finish_probation()
		GameState.play_story(GameState.ending_story(), GameState.ENDING_SCENE)


func _on_menu_requested() -> void:
	get_tree().paused = false
	Transition.change_scene(GameState.MENU_SCENE)


func _draw_board() -> void:
	var width := COLUMNS * TILE
	var tiles := {
		LaneData.Kind.SIDEWALK: SpriteLibrary.texture("tile_sidewalk"),
		LaneData.Kind.ROAD: SpriteLibrary.texture("tile_road"),
		LaneData.Kind.MEDIAN: SpriteLibrary.texture("tile_median"),
	}
	for row in _rows:
		var kind := day.lanes[row].kind
		var y := row * TILE
		var tile_texture: Texture2D = tiles[kind]
		if tile_texture:
			for col in COLUMNS:
				_board.draw_texture_rect(tile_texture, Rect2(col * TILE, y, TILE, TILE), false)
			if kind == LaneData.Kind.ROAD:
				_draw_lane_marking(row)
		# Placeholder latar sampai tileset dari Illustrator siap.
		elif kind == LaneData.Kind.SIDEWALK:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("c9c2b3"))
			for col in COLUMNS:
				_board.draw_rect(Rect2(col * TILE, y, TILE, TILE), Color("b5ad9c"), false, 1.0)
		elif kind == LaneData.Kind.MEDIAN:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("7fb069"))
		else:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("4a4a52"))
			_draw_lane_marking(row)

	_draw_building("house", 0)
	_draw_building("warehouse", _rows - 1)
	var font := ThemeDB.fallback_font
	var ink := Color("3b2f2f")
	_board.draw_string(font, Vector2(10, 30), "Rumah %s" % day.customer_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)
	_board.draw_string(font, Vector2(10, (_rows - 1) * TILE + 30), "Gudang Ngacir Express",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)


func _draw_lane_marking(row: int) -> void:
	# Marka putus-putus di antara dua lane jalan.
	if row + 1 >= _rows or day.lanes[row + 1].kind != LaneData.Kind.ROAD:
		return
	var y := (row + 1) * TILE
	var x := 8.0
	while x < COLUMNS * TILE:
		_board.draw_line(Vector2(x, y), Vector2(x + 20, y), Color(1, 0.96, 0.86, 0.75), 3.0)
		x += 40.0


func _draw_building(sprite_name: String, row: int) -> void:
	var texture := SpriteLibrary.texture(sprite_name)
	if texture:
		var size := texture.get_size() / SpriteLibrary.density(sprite_name)
		_board.draw_texture_rect(texture,
				Rect2(Vector2(COLUMNS * TILE - size.x - 8, row * TILE + TILE - size.y), size), false)
