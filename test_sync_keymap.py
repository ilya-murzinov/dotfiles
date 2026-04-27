#!/usr/bin/env python3
"""Tests for sync-keymap.py — documents the QMK→ZMK mapping behavior."""

import unittest
import sync_keymap
from sync_keymap import (
    parse_key,
    extract_layer,
    resolve,
    build_vial_position_map,
    format_combo,
    format_combos,
    splice_combos,
    build_macros_map,
    _decode_zmk_macro,
    _vial_macro_text,
    COMBO_CONFIG,
    MACROS,
    translate_totem_to_piantor_key_positions,
    totem_38_to_piantor_36,
    zmk_only_entry_for_piantor,
)


class TestResolve(unittest.TestCase):
    def test_simple_letter(self):
        self.assertEqual(resolve("KC_A"), "A")

    def test_simple_number(self):
        self.assertEqual(resolve("KC_1"), "N1")

    def test_unknown_raises(self):
        with self.assertRaises(ValueError):
            resolve("KC_NONEXISTENT")


class TestParseKeySimple(unittest.TestCase):
    def test_transparent(self):
        self.assertEqual(parse_key("KC_TRNS", 0, 0), "&trans")

    def test_no_key(self):
        self.assertEqual(parse_key("KC_NO", 0, 0), "&none")

    def test_spacer_raises(self):
        with self.assertRaises(ValueError):
            parse_key(-1, 0, 0)

    def test_letter(self):
        self.assertEqual(parse_key("KC_Q", 0, 0), "&kp Q")

    def test_number(self):
        self.assertEqual(parse_key("KC_5", 0, 0), "&kp N5")

    def test_punctuation(self):
        self.assertEqual(parse_key("KC_COMMA", 0, 0), "&kp COMMA")
        self.assertEqual(parse_key("KC_DOT", 0, 0), "&kp DOT")
        self.assertEqual(parse_key("KC_SCOLON", 0, 0), "&kp SEMI")

    def test_navigation(self):
        self.assertEqual(parse_key("KC_LEFT", 0, 0), "&kp LEFT")
        self.assertEqual(parse_key("KC_BSPACE", 0, 0), "&kp BSPC")
        self.assertEqual(parse_key("KC_PGUP", 0, 0), "&kp PAGE_UP")

    def test_unknown_raises(self):
        with self.assertRaises(ValueError):
            parse_key("KC_NONEXISTENT_KEY", 0, 0)


class TestParseKeyMouse(unittest.TestCase):
    def test_mouse_move(self):
        self.assertEqual(parse_key("KC_MS_L", 0, 0), "&mmv MOVE_LEFT")
        self.assertEqual(parse_key("KC_MS_U", 0, 0), "&mmv MOVE_UP")

    def test_mouse_scroll(self):
        self.assertEqual(parse_key("KC_WH_R", 0, 0), "&msc SCRL_RIGHT")
        self.assertEqual(parse_key("KC_WH_D", 0, 0), "&msc SCRL_DOWN")

    def test_mouse_button(self):
        self.assertEqual(parse_key("KC_BTN1", 0, 0), "&mkp MB1")
        self.assertEqual(parse_key("KC_BTN2", 0, 0), "&mkp MB2")


class TestParseKeyMedia(unittest.TestCase):
    def test_playback(self):
        self.assertEqual(parse_key("KC_MPLY", 0, 0), "&kp C_PLAY_PAUSE")

    def test_volume(self):
        self.assertEqual(parse_key("KC_VOLU", 0, 0), "&kp C_VOLUME_UP")
        self.assertEqual(parse_key("KC_VOLD", 0, 0), "&kp C_VOL_DN")
        self.assertEqual(parse_key("KC_MUTE", 0, 0), "&kp K_MUTE")

    def test_brightness(self):
        self.assertEqual(parse_key("KC_BRIU", 0, 0), "&kp C_BRIGHTNESS_INC")
        self.assertEqual(parse_key("KC_BRID", 0, 0), "&kp C_BRIGHTNESS_DEC")


