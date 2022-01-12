local menubar = require("menubar")
local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local gears = require("gears")

mymainmenu = awful.menu({ items = { { "awesome", Menu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

local awful = require "awful"

_G.Menu = {}

Menu.awesome = {
  {
    "hotkeys",
    function()
      hotkeys_popup.show_help(nil, awful.screen.focused())
    end,
  },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  {
    "quit",
    function()
      awesome.quit()
    end,
  },
}

Menu.main = awful.menu {
  items = {
    { "awesome", Menu.awesome },
    { "terminal", terminal },
    { "browser", "google-chrome-stable" },
    { "vim", "kitty -e vim" },
  },
}
