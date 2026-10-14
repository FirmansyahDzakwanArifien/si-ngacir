#!/usr/bin/env python3
"""Pembuat aset audio placeholder Si Ngacir (prosedural, tanpa sampel pihak ketiga).

Menghasilkan:
  assets/audio/music/gameplay_ceria.wav   musik gameplay, 32 detik, loop mulus
  assets/audio/voice/<nama>.wav           "celoteh" NPC (suara placeholder, bukan dialog nyata)

Jalankan dari akar repo (butuh Python 3 dan numpy):
    python3 tools/generate_audio.py            # buat semua
    python3 tools/generate_audio.py --check    # hanya cek hasil yang sudah ada

Semua bunyi dibuat dari rumus (gelombang, filter, noise ber-seed), jadi hasilnya sama setiap
dijalankan dan tidak ada masalah lisensi sampel. Tim Audio cukup mengganti file dengan
NAMA YANG SAMA bila sudah punya rekaman final. Format: WAV 16-bit mono 22050 Hz, sama dengan
aset audio yang sudah ada (build web ramping tidak punya dekoder .ogg / .mp3).
"""

import argparse
import sys
import wave
from pathlib import Path

import numpy as np

SR = 22050
ROOT = Path(__file__).resolve().parent.parent
MUSIC_DIR = ROOT / "assets" / "audio" / "music"
VOICE_DIR = ROOT / "assets" / "audio" / "voice"

# ------------------------------------------------------------------ utilitas dasar


def midi_hz(note: float) -> float:
    return 440.0 * 2.0 ** ((note - 69.0) / 12.0)


def write_wav(path: Path, samples: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = np.clip(samples, -1.0, 1.0)
    pcm = (data * 32767.0).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def read_wav(path: Path) -> np.ndarray:
    with wave.open(str(path), "rb") as w:
        assert w.getnchannels() == 1 and w.getsampwidth() == 2 and w.getframerate() == SR
        return np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64) / 32768.0


def envelope(n: int, attack: float, tau: float, release: float) -> np.ndarray:
    """Naik cepat (attack), meluruh eksponensial (tau), turun halus di ujung (release)."""
    t = np.arange(n) / SR
    env = np.exp(-t / tau)
    a = max(1, int(attack * SR))
    env[:a] *= np.linspace(0.0, 1.0, a, endpoint=False)
    r = min(n, max(1, int(release * SR)))
    env[-r:] *= np.linspace(1.0, 0.0, r)
    return env


def pulse(freq: float, n: int, duty: float) -> np.ndarray:
    """Gelombang pulsa band-limited (jumlah harmonik dibatasi supaya tidak aliasing)."""
    t = np.arange(n) / SR
    top = max(1, min(14, int(SR * 0.45 / freq)))
    k = np.arange(1, top + 1)[:, None]
    wave_ = (np.sin(k * np.pi * duty) / k * np.cos(2 * np.pi * k * freq * t - k * np.pi * duty)).sum(axis=0)
    return wave_ * (2.0 / np.pi)


def triangle(freq: float, n: int) -> np.ndarray:
    t = np.arange(n) / SR
    top = max(1, min(9, int(SR * 0.45 / freq)))
    out = np.zeros(n)
    for i in range(top):
        k = 2 * i + 1
        out += ((-1.0) ** i) / (k * k) * np.sin(2 * np.pi * k * freq * t)
    return out * (8.0 / np.pi ** 2)


def pluck(freq: float, n: int) -> np.ndarray:
    """Bunyi marimba/xilofon imut: sinus + oktaf, meluruh cepat."""
    t = np.arange(n) / SR
    return np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * freq * 2.0 * t) * np.exp(-t / 0.05)


def add(buf: np.ndarray, start: int, sig: np.ndarray) -> None:
    end = min(len(buf), start + len(sig))
    if end > start:
        buf[start:end] += sig[: end - start]


# ------------------------------------------------------------------ musik

BPM = 120  # 22050 * 60 / 120 = 11025 sampel per ketuk (bilangan bulat, loop tepat)
BEAT = SR * 60 // BPM
BAR_BEATS = 4
BARS = 16
LOOP_SAMPLES = BEAT * BAR_BEATS * BARS
MUSIC_TARGET_DB = -18.5
SWING = 0.58  # not "off-beat" digeser sedikit: terasa santai dan agak kocak
TAIL = SR * 2  # ekor yang dilipat ke awal supaya sambungan loop tidak terpotong

