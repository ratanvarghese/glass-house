local termfx = require("termfx")

local grid = require("src.grid")
local level = require("src.level")


local ui = {}

ui.init = termfx.init
ui.shutdown = termfx.shutdown

function ui.draw_level(lvl)
	grid.for_all_points(function(x, y, i)
		termfx.printat(x, y, lvl:symbol_at(x, y))
	end)
	termfx.present()
end

function ui.getinput()
	local evt = termfx.pollevent()
	return evt.char
end

function ui.drawpaths(lvl)
	grid.for_all_points(function(x, y, i)
		local n = lvl.paths.to_player[i]
		local c
		if n == 0 then
			c = "@"
		elseif n then
			c = n % 10
		else
			c = " "
		end
		termfx.printat(x, y + grid.MAX_Y + 1, c)

	end)
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
