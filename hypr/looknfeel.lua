-- Change the default Omarchy look'n'feel.

-- Disable all window transparency (Omarchy defaults to 0.985 active / 0.96 inactive).
o.window(".*", { opacity = "1 1" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
 hl.config({
   general = {
     -- No gaps between windows or borders.
     gaps_in = 2,
     gaps_out = 0,
     border_size = 2,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
   },
 })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

hl.curve("niriOpen", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("niriClose", { type = "bezier", points = { { 0.5, 1 }, { 0.89, 1 } } })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.5, bezier = "niriOpen", style = "popin 50%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "niriClose", style = "popin 80%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.5, bezier = "niriOpen" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.5, bezier = "niriClose" })

hl.curve("niriMove", { type = "spring", mass = 1, stiffness = 2000, dampening = 100 })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 20, spring = "niriMove" })
hl.curve("niriWorkspace", { type = "spring", mass = 1, stiffness = 2000, dampening = 89 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, spring = "niriWorkspace", style = "slidevert" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- Two columns fill the screen edge to edge instead of leaving a 1% gap on
-- each side (Omarchy's default column_width is 0.49).
hl.config({
  scrolling = {
    column_width = 0.5,
  },
})

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
