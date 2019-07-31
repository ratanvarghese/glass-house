local tiny = require("lib.tiny")

local enum = require("core.enum")
local act = require("core.act")
local grid = require("core.grid")
local tool = require("core.tool")
local clock = require("core.clock")

local decide = {}

function decide.player(e, world, cmd, n)
	if grid.directions[cmd] then
		local targ_i = grid.travel(e.pos, 1, cmd)
		local f
		if world.denizens[targ_i] then
			f = act[enum.power.mundane].melee
		else
			f = act[enum.power.mundane].pursue
		end
		return f, targ_i
	elseif cmd == enum.cmd.quit then
		decide.exit(world, true)
	elseif cmd == enum.cmd.exit then
		decide.exit(world, false)
	elseif cmd == enum.cmd.equip then
		return act[enum.power.tool].equip, (n or 1)
	elseif cmd == enum.cmd.drop then
		return act[enum.power.tool].drop, (n or 1)
	else
		error("Sorry, that command is not implemented")
	end
end

function decide.monster(e, world)
	local max_utility = -math.huge
	local max_utility_f = nil
	for p,v in pairs(e.power) do
		local actions = act[p] or {}
		for _,f in ipairs(actions) do
			local v = f(enum.actmode.utility, world, e, world.player_pos)
			if v > max_utility then
				max_utility = v
				max_utility_f = f
			end
		end
	end
	return max_utility_f, world.player_pos
end

function decide.get_ftarget(world, e)
	if e.decide == enum.decidemode.player then
		return decide.player(e, world, decide.input())
	elseif e.decide == enum.decidemode.monster then
		return decide.monster(e, world)
	end
	error("Bad decide mode")
end

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

function decide.process(system, e, dt)
	if e == system.entities[system.target_ent_i] and clock.has_credit(e.clock) then
		local f, target = decide.get_ftarget(system.world, e)
		f(enum.actmode.attempt, system.world, e, target)
		clock.spend_credit(e.clock)

		if e.decide == enum.decidemode.player and e.pos ~= e.destination then
			local f = act[enum.power.tool].pickup
			f(enum.actmode.attempt, system.world, e, 1)
		end
	end
end

function decide.post(system)
	if not clock.has_credit(system.entities[system.target_ent_i].clock) then
		system.target_ent_i = system.target_ent_i + 1
		system.changed_target = true
	end
end

function decide.cmp(sys, e1, e2)
	return e1.clock.id < e2.clock.id
end

function decide.make_system()
	local system = tiny.sortedProcessingSystem()
	system.filter = tiny.requireAll("clock", "decide", "pos")
	system.compare = decide.cmp
	system.process = decide.process
	system.preProcess = decide.pre
	system.postProcess = decide.post
	return system
end

function decide.init(exit_f, input_f)
	decide.exit = exit_f
	decide.input = input_f
	return decide
end

return decide.init(function() end, function() return enum.cmd.exit, 1 end)
