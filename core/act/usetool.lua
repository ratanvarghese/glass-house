local tool = require("core.tool")

local usetool = {pickup = {}, drop = {}, equip = {}}

local function has_inventory_i(e, inventory_i)
	return e.inventory and e.inventory[inventory_i] ~= nil
end

function usetool.pickup.possible(world, e, inventory_i)
	return has_inventory_i(world.terrain[e.pos], inventory_i)
end

function usetool.pickup.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.pickup.attempt(world, e, inventory_i)
	if not usetool.pickup.possible(world, e, inventory_i) then
		return false
	end
	local t = world.terrain[e.pos]
	e.inventory = e.inventory or {}
	table.insert(e.inventory, table.remove(t.inventory, inventory_i))
	world.addEntity(world, t)
	world.addEntity(world, e)
	return true
end

function usetool.drop.possible(world, e, inventory_i)
	return has_inventory_i(e, inventory_i)
end

function usetool.drop.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.drop.attempt(world, e, inventory_i)
	if not usetool.drop.possible(world, e, inventory_i) then
		return false
	end

	local t = world.terrain[e.pos]
	if not t.inventory then t.inventory = {} end
	table.insert(t.inventory, table.remove(e.inventory, inventory_i))
	world.addEntity(world, t)
	world.addEntity(world, e)
	return true
end

function usetool.equip.possible(world, e, inventory_i)
	return has_inventory_i(e, inventory_i)
end

function usetool.equip.utility(world, e, inventory_i)
	return 0 --Not ready for monsters to do this
end

function usetool.equip.attempt(world, e, inventory_i)
	if not usetool.equip.possible(world, e, inventory_i) then
		return false
	end

	tool.equip(e.inventory[inventory_i], e)
	return true
end

return usetool