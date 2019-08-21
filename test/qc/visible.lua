local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local visible = require("core.visible")

local mock = require("test.mock")

property "visible.at: just terrain" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w = mock.world_from_state(mock.state(seed))
		local k, e = visible.at(w, pos)
		if w.state.light[pos] then
			return k == w.state.terrain[pos].kind and e == enum.tile
		elseif w.state.memory[pos] and w.state.terrain[pos].kind ~= enum.tile.floor then
			return k == w.state.terrain[pos].kind and e == enum.tile
		else
			return not k and not e
		end
	end
}

property "visible.at: player" {
	generators = { int(), int() },
	check = function(seed, kind)
		local w = mock.world_from_state(mock.state(seed))
		local player = mock.add_player_denizen(seed, w.state)
		player.kind = kind
		local k, e = visible.at(w, player.pos)
		return k == kind and e == enum.monster
	end
}

property "visible.at: denizen" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int() },
	check = function(seed, pos, kind)
		local w = mock.world_from_state(mock.state(seed))
		w.state.denizens[pos] = {kind = kind}
		local k, e = visible.at(w, pos)
		if w.state.light[pos] then
			return k == kind and e == enum.monster
		else
			return e ~= enum.monster
		end
	end
}

property "visible.at: tool" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(), int() },
	check = function(seed, pos, kind, dummy1)
		local w = mock.world_from_state(mock.state(seed))
		w.state.terrain[pos].inventory = { {kind = dummy1}, {kind = kind} }
		local k, e = visible.at(w, pos)
		if w.state.light[pos] then
			return k == kind and e == enum.tool
		else
			return e ~= enum.tool
		end
	end
}

property "visible.stats: health" {
	generators = { int() },
	check = function(seed)
		local w = mock.world_from_state(mock.state(seed))
		local raw_health = base.copy(mock.add_player_denizen(seed, w.state).health)
		return base.equals(visible.stats(w).health, raw_health)
	end
}