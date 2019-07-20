local base = require("core.base")
local gen = require("core.gen")
local proxy = require("core.proxy")

local mock = {}

local big_room, big_room_start_i = gen.big_room()
local cave, cave_start_i = gen.cave()
function mock.world(make_cave)
	local res = {
		_denizens = {},
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
	res.terrain, res._terrain_ctrl = proxy.write_to_alt(res._terrain)
	res.denizens, res._denizens_ctrl = proxy.write_to_alt(res._denizens)
	res.addEntity = function(world, e)
		world._entities[e] = true
		world._entity_adds = world._entity_adds + 1
	end
	return res
end

return mock
