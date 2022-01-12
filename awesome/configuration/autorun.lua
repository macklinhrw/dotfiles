local awful = require("awful")

awful.spawn.with_shell("picom")
awful.spawn.with_shell("nitrogen --restore")
--awful.spawn.easy_async_with_shell("killall -q polybar", function()
--    awful.spawn.easy_async_with_shell("polybar example 2>&1 | tee -a /tmp/polybar.log & disown")
--end)
--awful.spawn.easy_async_with_shell("~/.config/polybar/launch.sh")
