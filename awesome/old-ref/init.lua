
terminal = "kitty"
editor = os.getenv "EDITOR" or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

require "configuration.bound"
require "configuration.layout"