# Nama nada -> nomor MIDI
NOTE = {"C4": 60, "D4": 62, "E4": 64, "G4": 67, "A4": 69, "C5": 72, "D5": 74, "E5": 76,
        "G5": 79, "A5": 81, "C6": 84, "D6": 86}

# Akor per birama (16 birama): akar bas, nada arpeggio (oktaf 4-5).
CHORDS = {
    "C": (48, [60, 64, 67, 72]),
    "Am": (45, [57, 60, 64, 69]),
    "F": (41, [57, 60, 65, 69]),
    "G": (43, [59, 62, 67, 71]),
    "Em": (40, [59, 64, 67, 71]),
}
PROGRESSION = ["C", "Am", "F", "G", "C", "Am", "F", "G",
               "F", "G", "Em", "Am", "F", "G", "C", "C"]

# Melodi utama: per birama daftar (nada, panjang dalam not delapan). "." = jeda. Jumlah tiap birama = 8.
MELODY = [
    [("E5", 1), ("G5", 1), ("C6", 2), ("A5", 1), ("G5", 1), ("E5", 2)],
    [("A5", 2), ("G5", 1), ("E5", 1), ("D5", 2), ("C5", 2)],
    [("C5", 1), ("D5", 1), ("E5", 2), ("G5", 2), ("E5", 1), ("D5", 1)],
    [("D5", 3), ("G5", 1), ("E5", 2), ("D5", 2)],
    [("G5", 1), ("C6", 1), ("G5", 1), ("E5", 1), ("G5", 2), ("C6", 2)],
    [("A5", 1), ("C6", 1), ("A5", 1), ("G5", 1), ("E5", 2), (".", 2)],
    [("A5", 2), ("G5", 1), ("E5", 1), ("C5", 2), ("D5", 1), ("E5", 1)],
    [("G5", 2), ("E5", 2), ("D5", 2), (".", 2)],
    [("A5", 1), ("G5", 1), ("E5", 1), ("G5", 1), ("A5", 2), ("C6", 2)],
    [("C6", 1), ("A5", 1), ("G5", 1), ("A5", 1), ("G5", 2), ("D5", 2)],
    [("E5", 1), ("G5", 1), ("A5", 1), ("G5", 1), ("E5", 2), ("D5", 2)],
    [("C5", 1), ("E5", 1), ("A5", 2), ("G5", 1), ("E5", 1), ("D5", 1), ("C5", 1)],
    [("C6", 2), ("A5", 1), ("G5", 1), ("A5", 2), ("C6", 2)],
    [("D6", 2), ("C6", 1), ("A5", 1), ("G5", 2), ("D5", 2)],
    [("E5", 1), ("G5", 1), ("C6", 1), ("G5", 1), ("E5", 1), ("G5", 1), ("C6", 2)],
    [("C6", 2), ("G5", 2), ("E5", 2), (".", 2)],
]


def eighth_time(bar: int, eighth: float) -> int:
    """Posisi sampel not delapan ke-`eighth` (boleh pecahan) di birama `bar`, dengan swing."""
    whole, frac = divmod(eighth, 1.0)
    whole = int(whole)
    beat_index = whole // 2
    within = SWING if whole % 2 == 1 else 0.0
    pos = beat_index + within + frac * (SWING if whole % 2 == 0 else 1.0 - SWING)
    return int((bar * BAR_BEATS + pos) * BEAT)


