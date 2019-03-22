local base = require("src.base")
local player = require("src.player")
local level = require("src.level")
local mon = require("src.mon")

local loop = {}

function loop.iter(ui)
	local old_level = level.current
	for _, denizen in ipairs(level.current.denizens_in_order) do
		ui.drawlevel()
		ui.drawstats()

		if not level.current.kill_set[denizen] then
			local i = level.current.denizens[base.getIdx(denizen.x, denizen.y)]
			assert(i == denizen, "ID error for denizen\n")

			if denizen.symbol == base.symbols.player then
				local c = ui.getinput()
				if not player.handle_input(c) then
					return false
				end
			else
				mon.act(denizen)
			end
		end

		if level.current.game_over then
			return false
		end

		if level.current ~= old_level then
			break
		end
	end
	level.current:check_kills()
	return true
end

return loop