class TestParseKeyTapDance(unittest.TestCase):
    def test_known_tap_dances(self):
        self.assertEqual(parse_key("TD(0)", 0, 0), "&eq_td")
        self.assertEqual(parse_key("TD(1)", 0, 0), "&minus_td")
        self.assertEqual(parse_key("TD(5)", 0, 0), "&paren_td")
        self.assertEqual(parse_key("TD(11)", 0, 0), "&apos_quote")
        self.assertEqual(parse_key("TD(13)", 0, 0), "&tilde_td")

    def test_unknown_tap_dance_raises(self):
        with self.assertRaises(ValueError):
            parse_key("TD(99)", 0, 0)


class TestParseKeyMacro(unittest.TestCase):
    def setUp(self):
        self._orig = dict(MACROS)
        MACROS.clear()
        MACROS.update({4: "&name", 5: "&last_name", 6: "&personal_email"})

    def tearDown(self):
        MACROS.clear()
        MACROS.update(self._orig)

    def test_known_macros(self):
        self.assertEqual(parse_key("M4", 0, 0), "&name")
        self.assertEqual(parse_key("M5", 0, 0), "&last_name")
        self.assertEqual(parse_key("M6", 0, 0), "&personal_email")

    def test_unknown_macro_raises(self):
        with self.assertRaises(ValueError):
            parse_key("M99", 0, 0)


class TestDecodeZmkMacro(unittest.TestCase):
    def test_plain_letters(self):
        self.assertEqual(_decode_zmk_macro("&kp I &kp L &kp I &kp A"), "ilia")

    def test_shifted_letter(self):
        self.assertEqual(_decode_zmk_macro("&kp LS(I) &kp L &kp I &kp A"), "Ilia")

    def test_email(self):
        result = _decode_zmk_macro(
            "&kp M &kp U &kp R &kp Z &kp N4 &kp N2 &kp AT &kp G &kp M &kp A &kp I &kp L &kp DOT &kp C &kp O &kp M"
        )
        self.assertEqual(result, "murz42@gmail.com")

    def test_cursor_keys_skipped(self):
        self.assertEqual(_decode_zmk_macro("&kp LPAR &kp RPAR &kp LEFT"), "()")

    def test_non_kp_returns_none(self):
        self.assertIsNone(_decode_zmk_macro("&kp A &mo 1"))

    def test_unknown_keycode_returns_none(self):
        self.assertIsNone(_decode_zmk_macro("&kp NONEXISTENT"))

    def test_empty_returns_none(self):
        self.assertIsNone(_decode_zmk_macro(""))


class TestVialMacroText(unittest.TestCase):
    def test_plain_text(self):
        self.assertEqual(_vial_macro_text([["text", "Ilia"]]), "Ilia")

    def test_text_with_cursor_tap(self):
        self.assertEqual(_vial_macro_text([["text", "()"], ["tap", "KC_LEFT"]]), "()")

    def test_unknown_tap_returns_none(self):
        self.assertIsNone(_vial_macro_text([["text", "x"], ["tap", "KC_F1"]]))

    def test_non_text_action_returns_none(self):
        self.assertIsNone(_vial_macro_text([["delay", 100]]))

    def test_empty_returns_none(self):
        self.assertIsNone(_vial_macro_text([]))


class TestBuildMacrosMap(unittest.TestCase):
    _ZMK = """
        name: name {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp LS(I) &kp L &kp I &kp A>;
        };
        personal_email: personal_email {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            bindings = <&kp M &kp U &kp R &kp Z &kp N4 &kp N2 &kp AT &kp G &kp M &kp A &kp I &kp L &kp DOT &kp C &kp O &kp M>;
        };
    """

    def test_matches_by_text(self):
        vil_macros = [
            [],                           # 0: empty
            [],                           # 1: empty
            [["text", "Ilia"]],           # 2: matches &name
            [["text", "murz42@gmail.com"]],  # 3: matches &personal_email
        ]
        result = build_macros_map(vil_macros, self._ZMK)
        self.assertEqual(result, {2: "&name", 3: "&personal_email"})

    def test_skips_empty_macros(self):
        result = build_macros_map([[], []], self._ZMK)
        self.assertEqual(result, {})

    def test_skips_unmatched_macros(self):
        vil_macros = [[["text", "no match here"]]]
        result = build_macros_map(vil_macros, self._ZMK)
        self.assertEqual(result, {})

    def test_skips_non_text_macros(self):
        vil_macros = [[["delay", 100]]]
        result = build_macros_map(vil_macros, self._ZMK)
        self.assertEqual(result, {})


