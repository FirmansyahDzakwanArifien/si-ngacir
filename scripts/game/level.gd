extends Node2D
## Satu hari pengiriman: Masbro membawa paket dari gudang (bawah) ke rumah pelanggan (atas).
## Map bisa jauh lebih tinggi dari layar; kamera mengikuti Masbro ke atas.

const TILE := 48.0
const COLUMNS := 15
const HUD_HEIGHT := 48.0
## Posisi Masbro di layar (0 = atas, 1 = bawah); lebih ke bawah supaya jalan di depan terlihat.
const CAMERA_ANCHOR := 0.65
const CAMERA_SMOOTHING := 8.0
## Area di luar layar tempat kendaraan "berputar" sebelum muncul lagi.
const LOOP_MARGIN_TILES := 4
const HIT_INVULNERABLE_TIME := 1.2
const CAT_SPAWN_DELAY := Vector2(2.5, 5.0)
const POPUP_COOLDOWN := 0.6
const SHOES_TIME := 8.0
const SHOES_SPEED := 0.6
## Kondisi paket minimal agar malam harinya memakai cutscene "bagus".
const GOOD_DAY_INTEGRITY := 0.7
const BLOCKERS := [&"cone", &"barrier", &"gerobak"]
const HONK_DISTANCE := 2.5 * 48.0
const HONK_COOLDOWN := 2.0
const VENDOR_COOLDOWN := 6.0
const RIVAL_SPEED := 300.0
const PEDESTRIANS := [["pejalan_ibu_walk", "pejalan_ibu_idle"], ["pejalan_anak_walk", "pejalan_anak_idle"]]
## Jarak (baris) ke rumah saat pelanggan mulai menyemangati.
const CUSTOMER_CHEER_ROWS := 6

enum State { INTRO, PLAYING, FINISHED }

## Kosongkan untuk memakai hari aktif dari GameState. Isi untuk mengetes hari tertentu.
@export var day: DayData

var state := State.INTRO
var damage := 0
var collisions := 0
var elapsed := 0.0
var coins := 0
var checkpoint_uses := 0

var _rows := 0
## Posisi papan saat kamera di paling atas (papan di tengah layar secara horizontal).
var _board_rest := Vector2(0, HUD_HEIGHT)
## Jarak kamera dari atas map, dalam piksel.
var _scroll := 0.0
## Geser papan ke kiri di layar yang lebih sempit dari papan (0 = tidak digeser).
var _scroll_x := 0.0
## Tinggi jendela map yang terlihat (mengikuti tinggi layar), dalam piksel dan baris.
var _view_height := 13 * TILE
var _view_rows := 13
var _shake_offset := Vector2.ZERO
## Menutup area di luar jendela map supaya kendaraan di luar papan tidak terlihat.
var _side_mask: Node2D
var _invulnerable_left := 0.0
var _board: Node2D
var _player: Player
var _rain: RainOverlay
var _vehicles: Array[Vehicle] = []
## Rakit per baris sungai, key: nomor baris.
var _rafts := {}
## Petak darat terakhir tempat Masbro berdiri; tujuan kembali bila jatuh ke air.
var _last_safe_cell := Vector2i.ZERO
var _cats: Array[StreetCat] = []
var _cat_timer := 1.5
var _honk_cooldown := 0.0
var _rival_timer := 6.0
## Waktu teriak terakhir tiap gerobak, key: Vector2i sel.
var _vendor_shouts := {}
var _popup_cooldown := 0.0
var _boost_left := 0.0
## Node item di papan, key: Vector2i(kolom, baris).
var _item_nodes := {}
var _collected := {}
## Pos terakhir yang dicapai; Vector2i(-1, -1) = belum ada.
var _checkpoint_cell := Vector2i(-1, -1)
var _hud: GameHud
var _customer: CustomerNpc
var _tips: TutorialTips
var _tip_scan := 0.0
## Kalimat pelanggan yang sudah diucapkan (supaya tidak diulang).
var _customer_said := {}


