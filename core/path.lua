local tiny = require("lib.tiny")

local enum = require("core.enum")
local flood = require("core.flood")
local proxy = require("core.proxy")

local path = {}

function path.walk_to(target, world)
	local function walkable(pos)
		local t_kind = world.terrain[pos].kind
		local good_t = t_kind ~= enum.terrain.wall and t_kind ~= enum.terrain.tough_wall
		return good_t and not world.denizens[pos]
	end

	return flood.gradient(target, walkable)
end

function path.reset_all(system)
	local w = system.world
	w.walk_paths = proxy.memoize(function(target) return path.walk_to(target, w) end)
end

function path.make_system()
	local system = tiny.system()
	system.filter = tiny.requireAll("pos")
	system.update = path.reset_all
	return system
end

return path
