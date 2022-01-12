local awful = require "awful"
local lain = require "lain"

-- Mouse bindings
awful.mouse.append_global_mousebindings {
  awful.button({}, 3, function()
    Menu.main:toggle()
  end),
}

-- Key bindings

-- General Utilities
awful.keyboard.append_global_keybindings {
  awful.key({}, "Print", function()
    awful.spawn "flameshot gui"
  end),
  awful.key({ "Shift" }, "Print", function()
    --awful.spawn "scr selection"
    awful.spawn "flameshot gui"
  end),
  awful.key({ "Control" }, "Print", function()
    --awful.spawn "scr window"
    awful.spawn "flameshot gui"
  end),
  awful.key({ modkey }, "Print", function()
    --awful.spawn "scr screentoclip"
    awful.spawn "flameshot gui"
  end),
  awful.key({ modkey, "Shift" }, "Print", function()
    --awful.spawn "scr selectiontoclip"
    awful.spawn "flameshot gui"
  end),
  awful.key({ modkey, "Control" }, "Print", function()
    --awful.spawn "scr windowtoclip"
    awful.spawn "flameshot gui"
  end),
}

-- General Awesome keys
awful.keyboard.append_global_keybindings {
  awful.key({ modkey }, "w", function()
    Menu.main:show()
  end, {
    description = "show main menu",
    group = "awesome",
  }),
  awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit, { descpicomription = "quit awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "Return", function()
    awful.spawn(terminal)
  end, {
    description = "open a terminal",
    group = "launcher",
  }),
  awful.key({ modkey }, "r", function()
    awful.spawn "dmenu_run"
  end, {
    description = "run prompt",
    group = "launcher",
  }),
  awful.key({ modkey }, "p", function()
    awful.spawn "rofi"
  end, {
    description = "run rofi",
    group = "launcher",
  }),
  awful.key({ modkey }, "b", function()
    awful.spawn "google-chrome-stable"
  end, {
    description = "start browser",
    group = "launcher",
  }),
  --awful.key({ modkey }, "a", function()
  --  require "ui.control_center"()
  --end),
}

-- shortcuts
awful.keyboard.append_global_keybindings {
-- Toggle Redshift with Mod+Shift+t
  awful.key({ modkey, "Shift" }, "t", function () lain.widget.contrib.redshift.toggle() end, {
    description = "toggle redshift",
    group = "launcher",
  }),
}

-- Tags related keybindings
awful.keyboard.append_global_keybindings {
  awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
  awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
}

-- Focus related keybindings
awful.keyboard.append_global_keybindings {
  awful.key({ modkey }, "j", function()
    awful.client.focus.byidx(1)
  end, {
    description = "focus next by index",
    group = "client",
  }),
  awful.key({ modkey }, "k", function()
    awful.client.focus.byidx(-1)
  end, {
    description = "focus previous by index",
    group = "client",
  }),
  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, {
    description = "go back",
    group = "client",
  }),
}

-- Layout related keybindings
awful.keyboard.append_global_keybindings {
  awful.key({ modkey, "Shift" }, "j", function()
    awful.client.swap.byidx(1)
  end, {
    description = "swap with next client by index",
    group = "client",
  }),
  awful.key({ modkey, "Shift" }, "k", function()
    awful.client.swap.byidx(-1)
  end, {
    description = "swap with previous client by index",
    group = "client",
  }),
  awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey }, "l", function()
    awful.tag.incmwfact(0.05)
  end, {
    description = "increase master width factor",
    group = "layout",
  }),
  awful.key({ modkey }, "h", function()
    awful.tag.incmwfact(-0.05)
  end, {
    description = "decrease master width factor",
    group = "layout",
  }),
  awful.key({ modkey, "Shift" }, "h", function()
    awful.tag.incnmaster(1, nil, true)
  end, {
    description = "increase the number of master clients",
    group = "layout",
  }),
  awful.key({ modkey, "Shift" }, "l", function()
    awful.tag.incnmaster(-1, nil, true)
  end, {
    description = "decrease the number of master clients",
    group = "layout",
  }),
  awful.key({ modkey, "Control" }, "h", function()
    awful.tag.incncol(1, nil, true)
  end, {
    description = "increase the number of columns",
    group = "layout",
  }),
  awful.key({ modkey, "Control" }, "l", function()
    awful.tag.incncol(-1, nil, true)
  end, {
    description = "decrease the number of columns",
    group = "layout",
  }),
  awful.key({ modkey }, "space", function()
    awful.layout.inc(1)
  end, {
    description = "select next",
    group = "layout",
  }),
  awful.key({ modkey, "Shift" }, "space", function()
    awful.layout.inc(-1)
  end, {
    description = "select previous",
    group = "layout",
  }),
}