func _ready() -> void:
	# Level tetap jalan saat pause supaya bisa menerima tombol unpause;
	# isi papan (kendaraan & Masbro) yang ikut berhenti.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if day == null:
		day = GameState.current_day()
	if day.map:
		_generate_map()
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
	_spawn_items()
	_spawn_vehicles()
	_spawn_customer()
	_spawn_player()
	if day.rainy:
		_rain = RainOverlay.new()
		_rain.area = Vector2(COLUMNS * TILE, _view_height)
		_rain.visibility_radius = day.visibility_tiles * TILE
		_rain.target = _player
		_rain.z_index = 10
		_board.add_child(_rain)
	_layout_board()
	get_viewport().size_changed.connect(_layout_board)
	_scroll = _camera_target()
	_scroll_x = _camera_target_x()
	_apply_board_position()

	_hud = GameHud.new()
	add_child(_hud)
	_hud.setup(day)
	_hud.start_requested.connect(_on_start_requested)
	_hud.resume_requested.connect(_set_paused.bind(false))
	_hud.retry_requested.connect(_on_retry_requested)
	_hud.next_requested.connect(_on_next_requested)
	_hud.menu_requested.connect(_on_menu_requested)
	_hud.checkpoint_requested.connect(_on_checkpoint_requested)
	_tips = TutorialTips.new(_hud)
	_hud.show_intro()
	var touch := TouchControls.new()
	touch.player = _player
	add_child(touch)
	_hud.pause_pressed.connect(_on_pause_pressed)
	AudioManager.play_music(&"gameplay")


## Rakit map prosedural untuk hari ini. DayData diduplikasi supaya resource asli tidak berubah.
func _generate_map() -> void:
	var params := day.map
	day = day.duplicate()
	var rng := RandomNumberGenerator.new()
	if params.fixed_seed != 0:
		rng.seed = params.fixed_seed
	else:
		rng.randomize()
	day.lanes = MapGenerator.generate(params, rng)
	day.eta_seconds = roundf(day.lanes.size() * params.eta_per_row)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var smoothing := 1.0 - exp(-CAMERA_SMOOTHING * delta)
	_scroll = lerpf(_scroll, _camera_target(), smoothing)
	_scroll_x = lerpf(_scroll_x, _camera_target_x(), smoothing)
	_apply_board_position()
	if state != State.PLAYING:
		return
	elapsed += delta
	_hud.update_timer(day.eta_seconds - elapsed)
	_hud.update_progress(1.0 - _player.position.y / ((_rows - 1) * TILE))

	_popup_cooldown = maxf(0.0, _popup_cooldown - delta)
	_scan_tips(delta)
	_update_customer()
	_update_cats(delta)
	_update_street_npcs(delta)
	_update_river(delta)
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
		if not vehicle.is_platform and vehicle.hitbox().intersects(player_box):
			_on_hit(vehicle)
			return


func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAYING and event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _camera_target() -> float:
	var target := _player.position.y + TILE / 2.0 - _view_height * CAMERA_ANCHOR
	return clampf(target, 0.0, maxf(0.0, _rows * TILE - _view_height))


## Di layar sempit papan digeser ke samping supaya Masbro tetap di tengah.
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


## Baris map yang sedang terlihat di layar (atas, bawah).
func _visible_rows() -> Vector2i:
	var top := floori(_scroll / TILE)
	return Vector2i(top, mini(_rows - 1, top + _view_rows))


func _spawn_vehicles() -> void:
	var margin := LOOP_MARGIN_TILES * TILE
	var loop_length := COLUMNS * TILE + margin
	for row in _rows:
		var lane := day.lanes[row]
		if (lane.kind != LaneData.Kind.ROAD and lane.kind != LaneData.Kind.RIVER) or lane.vehicle_count <= 0:
			continue
		var spacing := loop_length / lane.vehicle_count
		for i in lane.vehicle_count:
			var vehicle := Vehicle.new()
			vehicle.setup(lane.vehicle, TILE, lane.speed, lane.direction, -margin, loop_length)
			vehicle.position = Vector2(-margin + fposmod(lane.offset + i * spacing, loop_length), row * TILE)
			_board.add_child(vehicle)
			_vehicles.append(vehicle)
			if vehicle.is_platform:
				if not _rafts.has(row):
					_rafts[row] = []
				_rafts[row].append(vehicle)