def make_music() -> np.ndarray:
    assert len(MELODY) == BARS and len(PROGRESSION) == BARS
    for i, bar in enumerate(MELODY):
        assert sum(length for _, length in bar) == 8, f"birama {i + 1} tidak berjumlah 8"
    buf = np.zeros(LOOP_SAMPLES + TAIL)
    rng = np.random.default_rng(1207)

    for bar in range(BARS):
        root, tones = CHORDS[PROGRESSION[bar]]

        # Melodi: pulsa 25% (khas arcade), sedikit staccato.
        eighth = 0
        for name, length in MELODY[bar]:
            if name != ".":
                start = eighth_time(bar, eighth)
                end = eighth_time(bar, eighth + length)
                n = int((end - start) * 0.9)
                f = midi_hz(NOTE[name])
                vib = 1.0 + 0.004 * np.sin(2 * np.pi * 5.5 * np.arange(n) / SR)
                # Pulsa dibangun dari fase kumulatif (bukan frekuensi tetap) supaya vibrato halus.
                t = np.cumsum(f * vib) / SR
                top = max(1, min(12, int(SR * 0.45 / f)))
                k = np.arange(1, top + 1)[:, None]
                sig = (np.sin(k * np.pi * 0.25) / k * np.cos(2 * np.pi * k * t - k * np.pi * 0.25)).sum(axis=0) * (2 / np.pi)
                add(buf, start, sig * envelope(n, 0.004, 0.22, 0.03) * 0.30)
            eighth += length

        # Arpeggio marimba: satu nada per not delapan, bergoyang naik-turun.
        pattern = [0, 2, 1, 3, 2, 1, 3, 2]
        for e in range(8):
            start = eighth_time(bar, e)
            n = int(BEAT * 0.45)
            f = midi_hz(tones[pattern[e]] + 12)
            add(buf, start, pluck(f, n) * envelope(n, 0.002, 0.10, 0.02) * 0.10)

        # Bas segitiga yang melompat-lompat (akar, kuinta, oktaf).
        # Nada bas terakhir dibiarkan berdenging sampai ujung birama supaya tidak ada lubang sebelum ketukan 1.
        bass = [(0, 1.5, 0), (2, 1.0, 7), (4, 1.5, 0), (5, 1.0, 12), (6, 2.4, 7)]
        for e, length, interval in bass:
            start = eighth_time(bar, e)
            n = int((eighth_time(bar, e + length) - start) * 0.85)
            f = midi_hz(root + interval)
            sig = triangle(f, n) + 0.25 * np.sin(2 * np.pi * f * 2 * np.arange(n) / SR)
            add(buf, start, sig * envelope(n, 0.004, 0.30, 0.03) * 0.30)

        # Perkusi lembut: kick di ketuk 1 dan 3, "tok" di ketuk 2 dan 4, hat di tiap not delapan.
        for beat in (0, 2):
            n = int(0.16 * SR)
            t = np.arange(n) / SR
            freq = 50.0 + 90.0 * np.exp(-t / 0.035)
            kick = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-t / 0.07)
            add(buf, int((bar * BAR_BEATS + beat) * BEAT), kick * 0.34)
        for beat in (1, 3):
            n = int(0.09 * SR)
            noise = rng.standard_normal(n)
            tok = np.diff(noise, prepend=0.0) * np.exp(-np.arange(n) / SR / 0.025)
            add(buf, int((bar * BAR_BEATS + beat) * BEAT), tok * 0.07)
        for e in range(8):
            n = int(0.04 * SR)
            noise = rng.standard_normal(n)
            hat = np.diff(np.diff(noise, prepend=0.0), prepend=0.0) * np.exp(-np.arange(n) / SR / 0.012)
            add(buf, eighth_time(bar, e), hat * (0.040 if e % 2 == 0 else 0.026))

    # "Boing" kocak di ujung frasa (birama 8 dan 16): nada meluncur naik lalu meluruh.
    for bar, eighth in ((7, 6.0), (15, 6.0)):
        n = int(0.22 * SR)
        t = np.arange(n) / SR
        freq = 330.0 + 520.0 * (t / 0.22) ** 0.7
        sig = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-t / 0.09)
        add(buf, eighth_time(bar, eighth), sig * envelope(n, 0.003, 1.0, 0.04) * 0.20)

    # Lipat ekor ke awal supaya nada yang masih berbunyi di ujung menyambung ke birama pertama.
    loop = buf[:LOOP_SAMPLES].copy()
    loop[:TAIL] += buf[LOOP_SAMPLES:LOOP_SAMPLES + TAIL]

    # Hilangkan DC, lembutkan puncak (tanh), lalu atur level. Target -18,5 dBFS (RMS): sedikit
    # di bawah musik lama (-15 dBFS) dan suara NPC (-15,5 dBFS), supaya latar tidak menutupi
    # suara NPC. Saat NPC bicara, AudioManager masih menurunkan bus Music (ducking).
    loop -= loop.mean()
    loop = np.tanh(loop * 1.3)
    loop *= 10 ** (MUSIC_TARGET_DB / 20) / float(np.sqrt((loop ** 2).mean()))
    if np.abs(loop).max() > 0.6:
        loop *= 0.6 / np.abs(loop).max()
    return loop


