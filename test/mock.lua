local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local gen = require("core.gen")
local proxy = require("core.proxy")
local flood = require("core.flood")

local mock = {}

local big_room, big_room_start_i = gen.big_room()
local cave, cave_start_i = gen.cave()

function mock.world(make_cave)
	local res = {
		_denizens = {},
		_entities = {},
		_entity_adds = 0,
		_regens = {},
		num = 0
	}
	if make_cave then
		res._terrain = cave
		res._start_i = cave_start_i
	else
		res._terrain = big_room
		res._start_i = big_room_start_i
	end
	res._light = {}
	for i in grid.points() do
		res._light[i] = (math.random(1, 2) == 2)
	end
	res._memory = {}
	for i in grid.points() do
		res._memory[i] = (math.random(1, 2) == 2)
	end
	res.light, res._light_ctrl = proxy.read_write(res._light) --Expect writing nil
	res.memory, res._memory_ctrl = proxy.read_write(res._memory)
	res.terrain, res._terrain_ctrl = proxy.write_to_alt(res._terrain) --Protect shared data
	res.denizens, res._denizens_ctrl = proxy.read_write(res._denizens) --Expect writing nil
	res.addEntity = function(world, e)
		world._entities[e] = true
		world._entity_adds = world._entity_adds + 1
	end
	res._eligible = function(i)
		if not res.terrain[i] then return false end
		local t_kind = res.terrain[i].kind
		local good_t = t_kind ~= enum.terrain.wall and t_kind ~= enum.terrain.tough_wall
		return good_t and not res.denizens[i]
	end
	res._setup_walk_paths = function(world, ...)
		local targets = {...}
		world.walk_paths = {}
		for _,i in ipairs(targets) do
			world.walk_paths[i] = flood.gradient(i, res._eligible)
		end
	end
	res.regen = function(world, n)
		table.insert(world._regens, n)
	end
	return res
end

function mock.mini_world(cave, swap, x, y)
	local x = x or math.floor(grid.MAX_X/2)
	local y = y or math.floor(grid.MAX_Y/2)
	local w = mock.world(cave)
	local targ_i = grid.get_pos(x, y)
	local source_i = w._start_i
	if swap then
		targ_i, source_i = source_i, targ_i
	end
	local source = {pos=source_i, inventory={}}
	w._denizens[source_i] = source
	w._setup_walk_paths(w, source_i, targ_i)
	return w, source, targ_i
end

return mock
