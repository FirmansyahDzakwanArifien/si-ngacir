class_name CustomerNpc
extends Node2D
## Pelanggan yang menunggu di depan rumahnya dan bereaksi lewat balon ucapan.

enum Mood { WAITING, IMPATIENT, HAPPY, SAD }

var customer_id: StringName
var tile := 48.0

var mood := Mood.WAITING
var _body: Node2D
var _bubble: SpeechBubble
var _tween: Tween


func _ready() -> void:
	_body = Node2D.new()
	# Poros di kaki supaya lompat & goyang terlihat alami.
	_body.position = Vector2(tile / 2.0, tile)
	add_child(_body)
	var sprite := SpriteLibrary.sprite("customer_%s" % customer_id)
	if sprite:
		sprite.position = -_body.position
		_body.add_child(sprite)
	else:
		_body.draw.connect(func() -> void:
			_body.draw_circle(Vector2(0, -tile / 2.0), tile * 0.4, Palette.PINK)
			_body.draw_arc(Vector2(0, -tile / 2.0), tile * 0.4, 0, TAU, 24, Palette.OUTLINE, 3.0))
	_bubble = SpeechBubble.new()
	_bubble.side = SpeechBubble.Side.LEFT
	_bubble.position = Vector2(2, tile * 0.35)
	add_child(_bubble)
	set_mood(Mood.WAITING)


func say(text: String, duration := 2.8) -> void:
	_bubble.say(text, duration)


func set_mood(value: Mood) -> void:
	mood = value
	if _tween:
		_tween.kill()
	_body.rotation = 0.0
	_body.scale = Vector2.ONE
	_body.position = Vector2(tile / 2.0, tile)
	modulate = Color.WHITE
	_tween = create_tween().set_loops()
	match value:
		Mood.WAITING:
			# Melambai pelan.
			_tween.tween_property(_body, "rotation", 0.08, 0.6).set_trans(Tween.TRANS_SINE)
			_tween.tween_property(_body, "rotation", -0.08, 0.6).set_trans(Tween.TRANS_SINE)
		Mood.IMPATIENT:
			# Menghentak-hentak tidak sabar.
			_tween.tween_property(_body, "scale", Vector2(1.08, 0.92), 0.12)
			_tween.tween_property(_body, "scale", Vector2.ONE, 0.12)
			_tween.tween_interval(0.2)
		Mood.HAPPY:
			_tween.tween_property(_body, "position:y", tile - 12.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_tween.tween_property(_body, "position:y", tile, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		Mood.SAD:
			_tween.kill()
			_tween = null
			_body.scale = Vector2(1.05, 0.92)
			modulate = Color(0.8, 0.8, 0.9)