class TestParseKeyModTap(unittest.TestCase):
    """Mod-tap behavior depends on layer and position.

    Base layer positions 10-13 use &hml (home row mod left).
    Base layer positions 16-19 use &hmr (home row mod right).
    All other positions/layers use &mt.
    """

    def test_hml_on_base_layer_left(self):
        self.assertEqual(
            parse_key("LSFT_T(KC_A)", layer=0, pos=10),
            "&hml LEFT_SHIFT A",
        )
        self.assertEqual(
            parse_key("LGUI_T(KC_F)", layer=0, pos=13),
            "&hml LEFT_GUI F",
        )

    def test_hmr_on_base_layer_right(self):
        self.assertEqual(
            parse_key("RGUI_T(KC_J)", layer=0, pos=16),
            "&hmr LEFT_GUI J",  # LEFT_GUI intentional — macOS doesn't distinguish L/R
        )
        self.assertEqual(
            parse_key("RSFT_T(KC_SCOLON)", layer=0, pos=19),
            "&hmr RIGHT_SHIFT SEMI",
        )

    def test_mt_on_non_base_layer(self):
        self.assertEqual(
            parse_key("RALT_T(KC_RBRACKET)", layer=3, pos=17),
            "&mt RIGHT_ALT RIGHT_BRACKET",
        )

    def test_mt_on_base_layer_non_homerow(self):
        self.assertEqual(
            parse_key("LSFT_T(KC_Z)", layer=0, pos=21),
            "&mt LEFT_SHIFT Z",
        )


class TestParseKeyLayerTap(unittest.TestCase):
    def test_layer_tap(self):
        self.assertEqual(parse_key("LT3(KC_SPACE)", 0, 0), "&lt 3 SPACE")
        self.assertEqual(parse_key("LT4(KC_SPACE)", 0, 0), "&lt 4 SPACE")


class TestParseKeyMomentaryLayer(unittest.TestCase):
    def test_momentary(self):
        self.assertEqual(parse_key("MO(2)", 0, 0), "&mo 2")
        self.assertEqual(parse_key("MO(6)", 0, 0), "&mo 6")


class TestParseKeyShifted(unittest.TestCase):
    """Shifted keys use named ZMK aliases on most layers,
    but use LS(Nn) physical form on the Russian layer (layer 1)
    because the symbols have different meanings in the Russian layout.
    """

    def test_named_form_on_symbol_layers(self):
        self.assertEqual(parse_key("LSFT(KC_1)", layer=3, pos=0), "&kp EXCL")
        self.assertEqual(parse_key("LSFT(KC_2)", layer=3, pos=1), "&kp AT")
        self.assertEqual(parse_key("LSFT(KC_SLASH)", layer=3, pos=4), "&kp QUESTION")
        self.assertEqual(parse_key("LSFT(KC_MINUS)", layer=3, pos=0), "&kp UNDER")
        self.assertEqual(parse_key("LSFT(KC_0)", layer=4, pos=0), "&kp RPAR")
        self.assertEqual(parse_key("LSFT(KC_6)", layer=4, pos=0), "&kp CARET")
        self.assertEqual(parse_key("LSFT(KC_RBRACKET)", layer=3, pos=0), "&kp RIGHT_BRACE")

    def test_ls_form_on_russian_layer(self):
        self.assertEqual(parse_key("LSFT(KC_7)", layer=1, pos=4), "&kp LS(N7)")
        self.assertEqual(parse_key("LSFT(KC_2)", layer=1, pos=10), "&kp LS(N2)")
        self.assertEqual(parse_key("LSFT(KC_6)", layer=1, pos=11), "&kp LS(N6)")

    def test_shifted_slash_on_russian_layer(self):
        self.assertEqual(parse_key("LSFT(KC_SLASH)", layer=1, pos=22), "&kp LS(SLASH)")


