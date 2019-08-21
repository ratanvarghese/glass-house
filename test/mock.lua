local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local gen = require("core.gen")
local flood = require("core.flood")
local proxy = require("core.proxy")

local mock = {}

local function coin_flip()
	return (math.random(1, 2) == 1)
end

function mock.state(seed, force_big_room)
	math.randomseed(seed)
	local res = {num = math.random(1, 100), denizens = {}, light = {}, memory = {}}
	if force_big_room or coin_flip() then
		res.terrain, res.player_pos = gen.big_room()
	else
		res.terrain, res.player_pos = gen.cave()
	end
	for pos in grid.points() do
		res.light[pos] = coin_flip()
		res.memory[pos] = coin_flip()
	end
	return res
end

function mock.swap_player_pos(state, targ_pos)
	state.player_pos, targ_pos = targ_pos, state.player_pos
	return targ_pos
end

function mock.add_player_denizen(seed, state)
	math.randomseed(seed)
	local player = {
		pos = state.player_pos,
		destination = state.player_pos,
		inventory = {},
		usetool = {},
		health = {}
	}
	player.health.max = math.random(1, 1000)
	player.health.now = math.random(1, player.health.max)
	state.denizens[state.player_pos] = player
	return player
end

function mock.world_from_state(state)
	local res = tiny.world()
	res.state, res.ctrl = {}, {}
	for k,v in pairs(state) do
		if type(v) == "table" then
			res.state[k], res.ctrl[k] = proxy.read_write(v)
		else
			res.state[k] = v
		end
	end
	res._eligible = function(pos)
		if not res.state.terrain[pos] then return false end
		local t_kind = res.state.terrain[pos].kind
		local good_t = t_kind ~= enum.tile.wall and t_kind ~= enum.tile.tough_wall
		return good_t and not res.state.denizens[pos]
	end
	res._setup_walk_paths = function(world, ...)
		local targets = {...}
		world.walk_paths = {}
		for _,pos in ipairs(targets) do
			world.walk_paths[pos] = flood.gradient(pos, res._eligible)
		end
	end
	return res
end

function mock.mini_world(seed, pos, force_big_room)
	local state = mock.state(seed, force_big_room)
	local targ_pos = mock.swap_player_pos(state, pos)
	local src = mock.add_player_denizen(seed, state)
	local w = mock.world_from_state(state)
	w._setup_walk_paths(w, pos, targ_pos)
	return w, src, targ_pos
end

return mock