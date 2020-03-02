--- Entry point for `platform.unixterm`
-- @module platform.unixterm.main

local argparse = require("lib.argparse")

local p = argparse("glass-house", "Glass House")
p:flag("-s --stdio")

local args = p:parse()
local ui
if args.stdio then
	ui = require("platform.unixterm.stdio")
else
	ui = require("platform.unixterm.curses")
end
local save = require("platform.unixterm.save")
local common = require("platform.unixterm.common")

local setup = require("core.setup")

local w = setup.world(ui, save, os.time(), os.exit)

ui.init()
local ok, err = xpcall(function()
	while true do
		w.update(w, 1)
	end
end, common.error_handler)
ui.shutdown()
if not ok then
	print(err)
end