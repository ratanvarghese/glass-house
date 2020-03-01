--- Create tools and manage tool types
-- @module core.toolkit

local base = require("core.base")
local enum = require("core.enum")

local toolkit = {}

--- Table of tool types
toolkit.set = {}
toolkit.set[enum.tool.lantern] = {
	template = {
		kind = enum.tool.lantern,
		MAX_RADIUS = 2,
		power = {}
	},
	equip = function(data, denizen)
		if data.power[enum.power.light] then
			data.power[enum.power.light] = nil
		else
			data.power[enum.power.light] = data.MAX_RADIUS
		end
	end
}

--- Run a tool's equip function.
-- @tparam table obj the tool
-- @tparam table denizen the denizen equipping the tool
function toolkit.equip(obj, denizen)
	return toolkit.set[obj.kind].equip(obj, denizen)
end

--- Make a tool.
-- @tparam enum.tool kind
function toolkit.make(kind)
	return base.copy(toolkit.set[kind].template)
end

--- Given an inventory of tools, calculate a power factor.
-- @tparam enum.power p power an element of `core.enum.power` representing a power
-- @tparam[opt] {table,...} list inventory of tools
-- @tparam[opt] int default power factor to use if no tool has the relevant power
-- @see core.power
function toolkit.inventory_power(p, list, default)
	local list = list or {}
	local factors = {}
	table.insert(factors, default)
	for _,v in ipairs(list) do
		table.insert(factors, v.power[p])
	end
	if base.is_empty(factors) then
		return nil
	end
	return math.max(unpack(factors))
end

return toolkit
