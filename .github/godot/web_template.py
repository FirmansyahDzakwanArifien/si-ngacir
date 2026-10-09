# Opsi SCons untuk template export Web Si Ngacir yang lebih ramping.
# Dipakai CI: scons platform=web target=template_release profile=.github/godot/web_template.py
#
# Game ini 2D dengan Tampilan 3D (beta) opsional, memakai font Latin, audio WAV,
# tekstur WebP/PNG, dan SVG (dimuat saat runtime untuk sprite resolusi tinggi).
# Inti 3D tetap ada (mesh dasar, Label3D, partikel, cahaya, langit prosedural);
# modul lain yang tidak dipakai dimatikan.
# Mengubah file ini membuat CI membangun ulang template (cache berdasarkan isi file).

optimize = "size"
lto = "full"
threads = "no"

# Font: server teks lengkap tetap dipakai (server sederhana salah mengukur Fredoka
# variabel sehingga teks tombol terpotong), tanpa dukungan font Graphite.
graphite = "no"

for _name in [
    "astcenc", "basis_universal", "bmp", "camera", "csg", "cvtt", "dds", "enet", "etcpak",
    "fbx", "gltf", "gridmap", "hdr", "interactive_music", "jpg", "jsonrpc", "ktx",
    "lightmapper_rd", "meshoptimizer", "minimp3", "mobile_vr", "msdfgen", "multiplayer",
    "noise", "ogg", "openxr", "raycast", "regex", "squish", "tga", "theora", "tinyexr",
    "upnp", "vhacd", "vorbis", "webrtc", "websocket", "webxr", "xatlas_unwrap", "zip",
]:
    globals()["module_%s_enabled" % _name] = "no"