class TestParseKeyModifierWrappers(unittest.TestCase):
    def test_single_modifier(self):
        self.assertEqual(parse_key("LGUI(KC_1)", 0, 0), "&kp LG(N1)")
        self.assertEqual(parse_key("LCTL(KC_UP)", 0, 0), "&kp LC(UP)")
        self.assertEqual(parse_key("LCTL(KC_LEFT)", 0, 0), "&kp LC(LEFT)")

    def test_sgui_combined(self):
        self.assertEqual(
            parse_key("SGUI(KC_LBRACKET)", 0, 0),
            "&kp LG(LS(LEFT_BRACKET))",
        )
        self.assertEqual(
            parse_key("SGUI(KC_RBRACKET)", 0, 0),
            "&kp LG(LS(RIGHT_BRACKET))",
        )

    def test_lcag_combined(self):
        self.assertEqual(
            parse_key("LCAG(KC_LEFT)", 0, 0),
            "&kp LG(LA(LC(LEFT)))",
        )
        self.assertEqual(
            parse_key("LCAG(KC_F)", 0, 0),
            "&kp LG(LA(LC(F)))",
        )

    def test_lcg_combined(self):
        self.assertEqual(parse_key("LCG(KC_F)", 0, 0), "&kp LG(LC(F))")


class TestParseKeyMisc(unittest.TestCase):
    def test_rgb_becomes_none(self):
        self.assertEqual(parse_key("RGB_TOG", 0, 0), "&none")

    def test_caps_word(self):
        self.assertEqual(parse_key("QK_CAPS_WORD_TOGGLE", 0, 0), "&caps_word")


