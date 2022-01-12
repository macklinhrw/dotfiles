local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain  = require("lain")

-- {{{ Wibar

local markup     = lain.util.markup
local separators = lain.util.separators
local white      = beautiful.fg_focus
local gray       = beautiful.fg_highlight

-- Create a textclock widget
--mytextclock = wibox.widget {
--  format = ' %a %d %b, %I:%M %p ',
--  widget = wibox.widget.textclock,
--}


-- MPD
local mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset.fg = white
        artist = mpd_now.artist .. " "
        title  = mpd_now.title  .. " "

        if mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        elseif mpd_now.state == "stop" then
            artist = ""
            title  = ""
        end

        widget:set_markup(markup.font(beautiful.font, markup(gray, artist) .. markup(white, title)))
    end
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))


local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }


    -- Separators
    local first = wibox.widget.textbox('    ')
    local single_space = wibox.widget.textbox('  ')

    -- Create the wiblocal sgeo = screen:geomery()
    local sgeo = s.geometry
    local bar_height = 35;
    local bar_top_margin = 10;
    local bar_x_margin = 10;

    s.mywibar = awful.wibar({ position="top", screen = s, opacity = 0, type = "dock" })
    s.mywibar.width = sgeo.width;
    s.mywibar.height = bar_height + bar_top_margin;
    s.mywibar.visible = true
    --s.mywibox = awful.wibar({ screen = s, width=40, height=40 })

    -- Add widgets to the wibox
    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
        },
        {
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
        },
    }


    local mytextclock = wibox.widget.textclock(markup(gray, " %a")
    .. markup(white, " %d ") .. markup(gray, "%b ") ..  markup(white, "%I:%M %p "))
    mytextclock.font = beautiful.font

    local volume = lain.widget.alsabar({
        width = 60, margins = 3,
        colors = {
            background = "#383838",
            unmute     = "#80CCE6",
            mute       = "#FF9F9F"
        }
    })

    volume.bar:buttons(awful.util.table.join(
        awful.button({}, 1, function() -- left click
            awful.spawn(string.format("%s -e alsamixer", terminal))
        end),
        awful.button({}, 2, function() -- middle click
            os.execute(string.format("%s set %s 100%%", volume.cmd, volume.channel))
            volume.update()
        end),
        awful.button({}, 3, function() -- right click
            os.execute(string.format("%s set %s toggle", volume.cmd, volume.togglechannel or volume.channel))
            volume.update()
        end),
        awful.button({}, 4, function() -- scroll up
            os.execute(string.format("%s set %s 5%%+", volume.cmd, volume.channel))
            volume.update()
        end),
        awful.button({}, 5, function() -- scroll down
            os.execute(string.format("%s set %s 5%%-", volume.cmd, volume.channel))
            volume.update()
        end)
    ))

    local cpu = lain.widget.cpu {
        settings = function()
            widget:set_markup(markup(gray, "cpu ") .. cpu_now.usage .. "%")
        end
    }

    -- shows used (percentage) and remaining space in home partition
    local fsroot = lain.widget.fs({
        settings  = function()
            widget:set_markup(markup(gray, "/  ") ..  fs_now["/"].percentage .. "%") -- .. "% (" ..
            --fs_now["/"].free .. " " .. fs_now["/"].units .. " left)")
        end
    })
    -- output example: "/home: 37% (239.4 Gb left)"

    myredshift = wibox.widget.textbox()
    lain.widget.contrib.redshift.attach(
        myredshift,
        function (active)
            if active then
                myredshift:set_markup(markup(gray, "RS"))
            else
                myredshift:set_markup(markup(white, "RS"))
            end
        end
    )

    beautiful.systray_icon_spacing = 2;
    local systray = wibox.widget.systray()
    systray:set_base_size(30)
    
    local systray_widget = wibox.widget {
        {
          widget = systray
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place,
    }


    --local sgeo = s:geometry()
    s.mywibox = wibox({ screen = s, opacity = 1, type = "dock", ontop = false })
    s.mywibox.width = sgeo.width - 2 * bar_x_margin;
    s.mywibox.height = bar_height;
    s.mywibox.x = sgeo.x + bar_x_margin;
    s.mywibox.y = sgeo.y + bar_top_margin
    s.mywibox.visible = true
    s.mywibox.bg = beautiful.border_normal
    --s.mywibox = awful.wibar({ screen = s, width=40, height=40 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            first,
            s.mytaglist,
            single_space,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytasklist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            --mpd,
            systray_widget,
            single_space,
            fsroot,
            single_space,
            cpu,
            single_space,
            --myredshift,
            --single_space,
            volume.bar,
            single_space,
            mytextclock,
            single_space,
            s.mylayoutbox,
        },
    }
end)
-- }}}
