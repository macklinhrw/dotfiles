pcall(require, "luarocks.loader")

require "awful.autofocus"
local beautiful = require "beautiful"
local naughty = require "naughty"
local awful = require "awful"

-- err handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
    message = message,
  }
end)

-- truly beautiful
beautiful.init(require("gears").filesystem.get_configuration_dir() .. "themes/forest/theme.lua")

-- config stuff
require "configuration"

-- ui
require "ui"

awful.spawn.with_shell("compton")
awful.spawn.with_shell("nitrogen --restore")
