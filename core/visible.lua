--- Determine what the player can see
-- @module core.visible

local enum = require("core.enum")
local base = require("core.base")

local visible = {}

--- Determine what the player sees at a given position.
-- Players can see tiles, monsters and tools. The second argument is one of
-- `enum.tile`, `enum.monster` or `enum.tool`, depending on what type of thing the
-- player can see.
-- 
-- The first argument is a specific element of `enum.tile`, `enum.monster`
-- or `enum.tool` corresponding to what a player sees.
--
-- For example, if the player sees a floor, the return values would be:
--		enum.tile.floor, enum.tile
--
-- If nothing can be seen at `pos`, then both return values are false.
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @tparam grid.pos pos
-- @return integer kind, or false if nothing visible
-- @return enum containing `kind`, or false if nothing visible
function visible.at(world, pos)
	local tile = world.state.terrain[pos]
	assert(tile, "Tile not found")

	local tool_pile = tile.inventory
	local denizen = world.state.denizens[pos]
	local light = world.state.light[pos]
	local memory = world.state.memory[pos]

	if pos == world.state.player_pos then
		return denizen.kind, enum.monster, true
	elseif light then
		if denizen then
			return denizen.kind, enum.monster, true
		elseif tool_pile and #tool_pile > 0 then
			return tool_pile[#tool_pile].kind, enum.tool, true
		else
			return tile.kind, enum.tile, true
		end
	elseif memory and tile.kind ~= enum.tile.floor then
		return tile.kind, enum.tile, false
	else
		return false, false, false
	end
end

--- Determine what statistics the player can see.
-- The stats table has the form:
--	{
--		health = [int]
--	}
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @treturn table stats table
function visible.stats(world)
	local player = world.state.denizens[world.state.player_pos]
	local res = {}
	res.health = base.copy(player.health)
	return res
end

return visible