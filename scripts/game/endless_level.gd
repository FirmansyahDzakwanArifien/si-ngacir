extends Node2D
## Mode Endless (Shift Lembur): jalanan terus menyambung ke atas tanpa putus (2D).
## Masbro berangkat dari Gudang (baris 0) menuju baris negatif (-1, -2, -3, ...) selamanya:
## ambil paket di kios -> antar ke trotoar pelanggan -> dapat skor, koin, dan tambahan waktu ETA
## -> langsung lanjut ke kios paket berikutnya dengan jenis paket & daerah yang berganti-ganti!

const TILE := 48.0
const COLUMNS := 15
const HUD_HEIGHT := 48.0
const GOAL_SIGN_X := 312.0
const LED_COLOR := Color("ffb347")
const HIT_STOP_SCALE := 0.15
const HIT_STOP_TIME := 0.07
const START_COLUMN := 7
const BASE_STEP_TIME := 0.12
const CAMERA_ANCHOR := 0.65
const CAMERA_SMOOTHING := 8.0
const LOOP_MARGIN_TILES := 4
const HIT_INVULNERABLE_TIME := 1.2
const CAT_SPAWN_DELAY := Vector2(2.5, 5.0)
const POPUP_COOLDOWN := 0.6
const SHOES_TIME := 8.0
const SHOES_SPEED := 0.6
const BLOCKERS := [&"cone", &"barrier", &"gerobak"]
const HONK_DISTANCE := 2.5 * 48.0
const HONK_COOLDOWN := 2.0
const RIVAL_SPEED := 300.0
const PEEL_TIME := 12.0
const BARK_RANGE := 1
const BARK_COOLDOWN := 6.0
const PANIC_TIME := 3.0
const PANIC_SLIP_CHANCE := 0.3
const RAFT_GRACE := 0.2 * 48.0
const RIVER_ALT_TINT := Color(0.72, 0.84, 1.0)
const PEDESTRIANS := [["pejalan_ibu_walk", "pejalan_ibu_idle"], ["pejalan_anak_walk", "pejalan_anak_idle"]]
const KOKO_PICKUP_FIRST := "Eh Masbro! Ambil paketnya dulu di kios samping sebelum lanjut ke atas!"
const KOKO_CARGO_CRITICAL := "WOI MASBRO! Isinya remuk tuh! Pelan-pelan dikit!"
const KOKO_TIME_LOW := "Waktu tipis, Masbro! Jangan ngelamun!"
const CARGO_CRITICAL_INTEGRITY := 0.34
const TIME_LOW_SECONDS := 12.0
## Batas mundur ke belakang (baris) dan jarak pembersihan baris lama di belakang kamera.
const BACK_LIMIT_ROWS := 9
const PRUNE_BEHIND_ROWS := 18
## Batas maksimal akumulasi timer ETA agar ritme arcade tetap menegangkan.
const MAX_ETA_CAP := 55.0

enum State { INTRO, PLAYING, FINISHED }

var state := State.INTRO
var damage := 0
var has_package := false
var order_coins := 0
var _time_left := 25.0

## Peta baris aktif: key = row (int, 0 = gudang, negatif ke atas).
var _lanes := {}
var _row_city := {}
var _row_vehicles := {}
var _row_items := {}
var _row_nodes := {}
var _dropoff_info := {}
var _min_generated_row := 0
var _max_active_row := 0
var _highest_row := 0
var _next_order_num := 1
var _last_gen_pkg := &""
var _last_gen_city := &""

## Antrean order aktif & berikutnya (indeks 0 = order yang sedang dijalankan sekarang).
var _orders: Array[Dictionary] = []

var _board: Node2D
var _side_mask: Node2D
var _player: Player
var _rain: RainOverlay
var _sunlight: Sunlight
var _hud: GameHud
var _voices: NpcVoiceDirector

var _board_rest := Vector2(0, HUD_HEIGHT)
var _scroll := 0.0
var _scroll_x := 0.0
var _view_height := 13 * TILE
var _view_rows := 13
var _shake_offset := Vector2.ZERO
var _invulnerable_left := 0.0
var _last_safe_cell := Vector2i(START_COLUMN, 0)
var _vehicles: Array[Vehicle] = []
var _rafts := {}
var _cats: Array[StreetCat] = []
var _cat_timer := 2.0
var _honk_cooldown := 0.0
var _rival_timer := 8.0
var _peels := {}
var _panic_left := 0.0
var _bark_cooldowns := {}
var _popup_cooldown := 0.0
var _boost_left := 0.0
var _collected := {}
var _koko_said_order := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.is_endless = true
	GameState.is_replay = false

	_board = Node2D.new()
	_board.name = "Board"
	_board.process_mode = Node.PROCESS_MODE_PAUSABLE
	_board.draw.connect(_draw_board)
	add_child(_board)

	_side_mask = Node2D.new()
	_side_mask.z_index = 50
	_side_mask.draw.connect(_draw_side_mask)
	add_child(_side_mask)

	_setup_voices()
	_init_depot_row()
	_spawn_player()
	_ensure_chunks_ahead()

	var first_order: Dictionary = _orders[0]
	var first_day: DayData = first_order["day"]
	_time_left = float(first_order["time_budget"])
	has_package = first_order["pickup_cell"].x < 0
	_player.carrying = has_package
	_player.set_package(first_day.package.id, first_day.package.color)
	_player.step_time = first_day.package.step_time if has_package else BASE_STEP_TIME

	_rain = RainOverlay.new()
	_rain.area = Vector2(COLUMNS * TILE, _view_height)
	_rain.visibility_radius = 5.5 * TILE
	_rain.target = _player
	_rain.z_index = 10
	_rain.visible = false
	_rain.set_process(false)
	_board.add_child(_rain)

	_sunlight = Sunlight.new()
	_sunlight.rainy = false
	add_child(_sunlight)

	_layout_board()
	get_viewport().size_changed.connect(_layout_board)
	_scroll = _camera_target()
	_scroll_x = _camera_target_x()
	_apply_board_position()

	_hud = GameHud.new()
	add_child(_hud)
	_hud.setup(first_day, true)
	_sync_hud_to_active_order()
	_hud.start_requested.connect(_on_start_requested)
	_hud.resume_requested.connect(_set_paused.bind(false))
	_hud.retry_requested.connect(_on_retry_requested)
	_hud.menu_requested.connect(_on_menu_requested)
	_hud.pause_pressed.connect(_on_pause_pressed)
	_hud.show_endless_intro(1, GameState.endless_score, GameState.endless_best_score)

	var touch := TouchControls.new()
	touch.player = _player
	add_child(touch)

	AudioManager.play_music(&"endless", &"gameplay_malam")


func _active_order() -> Dictionary:
	return _orders[0]


func _active_day() -> DayData:
	return _orders[0]["day"] as DayData


func _init_depot_row() -> void:
	var depot := LaneData.new()
	depot.kind = LaneData.Kind.SIDEWALK
	depot.vehicle_count = 0
	_lanes[0] = depot
	_row_city[0] = load("res://resources/cities/pasar.tres") as CityTheme
	_min_generated_row = 0
	_max_active_row = 0


func _ensure_chunks_ahead() -> void:
	while _orders.size() < 3:
		var chunk := EndlessGenerator.build_chunk(
				_next_order_num, _min_generated_row, START_COLUMN, _last_gen_pkg, _last_gen_city)
		var day: DayData = chunk["day"]
		_last_gen_pkg = day.package.id
		_last_gen_city = StringName(day.city.display_name)
		_next_order_num += 1
		_install_chunk(chunk)
		_orders.append(chunk)
	_board.queue_redraw()


