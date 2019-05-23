local termfx = require("termfx")

local base = require("src.base")
local level = require("src.level")


local ui = {}

ui.init = termfx.init
ui.shutdown = termfx.shutdown

function ui.draw_level()
	base.for_all_points(function(x, y, i)
		termfx.printat(x, y, level.current:symbol_at(x, y))
	end)
	termfx.present()
end

function ui.getinput()
	local evt = termfx.pollevent()
	return evt.char
end

function ui.drawpaths()
	base.for_all_points(function(x, y, i)
		local n = level.current.paths.to_player[i]
		local c
		if n == 0 then
			c = "@"
		elseif n then
			c = n % 10
		else
			c = " "
		end
		termfx.printat(x, y + base.MAX_Y + 1, c)

	end)
	termfx.present()
end

function ui.draw_stats()
	local p = level.current.denizens[level.current.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	termfx.printat(base.MAX_X + 2, 1, hp_line)
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
