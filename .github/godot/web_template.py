# Opsi SCons untuk template export Web Si Ngacir yang lebih ramping.
# Dipakai CI: scons platform=web target=template_release profile=.github/godot/web_template.py
#
# Game ini 2D murni, memakai font Latin, audio WAV, tekstur WebP/PNG, dan SVG
# (dimuat saat runtime untuk sprite resolusi tinggi). Modul lain dimatikan.
# Mengubah file ini membuat CI membangun ulang template (cache berdasarkan isi file).

optimize = "size"
lto = "full"
threads = "no"
disable_3d = "yes"

# Font: server teks sederhana cukup untuk huruf Latin.
module_text_server_adv_enabled = "no"
module_text_server_fb_enabled = "yes"

for _name in [
    "astcenc", "basis_universal", "bmp", "camera", "csg", "cvtt", "dds", "enet", "etcpak",
    "fbx", "gltf", "gridmap", "hdr", "interactive_music", "jpg", "jsonrpc", "ktx",
    "lightmapper_rd", "meshoptimizer", "minimp3", "mobile_vr", "msdfgen", "multiplayer",
    "noise", "ogg", "openxr", "raycast", "regex", "squish", "tga", "theora", "tinyexr",
    "upnp", "vhacd", "vorbis", "webrtc", "websocket", "webxr", "xatlas_unwrap", "zip",
]:
    globals()["module_%s_enabled" % _name] = "no"
