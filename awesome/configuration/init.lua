
terminal = "kitty"
editor = os.getenv "EDITOR" or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

require("configuration.autorun")
require("configuration.keybindings")
require("configuration.layouts")
require("configuration.rules")

local gears = require("gears")