func _install_chunk(chunk: Dictionary) -> void:
	var day: DayData = chunk["day"]
	var rows: Dictionary = chunk["rows"]
	var start_row: int = chunk["start_row"]
	var dropoff_row: int = chunk["dropoff_row"]
	var pickup_cell: Vector2i = chunk["pickup_cell"]

	for r: int in rows:
		var lane: LaneData = rows[r]
		_lanes[r] = lane
		_row_city[r] = day.city
		_spawn_row_vehicles(r, lane, day.rainy)
		_spawn_row_items(r, lane)
		_register_row_vendors(r, lane)

	_min_generated_row = dropoff_row

	# Simpan info rumah pelanggan di baris drop-off.
	_dropoff_info[dropoff_row] = {
		"order_num": chunk["order_num"],
		"customer_name": day.customer_name,
		"delivered": false,
	}

	# Spawn kios penjemputan (jika ada).
	if pickup_cell.x >= 0:
		_spawn_pickup_for_chunk(chunk)

	# Spawn pelanggan di depan rumah drop-off.
	_spawn_customer_for_chunk(chunk)

	# Spawn Pak Buldog di beberapa median segmen (bukan di baris titik jemput / drop-off).
	if day.buldog_count > 0:
		_spawn_buldogs_for_chunk(chunk, start_row, dropoff_row, pickup_cell.y)

	chunk["said_hurry"] = false
	chunk["said_late"] = false


func _spawn_row_vehicles(row: int, lane: LaneData, rainy: bool) -> void:
	if (lane.kind != LaneData.Kind.ROAD and lane.kind != LaneData.Kind.RIVER) or lane.vehicle_count <= 0:
		return
	var margin := LOOP_MARGIN_TILES * TILE
	var loop_length := COLUMNS * TILE + margin
	var spacing := loop_length / lane.vehicle_count
	var list: Array[Vehicle] = []
	for i in lane.vehicle_count:
		var vehicle := Vehicle.new()
		vehicle.setup(lane.vehicle, TILE, lane.speed, lane.direction, -margin, loop_length)
		vehicle.position = Vector2(-margin + fposmod(lane.offset + i * spacing, loop_length), row * TILE)
		vehicle.headlights = rainy
		_board.add_child(vehicle)
		if _player and is_instance_valid(_player):
			_board.move_child(vehicle, _player.get_index())
		_vehicles.append(vehicle)
		list.append(vehicle)
		if vehicle.is_platform:
			if not _rafts.has(row):
				_rafts[row] = []
			_rafts[row].append(vehicle)
	_row_vehicles[row] = list


func _spawn_row_items(row: int, lane: LaneData) -> void:
	if lane.items.is_empty():
		return
	var map := {}
	for col: int in lane.items:
		var type: StringName = lane.items[col]
		var node := SpriteLibrary.sprite("item_%s" % type)
		if node == null:
			continue
		var holder := Node2D.new()
		holder.position = Vector2(col, row) * TILE
		holder.add_child(node)
		_board.add_child(holder)
		if _player and is_instance_valid(_player):
			_board.move_child(holder, _player.get_index())
		var tween := node.create_tween().set_loops()
		tween.tween_property(node, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
		map[col] = holder
	_row_items[row] = map


func _register_row_vendors(row: int, lane: LaneData) -> void:
	var center := Vector2(TILE / 2.0, TILE / 2.0)
	for col: int in lane.obstacles:
		if lane.obstacles[col] == &"gerobak":
			var cell := Vector2i(col, row)
			_voices.track_point(&"vendor", Vector2(cell) * TILE + center, _vendor_say.bind(cell))


func _add_row_node(row: int, node: Node) -> void:
	if not _row_nodes.has(row):
		_row_nodes[row] = []
	_row_nodes[row].append(node)


func _spawn_pickup_for_chunk(chunk: Dictionary) -> void:
	var pickup_cell: Vector2i = chunk["pickup_cell"]
	var day: DayData = chunk["day"]
	var stall := Node2D.new()
	stall.name = "PickupStall_%d" % chunk["order_num"]
	stall.position = Vector2(pickup_cell) * TILE
	var sprite := SpriteLibrary.sprite("pickup_stall")
	if sprite:
		stall.add_child(sprite)
	_board.add_child(stall)
	if _player and is_instance_valid(_player):
		_board.move_child(stall, _player.get_index())
	_add_row_node(pickup_cell.y, stall)
	chunk["pickup_stall"] = stall

	var marker := Node2D.new()
	marker.z_index = 12
	marker.position = Vector2(pickup_cell) * TILE + Vector2(TILE / 2.0, -14.0)
	var icon := SpriteLibrary.sprite("package_%s" % day.package.id)
	if icon:
		icon.scale *= 1.6
		icon.position = -icon.texture.get_size() * icon.scale / 2.0
		marker.add_child(icon)
	var arrow := Polygon2D.new()
	arrow.polygon = PackedVector2Array([Vector2(-10, 14), Vector2(10, 14), Vector2(0, 25)])
	arrow.color = Palette.CORAL
	marker.add_child(arrow)
	var label := Label.new()
	label.text = tr("AMBIL PAKET!")
	label.add_theme_font_override("font", UiTheme.font(700))
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Palette.YELLOW)
	label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(110, 18)
	label.position = Vector2(-55, -32)
	marker.add_child(label)
	_board.add_child(marker)
	if not Accessibility.reduce_motion:
		var tween := marker.create_tween().set_loops()
		tween.tween_property(marker, "position:y", marker.position.y - 6.0, 0.45).set_trans(Tween.TRANS_SINE)
		tween.tween_property(marker, "position:y", marker.position.y, 0.45).set_trans(Tween.TRANS_SINE)
	_add_row_node(pickup_cell.y, marker)
	chunk["pickup_marker"] = marker

	var order_num: int = chunk["order_num"]
	_voices.track_node(&"sender", stall, Vector2(TILE / 2.0, TILE / 2.0),
			_stall_say.bind(stall, pickup_cell),
			func() -> bool: return not _orders.is_empty() and _orders[0]["order_num"] == order_num and not has_package)


func _spawn_customer_for_chunk(chunk: Dictionary) -> void:
	var day: DayData = chunk["day"]
	var dropoff_row: int = chunk["dropoff_row"]
	var cust := CustomerNpc.new()
	cust.customer_id = day.customer_id
	cust.tile = TILE
	var house := SpriteLibrary.texture("house")
	var house_width := house.get_width() / SpriteLibrary.density("house") if house else 0.0
	cust.position = Vector2(COLUMNS * TILE - house_width - 8.0 - TILE, dropoff_row * TILE)
	_board.add_child(cust)
	if _player and is_instance_valid(_player):
		_board.move_child(cust, _player.get_index())
	_add_row_node(dropoff_row, cust)
	chunk["customer"] = cust

	var order_num: int = chunk["order_num"]
	_voices.track_node(&"customer", cust, Vector2(TILE / 2.0, TILE / 2.0),
			func(text: String) -> void:
				if is_instance_valid(cust):
					cust.say(text),
			func() -> bool: return not _orders.is_empty() and _orders[0]["order_num"] == order_num and has_package and _time_left > 8.0)


func _spawn_buldogs_for_chunk(chunk: Dictionary, start_row: int, dropoff_row: int, pickup_row: int) -> void:
	var day: DayData = chunk["day"]
	var candidates: Array[int] = []
	for r in range(dropoff_row + 2, start_row - 1):
		if not _lanes.has(r) or r == pickup_row:
			continue
		var lane: LaneData = _lanes[r]
		if lane.kind == LaneData.Kind.MEDIAN:
			candidates.append(r)
	candidates.shuffle()
	for i in mini(day.buldog_count, candidates.size()):
		var r := candidates[i]
		var lane: LaneData = _lanes[r]
		var cols: Array[int] = []
		for col in range(1, COLUMNS - 1):
			if not lane.obstacles.has(col) and not lane.items.has(col):
				cols.append(col)
		if cols.is_empty():
			continue
		var dog := StreetCat.new()
		dog.kind = &"buldog"
		dog.walk_sprite = "buldog_sit"
		dog.idle_sprite = "buldog_bark"
		dog.tile = TILE
		dog.board_width = COLUMNS * TILE
		dog.speed = 0.0
		dog.direction = 1 if randf() < 0.5 else -1
		dog.position = Vector2(cols.pick_random(), r) * TILE
		_board.add_child(dog)
		if _player and is_instance_valid(_player):
			_board.move_child(dog, _player.get_index())
		_cats.append(dog)


