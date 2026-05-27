------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

local monitor1 = "DP-1"
local monitor2 = "DP-4"

-- hl.monitor({
-- 	output = monitor1,
-- 	mode = "5120x2880@60",
-- 	position = "0x0",
-- 	scale = 2,
-- })
--
-- hl.monitor({
-- 	output = monitor2,
-- 	mode = "2560x1440@60",
-- 	position = "2560x0",
-- 	scale = "auto",
-- })
--
-- Persist workspaces to monitors. See https://wiki.hypr.land/Configuring/Basics/Workspaces/#workspace-rules
--
-- local function persistent_workspace(workspace, monitor)
-- 	hl.workspace_rule({
-- 		workspace = tostring(workspace),
-- 		monitor = monitor,
-- 		persistent = true,
-- 	})
-- end
--
-- for workspace = 1, 5 do
-- 	persistent_workspace(workspace, monitor1)
-- end
--
-- for workspace = 6, 10 do
-- 	persistent_workspace(workspace, monitor2)
-- end
