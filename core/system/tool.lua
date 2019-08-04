local tiny = require("lib.tiny")

local base = require("core.base")
local toolkit = require("core.toolkit")

local tool = {}

function tool.prepare_pickup(e, tool_index_list)
	e.usetool.pickup = e.usetool.pickup or {}
	base.extend_arr(e.usetool.pickup, ipairs(tool_index_list))
end

function tool.prepare_drop(e, tool_index_list)
	e.usetool.drop = e.usetool.drop or {}
	base.extend_arr(e.usetool.drop, ipairs(tool_index_list))
end

function tool.prepare_equip(e, tool_index_list)
	e.usetool.equip = e.usetool.equip or {}
	base.extend_arr(e.usetool.equip, ipairs(tool_index_list))
end

function tool.has_inventory_i(e, inventory_i)
	return e.inventory and e.inventory[inventory_i] ~= nil
end

local function process_pickup(world, e, t)
	table.sort(e.usetool.pickup)
	e.inventory = e.inventory or {}
	local max_pickup_list_i = #e.usetool.pickup
	for pickup_list_i=max_pickup_list_i,1,-1 do
		local inventory_i = e.usetool.pickup[pickup_list_i]
		table.insert(e.inventory, table.remove(t.inventory, inventory_i))
	end
	world.addEntity(world, t)
	world.addEntity(world, e)
	e.usetool.pickup = nil
end

local function process_drop(world, e, t)
	table.sort(e.usetool.drop)
	if not t.inventory then t.inventory = {} end
	local max_drop_list_i = #e.usetool.drop
	for drop_list_i=max_drop_list_i,1,-1 do
		local inventory_i = e.usetool.drop[drop_list_i]
		table.insert(t.inventory, table.remove(e.inventory, inventory_i))
	end
	world.addEntity(world, t)
	world.addEntity(world, e)
	e.usetool.drop = nil
end

local function process_equip(e)
	for _,inventory_i in ipairs(e.usetool.equip) do
		toolkit.equip(e.inventory[inventory_i], e)
	end
	e.usetool.equip = nil
end

function tool.process(system, e, dt)
	local world = system.world
	local t = world.state.terrain[e.pos]
	if e.usetool.pickup and tool.has_inventory_i(t, 1) then
		process_pickup(world, e, t)
	end

	if e.usetool.drop and tool.has_inventory_i(e, 1) then
		process_drop(world, e, t)
	end

	if e.usetool.equip and tool.has_inventory_i(e, 1) then
		process_equip(e)
	end
end

function tool.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("inventory", "usetool")
	system.process = tool.process
	return system
end

return tool