func _spawn_player() -> void:
	_player = Player.new()
	_player.tile = TILE
	_player.grid_size = Vector2i(COLUMNS, 13)
	_player.min_row = -1000000
	_player.max_row = 0
	_player.step_time = BASE_STEP_TIME
	_player.carrying = false
	_player.place(Vector2i(START_COLUMN, 0))
	_last_safe_cell = _player.cell
	_player.can_enter = _is_cell_free
	_player.free_row = func(row: int) -> bool: return _lanes.has(row) and (_lanes[row] as LaneData).kind == LaneData.Kind.RIVER
	_player.moved.connect(_on_player_moved)
	_player.blocked.connect(_on_player_blocked)
	_board.add_child(_player)


func _setup_voices() -> void:
	_voices = NpcVoiceDirector.new()
	_voices.name = "NpcVoices"
	_voices.tile = TILE
	_voices.can_speak = AudioManager.can_play_voice
	_voices.speak_audio = AudioManager.play_voice
	add_child(_voices)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var smoothing := 1.0 - exp(-CAMERA_SMOOTHING * delta)
	_scroll = lerpf(_scroll, _camera_target(), smoothing)
	_scroll_x = lerpf(_scroll_x, _camera_target_x(), smoothing)
	_apply_board_position()
	if state != State.PLAYING:
		return

	_time_left -= delta
	_hud.update_timer(_time_left)
	_update_route_progress()
	if _time_left <= 0.0:
		_fail(true)
		return

	_popup_cooldown = maxf(0.0, _popup_cooldown - delta)
	_update_customer_reactions()
	_update_cats(delta)
	_update_buldogs(delta)
	_update_street_npcs(delta)
	_update_river(delta)
	_panic_left = maxf(0.0, _panic_left - delta)
	if _boost_left > 0.0:
		_boost_left -= delta
		if _boost_left <= 0.0:
			_player.speed_multiplier = 1.0

	if _invulnerable_left > 0.0:
		_invulnerable_left -= delta
		if _invulnerable_left <= 0.0:
			_player.invulnerable = false
		return

	var player_box := _player.hitbox()
	for vehicle in _vehicles:
		if is_instance_valid(vehicle) and not vehicle.is_platform and vehicle.hitbox().intersects(player_box):
			_on_hit(vehicle)
			return


func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAYING and event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _camera_target() -> float:
	var target := _player.position.y + TILE / 2.0 - _view_height * CAMERA_ANCHOR
	# Jangan menggulir melewati bagian bawah gudang (baris 0).
	var bottom_limit := TILE - _view_height
	return minf(target, bottom_limit)


func _camera_target_x() -> float:
	var view_width := get_viewport().get_visible_rect().size.x
	var board_width := COLUMNS * TILE
	if view_width >= board_width:
		return 0.0
	var target := _player.position.x + TILE / 2.0 - view_width / 2.0
	return clampf(target, 0.0, board_width - view_width)


func _apply_board_position() -> void:
	_board.position = _board_rest + Vector2(-roundf(_scroll_x), -roundf(_scroll)) + _shake_offset
	if _rain:
		_rain.position.y = roundf(_scroll)
	if _board_rest.x > 0.0:
		_side_mask.queue_redraw()
	_board.queue_redraw()


func _visible_row_range() -> Vector2i:
	var top_row := floori(_scroll / TILE) - 1
	var bottom_row := ceili((_scroll + _view_height) / TILE) + 1
	return Vector2i(top_row, bottom_row)


func _update_route_progress() -> void:
	var active := _active_order()
	var start_y: float = float(active["start_row"]) * TILE
	var end_y: float = float(active["dropoff_row"]) * TILE
	var span := maxf(TILE, start_y - end_y)
	var frac := (start_y - _player.position.y) / span
	_hud.update_progress(clampf(frac, 0.0, 1.0))


func _sync_hud_to_active_order() -> void:
	var active := _active_order()
	var day: DayData = active["day"]
	var start_r: int = active["start_row"]
	var end_r: int = active["dropoff_row"]
	var pickup_cell: Vector2i = active["pickup_cell"]
	var pickup_frac := -1.0
	if not has_package and pickup_cell.x >= 0:
		pickup_frac = float(start_r - pickup_cell.y) / maxf(1.0, float(start_r - end_r))
	_hud.set_endless_order(day, pickup_frac)
	_hud.update_score(GameState.endless_score)
	_hud.update_coins(GameState.wallet)


func _set_rain(enabled: bool) -> void:
	if _rain:
		_rain.visible = enabled
		_rain.set_process(enabled)
	if _sunlight:
		_sunlight.set_rainy(enabled)
	for v in _vehicles:
		if is_instance_valid(v):
			v.headlights = enabled


func _is_cell_free(cell: Vector2i) -> bool:
	if not _lanes.has(cell.y):
		return false
	var active := _active_order()
	var pickup_cell: Vector2i = active["pickup_cell"]
	if not has_package and pickup_cell.x >= 0 and cell.y < pickup_cell.y:
		return false
	var lane: LaneData = _lanes[cell.y]
	if lane.obstacles.get(cell.x, &"") in BLOCKERS:
		return false
	var area := Rect2(Vector2(cell) * TILE + Vector2(6, 6), Vector2(TILE - 12, TILE - 12))
	for cat in _cats:
		if is_instance_valid(cat) and cat.hitbox().intersects(area):
			return false
	return true


func _on_player_blocked(cell: Vector2i) -> void:
	var active := _active_order()
	var pickup_cell: Vector2i = active["pickup_cell"]
	if not has_package and pickup_cell.x >= 0 and cell.y < pickup_cell.y:
		if _popup_cooldown <= 0.0:
			var arrow := "<- " if pickup_cell.x < _player.cell.x else "-> "
			_popup(arrow + tr("Ambil paket di kios dulu!"), Palette.YELLOW, _player.position)
			AudioManager.play_sfx(&"horn", 0.08)
		_koko_say(&"pickup_first", KOKO_PICKUP_FIRST)
		return
	if _popup_cooldown > 0.0 or not _lanes.has(cell.y):
		return
	var lane: LaneData = _lanes[cell.y]
	var obstacle: StringName = lane.obstacles.get(cell.x, &"")
	if obstacle == &"gerobak":
		_popup("Bakso, Mas?", Palette.CORAL, _player.position)
	elif obstacle in BLOCKERS:
		_popup("Awas!", Palette.ORANGE, _player.position)
	elif _walker_at(cell) and _walker_at(cell).kind == &"pedestrian":
		_popup("Permisi, Mas!", Palette.CORAL, _player.position)
	elif _walker_at(cell) and _walker_at(cell).kind == &"buldog":
		_popup("GRRR!", Palette.ORANGE, _player.position)
	else:
		_popup("Meong!", Color("f4a259"), _player.position)
		AudioManager.play_sfx(&"meow_2", 0.1)


