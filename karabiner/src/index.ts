// Aligned to vial/corne-keymap.vil (combos, nav, home row mods)
import {
  ifDevice,
  map,
  mapSimultaneous,
  rule,
  writeToProfile,
} from "karabiner.ts";
import { capsWord, hrm, holdTapLayer } from "karabiner.ts-greg-mods";

const builtIn = ifDevice({ is_built_in_keyboard: true });

writeToProfile("Default", [
  rule("Remap kes")
    .condition(builtIn)
    .manipulators([map("spacebar", "command").to("spacebar", "control")]),

  // Combos: order and set match corne-keymap.vil
  rule("Combos")
    .condition(builtIn)
    .manipulators([
      mapSimultaneous(["q", "w"], { key_up_when: "any" }).to("escape"),
      mapSimultaneous(["z", "x"], { key_up_when: "any" }).to("tab"),
      mapSimultaneous(["j", "k", "l"], { key_up_when: "any" }).to(
        "return_or_enter",
      ),
      mapSimultaneous(["f", "j", "k", "l"], { key_up_when: "any" }).to(
        "return_or_enter",
        "command",
      ),
      mapSimultaneous(["a", "j", "k", "l"], { key_up_when: "any" }).to(
        "return_or_enter",
        "shift",
      ),
      mapSimultaneous(["j", "l"], { key_up_when: "any" }).to(
        "delete_or_backspace",
      ),
      mapSimultaneous(["l", ";"], { key_up_when: "any" }).to(
        "delete_or_backspace",
      ),
      mapSimultaneous(["j", "k"], { key_up_when: "any" }).to(
        "left_arrow",
        "option",
      ),
      mapSimultaneous(["k", "l"], { key_up_when: "any" }).to(
        "right_arrow",
        "option",
      ),
    ]),

  holdTapLayer("spacebar")
    .permissiveHoldManipulators(
      map("h").to("left_arrow"),
      map("j").to("down_arrow"),
      map("k").to("up_arrow"),
      map("l").to("right_arrow"),
      map("u").to("page_down"),
      map("i").to("page_up"),
      map("s").to("up_arrow", "control"),
      map("d").to("left_arrow", "control"),
      map("f").to("right_arrow", "control"),
      map("c").to("open_bracket", ["command", "shift"]),
      map("v").to("close_bracket", ["command", "shift"]),
      map("q").to("q", "option"),
      map("w").to("w", "option"),
      map("e").to("e", "option"),
      map("r").to("r", "option"),
      map("t").to("t", "option"),
    )
    .tappingTerm(300)
    .description("Nav layer")
    .build(),

  rule("Disable Cmd+H").manipulators([
    map("h", "command").to("vk_none"),
    map("m", "command").to("vk_none"),
    map("h", "option").to("vk_none"),
  ]),

  capsWord()
    .toggle(
      mapSimultaneous(["a", ";"], { key_up_when: "any" })
        .condition(builtIn)
        .build()[0],
    )
    .build(),

  rule("Home row mods")
    .condition(builtIn)
    .manipulators(
      hrm(
        new Map([
          ["a", "left_shift"],
          ["s", "left_control"],
          ["d", "left_option"],
          ["f", "left_command"],
          [";", "right_shift"],
          ["j", "right_command"],
          ["k", "right_option"],
          ["l", "right_control"],
        ]),
      )
        .holdTapStrategy("permissive-hold")
        .tappingTerm(300)
        .build(),
    ),
]);
