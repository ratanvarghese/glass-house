local grid = require("src.grid")
local base = require("src.base")
local enum = require("src.enum")

local tool = {}

tool.set = {}

local LANTERN_RADIUS = 2
tool.set.lantern = {
	template = {
		name = "lantern",
		kind = enum.tool.lantern,
		MAX_RADIUS = LANTERN_RADIUS,
		powers = {
			[enum.power.light] = LANTERN_RADIUS
		}
	},
	equip = function(data, denizen)
		if data.powers[enum.power.light] then
			data.powers[enum.power.light] = nil
		else
			data.powers[enum.power.light] = data.MAX_RADIUS
		end
	end
}

function tool.equip(obj, denizen)
	return tool.set[obj.name].equip(obj, denizen)
end

function tool.make(name)
	return base.copy(tool.set[name].template)
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
	local map_f = function(v) return v.powers[enum.power.light] end
	local radii = list and base.map(list, map_f) or {}
	table.insert(radii, default)
	if base.is_empty(radii) then
		return nil
	end
	return math.max(unpack(radii))
end

return tool