class TestExtractLayer(unittest.TestCase):
    """Test the physical layout mapping from Corne (6-col) to Totem (5-col).

    Corne Vial layout per half: 4 rows x 7 elements each.
      - Index 0: spacer (-1)
      - Indices 1-5: main 5 columns
      - Index 6: extra 6th column (ignored for Totem)

    Right half keys are stored in reverse column order in Vial.
    """

    def _make_layer(self, left_rows, right_rows):
        """Build a minimal Vial layer structure."""
        return left_rows + right_rows

    def test_row0_left_to_right(self):
        layer = self._make_layer(
            [[-1, "KC_Q", "KC_W", "KC_E", "KC_R", "KC_T", "KC_NO"]] + [[-1] + ["KC_NO"] * 6] * 3,
            [[-1, "KC_NO", "KC_NO", "KC_NO", "KC_NO", "KC_NO", "KC_NO"]] * 4,
        )
        keys = extract_layer(layer, 0)
        self.assertEqual(keys[0], "&kp Q")
        self.assertEqual(keys[4], "&kp T")

    def test_right_half_reversal(self):
        """Right half indices [5..1] map to ZMK left-to-right."""
        layer = self._make_layer(
            [[-1] + ["KC_NO"] * 6] * 4,
            [[-1, "KC_P", "KC_O", "KC_I", "KC_U", "KC_Y", "KC_NO"]] + [[-1] + ["KC_NO"] * 6] * 3,
        )
        keys = extract_layer(layer, 0)
        # Right row 0: Vial[5]=Y → pos5, Vial[4]=U → pos6, etc.
        self.assertEqual(keys[5], "&kp Y")
        self.assertEqual(keys[6], "&kp U")
        self.assertEqual(keys[7], "&kp I")
        self.assertEqual(keys[8], "&kp O")
        self.assertEqual(keys[9], "&kp P")

    def test_row2_has_none_padding(self):
        """Row 2 gets &none at positions 20 and 31 (non-existent Totem keys)."""
        layer = self._make_layer(
            [[-1] + ["KC_NO"] * 6] * 2
            + [[-1, "KC_Z", "KC_X", "KC_C", "KC_V", "KC_B", -1]]
            + [[-1] + ["KC_NO"] * 6],
            [[-1] + ["KC_NO"] * 6] * 2
            + [[-1, "KC_NO", "KC_NO", "KC_NO", "KC_NO", "KC_NO", -1]]
            + [[-1] + ["KC_NO"] * 6],
        )
        keys = extract_layer(layer, 0)
        self.assertEqual(keys[20], "&none")  # left padding
        self.assertEqual(keys[21], "&kp Z")  # first real key
        self.assertEqual(keys[31], "&none")  # right padding

    def test_extra_6th_column_ignored(self):
        """Index 6 of each Vial row (extra Corne column) is not extracted."""
        layer = self._make_layer(
            [[-1, "KC_Q", "KC_W", "KC_E", "KC_R", "KC_T", "KC_MPLY"]] + [[-1] + ["KC_NO"] * 6] * 3,
            [[-1, "KC_P", "KC_O", "KC_I", "KC_U", "KC_Y", "KC_MPLY"]] + [[-1] + ["KC_NO"] * 6] * 3,
        )
        keys = extract_layer(layer, 0)
        # KC_MPLY at index 6 should not appear anywhere
        self.assertNotIn("&kp C_PLAY_PAUSE", keys)

    def test_thumb_mapping(self):
        """Thumb keys: left [3,4,5] outer→inner, right [5,4,3] inner→outer."""
        layer = self._make_layer(
            [[-1] + ["KC_NO"] * 6] * 3
            + [[-1, -1, -1, "KC_A", "KC_B", "KC_C", -1]],
            [[-1] + ["KC_NO"] * 6] * 3
            + [[-1, -1, -1, "KC_Z", "KC_Y", "KC_X", -1]],
        )
        keys = extract_layer(layer, 0)
        # Left thumb: [3]=A(outer/32), [4]=B(mid/33), [5]=C(inner/34)
        self.assertEqual(keys[32], "&kp A")
        self.assertEqual(keys[33], "&kp B")
        self.assertEqual(keys[34], "&kp C")
        # Right thumb: [5]=X(inner/35), [4]=Y(mid/36), [3]=Z(outer/37)
        self.assertEqual(keys[35], "&kp X")
        self.assertEqual(keys[36], "&kp Y")
        self.assertEqual(keys[37], "&kp Z")

    def test_produces_38_keys(self):
        """Totem has exactly 38 key positions."""
        layer = [[-1] + ["KC_NO"] * 6] * 4 + [[-1] + ["KC_NO"] * 6] * 4
        # Fix thumb rows to have proper spacers
        layer[3] = [-1, -1, -1, "KC_NO", "KC_NO", "KC_NO", -1]
        layer[7] = [-1, -1, -1, "KC_NO", "KC_NO", "KC_NO", -1]
        keys = extract_layer(layer, 0)
        self.assertEqual(len(keys), 38)


def _make_minimal_layer():
    """Return a minimal all-KC_NO Vial layer (8 rows x 7 cols)."""
    base = [[-1] + ["KC_NO"] * 6] * 4
    thumb = [[-1, -1, -1, "KC_NO", "KC_NO", "KC_NO", -1]]
    return base + thumb + [[-1] + ["KC_NO"] * 6] * 3 + thumb


