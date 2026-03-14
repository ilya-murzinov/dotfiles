# Karabiner (macOS) keyboard config

Source for [Karabiner-Elements](https://karabiner-elements.pablo.tools/) in TypeScript ([karabiner.ts](https://github.com/evan-liu/karabiner.ts)). HRM, nav layer (space), combos, mouse layer, Caps Word.

**Install:** From dotfiles root run `make karabiner`. That runs `npm install` and `npm run build` here; the build writes to `~/.config/karabiner/karabiner.json`. Restart Karabiner-Elements if it’s running.

**Manual:** `cd karabiner && npm install && npm run build`