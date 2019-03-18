local termfx = require("termfx")

local base = require("src.base")
local level = require("src.level")


local ui = {}

ui.init = termfx.init
ui.shutdown = termfx.shutdown

function ui.drawlevel()
	termfx.clear()

	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			termfx.printat(x, y, level.current:symbol_at(x, y))
		end
	end
	termfx.present()
end

function ui.getinput()
	local evt = termfx.pollevent()
	return evt.char
end

function ui.drawpaths()
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
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
		end
	end
	termfx.present()
end

return ui
