local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local toolkit = require("core.toolkit")

local light = {}

function light.set_area(arr, radius, pos, v)
	for i in grid.surround(pos, radius) do
		arr[i] = v
	end
end

function light.set_all(arr, v)
	for i in grid.points() do arr[i] = v end
end

function light.set_from_entity(e, light_arr, mem_arr, dark_arr)
	local p_light = enum.power.light
	local intrinsic_light = e.power and e.power[p_light] or nil
	local r_light = toolkit.inventory_power(p_light, e.inventory, intrinsic_light) or -math.huge

	local p_dark = enum.power.darkness
	local intrinsic_dark = e.power and e.power[p_dark] or nil
	local r_dark = toolkit.inventory_power(p_dark, e.inventory, intrinsic_dark) or -math.huge
	if r_light < r_dark and r_dark >= 0 then
		light.set_area(dark_arr, r_dark, e.pos, true)
	elseif r_light > r_dark and r_light >= 0 then
		light.set_area(light_arr, r_light, e.pos, true)
		light.set_area(mem_arr, r_light, e.pos, true)
	end
	--If equal, they cancel out
end

function light.cancel_light(light_arr, dark_arr)
	for i in pairs(dark_arr) do
		light_arr[i] = nil
	end
end

function light.setup_tables(system)
	system.world.state.light = {}
	system.world.state.dark = {}
	system.world.state.memory = system.world.state.memory or {}
end

function light.process(system, e, dt)
	light.set_from_entity(e, system.world.state.light, system.world.state.memory, system.world.state.dark)
end

function light.post(system)
	light.cancel_light(system.world.state.light, system.world.state.dark)
end

function light.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.filter("pos&(power|inventory)")

	system.preProcess = light.setup_tables
	system.process = light.process
	system.postProcess = light.post

	system.preWrap = light.setup_tables
	return system
end

return light
