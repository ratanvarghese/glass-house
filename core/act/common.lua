local enum = require("core.enum")

local common = {}

function common.move_denizen(world, d, new_pos)
	assert(not world.denizens[new_pos], "Attempt to move denizen onto denizen")
	local old_pos = d.pos
	d.pos = new_pos
	world.denizens[old_pos] = nil
	world.denizens[d.pos] = d
	if d.decide == enum.decidemode.player then
		world.player_pos = d.pos
		if world.terrain[d.pos].kind == enum.terrain.stair then
			world.regen(world, world.num+1)
			return
		end
	end
	world.addEntity(world, d)
end

return common