func _on_player_moved(cell: Vector2i) -> void:
	if state != State.PLAYING or not _lanes.has(cell.y):
		return

	if cell.y < _highest_row:
		_highest_row = cell.y
		_player.max_row = mini(0, _highest_row + BACK_LIMIT_ROWS)
		_prune_behind()

	var active := _active_order()
	var dropoff_row: int = active["dropoff_row"]
	var pickup_cell: Vector2i = active["pickup_cell"]

	# Sampai di baris pelanggan -> selesaikan order saat ini & langsung lanjut ke atas!
	if has_package and cell.y <= dropoff_row:
		_deliver_current_order()
		return

	var lane: LaneData = _lanes[cell.y]
	if lane.kind == LaneData.Kind.RIVER:
		var raft := _raft_under_player()
		if raft == null:
			_splash()
		else:
			_keep_on_raft(raft)
		return

	_last_safe_cell = cell
	if not has_package and cell == pickup_cell:
		_pick_up_active_package()
	elif not has_package and cell.y == pickup_cell.y and _popup_cooldown <= 0.0:
		var dir_hint := tr("<- Kios paket di kiri!") if pickup_cell.x < cell.x else tr("Kios paket di kanan! ->")
		_popup(dir_hint, Palette.YELLOW, _player.position)

	_collect_item(cell)

	if lane.obstacles.get(cell.x, &"") == &"hole" and not _player.invulnerable:
		_on_hole()
		return
	if _peels.has(cell) and not _player.last_move_was_slide:
		_remove_peel(cell, _peels[cell])
		if not _player.invulnerable and _player.slide():
			_popup("Kulit pisang!", Palette.YELLOW, _player.position)
			Effects.spray(_board, _player.position + Vector2(TILE / 2.0, TILE - 4.0), Vector2(_player.last_direction))
			AudioManager.play_sfx(&"slip")
			return

	var day := _active_day()
	var on_road := lane.kind == LaneData.Kind.ROAD
	var slip_chance := day.slip_chance if day.rainy else 0.0
	if _panic_left > 0.0:
		slip_chance = maxf(slip_chance, PANIC_SLIP_CHANCE)
	if on_road and not _player.last_move_was_slide and not _player.invulnerable \
			and randf() < slip_chance and _player.slide():
		_popup("Licin!", Color("8ecae6"), _player.position)
		Effects.spray(_board, _player.position + Vector2(TILE / 2.0, TILE - 4.0), Vector2(_player.last_direction))
		AudioManager.play_sfx(&"slip")


func _pick_up_active_package() -> void:
	var active := _active_order()
	var day: DayData = active["day"]
	has_package = true
	damage = 0
	_player.set_package(day.package.id, day.package.color)
	_player.step_time = day.package.step_time
	_player.receive_package()
	var marker: Node2D = active.get("pickup_marker")
	if is_instance_valid(marker):
		marker.queue_free()
		active["pickup_marker"] = null
	AudioManager.play_sfx(&"delivery", 0.05)
	var bonus := EndlessGenerator.package_bonus(day.package)
	var note := tr("Paket diambil!") if bonus == 0 else tr("%s! (+%d bonus)") % [tr(day.package.display_name), bonus]
	_popup(note, Palette.TEAL, _player.position)
	var stall: Node2D = active.get("pickup_stall")
	if is_instance_valid(stall):
		for child in stall.get_children():
			if child is SpeechBubble:
				child.queue_free()
		_stall_say(day.sender_line, stall, active["pickup_cell"])
	_hud.set_package_hud(day.package, 0)
	_hud.set_objective_delivery()
	var cust: CustomerNpc = active.get("customer")
	if is_instance_valid(cust):
		cust.set_mood(CustomerNpc.Mood.WAITING)
	_board.queue_redraw()


func _deliver_current_order() -> void:
	var completed := _active_order()
	var day: DayData = completed["day"]
	var order_num: int = completed["order_num"]
	var integrity := 1.0 - float(damage) / maxf(1.0, float(day.package.max_damage))
	var score_data := EndlessGenerator.evaluate_order(order_num, day.package, integrity, _time_left, order_coins)
	var broke := GameState.record_endless_delivery(score_data["total"], order_coins, score_data["streak_coins"])
	order_coins = 0

	# Tandai rumah ini selesai & rayakan di pelanggan tanpa mem-pause permainan.
	var dropoff_row: int = completed["dropoff_row"]
	if _dropoff_info.has(dropoff_row):
		_dropoff_info[dropoff_row]["delivered"] = true
	var cust: CustomerNpc = completed.get("customer")
	if is_instance_valid(cust):
		cust.set_mood(CustomerNpc.Mood.HAPPY)
		cust.say("Makasih, Masbro!", 2.2)

	AudioManager.play_sfx(&"delivery")
	var view := get_viewport().get_visible_rect().size
	if not Accessibility.reduce_motion:
		Effects.confetti(_hud, Vector2(view.x / 2.0, 0), view.x)

	# Lanjut langsung ke order berikutnya di depan!
	_orders.pop_front()
	_ensure_chunks_ahead()
	var next_order := _active_order()
	var next_day: DayData = next_order["day"]
	GameState.endless_order = next_order["order_num"]

	# Tambahan waktu (Time Extension) sesuai jarak order berikutnya.
	var time_add := maxf(12.0, roundf(float(next_order["time_budget"]) * 0.85))
	_time_left = minf(MAX_ETA_CAP, _time_left + time_add)

	has_package = next_order["pickup_cell"].x < 0
	damage = 0
	_koko_said_order.clear()
	_player.carrying = has_package
	_player.step_time = next_day.package.step_time if has_package else BASE_STEP_TIME
	if has_package:
		_player.set_package(next_day.package.id, next_day.package.color)

	_set_rain(next_day.rainy)
	_sync_hud_to_active_order()
	_hud.update_timer(_time_left)

	var banner_title := tr("ORDER #%d SELESAI!  +%d pts  ·  +%d dtk  ·  +%d koin") % [
			order_num, score_data["total"], roundi(time_add), score_data["streak_coins"]]
	if broke:
		banner_title = tr("REKOR BARU!") + "  " + banner_title
	var pkg_bonus := EndlessGenerator.package_bonus(next_day.package)
	var banner_sub := tr("Berikutnya: %s → %s") % [tr(next_day.package.display_name), next_day.customer_name]
	if pkg_bonus > 0:
		banner_sub += "  " + tr("(Bonus paket +%d)") % pkg_bonus
	_hud.show_banner(banner_title, banner_sub, Palette.YELLOW_DARK if broke else Palette.TEAL)
	_popup(tr("+%d pts · +%d dtk!") % [score_data["total"], roundi(time_add)], Palette.TEAL, _player.position)
	_board.queue_redraw()


func _prune_behind() -> void:
	var cutoff := _highest_row + PRUNE_BEHIND_ROWS
	while _max_active_row > cutoff:
		var r := _max_active_row
		_max_active_row -= 1
		if _row_vehicles.has(r):
			for v: Vehicle in _row_vehicles[r]:
				_vehicles.erase(v)
				if is_instance_valid(v):
					v.queue_free()
			_row_vehicles.erase(r)
		_rafts.erase(r)
		if _row_items.has(r):
			for holder: Node2D in _row_items[r].values():
				if is_instance_valid(holder):
					holder.queue_free()
			_row_items.erase(r)
		if _row_nodes.has(r):
			for n: Node in _row_nodes[r]:
				if is_instance_valid(n):
					n.queue_free()
			_row_nodes.erase(r)
		for cell: Vector2i in _peels.keys():
			if cell.y == r:
				var p: Node = _peels[cell]
				_peels.erase(cell)
				if is_instance_valid(p):
					p.queue_free()
		for cell: Vector2i in _collected.keys():
			if cell.y == r:
				_collected.erase(cell)
		_lanes.erase(r)
		_row_city.erase(r)
		_dropoff_info.erase(r)

	for i in range(_cats.size() - 1, -1, -1):
		var c := _cats[i]
		if not is_instance_valid(c) or roundi(c.position.y / TILE) > cutoff:
			if is_instance_valid(c):
				c.queue_free()
			_cats.remove_at(i)


