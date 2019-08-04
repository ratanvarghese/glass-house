local enum = require("core.enum")
local base = require("core.base")

local visible = {}

function visible.at(world, pos)
	local tile = world.state.terrain[pos]
	assert(tile, "Tile not found")

	local tool_pile = tile.inventory
	local denizen = world.state.denizens[pos]
	local light = world.state.light[pos]
	local memory = world.state.memory[pos]

	if pos == world.state.player_pos then
		return denizen.kind, enum.monster
	elseif light then
		if denizen then
			return denizen.kind, enum.monster
		elseif tool_pile and #tool_pile > 0 then
			return tool_pile[#tool_pile].kind, enum.tool
		else
			return tile.kind, enum.tile
		end
	elseif memory and tile.kind ~= enum.tile.floor then
		return tile.kind, enum.tile
	else
		return false, false
	end
end

function visible.stats(world)
	local player = world.state.denizens[world.state.player_pos]
	local res = {}
	res.health = base.copy(player.health)
	return res
end

return visible