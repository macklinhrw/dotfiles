-- Provides:
-- squeal::ram
--      used (integer - mega bytes)
--      total (integer - mega bytes)

-- credit: elenapan

local awful = require "awful"

local update_interval = 60
-- Returns the used amount of ram in percentage
local ram_script = [[
  sh -c "
  free -m | awk '/^Mem:/ {printf \"%d@@%d@\", $7, $2}'
  "]]

-- Periodically get ram info
awful.widget.watch(ram_script, update_interval, function(widget, stdout)
  local available = stdout:match "(.*)@@"
  local total = stdout:match "@@(.*)@"
  local used = tonumber(total) - tonumber(available)
  awesome.emit_signal("squeal::ram", used, tonumber(total))
end)