func _collect_item(cell: Vector2i) -> void:
	var lane: LaneData = _lanes[cell.y]
	if not lane.items.has(cell.x) or _collected.has(cell):
		return
	_collected[cell] = true
	var type: StringName = lane.items[cell.x]
	if _row_items.has(cell.y) and _row_items[cell.y].has(cell.x):
		var node: Node2D = _row_items[cell.y][cell.x]
		_row_items[cell.y].erase(cell.x)
		if is_instance_valid(node):
			var tween := node.create_tween()
			tween.set_parallel()
			tween.tween_property(node, "position:y", node.position.y - 30.0, 0.3)
			tween.tween_property(node, "modulate:a", 0.0, 0.3)
			tween.chain().tween_callback(node.queue_free)
	match type:
		&"coin":
			AudioManager.play_sfx(&"coin", 0.12)
			order_coins += 1
			GameState.add_coins(1, false)
			_hud.update_coins(GameState.wallet)
			_popup(tr("+1 koin"), Palette.YELLOW, _player.position)
		&"helmet":
			AudioManager.play_sfx(&"powerup", 0.08)
			_player.shielded = true
			_popup("Helm! Kebal 1x", Palette.TEAL, _player.position)
		&"shoes":
			AudioManager.play_sfx(&"powerup", 0.08)
			_boost_left = SHOES_TIME
			_player.speed_multiplier = SHOES_SPEED
			_popup("Sepatu kilat!", Palette.CORAL, _player.position)


func _update_river(delta: float) -> void:
	if _player.is_moving() or not _lanes.has(_player.cell.y):
		return
	if (_lanes[_player.cell.y] as LaneData).kind != LaneData.Kind.RIVER:
		return
	var raft := _raft_under_player()
	if raft == null:
		_splash()
		return
	_player.ride(raft.speed * raft.direction * delta)
	_keep_on_raft(raft)
	var center := _player.position.x + TILE / 2.0
	if center < 0.0 or center > COLUMNS * TILE:
		_splash()


func _raft_under_player() -> Vehicle:
	var x := _player.position.x + TILE / 2.0
	for raft: Vehicle in _rafts.get(_player.cell.y, []):
		if is_instance_valid(raft) and x >= raft.position.x - RAFT_GRACE and x <= raft.position.x + raft.length_px + RAFT_GRACE:
			return raft
	return null


func _keep_on_raft(raft: Vehicle) -> void:
	var left := raft.position.x
	var right := raft.position.x + raft.length_px - TILE
	var x := clampf(_player.position.x, left, maxf(left, right))
	if not is_equal_approx(x, _player.position.x):
		_player.ride(x - _player.position.x)


func _splash() -> void:
	var at := _player.position + Vector2(TILE / 2.0, TILE * 0.7)
	Effects.splash(_board, at)
	Effects.ripples(_board, at)
	Effects.bubbles(_board, at)
	Effects.impact(_board, at + Vector2(TILE * 0.8, -TILE * 0.2), "BYUR!", Palette.SKY_DEEP)
	_player.plop()
	AudioManager.play_sfx(&"splash", 0.1)
	if _player.invulnerable:
		_player.knock_back(_last_safe_cell)
		return
	_popup("Paket basah!" if has_package else "Basah kuyup!", Palette.SKY_DEEP, _player.position)
	_damage_package(1, _last_safe_cell)


func _on_hit(vehicle: Vehicle) -> void:
	var back := Vector2i(_player.cell.x, mini(_player.cell.y + 1, _player.max_row))
	var center := _player.position + Vector2(TILE / 2.0, TILE / 2.0)
	var side := -1.0 if vehicle.position.x + vehicle.length_px / 2.0 < center.x else 1.0
	Effects.impact(_board, center + Vector2(side * TILE * 0.35, -6), "BRAK!", Palette.YELLOW)
	_hit_stop()
	_flash()
	_damage_package(vehicle.damage, back)
	_player.tumble()


func _on_hole() -> void:
	_popup("Lubang!", Palette.ORANGE, _player.position)
	var at := _player.position + Vector2(TILE / 2.0, TILE - 6.0)
	Effects.dust(_board, at)
	Effects.dust(_board, at + Vector2(0, -8))
	Effects.gravel(_board, at, -1)
	Effects.gravel(_board, at, 1)
	Effects.impact(_board, at + Vector2(TILE * 0.9, -TILE * 0.3), "GEDEBUK!", Palette.ORANGE)
	_damage_package(1, _player.cell - _player.last_direction)


func _damage_package(amount: int, knock_to: Vector2i) -> void:
	knock_to = Vector2i(clampi(knock_to.x, 0, COLUMNS - 1), mini(knock_to.y, _player.max_row))
	if not _is_cell_free(knock_to):
		knock_to = _player.cell
	_shake()
	_invulnerable_left = HIT_INVULNERABLE_TIME
	_player.invulnerable = true
	if _player.shielded:
		_player.shielded = false
		AudioManager.vibrate(30)
		_popup("Helm melindungi!", Palette.TEAL, _player.position)
		var head := _player.position + Vector2(TILE / 2.0, TILE * 0.3)
		Effects.shards(_board, head, Palette.TEAL)
		Effects.impact(_board, head + Vector2(-TILE * 0.8, 0), "TENG!", Palette.TEAL)
		AudioManager.play_sfx(&"hit", 0.1)
		_player.knock_back(knock_to)
		return
	if not has_package:
		AudioManager.play_sfx(&"hit", 0.1)
		AudioManager.vibrate(60)
		_popup("Untung paketnya belum diambil!", Palette.YELLOW, _player.position)
		_player.knock_back(knock_to)
		return
	var pkg := _active_day().package
	damage = mini(damage + amount * pkg.fragility, pkg.max_damage)
	_hud.update_package(damage)
	if damage < pkg.max_damage and 1.0 - float(damage) / pkg.max_damage <= CARGO_CRITICAL_INTEGRITY:
		_koko_say(&"cargo_critical", KOKO_CARGO_CRITICAL)
	Effects.burst(_board, _player.position + Vector2(TILE / 2.0, TILE / 2.0), pkg.color)
	AudioManager.play_sfx(&"hit", 0.1)
	if damage >= pkg.max_damage:
		AudioManager.vibrate(300)
		var center := _player.position + Vector2(TILE / 2.0, TILE / 2.0)
		Effects.smoke(_board, center)
		Effects.burst(_board, center, pkg.color)
		Effects.impact(_board, center + Vector2(-TILE * 0.8, 0), "KRAK!", Palette.CORAL)
		_invulnerable_left = 0.0
		_player.invulnerable = false
		_fail(false)
		return
	AudioManager.play_sfx(&"package_damage", 0.05)
	AudioManager.vibrate(80 + 40 * amount)
	_player.knock_back(knock_to)


func _fail(timed_out: bool) -> void:
	state = State.FINISHED
	_player.input_enabled = false
	_player.invulnerable = false
	GameState.finish_endless_run(order_coins)
	order_coins = 0
	AudioManager.stop_voices()
	AudioManager.play_sfx(&"fail")
	var cust: CustomerNpc = _active_order().get("customer")
	if is_instance_valid(cust):
		cust.set_mood(CustomerNpc.Mood.SAD)
		cust.say("Yah, waktunya habis..." if timed_out else "Yah... paketnya...", 0.0)
	_hud.show_endless_game_over(timed_out, GameState.endless_delivered, GameState.endless_score,
			GameState.endless_best_score, GameState.endless_best_orders,
			GameState.endless_coins, GameState.endless_new_record)


