#!/usr/bin/env python3
"""Sync Vial (.vil) keymap to ZMK Totem and Piantor (5×5 Corne-style) keymaps.

Reads the Vial JSON layout and updates layer bindings and combos in
totem.keymap and zmk-piantor/config/piantor_pro_bt.keymap, preserving behaviors
and macros. Piantor omits Totem’s bottom-row &none padding; ZMK-only combo
positions are translated, except bt_clear (kept <32 35> to avoid a clash with
bt_0 on 5-col boards).

Usage: python3 sync_keymap.py [vial_file] [zmk_path]
"""

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent
VIL_DEFAULT = REPO / "vial" / "corne-keymap.vil"
ZMK_DEFAULT = REPO / "zmk" / "config" / "totem.keymap"
# Same logical layout as Totem; physical layout 5+5 / 3 thumb pairs (Vial / Corne)
PIANTOR_KEYMAP = REPO / "zmk-piantor" / "config" / "piantor_pro_bt.keymap"

# ── Configuration ─────────────────────────────────────────────────────────────
# Update these when adding new layers, tap dances, or macros.

LAYER_NAMES = ["base", "rus", "nav", "sym", "sym_add", "mouse", "media", "macros"]

# QMK tap dance and macro indices are independent namespaces; overlap is expected.
TAP_DANCES = {
    0: "&eq_td",
    1: "&minus_td",
    2: "&plus_td",
    3: "&mult_td",
    4: "&div_td",
    5: "&paren_td",
    6: "&bracket_td",
    7: "&curly_td",
    8: "&grave_td",
    9: "&pipe_td",
    10: "&amp_td",
    11: "&apos_quote",
    13: "&tilde_td",
}

# Auto-populated at runtime by matching Vial macro text against ZMK macro output.
# No manual updates needed when rearranging macros in Vial.
MACROS: dict[int, str] = {}

# Per-combo ZMK properties that can't be derived from Vial.
# Keys are Vial combo indices; omitted indices use defaults (no timeout/layers).
COMBO_CONFIG = {
    0:  {"name": "left_esc"},
    1:  {"name": "tab"},
    2:  {"name": "enter", "timeout_ms": 100},
    3:  {"name": "language_switch", "timeout_ms": 300, "layers": [0, 2]},
    6:  {"name": "caps_word", "timeout_ms": 100},
    7:  {"name": "mouse_layer", "slow_release": True, "layers": [0, 2]},
    8:  {"name": "backspace", "timeout_ms": 100},
    9:  {"name": "l_word", "timeout_ms": 100, "layers": [2]},
    10: {"name": "r_word", "layers": [2]},
}

# ZMK-only combos that have no Vial equivalent (Bluetooth, system reset, etc.).
_ZMK_ONLY_COMBOS = [
    {
        "name": "del_word",
        "bindings": "<&kp LA(BACKSPACE)>",
        "key-positions": "<35 16 17>",
        "layers": "<0 2>",
    },
    {
        "name": "del_word_fw",
        "bindings": "<&kp LA(DELETE)>",
        "key-positions": "<17 18 35>",
        "layers": "<0 2>",
    },
    {
        "name": "bt_clear",
        "bindings": "<&bt BT_CLR>",
        "key-positions": "<34 20>",
        "layers": "<6>",
    },
    {
        "name": "bt_0",
        "bindings": "<&bt BT_SEL 0>",
        "key-positions": "<34 21>",
        "layers": "<6>",
    },
    {
        "name": "bt_1",
        "bindings": "<&bt BT_SEL 1>",
        "key-positions": "<34 10>",
        "layers": "<6>",
    },
    {
        "name": "bt_2",
        "bindings": "<&bt BT_SEL 2>",
        "key-positions": "<34 0>",
        "layers": "<6>",
    },
    {
        "name": "reset",
        "bindings": "<&sys_reset>",
        "key-positions": "<34 0 10 21>",
        "layers": "<6>",
    },
]

# Piantor: Totem <34 20> and <34 21> would both end up on <32 20>; use a distinct
# chord (BT clear). Other entries use translate_totem_to_piantor_key_positions.
_ZMK_ONLY_COMBOS_PIANTOR_OVERRIDES = {
    "bt_clear": {"key-positions": "<32 35>"},
}