awful.keyboard.append_global_keybindings {
  awful.key {
    modifiers = { modkey },
    keygroup = "numrow",
    description = "only view tag",
    group = "tag",
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  },
  awful.key {
    modifiers = { modkey, "Control" },
    keygroup = "numrow",
    description = "toggle tag",
    group = "tag",
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end,
  },
  awful.key {
    modifiers = { modkey, "Shift" },
    keygroup = "numrow",
    description = "move focused client to tag",
    group = "tag",
    on_press = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },
  awful.key {
    modifiers = { modkey, "Control", "Shift" },
    keygroup = "numrow",
    description = "toggle focused client on tag",
    group = "tag",
    on_press = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end,
  },
  awful.key {
    modifiers = { modkey },
    keygroup = "numpad",
    description = "select layout directly",
    group = "layout",
    on_press = function(index)
      local t = awful.screen.focused().selected_tag
      if t then
        t.layout = t.layouts[index] or t.layout
      end
    end,
  },
}

client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings {
    awful.button({}, 1, function(c)
      c:activate { context = "mouse_click" }
    end),
    awful.button({ modkey }, 1, function(c)
      c:activate { context = "mouse_click", action = "mouse_move" }
    end),
    awful.button({ modkey }, 3, function(c)
      c:activate { context = "mouse_click", action = "mouse_resize" }
    end),
  }
end)

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings {
    awful.key({ modkey }, "f", function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end, {
      description = "toggle fullscreen",
      group = "client",
    }),
    awful.key({ modkey, "Shift" }, "c", function(c)
      c:kill()
    end, {
      description = "close",
      group = "client",
    }),
    awful.key(
      { modkey, "Control" },
      "space",
      awful.client.floating.toggle,
      { description = "toggle floating", group = "client" }
    ),
    awful.key({ modkey, "Control" }, "Return", function(c)
      c:swap(awful.client.getmaster())
    end, {
      description = "move to master",
      group = "client",
    }),
    awful.key({ modkey }, "m",  function()
      client.focus = awful.client.getmaster(); client.focus:raise()
    end, {
      description = "move to master",
      group = "client",
    }),
    awful.key({ modkey }, "o", function(c)
      c:move_to_screen()
    end, {
      description = "move to screen",
      group = "client",
    }),
    awful.key({ modkey }, "t", function(c)
      c.ontop = not c.ontop
    end, {
      description = "toggle keep on top",
      group = "client",
    }),
    awful.key({ modkey, "Shift" }, "n", function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end, {
      description = "minimize",
      group = "client",
    }),
    awful.key({ modkey, "Shift" }, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
    end, {
      description = "(un)maximize",
      group = "client",
    }),
    awful.key({ modkey, "Control" }, "m", function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end, {
      description = "(un)maximize vertically",
      group = "client",
    }),
    --awful.key({ modkey, "Shift" }, "m", function(c)
    --  c.maximized_horizontal = not c.maximized_horizontal
    --  c:raise()
    --end, {
    --  description = "(un)maximize horizontally",
    --  group = "client",
    --}),
  }
end)
