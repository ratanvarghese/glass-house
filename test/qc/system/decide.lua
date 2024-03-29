local enum = require("core.enum")
local grid = require("core.grid")
local power = require("core.power")
local act = require("core.act")
local decide = require("core.system.decide")

property "decide.player: movement commands" {
	generators = { int(1, #grid.direction_list), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(direction_i, pos)
		local d = grid.direction_list[direction_i]
		local mon = {pos = pos}
		local res_f, targ_i = decide.player(mon, {state={denizens={}}}, d, 1)
		return res_f == act[enum.power.mundane].pursue.attempt and targ_i == grid.travel(mon.pos, 1, d)
	end
}

property "decide.player: attack commands" {
	generators = { int(1, #grid.direction_list), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(direction_i, pos)
		local d = grid.direction_list[direction_i]
		local mon = {pos = pos}
		local predicted_targ_pos = grid.travel(mon.pos, 1, d)
		local targ = {pos=predicted_targ_pos}
		local state = {denizens={[predicted_targ_pos]=targ}}
		local res_f, targ_i = decide.player(mon, {state=state}, d, 1)
		return res_f == act[enum.power.mundane].melee.attempt and targ_i == predicted_targ_pos
	end
}

property "decide.player, decide.init: quit/exit commands" {
	generators = { bool(), tbl(), tbl(), int() },
	check = function(do_quit, e, world, n)
		local cmd = do_quit and enum.cmd.quit or enum.cmd.exit
		local old_exit = decide.exit
		local old_input = decide.input
		local args = nil
		decide.init(function(...) args = {...} end, function() end)
		decide.player(e, world, cmd, n)
		decide.init(old_exit, old_input)
		return args and args[1] == world and args[2] == do_quit
	end
}

property "decide.monster: pick function with maximum utility" {
	generators = {
		int(),
		int(),
		int(enum.power.MAX+1, enum.power.MAX*2),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(a, b, power_kind, pos)
		local mon = {power = {[power_kind] = power.DEFAULT}}
		local world = {state={player_pos = pos}}
		local min_f = function() return math.min(a, b) - 1 end
		local min_attempt = function() end
		local max_f = function() return math.max(a, b) + 1 end
		local max_attempt = function() end

		local min_t = {utility=min_f, attempt=min_attempt}
		local max_t={utility=max_f, attempt=max_attempt}
		act[power_kind] = {
			min = min_t,
			max = max_t,
			min_t,
			max_t
		}
		local res_f, res_targ = decide.monster(mon, world)
		act[power_kind] = nil
		return res_f == max_attempt and res_targ == world.state.player_pos
	end
}

property "decide.cmp: choose lowest clock id" {
	generators = {
		int(),
		int(),
		any()
	},
	check = function(a, b, system)
		local e1 = {clock={id=a}}
		local e2 = {clock={id=b}}
		local res = decide.cmp(system, e1, e2)
		return res or a >= b
	end
}

property "decide.get_ftarget: identical results to decide.monster or decide.player" {
	generators = {
		int(1, enum.decidemode.MAX-1),
		int(1, #grid.direction_list),
		int(),
		int(enum.power.MAX+1, enum.power.MAX*2),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(decidemode, direction_i, n, power_kind, x, y)
		local old_quit = decide.quit
		local old_input = decide.input
		local input_f = function() return grid.direction_list[direction_i], n end
		decide.init(function() end, input_f)
		local world = {state = {player_pos = grid.get_pos(x, y), denizens={}}}
		local mon = {
			power = {[power_kind] = power.DEFAULT},
			pos = grid.get_pos(x, y),
			decide = decidemode
		}
		local min_f = function() return math.min(x, y) - 1 end
		local min_attempt = function() end
		local max_f = function() return math.max(y, x) + 1 end
		local max_attempt = function() end

		local min_t = {utility=min_f, attempt=min_attempt}
		local max_t={utility=max_f, attempt=max_attempt}
		act[power_kind] = {
			min = min_t,
			max = max_t,
			min_t,
			max_t
		}
		local expect_f, expect_targ
		if decidemode == enum.decidemode.player then
			expect_f, expect_targ = decide.player(mon, world, input_f())
		elseif decidemode == enum.decidemode.monster then
			expect_f, expect_targ = decide.monster(mon, world)
		end
		local res_f, res_targ = decide.get_ftarget(world, mon)
		act[power_kind] = nil
		decide.init(old_quit, old_input)
		return res_f == expect_f and res_targ == expect_targ
	end
}
