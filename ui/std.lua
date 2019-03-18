local base = require("src.base")
local level = require("src.level")

local ui = {}

function ui.init()
	print("Welcome to GLASS TOWER")
end

function ui.shutdown()
	print("Bye!")
end

function ui.drawlevel()
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			io.write(level.symbol_at(level.current, x, y))
		end
		io.write("\n")
	end
end

function ui.getinput()
	io.write("> ")
	return io.read()
end

function ui.drawpaths()
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
			local n = level.current.paths.to_player[i]
			if n == 0 then
				io.write("@")
			elseif n then
				io.write(n % 10)
			else
				io.write(" ")
			end
		end
		io.write("\n")
	end
end

function ui.drawstats()
	local p = level.current.denizens[level.current.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	io.write(hp_line, "\n")
end

function ui.game_over(t)
	io.write(t.msg, "\n")
end

return ui
