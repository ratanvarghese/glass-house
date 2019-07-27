local tiny = require("lib.tiny")

local enum = require("core.enum")
local flood = require("core.flood")
local proxy = require("core.proxy")

local path = {}

function path.walkable(world, pos)
		local terrain_kind = world.terrain[pos].kind
		local good_t = (terrain_kind == enum.terrain.floor) or (terrain_kind == enum.terrain.stair)
		return good_t and not world.denizens[pos]
end

function path.reset_all(system)
	system.world.walk_paths = proxy.memoize(function(target)
		return flood.gradient(target, function(pos)
			return path.walkable(system.world, pos)
		end)
	end)
end

function path.make_system()
	local system = tiny.system()
	system.filter = tiny.requireAll("pos")
	system.update = path.reset_all
	return system
end

return path