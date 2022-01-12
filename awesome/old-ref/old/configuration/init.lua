local awful = require "awful"
terminal = "kitty"
editor = os.getenv "EDITOR" or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

require "configuration.ruled"
require "configuration.bindings"
require "configuration.layout"
