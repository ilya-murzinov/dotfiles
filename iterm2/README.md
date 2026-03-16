# iTerm2 config

iTerm2 does **not** use a `.iterm2.conf` file. It stores all preferences (key bindings, profiles, etc.) in a **plist**:

- **Default location:** `~/Library/Preferences/com.googlecode.iterm2.plist`
- **Here:** `iterm2/com.googlecode.iterm2.plist` (versioned in dotfiles)

## Symlink via Makefile

From the dotfiles repo root:

```bash
make install
```

This runs `link-iterm2`, which creates:

```
~/Library/Preferences/com.googlecode.iterm2.plist -> ~/dotfiles/iterm2/com.googlecode.iterm2.plist
```

iTerm2 will read and write the plist at the usual path; the real file lives in this repo.

## On a new machine

1. Clone dotfiles, run `make install` (or `make link-iterm2`).
2. Quit iTerm2 and reopen so it picks up the plist.

## Uninstall

```bash
make uninstall
```

removes the symlink (and other dotfile symlinks).

## If iTerm2 doesn't pick up the profile

1. **Fully quit iTerm2** (⌘Q or run `killall iTerm2`).
2. **Don't use "Load from custom folder"** — iTerm2 → Settings → General → under "Settings", **uncheck** "Load settings from a custom folder or URL". Then the app uses `~/Library/Preferences/` (your symlink).
3. **Install the font** if you use JetBrains Nerd: `brew install font-jetbrains-mono-nerd-font`.
4. Open iTerm2 again. If the font still doesn't apply, replace the symlink with a real copy once so iTerm2 definitely reads the file, then re-link:
   ```bash
   rm ~/Library/Preferences/com.googlecode.iterm2.plist
   cp ~/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/
   open -a iTerm2
   # after confirming it works, restore symlink:
   rm ~/Library/Preferences/com.googlecode.iterm2.plist
   ln -sf ~/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/
   ```