class TestBuildVialPositionMap(unittest.TestCase):
    def _vil(self, layers):
        return {"layout": layers, "combo": []}

    def test_base_layer_letters(self):
        layer = _make_minimal_layer()
        layer[0] = [-1, "KC_Q", "KC_W", "KC_E", "KC_R", "KC_T", "KC_NO"]
        layer[4] = [-1, "KC_P", "KC_O", "KC_I", "KC_U", "KC_Y", "KC_NO"]
        pos_map = build_vial_position_map(self._vil([layer]))
        self.assertEqual(pos_map["KC_Q"], 0)
        self.assertEqual(pos_map["KC_W"], 1)
        self.assertEqual(pos_map["KC_T"], 4)
        # Right half is stored reversed in Vial: col 5→pos5, col 1→pos9
        self.assertEqual(pos_map["KC_Y"], 5)
        self.assertEqual(pos_map["KC_P"], 9)

    def test_bottom_row_positions(self):
        layer = _make_minimal_layer()
        layer[2] = [-1, "KC_Z", "KC_X", "KC_C", "KC_V", "KC_B", -1]
        pos_map = build_vial_position_map(self._vil([layer]))
        self.assertEqual(pos_map["KC_Z"], 21)
        self.assertEqual(pos_map["KC_X"], 22)
        self.assertEqual(pos_map["KC_B"], 25)

    def test_thumb_positions(self):
        layer = _make_minimal_layer()
        layer[3] = [-1, -1, -1, "MO(2)", "LT4(KC_SPACE)", "MO(5)", -1]
        layer[7] = [-1, -1, -1, "MO(6)", "MO(1)", "LT3(KC_SPACE)", -1]
        pos_map = build_vial_position_map(self._vil([layer]))
        # Left thumbs: col3→32, col4→33, col5→34
        self.assertEqual(pos_map["MO(2)"], 32)
        self.assertEqual(pos_map["LT4(KC_SPACE)"], 33)
        self.assertEqual(pos_map["MO(5)"], 34)
        # Right thumbs reversed: col5→35, col4→36, col3→37
        self.assertEqual(pos_map["LT3(KC_SPACE)"], 35)
        self.assertEqual(pos_map["MO(1)"], 36)
        self.assertEqual(pos_map["MO(6)"], 37)

    def test_base_layer_takes_priority_over_later_layers(self):
        """A keycode from the base layer is not overridden if it reappears at a
        different position in a later layer."""
        base = _make_minimal_layer()
        base[0] = [-1, "KC_Q", "KC_NO", "KC_NO", "KC_NO", "KC_NO", "KC_NO"]  # KC_Q at pos 0
        nav = _make_minimal_layer()
        nav[1] = [-1, "KC_Q", "KC_NO", "KC_NO", "KC_NO", "KC_NO", "KC_NO"]  # KC_Q at pos 10
        pos_map = build_vial_position_map(self._vil([base, nav]))
        # Base layer position 0 should win over nav layer position 10
        self.assertEqual(pos_map["KC_Q"], 0)

    def test_nav_layer_keys_found_when_absent_from_base(self):
        base = _make_minimal_layer()
        nav = _make_minimal_layer()
        nav[5] = [-1, "KC_BSPACE", "KC_RIGHT", "KC_UP", "KC_DOWN", "KC_LEFT", "KC_NO"]
        pos_map = build_vial_position_map(self._vil([base, nav]))
        # Right half row 1, reversed: col5→15, col4→16, col3→17, col2→18, col1→19
        self.assertEqual(pos_map["KC_LEFT"], 15)
        self.assertEqual(pos_map["KC_DOWN"], 16)
        self.assertEqual(pos_map["KC_UP"], 17)
        self.assertEqual(pos_map["KC_RIGHT"], 18)


