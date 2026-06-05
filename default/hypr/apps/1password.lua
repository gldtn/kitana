--------------------------------
---- 1PASSWORD WINDOW RULES ----
--------------------------------

hl.window_rule({
  name  = "1password-private-floating",
  match = { class = "^(1[pP]assword)$" },

  no_screen_share = true,
  tag             = "+floating-window",
})
