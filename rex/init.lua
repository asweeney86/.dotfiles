-- Clear Terminal and session picker: chosen during migration.
rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session.switch")

-- Preserve access to the prefix key inside terminal programs.
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- tmux bindings, copied from the supplied migration table.
rex.bind("ctrl+l", "pane.send_key", { key = "ctrl+l" })

rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+b>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+b>shift+h", "pane.resize", { amount = 2, direction = "left" })
rex.bind("repeat/shift+h", "pane.resize", { amount = 2, direction = "left" })
rex.bind("ctrl+b>shift+j", "pane.resize", { amount = 2, direction = "down" })
rex.bind("repeat/shift+j", "pane.resize", { amount = 2, direction = "down" })
rex.bind("ctrl+b>shift+k", "pane.resize", { amount = 2, direction = "up" })
rex.bind("repeat/shift+k", "pane.resize", { amount = 2, direction = "up" })
rex.bind("ctrl+b>shift+l", "pane.resize", { amount = 2, direction = "right" })
rex.bind("repeat/shift+l", "pane.resize", { amount = 2, direction = "right" })
rex.bind("ctrl+b>ctrl+h", "client.tab.previous")
rex.bind("repeat/ctrl+h", "client.tab.previous")
rex.bind("ctrl+b>ctrl+l", "client.tab.next")
rex.bind("repeat/ctrl+l", "client.tab.next")
rex.bind("ctrl+b>r", "client.config.reload")
