class_name DeliveryReport
extends RefCounted
## Menghitung rating pelanggan dan upah harian dari hasil satu pengiriman.

const COMMENTS := {
	5: "Mukanya santai, tapi paketnya mulus tanpa lecet. Mantap!",
	3: "Lain kali lebih hati-hati, Masbro.",
	2: "Paketnya agak hancur, tapi isinya masih bisa dipakai.",
	1: "Ini paket atau hasil bongkar muatan kapal karam?!",
}
const FAILED_COMMENT := "Masbro... paket saya mana?"
## Omelan Bos Koko saat paket hancur.
const KOKO_FAILED_COMMENT := "ASTAGA, MASBRO! Itu barang kiriman, bukan onde-onde yang boleh diremukin!"
## Komentar pelanggan teliti (Pak Wali Kota).
const STRICT_COMMENTS := {
	5: "Sempurna. Ini layak dipajang di Balai Kota.",
	4: "Utuh, tapi upacaranya hampir dimulai.",
	3: "Ada goresan. Saya catat.",
	2: "Ini jauh dari standar Balai Kota, Masbro.",
	1: "Saya akan bicara dengan atasanmu.",
}
## Komentar pelanggan tidak sabaran (Nana).
const IMPATIENT_COMMENTS := {
	5: "T-tepat waktu? Gak lecet sedikit pun? Oke... bintang lima terpaksa saya kasih!",
	4: "Lumayan. Tapi detiknya tetap saya hitung, ya.",
	3: "Lama! Saya tulis di ulasan.",
	2: "Sudah telat, penyok pula!",
	1: "Bintang satu! Plus ulasan dua paragraf!",
}
## Upah tambahan per koin yang dipungut di jalan.
const COIN_VALUE := 1000
## Bintang maksimal bila paket sempat diganti di Pos.
const CHECKPOINT_MAX_STARS := 3
## Bintang maksimal dari pelanggan teliti kalau paket rusak sedikit pun.
const STRICT_DAMAGED_MAX_STARS := 3
## Bintang maksimal dari pelanggan tidak sabaran kalau terlambat.
const IMPATIENT_LATE_MAX_STARS := 3

var customer := ""
var stars := 0
var comment := ""
var integrity := 0.0
var elapsed := 0.0
var collisions := 0
var on_time := false
var late_seconds := 0
var base_wage := 0
var eta_bonus := 0
var damage_penalty := 0
var late_penalty := 0
var tip := 0
var coins := 0
var coin_bonus := 0
## Berapa kali paket diganti di Pos, dan dendanya.
var checkpoint_uses := 0
var checkpoint_penalty := 0
var strict := false
var impatient := false
var wage := 0


static func evaluate(day: DayData, damage: int, collisions: int, elapsed: float, coins := 0,
		checkpoint_uses := 0) -> DeliveryReport:
	var report := DeliveryReport.new()
	report.customer = day.customer_name
	report.collisions = collisions
	report.elapsed = elapsed
	report.integrity = clampf(1.0 - float(damage) / day.package.max_damage, 0.0, 1.0)
	report.late_seconds = maxi(0, ceili(elapsed - day.eta_seconds))
	report.on_time = report.late_seconds == 0
	report.stars = clampi(1 + roundi(report.integrity * 3.0) + (1 if report.on_time else 0), 1, 5)
	report.strict = day.strict_customer
	if report.strict and damage > 0:
		report.stars = mini(report.stars, STRICT_DAMAGED_MAX_STARS)
	report.impatient = day.impatient_customer
	if report.impatient and not report.on_time:
		report.stars = mini(report.stars, IMPATIENT_LATE_MAX_STARS)
	report.checkpoint_uses = checkpoint_uses
	if checkpoint_uses > 0:
		# Paket pengganti dari Pos: pelanggan tahu ada masalah di jalan.
		report.stars = mini(report.stars, CHECKPOINT_MAX_STARS)
	report.comment = _comment_for(report)

	report.base_wage = day.base_wage
	report.eta_bonus = day.eta_bonus if report.on_time else 0
	report.damage_penalty = damage * day.damage_penalty * (2 if report.strict else 1)
	report.late_penalty = report.late_seconds * day.late_penalty_per_second * (2 if report.impatient else 1)
	report.tip = day.perfect_tip if damage == 0 and report.on_time else 0
	report.coins = coins
	report.coin_bonus = coins * COIN_VALUE
	if day.map:
		report.checkpoint_penalty = checkpoint_uses * day.map.checkpoint_penalty
	report.wage = maxi(0, report.base_wage + report.eta_bonus + report.tip + report.coin_bonus
			- report.damage_penalty - report.late_penalty - report.checkpoint_penalty)
	return report


static func _comment_for(report: DeliveryReport) -> String:
	if report.strict:
		return STRICT_COMMENTS[report.stars]
	if report.impatient:
		return IMPATIENT_COMMENTS[report.stars]
	if report.stars == 4:
		return "Paket agak penyok, tapi masih aman." if report.on_time \
				else "Paketnya sampai dengan baik, cuma agak lama."
	return COMMENTS[report.stars]