func _spawn_items() -> void:
	for row in _rows:
		for col: int in day.lanes[row].items:
			var type: StringName = day.lanes[row].items[col]
			var node := SpriteLibrary.sprite("item_%s" % type)
			if node == null:
				continue
			var holder := Node2D.new()
			holder.position = Vector2(col, row) * TILE
			holder.add_child(node)
			_board.add_child(holder)
			# Item mengambang naik-turun supaya menarik perhatian.
			var tween := node.create_tween().set_loops()
			tween.tween_property(node, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_SINE)
			tween.tween_property(node, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
			_item_nodes[Vector2i(col, row)] = holder


func _spawn_customer() -> void:
	_customer = CustomerNpc.new()
	_customer.customer_id = day.customer_id
	_customer.tile = TILE
	# Berdiri di sebelah kiri rumah (rumah digambar di pojok kanan baris paling atas).
	var house := SpriteLibrary.texture("house")
	var house_width := house.get_width() / SpriteLibrary.density("house") if house else 0.0
	_customer.position = Vector2(COLUMNS * TILE - house_width - 8.0 - TILE, 0)
	_board.add_child(_customer)


## Pelanggan bereaksi terhadap jarak Masbro dan sisa waktu.
func _update_customer() -> void:
	var left := day.eta_seconds - elapsed
	if left < 0.0:
		_customer_line(&"late", "Kok lama, ya...", CustomerNpc.Mood.IMPATIENT)
	elif left <= 10.0:
		_customer_line(&"hurry", "Cepetan, Masbro...", CustomerNpc.Mood.IMPATIENT)
	elif _player.cell.y <= CUSTOMER_CHEER_ROWS:
		_customer_line(&"close", "Sedikit lagi, Masbro!", CustomerNpc.Mood.WAITING)


## Cek apa yang ada di depan Masbro untuk tips tutorial (4x per detik).
func _scan_tips(delta: float) -> void:
	_tip_scan -= delta
	if _tip_scan > 0.0:
		return
	_tip_scan = 0.25
	if day.eta_seconds - elapsed <= 10.0:
		_tips.trigger(&"eta")
	for row in range(maxi(0, _player.cell.y - 3), _player.cell.y):
		var lane := day.lanes[row]
		if lane.kind == LaneData.Kind.RIVER:
			_tips.trigger(&"river")
		for col: int in lane.items:
			if not _collected.has(Vector2i(col, row)):
				_tips.trigger(&"coin" if lane.items[col] == &"coin" else &"powerup")
		if &"hole" in lane.obstacles.values() and row >= _player.cell.y - 2:
			_tips.trigger(&"hole")


func _customer_line(key: StringName, text: String, mood: CustomerNpc.Mood) -> void:
	if _customer_said.has(key):
		return
	_customer_said[key] = true
	_customer.say(text)
	if _customer.mood != mood:
		_customer.set_mood(mood)


func _spawn_player() -> void:
	_player = Player.new()
	_player.tile = TILE
	_player.grid_size = Vector2i(COLUMNS, _rows)
	_player.step_time = day.package.step_time
	_player.package_id = day.package.id
	_player.package_color = day.package.color
	_player.place(Vector2i(floori(COLUMNS / 2.0), _rows - 1))
	_last_safe_cell = _player.cell
	_player.can_enter = _is_cell_free
	_player.moved.connect(_on_player_moved)
	_player.blocked.connect(_on_player_blocked)
	_board.add_child(_player)


func _update_cats(delta: float) -> void:
	for i in range(_cats.size() - 1, -1, -1):
		if not is_instance_valid(_cats[i]):
			_cats.remove_at(i)
	if day.cat_count > 0 or day.pedestrian_count > 0:
		_cat_timer -= delta
		if _cat_timer <= 0.0:
			_cat_timer = randf_range(CAT_SPAWN_DELAY.x, CAT_SPAWN_DELAY.y)
			var cats := _cats.filter(func(w: StreetCat) -> bool: return w.kind == &"cat").size()
			var walkers := _cats.size() - cats
			var want_walker := walkers < day.pedestrian_count and (cats >= day.cat_count or randf() < 0.5)
			if want_walker:
				_spawn_cat(&"pedestrian")
			elif cats < day.cat_count:
				_spawn_cat(&"cat")
	var player_box := _player.hitbox()
	for cat in _cats:
		if cat.hitbox().intersects(player_box) and cat.notice_player():
			_popup("Meong?" if cat.kind == &"cat" else "Eh, maaf!", Color("f4a259"), cat.position)


## Kucing menyeberang di jalan & median; pejalan kaki hanya berjalan di median.
## Keduanya muncul di baris yang sedang terlihat, tidak di trotoar gudang/rumah.
func _spawn_cat(kind: StringName = &"cat") -> void:
	var view := _visible_rows()
	var rows: Array[int] = []
	for row in range(maxi(1, view.x), mini(_rows - 1, view.y + 1)):
		var lane_kind := day.lanes[row].kind
		var allowed := lane_kind == LaneData.Kind.MEDIAN or (kind == &"cat" and lane_kind == LaneData.Kind.ROAD)
		if row != _player.cell.y and allowed:
			rows.append(row)
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
	# Kucing di bawah Masbro supaya Masbro tetap terlihat.
	_board.move_child(cat, _player.get_index())
	_cats.append(cat)


func _is_cell_free(cell: Vector2i) -> bool:
	if day.lanes[cell.y].obstacles.get(cell.x, &"") in BLOCKERS:
		return false
	var area := Rect2(Vector2(cell) * TILE + Vector2(6, 6), Vector2(TILE - 12, TILE - 12))
	for cat in _cats:
		if is_instance_valid(cat) and cat.hitbox().intersects(area):
			return false
	return true


func _on_player_blocked(cell: Vector2i) -> void:
	if _popup_cooldown > 0.0:
		return
	var obstacle: StringName = day.lanes[cell.y].obstacles.get(cell.x, &"")
	if obstacle == &"":
		_tips.trigger(&"walker")
	if obstacle == &"gerobak":
		_popup("Bakso, Mas?", Palette.CORAL, _player.position)
	elif obstacle in BLOCKERS:
		_popup("Awas!", Palette.ORANGE, _player.position)
	elif _walker_at(cell) and _walker_at(cell).kind == &"pedestrian":
		_popup("Permisi, Mas!", Palette.CORAL, _player.position)
	else:
		_popup("Meong!", Color("f4a259"), _player.position)
		AudioManager.play_sfx(&"meow", 0.1)


func _walker_at(cell: Vector2i) -> StreetCat:
	var area := Rect2(Vector2(cell) * TILE + Vector2(6, 6), Vector2(TILE - 12, TILE - 12))
	for walker in _cats:
		if is_instance_valid(walker) and walker.hitbox().intersects(area):
			return walker
	return null


## Klakson pengemudi, teriakan pedagang bakso, dan Bang Kilat.
func _update_street_npcs(delta: float) -> void:
	_honk_cooldown = maxf(0.0, _honk_cooldown - delta)
	var row := _player.cell.y
	if _honk_cooldown <= 0.0 and day.lanes[row].kind == LaneData.Kind.ROAD:
		for vehicle in _vehicles:
			if not is_instance_valid(vehicle) or vehicle.is_platform or vehicle.type == &"kilat":
				continue
			if roundi(vehicle.position.y / TILE) != row:
				continue
			var gap := _player.position.x - (vehicle.position.x + vehicle.length_px) if vehicle.direction > 0 \
					else vehicle.position.x - (_player.position.x + TILE)
			if gap >= 0.0 and gap <= HONK_DISTANCE:
				_honk_cooldown = HONK_COOLDOWN
				_npc_say(vehicle, "Tin tin!", Vector2(vehicle.length_px / 2.0, 6))
				AudioManager.play_sfx(&"horn", 0.08)
				break

	for check_row in range(maxi(0, row - 1), mini(_rows, row + 2)):
		var obstacles := day.lanes[check_row].obstacles
		for col: int in obstacles:
			if obstacles[col] != &"gerobak" or absi(col - _player.cell.x) > 2:
				continue
			var cell := Vector2i(col, check_row)
			if elapsed - _vendor_shouts.get(cell, -VENDOR_COOLDOWN) >= VENDOR_COOLDOWN:
				_vendor_shouts[cell] = elapsed
				var bubble := _npc_say(_board, "Bakso! Bakso!", Vector2(cell) * TILE + Vector2(TILE / 2.0, 6))
				bubble.get_parent().move_child(bubble, -1)

	if day.rival_interval > 0.0:
		for i in range(_vehicles.size() - 1, -1, -1):
			if not is_instance_valid(_vehicles[i]):
				_vehicles.remove_at(i)
		_rival_timer -= delta
		if _rival_timer <= 0.0:
			_rival_timer = day.rival_interval * randf_range(0.8, 1.2)
			_spawn_rival()


## Balon ucapan sementara yang menempel pada node (ikut bergerak bersamanya).
func _npc_say(owner: Node2D, text: String, offset: Vector2) -> SpeechBubble:
	var bubble := SpeechBubble.new()
	bubble.side = SpeechBubble.Side.ABOVE
	bubble.position = offset
	owner.add_child(bubble)
	bubble.say(text, 1.6)
	get_tree().create_timer(1.8, false).timeout.connect(func() -> void:
		if is_instance_valid(bubble):
			bubble.queue_free())
	return bubble


## Bang Kilat melesat sekali di lane jalan yang terlihat di depan Masbro.
func _spawn_rival() -> void:
	var view := _visible_rows()
	var rows: Array[int] = []
	for row in range(maxi(1, view.x), mini(_rows - 1, view.y + 1)):
		if day.lanes[row].kind == LaneData.Kind.ROAD and row <= _player.cell.y:
			rows.append(row)
	if rows.is_empty():
		return
	var rival := Vehicle.new()
	var direction := 1 if randf() < 0.5 else -1
	rival.setup(&"kilat", TILE, RIVAL_SPEED, direction, -TILE * 2.0, COLUMNS * TILE + TILE * 4.0)
	rival.one_shot = true
	rival.position = Vector2(-TILE * 2.0 if direction > 0 else COLUMNS * TILE + TILE, rows.pick_random() * TILE)
	_board.add_child(rival)
	_vehicles.append(rival)
	_npc_say(rival, "Minggir, Masbro!", Vector2(TILE / 2.0, 6))
	_tips.trigger(&"rival")
	AudioManager.play_sfx(&"horn", 0.15)


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
	_customer.say(day.customer_greeting, 3.5)
	_tips.trigger(&"move")


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
	if day.lanes[cell.y].kind == LaneData.Kind.RIVER:
		if _raft_under_player() == null:
			_splash()
		return
	_last_safe_cell = cell
	if day.lanes[cell.y].checkpoint and cell.y != _checkpoint_cell.y:
		_reach_checkpoint(cell)
	_collect_item(cell)
	if day.lanes[cell.y].obstacles.get(cell.x, &"") == &"hole" and not _player.invulnerable:
		_on_hole()
		return
	var on_wet_road := day.rainy and day.lanes[cell.y].kind == LaneData.Kind.ROAD
	if on_wet_road and not _player.last_move_was_slide and not _player.invulnerable \
			and randf() < day.slip_chance and _player.slide():
		_popup("Licin!", Color("8ecae6"), _player.position)
		AudioManager.play_sfx(&"slip")


func _collect_item(cell: Vector2i) -> void:
	var items := day.lanes[cell.y].items
	if not items.has(cell.x) or _collected.has(cell):
		return
	# Dicatat di level, bukan dihapus dari LaneData, supaya resource map tetap utuh.
	_collected[cell] = true
	var type: StringName = items[cell.x]
	if _item_nodes.has(cell):
		var node: Node2D = _item_nodes[cell]
		_item_nodes.erase(cell)
		var tween := node.create_tween()
		tween.set_parallel()
		tween.tween_property(node, "position:y", node.position.y - 30.0, 0.3)
		tween.tween_property(node, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(node.queue_free)
	AudioManager.play_sfx(&"star", 0.15)
	match type:
		&"coin":
			coins += 1
			_popup("+%s" % GameState.rupiah(DeliveryReport.COIN_VALUE), Palette.YELLOW, _player.position)
		&"helmet":
			_player.shielded = true
			_popup("Helm! Kebal 1x", Palette.TEAL, _player.position)
		&"shoes":
			_boost_left = SHOES_TIME
			_player.speed_multiplier = SHOES_SPEED
			_popup("Sepatu kilat!", Palette.CORAL, _player.position)


## Masbro ikut terbawa rakit; keluar layar atau tanpa rakit berarti tercebur.
func _update_river(delta: float) -> void:
	if _player.is_moving() or day.lanes[_player.cell.y].kind != LaneData.Kind.RIVER:
		return
	var raft := _raft_under_player()
	if raft == null:
		_splash()
		return
	_player.ride(raft.speed * raft.direction * delta)
	var center := _player.position.x + TILE / 2.0
	if center < 0.0 or center > COLUMNS * TILE:
		_splash()


func _raft_under_player() -> Vehicle:
	var center := _player.position.x + TILE / 2.0
	for raft: Vehicle in _rafts.get(_player.cell.y, []):
		if center >= raft.position.x + 4.0 and center <= raft.position.x + raft.length_px - 4.0:
			return raft
	return null


func _splash() -> void:
	Effects.splash(_board, _player.position + Vector2(TILE / 2.0, TILE * 0.7))
	AudioManager.play_sfx(&"splash", 0.1)
	if _player.invulnerable:
		# Sedang kebal (baru tertabrak): cukup kembali ke tepian.
		_player.knock_back(_last_safe_cell)
		return
	_popup("Paket basah!", Palette.SKY_DEEP, _player.position)
	_damage_package(1, _last_safe_cell)


func _on_hit(vehicle: Vehicle) -> void:
	var back := Vector2i(_player.cell.x, mini(_player.cell.y + 1, _rows - 1))
	_damage_package(vehicle.damage, back)


func _on_hole() -> void:
	# Terperosok: paket terguncang, Masbro kembali ke petak sebelumnya.
	_popup("Lubang!", Palette.ORANGE, _player.position)
	_damage_package(1, _player.cell - _player.last_direction)


func _damage_package(amount: int, knock_to: Vector2i) -> void:
	knock_to = Vector2i(clampi(knock_to.x, 0, COLUMNS - 1), clampi(knock_to.y, 0, _rows - 1))
	if not _is_cell_free(knock_to):
		knock_to = _player.cell
	_shake()
	_invulnerable_left = HIT_INVULNERABLE_TIME
	_player.invulnerable = true
	if _player.shielded:
		# Helm menahan benturan; paket aman.
		_player.shielded = false
		_popup("Helm melindungi!", Palette.TEAL, _player.position)
		AudioManager.play_sfx(&"hit", 0.1)
		_player.knock_back(knock_to)
		return
	collisions += 1
	_tips.trigger(&"hit")
	damage = mini(damage + amount * day.package.fragility, day.package.max_damage)
	_hud.update_package(damage)
	Effects.burst(_board, _player.position + Vector2(TILE / 2.0, TILE / 2.0), day.package.color)
	AudioManager.play_sfx(&"hit", 0.1)
	if damage >= day.package.max_damage:
		_invulnerable_left = 0.0
		_player.invulnerable = false
		_fail()
		return
	AudioManager.play_sfx(&"package_damage", 0.05)
	_player.knock_back(knock_to)


func _deliver() -> void:
	state = State.FINISHED
	_player.input_enabled = false
	_hud.update_progress(1.0)
	var report := DeliveryReport.evaluate(day, damage, collisions, elapsed, coins, checkpoint_uses)
	GameState.record_delivery(day, report.wage)
	GameState.last_day_good = report.integrity >= GOOD_DAY_INTEGRITY
	# Koin yang dipungut masuk dompet untuk belanja di toko.
	GameState.add_coins(coins)
	AudioManager.play_sfx(&"delivery")
	_player.celebrate()
	_customer.set_mood(CustomerNpc.Mood.HAPPY)
	_customer.say("Makasih, Masbro!" if report.stars >= 3 else "Hmm... ya sudah, makasih.", 0.0)
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
	_customer.set_mood(CustomerNpc.Mood.SAD)
	_customer.say("Yah... paketnya...", 0.0)
	var can_continue := _checkpoint_cell.y >= 0 and day.map != null
	_hud.show_failed(GameState.is_replay, day.map.checkpoint_penalty if can_continue else 0)


func _reach_checkpoint(cell: Vector2i) -> void:
	_checkpoint_cell = cell
	_popup("Pos tercapai!", Palette.TEAL, _player.position)
	_tips.trigger(&"checkpoint")
	AudioManager.play_sfx(&"star")
	_board.queue_redraw()


## Paket pengganti dari Pos: kondisi paket pulih, denda dicatat, waktu tetap berjalan.
func _on_checkpoint_requested() -> void:
	checkpoint_uses += 1
	damage = 0
	_hud.update_package(0)
	_hud.hide_overlay()
	_player.place(_checkpoint_cell)
	_last_safe_cell = _checkpoint_cell
	_invulnerable_left = HIT_INVULNERABLE_TIME
	_player.invulnerable = true
	_player.input_enabled = true
	state = State.PLAYING
	AudioManager.play_sfx(&"pickup")
	_popup("Paket baru!", Palette.TEAL, _player.position)
	_customer.set_mood(CustomerNpc.Mood.WAITING)


func _layout_board() -> void:
	var view := get_viewport().get_visible_rect().size
	_board_rest = Vector2(floorf(maxf(0.0, view.x - COLUMNS * TILE) / 2.0), HUD_HEIGHT)
	# Jendela map mengisi tinggi layar (layar potret melihat lebih banyak baris).
	_view_height = minf(view.y - HUD_HEIGHT, _rows * TILE)
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
	var bottom := HUD_HEIGHT + _view_height
	# Sisi kiri/kanan papan (layar lebar): taman rumput yang ikut bergulir dengan kamera.
	if left > 0.0:
		_side_mask.draw_rect(Rect2(0, HUD_HEIGHT, left, view.y), color)
		_side_mask.draw_rect(Rect2(right, HUD_HEIGHT, view.x - right, view.y), color)
		var city := _city()
		var grass := SpriteLibrary.texture(city.side_tile)
		if grass:
			var tint := city.side_tint
			var start_x := left - ceilf(left / TILE) * TILE
			var y := HUD_HEIGHT - fposmod(_scroll, TILE)
			while y < view.y:
				var x := start_x
				while x < view.x:
					# Lewati petak yang berada di dalam papan permainan.
					if x + TILE <= left or x >= right:
						_side_mask.draw_texture_rect(grass, Rect2(x, y, TILE, TILE), false, tint)
					x += TILE
				y += TILE
	if left > 0.0:
		_side_mask.draw_rect(Rect2(left - 4, HUD_HEIGHT, 4, view.y), Palette.OUTLINE)
		_side_mask.draw_rect(Rect2(right, HUD_HEIGHT, 4, view.y), Palette.OUTLINE)
	if bottom < view.y:
		_side_mask.draw_rect(Rect2(0, bottom, view.x, view.y - bottom), color)


func _on_pause_pressed() -> void:
	if state == State.PLAYING and not get_tree().paused:
		_set_paused(true)


func _shake() -> void:
	var tween := create_tween()
	for i in 6:
		tween.tween_property(self, "_shake_offset", Vector2(randf_range(-6, 6), randf_range(-6, 6)), 0.03)
	tween.tween_property(self, "_shake_offset", Vector2.ZERO, 0.03)


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
	var evening := day.evening_good if GameState.last_day_good else day.evening_rough
	if GameState.advance_day():
		GameState.play_story(StoryData.combine([evening, GameState.current_day().story]), GameState.LEVEL_SCENE)
	elif GameState.is_replay:
		Transition.change_scene(GameState.ENDING_SCENE)
	else:
		GameState.finish_probation()
		GameState.play_story(GameState.ending_story(), GameState.ENDING_SCENE)


func _on_menu_requested() -> void:
	get_tree().paused = false
	Transition.change_scene(GameState.MENU_SCENE)


## Tema lokasi hari ini (tema bawaan bila DayData.city kosong).
func _city() -> CityTheme:
	return day.city if day.city else CityTheme.new()


func _draw_board() -> void:
	var width := COLUMNS * TILE
	var city := _city()
	var tiles := {
		LaneData.Kind.SIDEWALK: SpriteLibrary.texture(city.sidewalk_tile),
		LaneData.Kind.ROAD: SpriteLibrary.texture("tile_road"),
		LaneData.Kind.MEDIAN: SpriteLibrary.texture(city.median_tile),
		LaneData.Kind.RIVER: SpriteLibrary.texture("tile_water"),
	}
	for row in _rows:
		var kind := day.lanes[row].kind
		var y := row * TILE
		var tile_texture: Texture2D = tiles[kind]
		if tile_texture:
			var tint := city.road_tint if kind == LaneData.Kind.ROAD else Color.WHITE
			for col in COLUMNS:
				_board.draw_texture_rect(tile_texture, Rect2(col * TILE, y, TILE, TILE), false, tint)
			if kind == LaneData.Kind.ROAD:
				_draw_lane_marking(row)
		# Placeholder latar sampai tileset dari Illustrator siap.
		elif kind == LaneData.Kind.SIDEWALK:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("c9c2b3"))
			for col in COLUMNS:
				_board.draw_rect(Rect2(col * TILE, y, TILE, TILE), Color("b5ad9c"), false, 1.0)
		elif kind == LaneData.Kind.MEDIAN:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("7fb069"))
		elif kind == LaneData.Kind.RIVER:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("5bc0eb"))
		else:
			_board.draw_rect(Rect2(0, y, width, TILE), Color("4a4a52"))
			_draw_lane_marking(row)

	_draw_river_banks()
	_draw_checkpoints()
	_draw_obstacles()
	_draw_building("house", 0)
	_draw_building("warehouse", _rows - 1)
	var font := ThemeDB.fallback_font
	var ink := Color("3b2f2f")
	_board.draw_string(font, Vector2(10, 30), tr("Rumah %s") % day.customer_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)
	_board.draw_string(font, Vector2(10, (_rows - 1) * TILE + 30), tr("Gudang Ngacir Express"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)


func _draw_checkpoints() -> void:
	var font := ThemeDB.fallback_font
	for row in _rows:
		if not day.lanes[row].checkpoint:
			continue
		var reached := row == _checkpoint_cell.y
		var sprite_name := "checkpoint_flag_on" if reached else "checkpoint_flag"
		var texture := SpriteLibrary.texture(sprite_name)
		for col in [0, COLUMNS - 1]:
			var rect := Rect2(Vector2(col, row) * TILE, Vector2(TILE, TILE))
			if texture:
				_board.draw_texture_rect(texture, rect, false)
			else:
				_board.draw_rect(rect.grow(-10), Palette.TEAL)
		_board.draw_string(font, Vector2(TILE + 6, row * TILE + 30), tr("POS"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.OUTLINE)


## Garis tepian di atas dan bawah setiap blok sungai.
func _draw_river_banks() -> void:
	for row in _rows:
		if day.lanes[row].kind != LaneData.Kind.RIVER:
			continue
		for edge: int in [row, row + 1]:
			var neighbour := edge - 1 if edge == row else edge
			if neighbour < 0 or neighbour >= _rows or day.lanes[neighbour].kind == LaneData.Kind.RIVER:
				continue
			_board.draw_line(Vector2(0, edge * TILE), Vector2(COLUMNS * TILE, edge * TILE), Palette.OUTLINE, 3.0)
			_board.draw_line(Vector2(0, edge * TILE + (2 if edge == row else -2)),
					Vector2(COLUMNS * TILE, edge * TILE + (2 if edge == row else -2)), Color(1, 1, 1, 0.6), 2.0)


func _draw_obstacles() -> void:
	for row in _rows:
		var obstacles := day.lanes[row].obstacles
		for col: int in obstacles:
			var sprite_name := "obstacle_%s" % obstacles[col]
			var texture := SpriteLibrary.texture(sprite_name)
			var rect := Rect2(Vector2(col, row) * TILE, Vector2(TILE, TILE))
			if texture:
				_board.draw_texture_rect(texture, rect, false)
			else:
				_board.draw_rect(rect.grow(-8), Palette.ORANGE if obstacles[col] != &"hole" else Color.BLACK)


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
