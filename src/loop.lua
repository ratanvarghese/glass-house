local base = require("src.base")
local enum = require("src.enum")
local grid = require("src.grid")
local player = require("src.player")
local level = require("src.level")
local mon = require("src.mon")

local loop = {}

function loop.iter(ui)
	local old_level = level.current
	local old_stats = nil
	for _, denizen in ipairs(level.current.denizens_in_order) do
		ui.draw_level(level.current)

		local new_stats = player.stats(level.current)
		if not base.equals(old_stats, new_stats) then
			ui.draw_stats(new_stats)
		end

		if not level.current.kill_set[denizen] then
			local i = level.current.denizens[grid.get_idx(denizen.x, denizen.y)]
			assert(i == denizen, "ID error for denizen\n")

			if denizen.kind == enum.monster.player then
				local c, n = ui.getinput()
				if not player.handle_input(level.current, c, n) then
					return false
				end
			else
				mon.act(level.current, denizen)
			end
		end

		if level.current.game_over then
			return false
		end

		if level.current ~= old_level then
			break
		end

		old_stats = base.copy(new_stats)
	end
	level.current:check_kills()
	return true
end

return loop
