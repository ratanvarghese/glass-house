local tiny = require("lib.tiny")

local enum = require("core.enum")
local act = require("core.act")
local grid = require("core.grid")
local tool = require("core.tool")
local clock = require("core.clock")

local decide = {}

function decide.player(e, world, cmd, n)
	if grid.directions[cmd] then
		local f = act[enum.power.mundane].pursue
		local targ_i = grid.travel(e.pos, 1, cmd)
		return f, targ_i
	elseif cmd == enum.cmd.quit then
		decide.exit(world, true)
	elseif cmd == enum.cmd.exit then
		decide.exit(world, false)
	elseif cmd == enum.cmd.equip then
		if n and e.inventory and e.inventory[n] then
			return function(dummy, world, e, dummy2)
				tool.equip(e.inventory[n], e)
				return true
			end
		else
			return function() end
		end
	elseif cmd == enum.cmd.drop then
		if e.inventory and #e.inventory > 0 then
			return function(dummy, world, e, dummy2)
				local t = world.terrain[e.pos]
				if not t.inventory then t.inventory = {} end
				table.insert(t.inventory, table.remove(e.inventory))
				world.addEntity(world, t)
				world.addEntity(world, e)
				return true
			end
		else
			return function() end
		end
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
	end
end

function decide.process(system, e, dt)
	if e == system.entities[system.target_ent_i] then
		clock.earn_credit(e.clock)
		local old_pos = e.pos
		while clock.has_credit(e.clock) do
			local f, target = decide.get_ftarget(system.world, e)
			f(enum.actmode.attempt, system.world, e, target)
			clock.spend_credit(e.clock)
		end
		if e.decide == enum.decidemode.player and e.pos ~= old_pos then
			local t = system.world.terrain[e.pos]
			if t.inventory and #t.inventory > 0 then
				e.inventory = e.inventory or {}
				table.insert(e.inventory, table.remove(t.inventory))
				system.world.addEntity(system.world, t)
				system.world.addEntity(system.world, e)
			end
		end
	end
end

function decide.post(system)
	system.target_ent_i = system.target_ent_i + 1
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