func _update_customer_reactions() -> void:
	var active := _active_order()
	var day: DayData = active["day"]
	var cust: CustomerNpc = active.get("customer")
	if _time_left <= 10.0 and not active["said_hurry"]:
		active["said_hurry"] = true
		if is_instance_valid(cust):
			cust.say(day.customer_hurry_line)
			cust.set_mood(CustomerNpc.Mood.IMPATIENT)
	if _time_left <= TIME_LOW_SECONDS and has_package:
		_koko_say(&"time_low", KOKO_TIME_LOW)


func _update_cats(delta: float) -> void:
	for i in range(_cats.size() - 1, -1, -1):
		if not is_instance_valid(_cats[i]):
			_cats.remove_at(i)
	var day := _active_day()
	if day.cat_count > 0 or day.pedestrian_count > 0:
		_cat_timer -= delta
		if _cat_timer <= 0.0:
			_cat_timer = randf_range(CAT_SPAWN_DELAY.x, CAT_SPAWN_DELAY.y)
			var cats := _cats.filter(func(w: StreetCat) -> bool: return w.kind == &"cat").size()
			var walkers := _cats.filter(func(w: StreetCat) -> bool: return w.kind == &"pedestrian").size()
			var want_walker := walkers < day.pedestrian_count and (cats >= day.cat_count or randf() < 0.5)
			if want_walker:
				_spawn_cat(&"pedestrian")
			elif cats < day.cat_count:
				_spawn_cat(&"cat")
	var player_box := _player.hitbox()
	for cat in _cats:
		if cat.kind != &"buldog" and cat.hitbox().intersects(player_box) and cat.notice_player():
			_popup("Meong?" if cat.kind == &"cat" else "Eh, maaf!", Color("f4a259"), cat.position)


func _spawn_cat(kind: StringName) -> void:
	var vis := _visible_row_range()
	var pickup_row: int = _active_order()["pickup_cell"].y
	var rows: Array[int] = []
	for r in range(vis.x, vis.y + 1):
		if not _lanes.has(r) or r == _player.cell.y or r == pickup_row or _dropoff_info.has(r) or r == 0:
			continue
		var lane_kind: LaneData.Kind = (_lanes[r] as LaneData).kind
		var allowed := lane_kind == LaneData.Kind.MEDIAN or (kind == &"cat" and lane_kind == LaneData.Kind.ROAD)
		if allowed:
			rows.append(r)
	if rows.is_empty():
		return
	var cat := StreetCat.new()
	cat.kind = kind
	if kind == &"pedestrian":
		var look: Array = PEDESTRIANS.pick_random()
		cat.walk_sprite = look[0]
		cat.idle_sprite = look[1]
	cat.tile = TILE
	cat.board_width = COLUMNS * TILE
	cat.direction = 1 if randf() < 0.5 else -1
	cat.speed = randf_range(30.0, 55.0) if kind == &"cat" else randf_range(22.0, 38.0)
	cat.position = Vector2(-TILE if cat.direction > 0 else COLUMNS * TILE, rows.pick_random() * TILE)
	_board.add_child(cat)
	_board.move_child(cat, _player.get_index())
	_cats.append(cat)
	_voices.track_node(kind, cat, Vector2(TILE / 2.0, TILE / 2.0), _walker_say.bind(cat))


func _update_buldogs(delta: float) -> void:
	for dog in _cats:
		if not is_instance_valid(dog) or dog.kind != &"buldog":
			continue
		var cooldown: float = maxf(0.0, _bark_cooldowns.get(dog, 0.0) - delta)
		_bark_cooldowns[dog] = cooldown
		var dog_cell := Vector2i(roundi(dog.position.x / TILE), roundi(dog.position.y / TILE))
		var gap := (_player.cell - dog_cell).abs()
		if cooldown > 0.0 or maxi(gap.x, gap.y) > BARK_RANGE:
			continue
		_bark_cooldowns[dog] = BARK_COOLDOWN
		dog.notice_player()
		_npc_say(dog, "GUK! GUK!", Vector2(TILE / 2.0, 6))
		AudioManager.play_sfx(&"bark", 0.1)
		_shake()
		_panic_left = PANIC_TIME
		_boost_left = maxf(_boost_left, PANIC_TIME)
		_player.speed_multiplier = SHOES_SPEED
		_popup("Panik! Ngacir!", Palette.ORANGE, _player.position)


func _update_street_npcs(delta: float) -> void:
	_voices.tick(delta, _player.position + Vector2(TILE / 2.0, TILE / 2.0))
	_honk_cooldown = maxf(0.0, _honk_cooldown - delta)
	var row := _player.cell.y
	if _honk_cooldown <= 0.0 and _lanes.has(row) and (_lanes[row] as LaneData).kind == LaneData.Kind.ROAD:
		for vehicle in _vehicles:
			if not is_instance_valid(vehicle) or vehicle.is_platform or vehicle.type == &"kuro":
				continue
			if roundi(vehicle.position.y / TILE) != row:
				continue
			var gap := _player.position.x - (vehicle.position.x + vehicle.length_px) if vehicle.direction > 0 \
					else vehicle.position.x - (_player.position.x + TILE)
			if gap >= 0.0 and gap <= HONK_DISTANCE:
				_honk_cooldown = HONK_COOLDOWN
				_npc_say(vehicle, "Tin tin!", Vector2(vehicle.length_px / 2.0, 6))
				var horn_sfx := &"horn"
				if vehicle.type in [&"truk", &"bus"]:
					horn_sfx = &"horn_truck"
				elif vehicle.type in [&"mobil", &"angkot"]:
					horn_sfx = &"horn_car"
				AudioManager.play_sfx(horn_sfx, 0.08)
				break

	var day := _active_day()
	if day.rival_interval > 0.0:
		for i in range(_vehicles.size() - 1, -1, -1):
			if not is_instance_valid(_vehicles[i]):
				_vehicles.remove_at(i)
		_rival_timer -= delta
		if _rival_timer <= 0.0:
			_rival_timer = day.rival_interval * randf_range(0.8, 1.2)
			_spawn_rival()


func _spawn_rival() -> void:
	var vis := _visible_row_range()
	var rows: Array[int] = []
	for r in range(vis.x, _player.cell.y + 1):
		if _lanes.has(r) and (_lanes[r] as LaneData).kind == LaneData.Kind.ROAD:
			rows.append(r)
	if rows.is_empty():
		return
	var day := _active_day()
	var rival := Vehicle.new()
	var direction := 1 if randf() < 0.5 else -1
	var row: int = rows.pick_random()
	rival.setup(&"kuro", TILE, RIVAL_SPEED, direction, -TILE * 2.0, COLUMNS * TILE + TILE * 4.0)
	rival.one_shot = true
	rival.headlights = day.rainy
	rival.position = Vector2(-TILE * 2.0 if direction > 0 else COLUMNS * TILE + TILE, row * TILE)
	_board.add_child(rival)
	_vehicles.append(rival)
	_npc_say(rival, "Minggir, kapibara!", Vector2(TILE / 2.0, 6))
	AudioManager.play_sfx(&"horn", 0.15)
	if randf() < day.peel_chance:
		_drop_peel(row, rival.position.x)


func _drop_peel(row: int, start_x: float) -> void:
	if not _lanes.has(row):
		return
	var lane: LaneData = _lanes[row]
	var cols: Array[int] = []
	for col in COLUMNS:
		var cell := Vector2i(col, row)
		if cell != _player.cell and not _peels.has(cell) and lane.obstacles.get(col, &"") == &"":
			cols.append(col)
	if cols.is_empty():
		return
	var col: int = cols.pick_random()
	var delay := absf(col * TILE - start_x) / RIVAL_SPEED
	get_tree().create_timer(delay, false).timeout.connect(_place_peel.bind(Vector2i(col, row)))


