local enum = require("core.enum")
local base = require("core.base")

local visible = {}

function visible.at(world, pos)
	local tile = world.terrain[pos]
	assert(tile, "Tile not found")

	local tool_pile = tile.inventory
	local denizen = world.denizens[pos]
	local light = world.light[pos]
	local memory = world.memory[pos]

	if pos == world.player_pos then
		return denizen.kind, enum.monster
	elseif light then
		if denizen then
			return denizen.kind, enum.monster
		elseif tool_pile and #tool_pile > 0 then
			return tool_pile[#tool_pile].kind, enum.tool
		else
			return tile.kind, enum.terrain
		end
	elseif memory and tile.kind ~= enum.terrain.floor then
		return tile.kind, enum.terrain
	else
		return false, false
	end
end

function visible.stats(world)
	local player = world.denizens[world.player_pos]
	local res = {}
	res.health = base.copy(player.health)
	return res
end

return visible