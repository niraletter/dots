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
hl.unbind("SUPER + Q")

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

-- Swap windows on SUPER+CTRL+LEFT/RIGHT too (mirrors SUPER+SHIFT+LEFT/RIGHT)
o.rebind("SUPER + CTRL + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.rebind("SUPER + CTRL + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + CTRL + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + CTRL + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

hl.unbind("SUPER + B")
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + ALT + B")
o.bind("SUPER + B", "Browser", { launch = "google-chrome-stable" })
o.bind("SUPER + SHIFT + B", "Browser private", { launch = "google-chrome-stable --incognito" })

hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Foot", { launch = "foot" })

hl.unbind("SUPER + M")
o.bind("SUPER + M", "Zed", { launch = "zeditor" })

hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "VS Code", { launch = "code" })

hl.unbind("SUPER + N")
o.bind("SUPER + N", "Omawrite", { launch = "omawrite" })

hl.unbind("ALT + SPACE")
-- Alt+Space binding removed
-- Niri-like focus bindings: one press = one focus move (no hold-to-repeat).
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + UP", "Focus on upper window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + DOWN", "Focus on lower window", hl.dsp.focus({ direction = "d" }))

-- Clone Activity (btop) onto SUPER + CTRL + T as well (was: Theme menu).
hl.unbind("SUPER + CTRL + T")
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

-- Screenshot on SUPER + SHIFT + S (same action as PRINT)
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- Push-to-talk: Caps Lock
o.bind_hold("code:66", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { ignore_mods = true })

-- Mouse left thumb button (back button) unbound.
hl.unbind("mouse:275")

-- Make Super+C/V work as copy/paste inside Zed's embedded terminal too.
-- Omarchy treats Zed as a non-terminal app, so Super+C defaults to Ctrl+C
-- (SIGINT in the terminal). Force Ctrl+Shift+C/V for Zed instead.
local function is_terminal(w)
  if not w then return false end
  if w.class == "dev.zed.Zed" then return true end
  for _, tag in ipairs(w.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then return true end
  end
  return false
end
local function universal_clipboard(key)
  return function()
    local w = hl.get_active_window()
    local mods = is_terminal(w) and "CTRL SHIFT" or "CTRL"
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
    hl.timer(function() hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" })) end, { timeout = 50, type = "oneshot" })
  end
end
hl.unbind("SUPER + C")
hl.unbind("SUPER + V")
o.bind("SUPER + C", "Universal copy", universal_clipboard("C"))
o.bind("SUPER + V", "Universal paste", universal_clipboard("V"))
