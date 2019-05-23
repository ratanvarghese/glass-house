local base = require("src.base")

local tool_set = {}
local equip_set = {}

tool_set.lantern = {
	name = "lantern",
	light_radius = 2,
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

return tool
