local awful = require "awful"
local l = awful.layout.suit

awful.layout.layouts = {
  l.floating,
  l.tile,
  l.spiral,
}