# ------------------------------------------------------------------ suara NPC (celoteh)

# Formant kasar (Hz) per vokal: dua resonator sudah cukup untuk kesan "bicara" kartun.
VOWELS = {"a": (800, 1200, 2500), "i": (320, 2300, 3000), "u": (350, 800, 2400),
          "e": (520, 1900, 2600), "o": (450, 900, 2400)}


def resonate(x: np.ndarray, freq: float, bandwidth: float) -> np.ndarray:
    """Filter resonator orde dua (puncak di `freq`)."""
    r = np.exp(-np.pi * bandwidth / SR)
    a1 = 2.0 * r * np.cos(2.0 * np.pi * freq / SR)
    a2 = -r * r
    gain = 1.0 - r
    y = np.zeros(len(x))
    y1 = y2 = 0.0
    for i, v in enumerate(x.tolist()):
        out = gain * v + a1 * y1 + a2 * y2
        y[i] = out
        y2, y1 = y1, out
    return y


def syllable(f0_start: float, f0_end: float, vowel: str, duration: float, rng, breathy: float) -> np.ndarray:
    n = int(duration * SR)
    t = np.arange(n) / SR
    f0 = np.linspace(f0_start, f0_end, n)
    phase = np.cumsum(f0) / SR
    source = 2.0 * (phase % 1.0) - 1.0  # gigi gergaji = kaya harmonik, cocok jadi sumber suara
    source += breathy * rng.standard_normal(n)
    f1, f2, f3 = VOWELS[vowel]
    voiced = resonate(source, f1, 110) + 0.8 * resonate(source, f2, 140) + 0.3 * resonate(source, f3, 220)
    env = envelope(n, 0.012, duration * 0.9, 0.025)
    sig = voiced * env
    # Letupan konsonan di awal suku kata.
    burst_n = int(0.018 * SR)
    burst = np.diff(rng.standard_normal(burst_n), prepend=0.0) * np.exp(-np.arange(burst_n) / SR / 0.006)
    sig[:burst_n] += burst * 0.35 * np.abs(sig).max()
    return sig


def make_babble(seed: int, f0: float, vowels: str, durations, slope: float, gap: float = 0.035,
                breathy: float = 0.04, loudness: float = 0.55) -> np.ndarray:
    rng = np.random.default_rng(seed)
    pieces = []
    count = len(vowels)
    for i, vowel in enumerate(vowels):
        progress = i / max(1, count - 1)
        base = f0 * (1.0 + slope * (progress - 0.5))  # intonasi naik/turun sepanjang kalimat
        stress = 1.0 + (0.07 if i % 2 == 0 else 0.0)  # suku kata bertekanan sedikit lebih tinggi
        start, end = base * stress, base * (1.0 + 0.04 * slope)
        pieces.append(syllable(start, end, vowel, durations[i % len(durations)], rng, breathy))
        pieces.append(np.zeros(int(gap * SR)))
    sig = np.concatenate(pieces[:-1])
    sig = sig / (np.abs(sig).max() + 1e-9) * loudness
    fade = int(0.012 * SR)
    sig[-fade:] *= np.linspace(1.0, 0.0, fade)
    return sig


# nama -> argumen make_babble. Satu file per baris dialog di scripts/data/npc_voices.gd.
VOICES = {
    "customer_1": dict(seed=11, f0=220, vowels="iaoie", durations=[0.11, 0.10, 0.14], slope=0.30),
    "customer_2": dict(seed=12, f0=235, vowels="eauioa", durations=[0.10, 0.12], slope=-0.10),
    "customer_3": dict(seed=13, f0=205, vowels="oiea", durations=[0.13, 0.11, 0.18], slope=0.45),
    "vendor_1": dict(seed=21, f0=150, vowels="aoao", durations=[0.13, 0.17], slope=0.20, loudness=0.62),
    "vendor_2": dict(seed=22, f0=140, vowels="aoaoia", durations=[0.11, 0.15], slope=-0.15, loudness=0.62),
    "vendor_3": dict(seed=23, f0=160, vowels="oaeao", durations=[0.12, 0.16, 0.12], slope=0.15, loudness=0.62),
    "pedestrian_1": dict(seed=31, f0=190, vowels="eou", durations=[0.12, 0.16], slope=0.10),
    "pedestrian_2": dict(seed=32, f0=270, vowels="iaei", durations=[0.10, 0.13], slope=0.25),
    "pedestrian_3": dict(seed=33, f0=310, vowels="uaiou", durations=[0.09, 0.12], slope=-0.20),
    "sender_1": dict(seed=41, f0=175, vowels="aeiou", durations=[0.11, 0.14], slope=0.20),
    "sender_2": dict(seed=42, f0=200, vowels="oaie", durations=[0.12, 0.15], slope=0.35),
}


