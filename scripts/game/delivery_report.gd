class_name DeliveryReport
extends RefCounted
## Menghitung rating pelanggan dan upah harian dari hasil satu pengiriman.

const COMMENTS := {
	5: "Paketnya utuh, kurirnya santai. Recommended!",
	3: "Hati-hati kalau antar paket, Masbro.",
	2: "Masbro... paketnya rusak, tapi masih bisa diterima.",
	1: "Mas... ini paket apa habis perang?",
}
const FAILED_COMMENT := "Masbro... paket saya mana?"

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
var wage := 0


static func evaluate(day: DayData, damage: int, collisions: int, elapsed: float) -> DeliveryReport:
	var report := DeliveryReport.new()
	report.customer = day.customer_name
	report.collisions = collisions
	report.elapsed = elapsed
	report.integrity = clampf(1.0 - float(damage) / day.package.max_damage, 0.0, 1.0)
	report.late_seconds = maxi(0, ceili(elapsed - day.eta_seconds))
	report.on_time = report.late_seconds == 0
	report.stars = clampi(1 + roundi(report.integrity * 3.0) + (1 if report.on_time else 0), 1, 5)
	report.comment = _comment_for(report)

	report.base_wage = day.base_wage
	report.eta_bonus = day.eta_bonus if report.on_time else 0
	report.damage_penalty = damage * day.damage_penalty
	report.late_penalty = report.late_seconds * day.late_penalty_per_second
	report.wage = maxi(0, report.base_wage + report.eta_bonus - report.damage_penalty - report.late_penalty)
	return report


static func _comment_for(report: DeliveryReport) -> String:
	if report.stars == 4:
		return "Paket agak penyok, tapi masih aman." if report.on_time \
				else "Paketnya sampai dengan baik, cuma agak lama."
	return COMMENTS[report.stars]
