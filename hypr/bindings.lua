-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Custom app bindings (preinstalled webapps/signal/music/obsidian disabled in hyprland.lua)
-- Swap SUPER+F and SUPER+ALT+F (was: SUPER+F=fullscreen, SUPER+ALT+F=maximized)
hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.unbind("SUPER + CTRL + E")
hl.unbind("SUPER + PERIOD")
o.bind("SUPER + PERIOD", "Emojis", "omarchy-shell shell toggle omarchy.emojis")

o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
o.bind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })

hl.unbind("SUPER + D")
o.bind("SUPER + D", "Docker", { tui = "omarchy-launch-docker-tui" })

hl.unbind("SUPER + SHIFT + D")
o.bind("SUPER + SHIFT + D", "Discord", { launch = "discord" })

hl.unbind("SUPER + B")
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + ALT + B")
o.bind("SUPER + B", "Browser", { launch = "google-chrome-stable" })
o.bind("SUPER + SHIFT + B", "Browser private", { launch = "google-chrome-stable --incognito" })

hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Foot", { launch = "foot" })

hl.unbind("SUPER + M")
o.bind("SUPER + M", "Zed", { launch = "zeditor" })

hl.unbind("SUPER + N")
o.bind("SUPER + N", "Omawrite", { launch = "omawrite" })

o.bind("ALT + SPACE", "OmaCast", "omarchy-shell shell toggle io.github.terrifiedbug.omacast '{}'")

-- Niri-like hold-to-repeat focus movement (default binds fire once per
-- press; holding them did nothing). Unbind then re-bind with repeating.
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }), { repeating = true })
o.bind("SUPER + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }), { repeating = true })
o.bind("SUPER + UP", "Focus on upper window", hl.dsp.focus({ direction = "u" }), { repeating = true })
o.bind("SUPER + DOWN", "Focus on lower window", hl.dsp.focus({ direction = "d" }), { repeating = true })

-- Activity monitor (btop) via the initial standard omarchy TUI launcher
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- Screenshot on SUPER + SHIFT + S (same action as PRINT)
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")
