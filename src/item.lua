local base = require("src.base")

local item_set = {}
local equip_set = {}

item_set.lantern = {
	name = "lantern",
	light_radius = 2,
	on = true
}
function equip_set.lantern(item, denizen)
	if item.light_radius > 0 then
		item.light_radius = 0
	else
		item.light_radius = 2
	end
end


local item = {}

function item.equip(obj, denizen)
	return equip_set[obj.name](obj, denizen)
end

function item.make(name)
	return base.copy(item_set[name])
end

return item