func _place_peel(cell: Vector2i) -> void:
	if state != State.PLAYING or not _lanes.has(cell.y) or _peels.has(cell) or cell == _player.cell:
		return
	var holder := Node2D.new()
	holder.name = "Peel"
	holder.position = Vector2(cell) * TILE
	var node := SpriteLibrary.sprite("item_kulit_pisang")
	if node:
		holder.add_child(node)
	_board.add_child(holder)
	_board.move_child(holder, _player.get_index())
	_peels[cell] = holder
	get_tree().create_timer(PEEL_TIME, false).timeout.connect(_remove_peel.bind(cell, holder))


func _remove_peel(cell: Vector2i, holder: Node2D) -> void:
	if _peels.get(cell) == holder:
		_peels.erase(cell)
	if is_instance_valid(holder):
		var tween := holder.create_tween()
		tween.tween_property(holder, "modulate:a", 0.0, 0.25)
		tween.tween_callback(holder.queue_free)


func _walker_at(cell: Vector2i) -> StreetCat:
	var area := Rect2(Vector2(cell) * TILE + Vector2(6, 6), Vector2(TILE - 12, TILE - 12))
	for walker in _cats:
		if is_instance_valid(walker) and walker.hitbox().intersects(area):
			return walker
	return null


func _vendor_say(text: String, cell: Vector2i) -> void:
	if not _lanes.has(cell.y):
		return
	var bubble := _npc_say(_board, text, Vector2(cell) * TILE + Vector2(TILE / 2.0, 6))
	bubble.get_parent().move_child(bubble, -1)


func _stall_say(text: String, stall: Node2D, cell: Vector2i) -> void:
	if not is_instance_valid(stall):
		return
	if cell.x >= COLUMNS / 2:
		_npc_say(stall, text, Vector2(4.0, 14.0), SpeechBubble.Side.LEFT)
	else:
		_npc_say(stall, text, Vector2(TILE - 4.0, 14.0), SpeechBubble.Side.RIGHT)


func _walker_say(text: String, walker: Node2D) -> void:
	if is_instance_valid(walker) and walker is StreetCat and (walker as StreetCat).kind == &"pedestrian":
		_npc_say(walker, text, Vector2(TILE / 2.0, 6))


func _npc_say(owner: Node2D, text: String, offset: Vector2, side := SpeechBubble.Side.ABOVE) -> SpeechBubble:
	var bubble := SpeechBubble.new()
	bubble.side = side
	bubble.position = offset
	owner.add_child(bubble)
	bubble.say(text, 2.2)
	var bubble_id := bubble.get_instance_id()
	get_tree().create_timer(2.4, false).timeout.connect(func() -> void:
		var node := instance_from_id(bubble_id) as Node
		if node:
			node.queue_free())
	return bubble


func _koko_say(id: StringName, text: String) -> void:
	if _koko_said_order.has(id):
		return
	_koko_said_order[id] = true
	_hud.show_radio(tr(text))


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
	var width := label.get_minimum_size().x
	label.position.x = clampf(at.x + TILE / 2.0 - width / 2.0, 4.0, COLUMNS * TILE - width - 4.0)
	_board.add_child(label)
	var tween := label.create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 24.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func _hit_stop() -> void:
	Engine.time_scale = HIT_STOP_SCALE
	get_tree().create_timer(HIT_STOP_TIME, true, false, true).timeout.connect(
			Engine.set.bind(&"time_scale", 1.0))


func _flash() -> void:
	if Accessibility.reduce_motion:
		return
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.35)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.add_child(flash)
	var tween := flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.18)
	tween.tween_callback(flash.queue_free)


func _shake() -> void:
	if Accessibility.reduce_motion:
		return
	var tween := create_tween()
	for i in 6:
		tween.tween_property(self, "_shake_offset", Vector2(randf_range(-6, 6), randf_range(-6, 6)), 0.03)
	tween.tween_property(self, "_shake_offset", Vector2.ZERO, 0.03)


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


func _on_pause_pressed() -> void:
	if state == State.PLAYING and not get_tree().paused:
		_set_paused(true)


func _on_retry_requested() -> void:
	get_tree().paused = false
	GameState.start_endless()


