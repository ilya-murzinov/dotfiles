// Aligned to vial/corne-keymap-mini.vil (combos, nav, mouse, home row mods)
import {
  ifDevice,
  ifVar,
  map,
  mapSimultaneous,
  rule,
  toSetVar,
  writeToProfile,
} from 'karabiner.ts'
import { capsWord, hrm, holdTapLayer } from "karabiner.ts-greg-mods";

const builtIn = ifDevice({ is_built_in_keyboard: true });
const navActive = ifVar('nav_layer', 1);
const mouseActive = ifVar('mouse_layer', 1);

writeToProfile(
  'Default',
  [
  rule('Remap kes').condition(builtIn).manipulators([
    map('spacebar', 'command').to('spacebar', 'control'),
  ]),

  // Combos: order and set match corne-keymap-mini.vil
  rule('Combos').condition(builtIn).manipulators([
    mapSimultaneous(['q', 'w'], { key_up_when: 'any' }).to('escape'),
    mapSimultaneous(['z', 'x'], { key_up_when: 'any' }).to('tab'),
    mapSimultaneous(['j', 'k', 'l'], { key_up_when: 'any' }).to('return_or_enter'),
    mapSimultaneous(['a', 's'], { key_up_when: 'any' }).to('tab'),
    mapSimultaneous(['f', 'j', 'k', 'l'], { key_up_when: 'any' }).to('return_or_enter', 'command'),
    mapSimultaneous(['a', 'j', 'k', 'l'], { key_up_when: 'any' }).to('return_or_enter', 'shift'),
    mapSimultaneous(['j', 'l'], { key_up_when: 'any' }).to('delete_or_backspace'),
    mapSimultaneous(['l', ';'], { key_up_when: 'any' }).to('delete_or_backspace'),
    mapSimultaneous(['j', 'k'], { key_up_when: 'any' }).to('left_arrow', 'option'),
    mapSimultaneous(['k', 'l'], { key_up_when: 'any' }).to('right_arrow', 'option'),
  ]),

  holdTapLayer('spacebar')
    .permissiveHoldManipulators(
      map('h').to('left_arrow'),
      map('j').to('down_arrow'),
      map('k').to('up_arrow'),
      map('l').to('right_arrow'),
      map('u').to('page_down'),
      map('i').to('page_up'),
      map('s').to('up_arrow', 'control'),
      map('d').to('left_arrow', 'control'),
      map('f').to('right_arrow', 'control'),
      map('c').to('open_bracket', 'command'),
      map('v').to('close_bracket', 'command'),
      map('m').to({ key_code: 'open_bracket', modifiers: ['command', 'shift'] }),
      map(',').to({ key_code: 'close_bracket', modifiers: ['command', 'shift'] }),
  )
  .tappingTerm(300)
  .description("Nav layer")
  .build(),

  // Mouse layer: d+f together (matches Vial combo LALT_T(D)+LGUI_T(F) -> MO(5))
  rule('Mouse layer').condition(builtIn).manipulators([
    mapSimultaneous(['d', 'f'], { key_up_when: 'any' })
      .to(toSetVar('mouse_layer', 1))
      .toAfterKeyUp(toSetVar('mouse_layer', 0)),
    map('h').condition(mouseActive).toMouseKey({ x: -200, speed_multiplier: 10 }),
    map('j').condition(mouseActive).toMouseKey({ y: 200, speed_multiplier: 10 }),
    map('k').condition(mouseActive).toMouseKey({ y: -200, speed_multiplier: 10 }),
    map('l').condition(mouseActive).toMouseKey({ x: 200, speed_multiplier: 10 }),
    map('u').condition(mouseActive).toMouseKey({ vertical_wheel: 1 }),
    map('i').condition(mouseActive).toMouseKey({ vertical_wheel: -1 }),
    map(',').condition(mouseActive).toMouseKey({ horizontal_wheel: -1 }),
    map('.').condition(mouseActive).toMouseKey({ horizontal_wheel: 1 }),
    map('spacebar').condition(mouseActive).toPointingButton('button1'),
    map('right_command').condition(mouseActive).toPointingButton('button2'),
  ]),

  rule('Disable Cmd+H').manipulators([
    map('h', 'command').to('vk_none'),
    map('m', 'command').to('vk_none'),
    map('h', 'option').to('vk_none'),
  ]),

  capsWord()
    .toggle(mapSimultaneous(['a', ';'], { key_up_when: 'any' }).condition(builtIn).build()[0])
    .build(),

  rule("Home row mods").condition(builtIn).manipulators(
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
      ]))
      .holdTapStrategy("permissive-hold")
      .tappingTerm(300)
      .build()
  ),
])
