------------------
---- MONITORS ----
------------------
---
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
  output   = "DP-1",
  mode     = "5120x2880@60",
  position = "0x0",
  scale    = 2,
})

hl.monitor({
  output   = "DP-4",
  mode     = "2560x1440@60",
  position = "2560x0",
  scale    = "auto",
})

local function persistent_workspace(workspace, monitor)
  hl.workspace_rule({
    workspace  = tostring(workspace),
    monitor    = monitor,
    persistent = true,
  })
end

for workspace = 1, 5 do
  persistent_workspace(workspace, "DP-1")
end

for workspace = 6, 10 do
  persistent_workspace(workspace, "DP-4")
end
