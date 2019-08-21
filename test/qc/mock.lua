local base = require("core.base")
local grid = require("core.grid")

local mock = require("test.mock")

property "mock.state: same result multiple times" {
	generators = {
		int(),
		bool(),
		int(1, 10)
	},
	check = function(seed, force_big_room, iters)
		local first = mock.state(seed, force_big_room)
		for i=1,iters do
			if not base.equals(first, mock.state(seed, force_big_room)) then
				return false
			end
		end
		return true
	end
}

property "mock.swap_player_pos: reversible" {
	generators = {
		int(),
		bool(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(1, 10)
	},
	check = function(seed, force_big_room, pos_1, iters)
		local state = mock.state(seed, force_big_room)
		local state_1 = base.copy(state)
		local cur_pos = mock.swap_player_pos(state, pos_1)
		local state_2 = base.copy(state)
		local pos_2 = cur_pos

		for i=1,iters do
			local p = mock.swap_player_pos(state, cur_pos)
			if cur_pos == pos_1 then
				if p ~= pos_2 or not base.equals(state, state_2) then
					return false
				end
			elseif cur_pos == pos_2 then
				if p ~= pos_1 or not base.equals(state, state_1) then
					return false
				end
			end
			cur_pos = p
		end
		return true
	end
}

property "mock.add_player_denizen: same result multiple times" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(1, 10)
	},
	check = function(seed, pos, iters)
		local state = {denizens = {}, player_pos = pos}
		local first = mock.add_player_denizen(seed, base.copy(state))
		for i=1,iters do
			if not base.equals(first, mock.add_player_denizen(seed, base.copy(state))) then
				return false
			end
		end
		return true
	end
}