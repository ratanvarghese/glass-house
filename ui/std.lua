local base = require("src.base")
local level = require("src.level")

local ui = {}

function ui.init()
	print("Welcome to GLASS TOWER")
end

function ui.shutdown()
	print("Bye!")
end

function ui.draw_level()
	base.for_all_points(function(x, y, i)
		io.write(level.symbol_at(level.current, x, y))
		if x == base.MAX_X then
			io.write("\n")
		end
	end)
end

function ui.getinput()
	io.write("> ")
	return io.read()
end

function ui.drawpaths()
	base.for_all_points(function(x, y, i)
		local n = level.current.paths.to_player[i]
		if n == 0 then
			io.write("@")
		elseif n then
			io.write(n % 10)
		else
			io.write(" ")
		end
		if y == base.MAX_Y then
			io.write("\n")
		end
	end)
end

function ui.draw_stats()
	local p = level.current.denizens[level.current.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	io.write(hp_line, "\n")
end

function ui.game_over(t)
	io.write(t.msg, "\n")
end

return ui
