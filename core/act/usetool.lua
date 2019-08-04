local tool = require("core.system.tool")

local usetool = {pickup = {}, drop = {}, equip = {}}

function usetool.pickup.possible(world, e, inventory_i)
	return tool.has_inventory_i(world.state.terrain[e.pos], inventory_i)
end

function usetool.pickup.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.pickup.attempt(world, e, inventory_i)
	if not usetool.pickup.possible(world, e, inventory_i) then
		return false
	end
	tool.prepare_pickup(e, {inventory_i})
	return true
end

function usetool.drop.possible(world, e, inventory_i)
	return tool.has_inventory_i(e, inventory_i)
end

function usetool.drop.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.drop.attempt(world, e, inventory_i)
	if not usetool.drop.possible(world, e, inventory_i) then
		return false
	end
	tool.prepare_drop(e, {inventory_i})
	return true
end

function usetool.equip.possible(world, e, inventory_i)
	return tool.has_inventory_i(e, inventory_i)
end

function usetool.equip.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.equip.attempt(world, e, inventory_i)
	if not usetool.equip.possible(world, e, inventory_i) then
		return false
	end
	tool.prepare_equip(e, {inventory_i})
	return true
end

return usetool