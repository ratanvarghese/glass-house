--- System for deciding on an action
-- @module core.system.decide

local tiny = require("lib.tiny")

local enum = require("core.enum")
local act = require("core.act")
local grid = require("core.grid")
local clock = require("core.clock")

local decide = {}

--- Select action function from player commands
-- @tparam table e player entity
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @tparam enum.cmd cmd
-- @tparam int n inventory index
-- @treturn func action function
-- @return inventory number (int) or target position (`grid.pos`)
function decide.player(e, world, cmd, n)
	if grid.directions[cmd] then
		local targ_i = grid.travel(e.pos, 1, cmd)
		local f
		if world.state.denizens[targ_i] then
			f = act[enum.power.mundane].melee.attempt
		else
			f = act[enum.power.mundane].pursue.attempt
		end
		return f, targ_i
	elseif cmd == enum.cmd.quit then
		decide.exit(world, true)
	elseif cmd == enum.cmd.exit then
		decide.exit(world, false)
	elseif cmd == enum.cmd.equip then
		return act[enum.power.tool].equip.attempt, (n or 1)
	elseif cmd == enum.cmd.drop then
		return act[enum.power.tool].drop.attempt, (n or 1)
	else
		error("Sorry, that command is not implemented")
	end
end

--- Select action function for monster using utility-based AI
-- @tparam table e monster entity
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @treturn func action function
-- @return inventory number (int) or target position (`grid.pos`)
function decide.monster(e, world)
	local max_utility = -math.huge
	local max_utility_f = nil
	local max_utility_power = nil
	for p,v in pairs(e.power) do
		local actions = act[p] or {}
		for _,t in pairs(actions) do
			local v = t.utility(world, e, world.state.player_pos)
			if v > max_utility then
				max_utility = v
				max_utility_f = t.attempt
				max_utility_power = p
			end
		end
	end
	return max_utility_f, world.state.player_pos
end

--- Select action function
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @tparam table e monster or player entity
-- @treturn func action function
-- @return inventory number (int) or target position (`grid.pos`)
function decide.get_ftarget(world, e)
	if e.decide == enum.decidemode.player then
		return decide.player(e, world, decide.input())
	elseif e.decide == enum.decidemode.monster then
		return decide.monster(e, world)
	end
	error("Bad decide mode")
end

--- Preprocess system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function decide.pre(system)
	if not system.target_ent_i or not system.entities[system.target_ent_i] then
		system.target_ent_i = 1
		system.changed_target = true
	end
	if system.changed_target then
		clock.earn_credit(system.entities[system.target_ent_i].clock)
	end
	system.changed_target = false
end

--- Process system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function decide.process(system, e, dt)
	if e == system.entities[system.target_ent_i] and clock.has_credit(e.clock) then
		local f, target = decide.get_ftarget(system.world, e)
		f(system.world, e, target)
		clock.spend_credit(e.clock)

		if e.decide == enum.decidemode.player and e.pos ~= e.destination then
			local f = act[enum.power.tool].pickup.attempt
			f(system.world, e, 1)
		end
	end
end

--- Postprocess system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function decide.post(system)
	if not clock.has_credit(system.entities[system.target_ent_i].clock) then
		system.target_ent_i = system.target_ent_i + 1
		system.changed_target = true
	end
end

--- Sort system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function decide.cmp(sys, e1, e2)
	return e1.clock.id < e2.clock.id
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function decide.make_system()
	local system = tiny.sortedProcessingSystem()
	system.filter = tiny.requireAll("clock", "decide", "pos")
	system.compare = decide.cmp
	system.process = decide.process
	system.preProcess = decide.pre
	system.postProcess = decide.post
	return system
end

--- Initialize callbacks for `core.system.decide` module
-- @tparam func exit_f exit callback
-- @tparam func input_f player input callback
-- @treturn table `core.system.decide` module
function decide.init(exit_f, input_f)
	decide.exit = exit_f
	decide.input = input_f
	return decide
end

return decide.init(function() end, function() return enum.cmd.exit, 1 end)
