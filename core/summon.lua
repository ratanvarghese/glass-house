local grid = require("core.grid")
local enum = require("core.enum")
local move = require("core.system.move")

local clock = require("core.clock")

local bestiary = require("core.bestiary")

local summon = {}

function summon.summon(world, kind, pos, add, h_ratio)
	local h_ratio = h_ratio or 1
	local tries = 0
	local options
	if pos then
		options = move.options(world, pos)
	else
		options = {}
		for i=1,5 do			
			local x = math.random(1, grid.MAX_X)
			local y = math.random(1, grid.MAX_Y)
			local new_pos = grid.get_pos(x, y)
			if move.walkable(world.state.terrain, world.state.denizens, new_pos) then
				table.insert(options, new_pos)
			end
		end
	end

	local n_options = #(options)
	if n_options > 0 then
		local m = bestiary.make(kind, options[math.random(1, n_options)])
		m.health.now = math.floor(m.health.max * h_ratio)
		world.state.denizens[m.pos] = m
		if add then
			world.addEntity(world, m)
			clock.spend_credit(m.clock)
		end
		return true
	else
		return false
	end
end

return summon