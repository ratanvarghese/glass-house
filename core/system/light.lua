--- System to manage light and darkness
-- @module core.system.light

local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local toolkit = require("core.toolkit")

local light = {}

--- Set square area of a grid to a given value.
-- @tparam {[grid.pos]=bool,...} arr a grid
-- @tparam int radius minimum distance of square edge from center
-- @tparam grid.pos pos center of square
-- @tparam bool v value to assign to square area
function light.set_area(arr, radius, pos, v)
	for i in grid.surround(pos, radius) do
		arr[i] = v
	end
end

--- Set all points of a grid to a given value.
-- @tparam {[grid.pos]=bool,...} arr a grid
-- @tparam bool v value to assign to all points of grid
function light.set_all(arr, v)
	for i in grid.points() do arr[i] = v end
end

--- Given an entity, set light and darkness of surrounding points.
-- @tparam table e entity
-- @tparam {[grid.pos]=bool,...} light_arr table with true values for lit points
-- @tparam {[grid.pos]=bool,...} mem_arr table with true values for points player remembers
-- @tparam {[grid.pos]=bool,...} dark_arr table with true values for dark points
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

--- Ensure that for any given point, explicit darkness override light.
-- Explicit darkness is not the mere absence of light, but a magical darkness
-- caused by enum.power.darkness.
-- @tparam {[grid.pos]=bool,...} light_arr table with true values for lit points
-- @tparam {[grid.pos]=bool,...} dark_arr table with true values for dark points
function light.cancel_light(light_arr, dark_arr)
	for i in pairs(dark_arr) do
		light_arr[i] = nil
	end
end

--- Setup state associated with light and darkness
-- @tparam tiny.system system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function light.setup_tables(system)
	system.world.state.light = {}
	system.world.state.dark = {}
	system.world.state.memory = system.world.state.memory or {}
end

--- Process system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function light.process(system, e, dt)
	light.set_from_entity(e, system.world.state.light, system.world.state.memory, system.world.state.dark)
end

--- Postprocess system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function light.post(system)
	light.cancel_light(system.world.state.light, system.world.state.dark)
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
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
