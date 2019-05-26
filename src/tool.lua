local grid = require("src.grid")
local base = require("src.base")
local enum = require("src.enum")

local tool_set = {}
local equip_set = {}

tool_set.lantern = {
	name = "lantern",
	light_radius = 2,
	kind = enum.tool.lantern,
	on = true
}
function equip_set.lantern(tool, denizen)
	if tool.light_radius > 0 then
		tool.light_radius = 0
	else
		tool.light_radius = 2
	end
end


local tool = {}

function tool.equip(obj, denizen)
	return equip_set[obj.name](obj, denizen)
end

function tool.make(name)
	return base.copy(tool_set[name])
end

function tool.pile_from_array(pile_array, x, y, make_missing)
	local i = grid.get_idx(x, y)
	local pile = pile_array[i]
	if not pile and make_missing then
		pile = {}
		pile_array[i] = pile
	end
	return pile
end

function tool.pickup_from_array(pile_array, tool_idx, x, y)
	local pile = tool.pile_from_array(pile_array, x, y, false)
	if not pile or #pile < 1 then
		return nil
	end
	return table.remove(pile, tool_idx)
end

function tool.pickup_all_from_array(pile_array, x, y)
	local i = grid.get_idx(x, y)
	local pile = pile_array[i]
	pile_array[i] = nil
	return pile
end

function tool.drop_onto_array(pile_array, tool_to_drop, x, y)
	local i = grid.get_idx(x, y)
	local pile = pile_array[i]
	if pile then
		table.insert(pile, tool_to_drop)
	else
		pile_array[i] = {tool_to_drop}
	end
end

function tool.light_from_list(list, default)
	if not list then
		return default
	end

	local radii = base.map_k(list, "light_radius")
	if base.is_empty(radii) then
		return default
	elseif not default then
		return math.max(unpack(radii))
	else
		return math.max(default, unpack(radii))
	end
end

return tool
