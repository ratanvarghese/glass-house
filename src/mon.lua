local base = require("src.base")
local level = require("src.level")
local tool = require("src.tool")

local mon = {}

function mon.act(denizen)
	--mon.wander(denizen)
	mon.follow_player(denizen)
end

function mon.wander(denizen)
	local d = base.rn_direction()
	level.current:move(denizen, denizen.x + d.x, denizen.y + d.y)
end

function mon.follow_player(denizen)
	local _, x, y = base.adjacent_min(level.current.paths.to_player, denizen.x, denizen.y)
	if not level.current:move(denizen, x, y) and (denizen.x ~= x or denizen.y ~= y) then
		level.current:bump_hit(denizen, x, y, 1)
	end
end

function mon.drop_tool(pile_array, denizen, tool_idx)
	if not denizen.inventory or #denizen.inventory < 1 then
		return false
	end

	local tool_to_drop = table.remove(denizen.inventory, tool_idx)
	tool.drop_onto_array(pile_array, tool_to_drop, denizen.x, denizen.y)
	return true
end

function mon.pickup_tool(pile_array, denizen, tool_idx)
	local targ_tool = tool.pickup_from_array(pile_array, tool_idx, denizen.x, denizen.y)
	if not targ_tool then
		return false
	end

	local inventory = denizen.inventory
	if inventory then
		table.insert(inventory, targ_tool)
	else
		denizen.inventory = {targ_tool}
	end
	return true
end

function mon.pickup_all_tools(pile_array, denizen)
	local pile = tool.pickup_all_from_array(pile_array, denizen.x, denizen.y)
	if not pile then
		return
	end

	for i,v in ipairs(pile) do
		table.insert(denizen.inventory, v)
	end
end

return mon