class TestFormatCombo(unittest.TestCase):
    def _pos_map(self):
        # Minimal position map with known positions
        return {
            "KC_Q": 0,
            "KC_W": 1,
            "RGUI_T(KC_J)": 16,
            "RALT_T(KC_K)": 17,
            "RCTL_T(KC_L)": 18,
            "MO(1)": 36,
            "MO(2)": 33,
        }

    def test_simple_two_key_combo(self):
        combo = ["KC_Q", "KC_W", "KC_NO", "KC_NO", "KC_ESCAPE"]
        result = format_combo(0, combo, self._pos_map())
        self.assertIn("left_esc {", result)
        self.assertIn("bindings = <&kp ESCAPE>;", result)
        self.assertIn("key-positions = <0 1>;", result)

    def test_three_key_combo_with_timeout(self):
        combo = ["RGUI_T(KC_J)", "RALT_T(KC_K)", "RCTL_T(KC_L)", "KC_NO", "KC_ENTER"]
        result = format_combo(2, combo, self._pos_map())
        self.assertIn("enter {", result)
        self.assertIn("key-positions = <16 17 18>;", result)
        self.assertIn("timeout-ms = <100>;", result)

    def test_slow_release_and_layers(self):
        combo = ["RGUI_T(KC_J)", "RALT_T(KC_K)", "RCTL_T(KC_L)", "KC_NO", "MO(5)"]
        # Reuse index 7 (mouse_layer) config
        pos_map = {**self._pos_map(), "LALT_T(KC_D)": 12, "LGUI_T(KC_F)": 13, "LCTL_T(KC_S)": 11}
        combo7 = ["LALT_T(KC_D)", "LGUI_T(KC_F)", "LCTL_T(KC_S)", "KC_NO", "MO(5)"]
        result = format_combo(7, combo7, pos_map)
        self.assertIn("mouse_layer {", result)
        self.assertIn("slow-release;", result)
        self.assertIn("layers = <0 2>;", result)

    def test_caps_word_output(self):
        combo = ["MO(1)", "MO(2)", "KC_NO", "KC_NO", "QK_CAPS_WORD_TOGGLE"]
        result = format_combo(6, combo, self._pos_map())
        self.assertIn("caps_word {", result)
        self.assertIn("bindings = <&caps_word>;", result)
        self.assertIn("key-positions = <36 33>;", result)

    def test_unknown_trigger_key_raises(self):
        combo = ["KC_NONEXISTENT", "KC_W", "KC_NO", "KC_NO", "KC_ESCAPE"]
        with self.assertRaises(ValueError, msg="should raise for unmapped trigger key"):
            format_combo(0, combo, self._pos_map())

    def test_fallback_name_for_unconfigured_index(self):
        combo = ["KC_Q", "KC_W", "KC_NO", "KC_NO", "KC_ESCAPE"]
        result = format_combo(99, combo, self._pos_map())
        self.assertIn("combo_99 {", result)


class TestSpliceCombos(unittest.TestCase):
    _TEMPLATE = (
        '/ {\n'
        '    combos {\n'
        '        compatible = "zmk,combos";\n'
        '\n'
        '        old_combo {\n'
        '            bindings = <&kp A>;\n'
        '            key-positions = <0 1>;\n'
        '        };\n'
        '    };\n'
        '\n'
        '    keymap {\n'
        '        compatible = "zmk,keymap";\n'
        '    };\n'
        '};\n'
    )

    def test_replaces_combo_content(self):
        new_content = (
            '        new_combo {\n'
            '            bindings = <&kp B>;\n'
            '            key-positions = <2 3>;\n'
            '        };'
        )
        result = splice_combos(self._TEMPLATE, new_content)
        self.assertIn("new_combo", result)
        self.assertNotIn("old_combo", result)

    def test_preserves_surrounding_structure(self):
        result = splice_combos(self._TEMPLATE, "        x {};\n        y {};")
        self.assertIn('compatible = "zmk,combos";', result)
        self.assertIn('compatible = "zmk,keymap";', result)

    def test_raises_when_no_combos_block(self):
        with self.assertRaises(ValueError):
            splice_combos("no combos here", "content")


class TestPiantorTotemTranslation(unittest.TestCase):
    def test_totem_to_piantor_bt_chords(self):
        self.assertEqual(translate_totem_to_piantor_key_positions("<34 21>"), "<32 20>")
        self.assertEqual(translate_totem_to_piantor_key_positions("<35 34>"), "<33 32>")
        self.assertEqual(translate_totem_to_piantor_key_positions("<34 0 10 21>"), "<32 0 10 20>")

    def test_bt_clear_override(self):
        entry = zmk_only_entry_for_piantor(
            {"name": "bt_clear", "bindings": "<&bt BT_CLR>", "key-positions": "<34 20>", "layers": "<6>"}
        )
        self.assertEqual(entry["key-positions"], "<32 35>")

    def test_totem_38_to_piantor_36_drops_padding(self):
        k = [f"{i}" for i in range(38)]
        out = totem_38_to_piantor_36(k)
        self.assertEqual(len(out), 36)
        self.assertEqual(out[19], "19")
        self.assertEqual(out[20], "21")
        self.assertEqual(out[29], "30")
        self.assertEqual(out[30], "32")


if __name__ == "__main__":
    unittest.main()