# ── Macro auto-detection ──────────────────────────────────────────────────────

# ZMK keycode → character it produces (lowercase; LS(X) produces X.upper())
_ZMK_KEY_CHAR: dict[str, str] = {
    **{c: c.lower() for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"},
    **{f"N{d}": d for d in "0123456789"},
    "COMMA": ",", "DOT": ".", "SLASH": "/", "FSLH": "/", "SEMI": ";",
    "SQT": "'", "BACKSLASH": "\\", "LEFT_BRACKET": "[", "RIGHT_BRACKET": "]",
    "LBKT": "[", "RBKT": "]", "LBRC": "{", "RBRC": "}",
    "MINUS": "-", "EQUAL": "=", "GRAVE": "`", "SPACE": " ",
    "AT": "@", "EXCL": "!", "HASH": "#", "DOLLAR": "$", "PERCENT": "%",
    "CARET": "^", "AMPS": "&", "ASTRK": "*", "STAR": "*",
    "LPAR": "(", "RPAR": ")", "UNDER": "_", "PLUS": "+",
    "QUESTION": "?", "PIPE": "|", "TILDE": "~", "DOUBLE_QUOTES": '"',
    "COLON": ":",
}

_ZMK_CURSOR_KEYS = {
    "LEFT", "RIGHT", "UP", "DOWN", "BSPC", "RET", "TAB", "ESCAPE", "HOME", "END",
}


def _decode_zmk_macro(bindings_str: str) -> str | None:
    """Decode a ZMK macro bindings string to the text it types.

    Returns None for macros with non-text actions (e.g., layer changes).
    Cursor-movement keys (&kp LEFT etc.) are skipped — they don't produce text.
    """
    text = []
    for part in bindings_str.split("&"):
        part = part.strip()
        if not part:
            continue
        tokens = part.split()
        behavior, args = tokens[0], tokens[1:]
        if behavior != "kp" or not args:
            return None
        keycode = args[0]
        ls_m = re.match(r"^LS\((\w+)\)$", keycode)
        if ls_m:
            char = _ZMK_KEY_CHAR.get(ls_m.group(1))
            if char is None:
                return None
            text.append(char.upper())
        elif keycode in _ZMK_CURSOR_KEYS:
            pass
        else:
            char = _ZMK_KEY_CHAR.get(keycode)
            if char is None:
                return None
            text.append(char)
    return "".join(text) or None


def _parse_zmk_macro_texts(zmk_text: str) -> dict[str, str]:
    """Parse ZMK keymap for behavior-macro definitions. Returns {name: typed_text}."""
    result = {}
    macro_re = re.compile(
        r"(\w+):\s*\w+\s*\{[^}]*?"
        r'compatible\s*=\s*"zmk,behavior-macro"[^}]*?'
        r"bindings\s*=\s*<([^>]*)>",
        re.DOTALL,
    )
    for m in macro_re.finditer(zmk_text):
        name, bindings = m.group(1), m.group(2).strip()
        decoded = _decode_zmk_macro(bindings)
        if decoded:
            result[name] = decoded
    return result


def _vial_macro_text(actions: list) -> str | None:
    """Extract the text a Vial macro types. Returns None for non-text macros."""
    _skip_taps = {"KC_LEFT", "KC_RIGHT", "KC_UP", "KC_DOWN", "KC_BSPACE", "KC_ENTER", "KC_TAB"}
    text = []
    for action in actions:
        kind = action[0]
        if kind == "text":
            text.append(action[1])
        elif kind == "tap":
            if action[1] not in _skip_taps:
                return None
        else:
            return None
    return "".join(text) or None


def build_macros_map(vil_macros: list, zmk_text: str) -> dict[int, str]:
    """Auto-detect Vial macro index → ZMK behavior name by matching typed text.

    Decodes both sides to the string they produce and matches on equality.
    Macros with no text equivalent (non-text actions) are silently skipped.
    """
    zmk_name_by_text = {text: name for name, text in _parse_zmk_macro_texts(zmk_text).items()}
    result = {}
    for idx, actions in enumerate(vil_macros):
        if not actions:
            continue
        vial_text = _vial_macro_text(actions)
        if vial_text is None:
            continue
        zmk_name = zmk_name_by_text.get(vial_text)
        if zmk_name:
            result[idx] = f"&{zmk_name}"
    return result


# ── Keycode tables ────────────────────────────────────────────────────────────

# Positions where home-row mods live (base layer only)
HML_POS = {10, 11, 12, 13}
HMR_POS = {16, 17, 18, 19}

# QMK mod-tap prefix → ZMK modifier name
MOD_TAP = {
    "LSFT_T": "LEFT_SHIFT",
    "LCTL_T": "LCTRL",
    "LALT_T": "LEFT_ALT",
    "LGUI_T": "LEFT_GUI",
    "RSFT_T": "RIGHT_SHIFT",
    "RCTL_T": "RCTRL",
    "RALT_T": "RIGHT_ALT",
    "RGUI_T": "LEFT_GUI",  # macOS doesn't distinguish L/R GUI
}

# QMK simple keycode → ZMK keycode
SIMPLE = {
    **{f"KC_{c}": c for c in "QWERTYUIOPASDFGHJKLZXCVBNM"},
    "KC_1": "N1", "KC_2": "N2", "KC_3": "N3", "KC_4": "N4", "KC_5": "N5",
    "KC_6": "N6", "KC_7": "N7", "KC_8": "N8", "KC_9": "N9", "KC_0": "N0",
    "KC_COMMA": "COMMA",
    "KC_DOT": "DOT",
    "KC_SLASH": "SLASH",
    "KC_SCOLON": "SEMI",
    "KC_BSLASH": "BACKSLASH",
    "KC_LBRACKET": "LEFT_BRACKET",
    "KC_RBRACKET": "RIGHT_BRACKET",
    "KC_MINUS": "MINUS",
    "KC_EQUAL": "EQUAL",
    "KC_GRAVE": "GRAVE",
    "KC_QUOTE": "SQT",
    "KC_LSHIFT": "LEFT_SHIFT",
    "KC_RSHIFT": "RIGHT_SHIFT",
    "KC_LCTRL": "LCTRL",
    "KC_RCTRL": "RCTRL",
    "KC_LALT": "LEFT_ALT",
    "KC_RALT": "RIGHT_ALT",
    "KC_LGUI": "LEFT_GUI",
    "KC_RGUI": "RIGHT_GUI",
    "KC_LEFT": "LEFT",
    "KC_RIGHT": "RIGHT",
    "KC_UP": "UP",
    "KC_DOWN": "DOWN",
    "KC_PGUP": "PAGE_UP",
    "KC_PGDOWN": "PAGE_DOWN",
    "KC_HOME": "HOME",
    "KC_END": "END",
    "KC_BSPACE": "BSPC",
    "KC_DELETE": "DELETE",
    "KC_ENTER": "RET",
    "KC_TAB": "TAB",
    "KC_ESCAPE": "ESCAPE",
    "KC_SPACE": "SPACE",
    "KC_MPLY": "C_PLAY_PAUSE",
    "KC_VOLU": "C_VOLUME_UP",
    "KC_VOLD": "C_VOL_DN",
    "KC_MUTE": "K_MUTE",
    "KC_BRIU": "C_BRIGHTNESS_INC",
    "KC_BRID": "C_BRIGHTNESS_DEC",
}

# LSFT(KC_X) → (named ZMK alias, raw ZMK key for LS() form)
SHIFTED = {
    "KC_1": ("EXCL", "N1"),
    "KC_2": ("AT", "N2"),
    "KC_3": ("HASH", "N3"),
    "KC_4": ("DOLLAR", "N4"),
    "KC_5": ("PERCENT", "N5"),
    "KC_6": ("CARET", "N6"),
    "KC_7": ("AMPS", "N7"),
    "KC_8": ("ASTRK", "N8"),
    "KC_9": ("LPAR", "N9"),
    "KC_0": ("RPAR", "N0"),
    "KC_MINUS": ("UNDER", "MINUS"),
    "KC_EQUAL": ("PLUS", "EQUAL"),
    "KC_SLASH": ("QUESTION", "SLASH"),
    "KC_LBRACKET": ("LEFT_BRACE", "LEFT_BRACKET"),
    "KC_RBRACKET": ("RIGHT_BRACE", "RIGHT_BRACKET"),
    "KC_BSLASH": ("PIPE", "BACKSLASH"),
    "KC_GRAVE": ("TILDE", "GRAVE"),
    "KC_QUOTE": ("DOUBLE_QUOTES", "SQT"),
}

# Mouse/pointing keycodes → full ZMK binding (not &kp)
MOUSE = {
    "KC_MS_L": "&mmv MOVE_LEFT",
    "KC_MS_R": "&mmv MOVE_RIGHT",
    "KC_MS_U": "&mmv MOVE_UP",
    "KC_MS_D": "&mmv MOVE_DOWN",
    "KC_WH_L": "&msc SCRL_LEFT",
    "KC_WH_R": "&msc SCRL_RIGHT",
    "KC_WH_U": "&msc SCRL_UP",
    "KC_WH_D": "&msc SCRL_DOWN",
    "KC_BTN1": "&mkp MB1",
    "KC_BTN2": "&mkp MB2",
}

# Single-modifier wrapper → ZMK modifier function
MOD_WRAP = {
    "LGUI": "LG", "RGUI": "RG", "LCTL": "LC", "RCTL": "RC",
    "LALT": "LA", "RALT": "RA", "LSFT": "LS", "RSFT": "RS",
}

# Combined-modifier wrappers → ZMK nesting
COMBINED_WRAP = {
    "SGUI": lambda k: f"LG(LS({k}))",
    "LCAG": lambda k: f"LG(LA(LC({k})))",
    "LCG": lambda k: f"LG(LC({k}))",
}

# ── Keycode parser ────────────────────────────────────────────────────────────


def resolve(code):
    """Resolve a QMK keycode to its ZMK name."""
    if code in SIMPLE:
        return SIMPLE[code]
    raise ValueError(f"Unknown keycode in resolve: {code!r} — add it to SIMPLE table")


def parse_key(code, layer, pos):
    """Convert a single QMK keycode to a ZMK binding string."""
    if code == -1 or code is None:
        raise ValueError(f"Unexpected spacer (-1/None) at layer {layer} pos {pos}")

    if code == "KC_TRNS":
        return "&trans"
    if code == "KC_NO":
        return "&none"
    if code in MOUSE:
        return MOUSE[code]
    if code in SIMPLE:
        return f"&kp {SIMPLE[code]}"

    # Tap dance: TD(n)
    m = re.match(r"^TD\((\d+)\)$", code)
    if m:
        idx = int(m.group(1))
        if idx not in TAP_DANCES:
            raise ValueError(f"Unknown tap dance TD({idx}) at layer {layer} pos {pos}")
        return TAP_DANCES[idx]

    # Vial macro: Mn
    m = re.match(r"^M(\d+)$", code)
    if m:
        idx = int(m.group(1))
        if idx not in MACROS:
            raise ValueError(f"Unknown macro M{idx} at layer {layer} pos {pos}")
        return MACROS[idx]

    # Mod-tap: XXXX_T(KC_YYY)
    m = re.match(r"^(\w+_T)\((\w+)\)$", code)
    if m:
        mod, key = m.group(1), m.group(2)
        if mod in MOD_TAP:
            zmk_mod = MOD_TAP[mod]
            zmk_key = resolve(key)
            if layer == 0 and pos in HML_POS:
                return f"&hml {zmk_mod} {zmk_key}"
            if layer == 0 and pos in HMR_POS:
                return f"&hmr {zmk_mod} {zmk_key}"
            return f"&mt {zmk_mod} {zmk_key}"

    # Layer-tap: LTn(KC_YYY)
    m = re.match(r"^LT(\d+)\((\w+)\)$", code)
    if m:
        return f"&lt {m.group(1)} {resolve(m.group(2))}"

    # Momentary layer: MO(n)
    m = re.match(r"^MO\((\d+)\)$", code)
    if m:
        return f"&mo {m.group(1)}"

    # Modifier wrapper: XXXX(KC_YYY)
    m = re.match(r"^(\w+)\((\w+)\)$", code)
    if m:
        wrap, inner = m.group(1), m.group(2)

        if wrap in COMBINED_WRAP:
            return f"&kp {COMBINED_WRAP[wrap](resolve(inner))}"

        if wrap == "LSFT" and inner in SHIFTED:
            named, raw = SHIFTED[inner]
            # Russian layer: use LS() form (physical key meaning, not symbol)
            if layer == 1:
                return f"&kp LS({raw})"
            return f"&kp {named}"

        if wrap in MOD_WRAP:
            return f"&kp {MOD_WRAP[wrap]}({resolve(inner)})"

    # RGB (Totem has no RGB LEDs)
    if code.startswith("RGB_"):
        return "&none"

    # QMK special keycodes
    if code == "QK_CAPS_WORD_TOGGLE":
        return "&caps_word"

    raise ValueError(f"Unknown keycode: {code!r} at layer {layer} pos {pos}")


# ── Layout extraction ─────────────────────────────────────────────────────────


def extract_layer(layer_data, layer_idx):
    """Extract 38 Totem key bindings from a Corne Vial layer.

    Corne layout: 8 rows of 7 elements each (4 left-half rows + 4 right-half).
    Totem layout: 38 keys (10 + 10 + 12 + 6).

    Returns a list of 38 ZMK binding strings.
    """
    left, right = layer_data[:4], layer_data[4:]
    keys = []

    # Rows 0-1 (top, home): 5 left + 5 right = 10 each
    for row in range(2):
        for i in range(1, 6):
            keys.append(parse_key(left[row][i], layer_idx, len(keys)))
        for i in range(5, 0, -1):
            keys.append(parse_key(right[row][i], layer_idx, len(keys)))

    # Row 2 (bottom): &none + 5 left + 5 right + &none = 12
    keys.append("&none")
    for i in range(1, 6):
        keys.append(parse_key(left[2][i], layer_idx, len(keys)))
    for i in range(5, 0, -1):
        keys.append(parse_key(right[2][i], layer_idx, len(keys)))
    keys.append("&none")

    # Thumb: left [3,4,5] outer→inner + right [5,4,3] inner→outer = 6
    for i in range(3, 6):
        keys.append(parse_key(left[3][i], layer_idx, len(keys)))
    for i in range(5, 2, -1):
        keys.append(parse_key(right[3][i], layer_idx, len(keys)))

    return keys


# ── Formatting ────────────────────────────────────────────────────────────────


def format_layer(name, keys):
    """Format a layer as column-aligned ZMK keymap text."""
    # Collect keys per column (10 columns: 0-4 left, 5-9 right)
    col_keys = {i: [] for i in range(10)}
    for row_keys in [keys[0:10], keys[10:20], keys[21:31]]:
        for i, k in enumerate(row_keys):
            col_keys[i].append(k)
    for i, k in enumerate(keys[32:35]):
        col_keys[i + 2].append(k)
    for i, k in enumerate(keys[35:38]):
        col_keys[i + 5].append(k)

    widths = {i: max((len(k) for k in ks), default=0) for i, ks in col_keys.items()}

    sep = "    "
    prefix = " " * 7  # align with row 2 content (after "&none  ")

    def fmt(key_list, col_start, pad_last=False):
        parts = []
        for i, k in enumerate(key_list):
            col = col_start + i
            if i < len(key_list) - 1 or pad_last:
                parts.append(k.ljust(widths[col]))
            else:
                parts.append(k)
        return "  ".join(parts)

    r0 = f"{prefix}{fmt(keys[0:5], 0, pad_last=True)}{sep}{fmt(keys[5:10], 5)}"
    r1 = f"{prefix}{fmt(keys[10:15], 0, pad_last=True)}{sep}{fmt(keys[15:20], 5)}"
    r2 = f"&none  {fmt(keys[21:26], 0, pad_last=True)}{sep}{fmt(keys[26:31], 5)}  &none"

    thumb_offset = len(prefix) + widths[0] + 2 + widths[1] + 2
    r3 = f"{' ' * thumb_offset}{fmt(keys[32:35], 2, pad_last=True)}{sep}{fmt(keys[35:38], 5)}"

    return "\n".join([
        f"        {name} {{",
        f"            bindings = <",
        r0,
        r1,
        r2,
        r3,
        f"            >;",
        f"        }};",
    ])


def totem_38_to_piantor_36(keys: list) -> list:
    """Drop Totem bottom-row padding keys (indices 20 and 31)."""
    if len(keys) != 38:
        raise ValueError(f"expected 38 Totem keys, got {len(keys)}")
    return keys[0:20] + keys[21:31] + keys[32:38]


def translate_totem_to_piantor_key_positions(angles: str) -> str:
    """Map Totem physical indices (0–37) to Piantor 5×5+3 (0–35)."""
    m = re.search(r"<\s*([\d\s]+)\s*>", angles.strip())
    if not m:
        raise ValueError(f"expected <…> in {angles!r}")

    def map_pos(p: int) -> int:
        if p < 20:
            return p
        if p == 20:
            return 20
        if 21 <= p <= 30:
            return p - 1
        if p == 31:
            return 29
        if 32 <= p <= 37:
            return p - 2
        raise ValueError(f"invalid Totem key position {p}")

    parts = m.group(1).split()
    return "<" + " ".join(str(map_pos(int(x))) for x in parts) + ">"


def format_layer_piantor(name, keys_38):
    """36-key Corne-style row (no bottom &none padding) matching five_col ZMK order."""
    k = totem_38_to_piantor_36(keys_38)
    col_keys = {i: [] for i in range(10)}
    for row_keys in (k[0:10], k[10:20], k[20:30]):
        for i, key in enumerate(row_keys):
            col_keys[i].append(key)
    for i, key in enumerate(k[30:33]):
        col_keys[i + 2].append(key)
    for i, key in enumerate(k[33:36]):
        col_keys[i + 5].append(key)
    widths = {i: max((len(x) for x in col_keys[i]), default=0) for i in range(10)}

    sep = "    "
    prefix = " " * 7

    def fmt(key_list, col_start, pad_last=False):
        parts = []
        for j, key in enumerate(key_list):
            col = col_start + j
            if j < len(key_list) - 1 or pad_last:
                parts.append(key.ljust(widths[col]))
            else:
                parts.append(key)
        return "  ".join(parts)

    r0 = f"{prefix}{fmt(k[0:5], 0, pad_last=True)}{sep}{fmt(k[5:10], 5)}"
    r1 = f"{prefix}{fmt(k[10:15], 0, pad_last=True)}{sep}{fmt(k[15:20], 5)}"
    r2 = f"{prefix}{fmt(k[20:25], 0, pad_last=True)}{sep}{fmt(k[25:30], 5)}"
    thumb_offset = len(prefix) + widths[0] + 2 + widths[1] + 2
    r3 = f"{' ' * thumb_offset}{fmt(k[30:33], 2, pad_last=True)}{sep}{fmt(k[33:36], 5)}"

    return "\n".join([
        f"        {name} {{",
        f"            bindings = <",
        r0, r1, r2, r3,
        f"            >;",
        f"        }};",
    ])


# ── File splicing ─────────────────────────────────────────────────────────────


def splice_keymap(zmk_text, layers_text):
    """Replace the keymap layers in the ZMK file, preserving everything else."""
    marker = 'compatible = "zmk,keymap";'
    marker_pos = zmk_text.find(marker)
    if marker_pos == -1:
        raise ValueError("Could not find keymap section in ZMK file")

    # Everything up to and including the marker line + blank line
    marker_end = zmk_text.index("\n", marker_pos) + 1
    header = zmk_text[:marker_end]

    # Find the closing "    };\n};" from the marker onward
    tail_pattern = re.compile(r"\n(    \};\n\};)\s*$")
    tail_match = tail_pattern.search(zmk_text, marker_end)
    if not tail_match:
        raise ValueError("Could not find keymap closing braces")

    footer = "\n" + tail_match.group(1) + "\n"

    return header + "\n" + layers_text + "\n" + footer


# ── Combo syncing ─────────────────────────────────────────────────────────────


def build_vial_position_map(vil):
    """Map each raw Vial keycode to its Totem physical position (0-37).

    Scans all layers in order; earlier layers (lower index) take priority,
    so base-layer keycodes like LALT_T(KC_D) are preferred over their
    nav-layer equivalents, while nav-layer-only keycodes like KC_UP are
    picked up from their first appearance in any layer.
    """
    pos_map = {}

    for layer_data in vil["layout"]:
        left, right = layer_data[:4], layer_data[4:]
        pos = 0

        def register(code):
            nonlocal pos
            if code not in ("KC_NO", "KC_TRNS", -1) and code not in pos_map:
                pos_map[code] = pos
            pos += 1

        for row in range(2):
            for i in range(1, 6):
                register(left[row][i])
            for i in range(5, 0, -1):
                register(right[row][i])

        pos += 1  # position 20: &none (left edge of bottom row)
        for i in range(1, 6):
            register(left[2][i])
        for i in range(5, 0, -1):
            register(right[2][i])
        pos += 1  # position 31: &none (right edge of bottom row)

        for i in range(3, 6):
            register(left[3][i])
        for i in range(5, 2, -1):
            register(right[3][i])

    return pos_map


def format_combo(idx, vial_combo, pos_map):
    """Format a single Vial combo entry as a ZMK combo block string."""
    trigger_keys = [k for k in vial_combo[:4] if k != "KC_NO"]
    output_key = vial_combo[4]

    positions = []
    for k in trigger_keys:
        if k not in pos_map:
            raise ValueError(f"Combo {idx}: trigger key {k!r} not found in any layer")
        positions.append(pos_map[k])

    binding = parse_key(output_key, layer=0, pos=0)
    cfg = COMBO_CONFIG.get(idx, {})
    name = cfg.get("name", f"combo_{idx}")

    lines = [
        f"        {name} {{",
        f"            bindings = <{binding}>;",
        f"            key-positions = <{' '.join(str(p) for p in positions)}>;",
    ]
    if "timeout_ms" in cfg:
        lines.append(f"            timeout-ms = <{cfg['timeout_ms']}>;")
    if cfg.get("slow_release"):
        lines.append(f"            slow-release;")
    if "layers" in cfg:
        lines.append(f"            layers = <{' '.join(str(l) for l in cfg['layers'])}>;")
    lines.append(f"        }};")

    return "\n".join(lines)


def format_zmk_only_combo(entry):
    """Format a ZMK-only combo dict as a combo block string."""
    lines = [f"        {entry['name']} {{"]
    lines.append(f"            bindings = {entry['bindings']};")
    lines.append(f"            key-positions = {entry['key-positions']};")
    if "timeout-ms" in entry:
        lines.append(f"            timeout-ms = {entry['timeout-ms']};")
    if entry.get("slow-release"):
        lines.append(f"            slow-release;")
    if "layers" in entry:
        lines.append(f"            layers = {entry['layers']};")
    lines.append(f"        }};")
    return "\n".join(lines)


def format_combos(vil):
    """Generate all ZMK combo block text from Vial combo data + ZMK-only combos."""
    pos_map = build_vial_position_map(vil)

    blocks = []
    for idx, combo in enumerate(vil["combo"]):
        output_key = combo[4]
        if output_key == "KC_NO":
            continue
        trigger_keys = [k for k in combo[:4] if k != "KC_NO"]
        if not trigger_keys:
            continue
        blocks.append(format_combo(idx, combo, pos_map))

    for entry in _ZMK_ONLY_COMBOS:
        blocks.append(format_zmk_only_combo(entry))

    return "\n\n".join(blocks)


def build_vial_position_map_piantor(vil):
    """Map Vial keycodes to Piantor physical order (0–35; no Totem &none padding)."""
    pos_map = {}

    for layer_data in vil["layout"]:
        left, right = layer_data[:4], layer_data[4:]
        pos = 0

        def register(code):
            nonlocal pos
            if code not in ("KC_NO", "KC_TRNS", -1) and code not in pos_map:
                pos_map[code] = pos
            pos += 1

        for row in range(2):
            for i in range(1, 6):
                register(left[row][i])
            for i in range(5, 0, -1):
                register(right[row][i])

        for i in range(1, 6):
            register(left[2][i])
        for i in range(5, 0, -1):
            register(right[2][i])

        for i in range(3, 6):
            register(left[3][i])
        for i in range(5, 2, -1):
            register(right[3][i])

    return pos_map


def zmk_only_entry_for_piantor(totem_entry: dict) -> dict:
    out = dict(totem_entry)
    ovr = _ZMK_ONLY_COMBOS_PIANTOR_OVERRIDES.get(totem_entry["name"], {})
    if ovr:
        out.update(ovr)
    else:
        out["key-positions"] = translate_totem_to_piantor_key_positions(
            totem_entry["key-positions"]
        )
    return out


def format_combos_piantor(vil):
    """Combos for Piantor vial key positions (5-col) + translated ZMK-only list."""
    pos_map = build_vial_position_map_piantor(vil)

    blocks = []
    for idx, combo in enumerate(vil["combo"]):
        output_key = combo[4]
        if output_key == "KC_NO":
            continue
        trigger_keys = [k for k in combo[:4] if k != "KC_NO"]
        if not trigger_keys:
            continue
        blocks.append(format_combo(idx, combo, pos_map))

    for entry in _ZMK_ONLY_COMBOS:
        blocks.append(format_zmk_only_combo(zmk_only_entry_for_piantor(entry)))

    return "\n\n".join(blocks)


def splice_combos(zmk_text, combos_content):
    """Replace the combos block content in the ZMK file."""
    pattern = re.compile(
        r'(    combos \{\n        compatible = "zmk,combos";\n\n)'
        r'.*?'
        r'(\n    \};)',
        re.DOTALL,
    )
    m = pattern.search(zmk_text)
    if not m:
        raise ValueError("Could not find combos block in ZMK file")
    return zmk_text[: m.start()] + m.group(1) + combos_content + m.group(2) + zmk_text[m.end():]


# ── Main ──────────────────────────────────────────────────────────────────────


def main():
    vil_path = Path(sys.argv[1]) if len(sys.argv) > 1 else VIL_DEFAULT
    zmk_path = Path(sys.argv[2]) if len(sys.argv) > 2 else ZMK_DEFAULT
    piantor_path = Path(sys.argv[3]) if len(sys.argv) > 3 else PIANTOR_KEYMAP

    vil = json.loads(vil_path.read_text())
    zmk_text = zmk_path.read_text()

    MACROS.clear()
    MACROS.update(build_macros_map(vil.get("macro", []), zmk_text))

    layer_blocks = []
    piantor_layer_blocks = []
    for i, name in enumerate(LAYER_NAMES):
        if i >= len(vil["layout"]):
            break
        keys = extract_layer(vil["layout"][i], i)
        layer_blocks.append(format_layer(name, keys))
        piantor_layer_blocks.append(format_layer_piantor(name, keys))

    layers_text = "\n\n".join(layer_blocks)
    new_text = splice_keymap(zmk_text, layers_text)

    combos_content = format_combos(vil)
    new_text = splice_combos(new_text, combos_content)

    zmk_path.write_text(new_text)

    piantor_text = piantor_path.read_text()
    MACROS.clear()
    MACROS.update(build_macros_map(vil.get("macro", []), piantor_text))
    piantor_layers_text = "\n\n".join(piantor_layer_blocks)
    piantor_new = splice_keymap(piantor_text, piantor_layers_text)
    piantor_new = splice_combos(piantor_new, format_combos_piantor(vil))
    piantor_path.write_text(piantor_new)

    active_combos = sum(
        1 for c in vil["combo"] if c[4] != "KC_NO" and any(k != "KC_NO" for k in c[:4])
    )
    print(
        f"Synced {len(layer_blocks)} layers + {active_combos} combos"
        f" from {vil_path.name} → {zmk_path.name} and {piantor_path.name}"
    )


if __name__ == "__main__":
    main()
