local termfx = require("termfx")

local grid = require("src.grid")
local enum = require("src.enum")
local level = require("src.level")
local cmdutil = require("ui.cmdutil")

local ui = {}

ui.init = termfx.init
ui.shutdown = termfx.shutdown

function ui.draw_level(lvl)
	local rows = cmdutil.row_strings(cmdutil.symbol_grid(lvl))
	for y,v in ipairs(rows) do
		termfx.printat(1, y, v)
	end
	termfx.present()
end

local function get_key()
	local evt = termfx.pollevent()
	return evt.char
end

function ui.get_input()
	return enum.cmd[cmdutil.keys[get_key()]], 1
end

function ui.draw_paths(lvl)
	local rows = cmdutil.row_strings(cmdutil.paths_grid(lvl))
	for y,v in ipairs(rows) do
		termfx.printat(1, y + grid.MAX_Y + 1, v)
	end
	termfx.present()
end

function ui.draw_stats(stats)
	local hp_line = string.format("HP: %2d", stats.hp)
	termfx.printat(grid.MAX_X + 2, 1, hp_line)
	termfx.present()
end

function ui.game_over(t)
	termfx.clear()
	termfx.printat(10, 10, t.msg)
	termfx.printat(10, 12, "Press any key to exit.")
	termfx.present()
	get_key()	
end

return ui
