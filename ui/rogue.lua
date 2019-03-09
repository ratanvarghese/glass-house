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
			termfx.printat(x, y, level.symbol_at(level.current, x, y))
		end
	end
	termfx.present()
end

function ui.getinput()
	local evt = termfx.pollevent()
	return evt.char
end

return ui
