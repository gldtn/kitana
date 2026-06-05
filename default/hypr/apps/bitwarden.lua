-------------------------------
---- BITWARDEN WINDOW RULES ----
-------------------------------

hl.window_rule({
  name  = "bitwarden-private-floating",
  match = { class = "^(Bitwarden)$" },

  no_screen_share = true,
  tag             = "+floating-window",
})

hl.window_rule({
  name  = "bitwarden-browser-extension-private-floating",
  match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" },

  no_screen_share = true,
  tag             = "+floating-window",
})
