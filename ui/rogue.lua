local termfx = require("termfx")

local grid = require("src.grid")
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

function ui.getinput()
	local evt = termfx.pollevent()
	return evt.char
end

function ui.draw_paths(lvl)
	local rows = cmdutil.row_strings(cmdutil.paths_grid(lvl))
	for y,v in ipairs(rows) do
		termfx.printat(1, y + grid.MAX_Y + 1, v)
	end
	termfx.present()
end

function ui.draw_stats(lvl)
	local p = lvl.denizens[lvl.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	termfx.printat(grid.MAX_X + 2, 1, hp_line)
	termfx.present()
end

function ui.game_over(t)
	termfx.clear()
	termfx.printat(10, 10, t.msg)
	termfx.printat(10, 12, "Press any key to exit.")
	termfx.present()
	ui.getinput()
end

return ui