func _on_menu_requested() -> void:
	get_tree().paused = false
	GameState.exit_endless()
	Transition.change_scene(GameState.MENU_SCENE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if state == State.PLAYING and is_inside_tree() and not get_tree().paused:
			_set_paused(true)


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if _voices:
		_voices.clear()
	AudioManager.stop_voices()
	if order_coins > 0:
		GameState.save_profile()


func _layout_board() -> void:
	var view := get_viewport().get_visible_rect().size
	_board_rest = Vector2(floorf(maxf(0.0, view.x - COLUMNS * TILE) / 2.0), HUD_HEIGHT)
	_view_height = view.y - HUD_HEIGHT
	_view_rows = ceili(_view_height / TILE)
	if _rain:
		_rain.resize(Vector2(COLUMNS * TILE, _view_height))
	_apply_board_position()
	_side_mask.queue_redraw()


func _draw_side_mask() -> void:
	var view := get_viewport().get_visible_rect().size
	var color := ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color") as Color
	var left := _board_rest.x
	var right := _board_rest.x + COLUMNS * TILE
	if left > 0.0:
		_side_mask.draw_rect(Rect2(0, HUD_HEIGHT, left, view.y), color)
		_side_mask.draw_rect(Rect2(right, HUD_HEIGHT, view.x - right, view.y), color)
		var city: CityTheme = _row_city.get(_player.cell.y, _active_day().city) if _player else _active_day().city
		var grass := SpriteLibrary.texture(city.side_tile) if city else null
		if grass:
			var tint := city.side_tint
			var start_x := left - ceilf(left / TILE) * TILE
			var y := HUD_HEIGHT - fposmod(_scroll, TILE)
			while y < view.y:
				var x := start_x
				while x < view.x:
					if x + TILE <= left or x >= right:
						_side_mask.draw_texture_rect(grass, Rect2(x, y, TILE, TILE), false, tint)
					x += TILE
				y += TILE
		_side_mask.draw_rect(Rect2(left - 4, HUD_HEIGHT, 4, view.y), Palette.OUTLINE)
		_side_mask.draw_rect(Rect2(right, HUD_HEIGHT, 4, view.y), Palette.OUTLINE)


func _draw_board() -> void:
	var vis := _visible_row_range()
	var width := COLUMNS * TILE
	var road_tex := SpriteLibrary.texture("tile_road")
	var water_tex := SpriteLibrary.texture("tile_water")

	for row in range(vis.x, vis.y + 1):
		if not _lanes.has(row):
			continue
		var lane: LaneData = _lanes[row]
		var city: CityTheme = _row_city.get(row, _active_day().city)
		var y := row * TILE
		var tile_tex: Texture2D = null
		match lane.kind:
			LaneData.Kind.SIDEWALK:
				tile_tex = SpriteLibrary.texture(city.sidewalk_tile) if city else null
			LaneData.Kind.ROAD:
				tile_tex = road_tex
			LaneData.Kind.MEDIAN:
				tile_tex = SpriteLibrary.texture(city.median_tile) if city else null
			LaneData.Kind.RIVER:
				tile_tex = water_tex

		if tile_tex:
			var tint := city.road_tint if (lane.kind == LaneData.Kind.ROAD and city) else Color.WHITE
			if lane.kind == LaneData.Kind.RIVER and absi(row) % 2 == 1:
				tint = RIVER_ALT_TINT
			for col in COLUMNS:
				_board.draw_texture_rect(tile_tex, Rect2(col * TILE, y, TILE, TILE), false, tint)
			if lane.kind == LaneData.Kind.ROAD:
				_draw_lane_marking(row)
		else:
			var fallback := Color("4a4a52")
			if lane.kind == LaneData.Kind.SIDEWALK:
				fallback = Color("c9c2b3")
			elif lane.kind == LaneData.Kind.MEDIAN:
				fallback = Color("7fb069")
			elif lane.kind == LaneData.Kind.RIVER:
				fallback = Color("5bc0eb")
			_board.draw_rect(Rect2(0, y, width, TILE), fallback)

		# Tepian sungai & busa antar lane air.
		if lane.kind == LaneData.Kind.RIVER:
			_draw_river_bank_for_row(row)

		# Rintangan statis pada baris ini.
		for col: int in lane.obstacles:
			var sprite_name := "obstacle_%s" % lane.obstacles[col]
			var tex := SpriteLibrary.texture(sprite_name)
			var rect := Rect2(Vector2(col, row) * TILE, Vector2(TILE, TILE))
			if tex:
				_board.draw_texture_rect(tex, rect, false)
			else:
				_board.draw_rect(rect.grow(-8), Palette.ORANGE if lane.obstacles[col] != &"hole" else Color.BLACK)

	# Penanda kios paket untuk order aktif selama paket belum diambil.
	_draw_pickup_guide()

	# Bangunan depot di baris 0 dan rumah pelanggan di setiap baris drop-off yang terlihat.
	if 0 >= vis.x and 0 <= vis.y:
		_draw_building("warehouse", 0)
		_draw_depot_billboard()
	for row in range(vis.x, vis.y + 1):
		if _dropoff_info.has(row):
			_draw_dropoff_row(row, _dropoff_info[row])


func _draw_dropoff_row(row: int, info: Dictionary) -> void:
	var y := row * TILE
	var delivered: bool = info["delivered"]
	# Sorotan tipis pada garis antar pelanggan aktif saat Masbro membawa paket.
	if not delivered and has_package and row == _active_order()["dropoff_row"]:
		_board.draw_rect(Rect2(0, y, COLUMNS * TILE, TILE), Color(Palette.TEAL, 0.22))
	_draw_building("house", row)
	var font := ThemeDB.fallback_font
	var label := tr("Rumah %s") % info["customer_name"]
	_board.draw_string(font, Vector2(10, y + 30), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("3b2f2f"))
	var sign_tex := SpriteLibrary.texture("deco_sign_next")
	if sign_tex:
		var size := sign_tex.get_size() / SpriteLibrary.density("deco_sign_next")
		var rect := Rect2(Vector2(GOAL_SIGN_X, y + TILE - size.y), size)
		_board.draw_texture_rect(sign_tex, rect, false)
		var sign_text := "SELESAI!" if delivered else ("ORDER #%d" % info["order_num"])
		var sfont := UiTheme.font(600)
		var fsize := 11
		while fsize > 8 and sfont.get_string_size(sign_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x > 66.0:
			fsize -= 1
		var tw := sfont.get_string_size(sign_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x
		_board.draw_string(sfont, rect.position + Vector2(5.0 + (70.0 - tw) / 2.0, 21), sign_text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color.WHITE)


func _draw_pickup_guide() -> void:
	if has_package or _orders.is_empty():
		return
	var pickup_cell: Vector2i = _active_order()["pickup_cell"]
	if pickup_cell.x < 0:
		return
	var y := pickup_cell.y * TILE
	var width := COLUMNS * TILE
	_board.draw_rect(Rect2(0, y, width, TILE), Color(Palette.YELLOW, 0.18))
	var stripe_x := 0.0
	var toggle := false
	while stripe_x < width:
		var seg := minf(24.0, width - stripe_x)
		_board.draw_rect(Rect2(stripe_x, y - 3.0, seg, 6.0), Palette.CORAL if toggle else Palette.YELLOW)
		stripe_x += 24.0
		toggle = not toggle
	_board.draw_line(Vector2(0, y - 3.0), Vector2(width, y - 3.0), Palette.OUTLINE, 1.5)
	_board.draw_line(Vector2(0, y + 3.0), Vector2(width, y + 3.0), Palette.OUTLINE, 1.5)
	var stall_center := Vector2(pickup_cell) * TILE + Vector2(TILE / 2.0, TILE / 2.0)
	_board.draw_circle(stall_center, TILE * 0.56, Color(Palette.YELLOW, 0.38))
	_board.draw_arc(stall_center, TILE * 0.56, 0.0, TAU, 32, Palette.CORAL, 3.0, true)
	var font := UiTheme.font(700)
	for col in COLUMNS:
		if absi(col - pickup_cell.x) <= 1 or col % 3 != 1:
			continue
		var arrow_text := tr("AMBIL PAKET >>>") if col < pickup_cell.x else tr("<<< AMBIL PAKET")
		var pos := Vector2(col * TILE, y + 30.0)
		_board.draw_string_outline(font, pos, arrow_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, 4, Palette.OUTLINE)
		_board.draw_string(font, pos, arrow_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.YELLOW)


func _draw_lane_marking(row: int) -> void:
	if not _lanes.has(row + 1) or (_lanes[row + 1] as LaneData).kind != LaneData.Kind.ROAD:
		return
	var y := (row + 1) * TILE
	var x := 8.0
	while x < COLUMNS * TILE:
		_board.draw_line(Vector2(x, y), Vector2(x + 20, y), Color(1, 0.96, 0.86, 0.75), 3.0)
		x += 40.0


func _draw_river_bank_for_row(row: int) -> void:
	for edge: int in [row, row + 1]:
		var neighbour := edge - 1 if edge == row else edge
		if _lanes.has(neighbour) and (_lanes[neighbour] as LaneData).kind == LaneData.Kind.RIVER:
			continue
		_board.draw_line(Vector2(0, edge * TILE), Vector2(COLUMNS * TILE, edge * TILE), Palette.OUTLINE, 3.0)
		_board.draw_line(Vector2(0, edge * TILE + (2 if edge == row else -2)),
				Vector2(COLUMNS * TILE, edge * TILE + (2 if edge == row else -2)), Color(1, 1, 1, 0.6), 2.0)
	if _lanes.has(row + 1) and (_lanes[row + 1] as LaneData).kind == LaneData.Kind.RIVER:
		var y := (row + 1) * TILE
		var x := 4.0
		while x < COLUMNS * TILE:
			_board.draw_line(Vector2(x, y), Vector2(x + 18.0, y), Color(1, 1, 1, 0.75), 3.0)
			x += 30.0


func _draw_depot_billboard() -> void:
	var texture := SpriteLibrary.texture("deco_billboard")
	if texture == null:
		_board.draw_string(ThemeDB.fallback_font, Vector2(10, 30), tr("Gudang Ngacir Express"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("3b2f2f"))
		return
	var size := texture.get_size() / SpriteLibrary.density("deco_billboard")
	var rect := Rect2(Vector2(6, (TILE - size.y) / 2.0), size)
	_board.draw_texture_rect(texture, rect, false)
	var width := size.x - 16.0
	_board.draw_string(UiTheme.font(700), rect.position + Vector2(8, 20), "NGACIR EXPRESS",
			HORIZONTAL_ALIGNMENT_CENTER, width, 12, LED_COLOR)
	_board.draw_string(UiTheme.font(500), rect.position + Vector2(8, 33), tr("Shift Lembur") + " ∞",
			HORIZONTAL_ALIGNMENT_CENTER, width, 10, LED_COLOR)


func _draw_building(sprite_name: String, row: int) -> void:
	var texture := SpriteLibrary.texture(sprite_name)
	if texture == null:
		return
	var size := texture.get_size() / SpriteLibrary.density(sprite_name)
	var position_at := Vector2(COLUMNS * TILE - size.x - 8.0, row * TILE + TILE - size.y)
	_board.draw_texture_rect(texture, Rect2(position_at, size), false)