# ------------------------------------------------------------------ pemeriksaan


def describe(path: Path) -> dict:
    data = read_wav(path)
    peak = float(np.abs(data).max())
    rms = float(np.sqrt((data ** 2).mean()))
    return {"seconds": len(data) / SR, "peak": peak, "rms_db": 20 * np.log10(max(rms, 1e-9)),
            "nan": bool(np.isnan(data).any()), "data": data}


def check() -> int:
    errors = 0

    def fail(message: str) -> None:
        nonlocal errors
        errors += 1
        print("GAGAL:", message)

    music = MUSIC_DIR / "gameplay_ceria.wav"
    if not music.exists():
        fail(f"{music} belum ada")
    else:
        info = describe(music)
        data = info["data"]
        expected = LOOP_SAMPLES / SR
        print(f"musik  : {info['seconds']:.3f}s (target {expected:.3f}s)  puncak {info['peak']:.2f}  rata-rata {info['rms_db']:.1f} dBFS")
        if abs(info["seconds"] - expected) > 1.0 / SR:
            fail("panjang musik tidak tepat satu loop (16 birama)")
        if info["peak"] >= 0.8 or info["nan"]:
            fail("musik terlalu keras (puncak >= 0,8) atau berisi NaN")
        if not (-21.0 <= info["rms_db"] <= -16.0):
            fail("level rata-rata musik di luar -21..-16 dBFS (terlalu pelan menutupi/ tertutup suara NPC)")
        # Sambungan loop: lompatan antar sampel terakhir -> pertama harus sekecil lompatan biasa.
        seam = abs(float(data[0] - data[-1]))
        typical = float(np.percentile(np.abs(np.diff(data)), 99))
        print(f"loop   : lompatan di sambungan {seam:.4f}, lompatan biasa (persentil 99) {typical:.4f}")
        if seam > typical:
            fail("sambungan loop terdengar klik (lompatan lebih besar dari biasa)")
        # Celah: energi di sekitar titik sambung (75 ms sebelum + 75 ms sesudah) tidak boleh senyap.
        # (Ketukan 1 sengaja lebih keras dari ujung birama, jadi bukan itu yang diukur.)
        win = int(0.075 * SR)
        around = np.concatenate([data[-win:], data[:win]])
        overall = float(np.sqrt((data ** 2).mean()))
        ratio = float(np.sqrt((around ** 2).mean())) / overall
        print(f"         energi di sekitar sambungan = {ratio:.2f}x rata-rata lagu")
        if ratio < 0.3:
            fail("area sambungan loop nyaris senyap (terdengar celah saat loop)")

    for name in VOICES:
        path = VOICE_DIR / f"{name}.wav"
        if not path.exists():
            fail(f"{path} belum ada")
            continue
        info = describe(path)
        print(f"suara  : {name:13s} {info['seconds']:.2f}s  puncak {info['peak']:.2f}")
        if not (0.2 <= info["seconds"] <= 1.6):
            fail(f"{name}: durasi di luar 0,2-1,6 detik")
        if info["peak"] >= 0.95 or info["peak"] < 0.1 or info["nan"]:
            fail(f"{name}: level tidak wajar")
    print("hasil  :", "OK" if errors == 0 else f"{errors} masalah")
    return 1 if errors else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true", help="hanya periksa file yang sudah ada")
    args = parser.parse_args()
    if not args.check:
        write_wav(MUSIC_DIR / "gameplay_ceria.wav", make_music())
        for name, params in VOICES.items():
            write_wav(VOICE_DIR / f"{name}.wav", make_babble(**params))
        print(f"dibuat: 1 musik + {len(VOICES)} suara NPC")
    return check()


if __name__ == "__main__":
    sys.exit(main())
