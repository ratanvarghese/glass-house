local grid = require("src.grid")
local level = require("src.level")

local ui = {}

function ui.init()
	print("Welcome to GLASS TOWER")
end

function ui.shutdown()
	print("Bye!")
end

function ui.draw_level(lvl)
	grid.make_full(function(x, y, i)
		io.write(lvl:symbol_at(x, y))
		if x == grid.MAX_X then
			io.write("\n")
		end
	end)
end

function ui.getinput()
	io.write("> ")
	return io.read()
end

function ui.drawpaths(lvl)
	grid.make_full(function(x, y, i)
		local n = lvl.paths.to_player[i]
		if n == 0 then
			io.write("@")
		elseif n then
			io.write(n % 10)
		else
			io.write(" ")
		end
		if x == grid.MAX_X then
			io.write("\n")
		end
	end)
end

function ui.draw_stats(lvl)
	local p = lvl.denizens[lvl.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	io.write(hp_line, "\n")
end

function ui.game_over(t)
	io.write(t.msg, "\n")
end

return ui
