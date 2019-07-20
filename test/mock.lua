local base = require("core.base")
local gen = require("core.gen")

local mock = {}

local big_room, big_room_start_i = gen.big_room()
local cave, cave_start_i = gen.cave()
function mock.world(make_cave)
	local res = {
		terrain = {},
		denizens = {},

		_denizens = {},
		_active_terrain = {},
		_terrain_reads = 0,
		_terrain_writes = 0,
		_active_denizens = {},
		_denizen_reads = 0,
		_denizen_writes = 0,
		_entities = {},
		_entity_adds = 0
	}
	if make_cave then
		res._terrain = cave
		res._start_i = cave_start_i
	else
		res._terrain = big_room
		res._start_i = big_room_start_i
	end
	res._terrain_mt = {
		__index = function(t, k)
			local v = res._active_terrain[k]
			if not v then
				v = base.copy(res._terrain[k])
				res._active_terrain[k] = v
			end
			res._terrain_reads = res._terrain_reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			res._terrain_writes = res._terrain_writes + 1
			res._active_terrain[k] = v
		end
	}
	setmetatable(res.terrain, res._terrain_mt)
	res._denizen_mt = {
		__index = function(t, k)
			local v = res._active_denizens[k]
			if not v then
				v = base.copy(res._denizens[k])
				res._active_denizens[k] = v
			end
			res._denizen_reads = res._denizen_reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			res._denizen_writes = res._denizen_writes + 1
			res._active_denizens[k] = v
		end
	}
	setmetatable(res.denizens, res._denizen_mt)
	res.addEntity = function(world, e)
		world._entities[e] = true
		world._entity_adds = world._entity_adds + 1
	end
	return res
end

return mock
