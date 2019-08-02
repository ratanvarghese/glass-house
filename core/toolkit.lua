local base = require("core.base")
local enum = require("core.enum")

local toolkit = {}

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

function toolkit.equip(obj, denizen)
	return toolkit.set[obj.kind].equip(obj, denizen)
end

function toolkit.make(kind)
	return base.copy(toolkit.set[kind].template)
end

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
