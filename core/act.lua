local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")

local act = {}

local function modesplit(t)
	local possible_f = t.possible
	local utility_f = t.utility
	local attempt_f = t.attempt
	return function(mode, ...)
		if mode == enum.actmode.possible then
			return possible_f(...)
		elseif mode == enum.actmode.utility then
			return utility_f(...)
		elseif mode == enum.actmode.attempt then
			return attempt_f(...)
		else
			error("Bad mode")
		end
	end
end

local function move_denizen(world, d, new_pos)
	local old_pos = d.pos
	d.pos = new_pos
	world.denizens[old_pos] = nil
	world.denizens[d.pos] = d
	world.addEntity(world, d)
end

local mundane_wander = {}
function mundane_wander.options(world, source_pos)
	local options = {
		grid.travel(source_pos, 1, enum.cmd.north),
		grid.travel(source_pos, 1, enum.cmd.south),
		grid.travel(source_pos, 1, enum.cmd.east),
		grid.travel(source_pos, 1, enum.cmd.west)
	}

	local max_p = #options
	for i=max_p,1,-1 do
		local pos = options[i]
		if world.denizens[pos] or world.terrain[pos].kind ~= enum.terrain.floor then
			table.remove(options, i)
		end
	end
	return options
end

function mundane_wander.possible(world, source, dummy_i)
	return #(mundane_wander.options(world, source.pos)) > 0
end

function mundane_wander.utility(world, source, dummy_i)
	return mundane_wander.possible(world, source, dummy_i) and 1 or 0
end

function mundane_wander.attempt(world, source, dummy_i)
	local options = mundane_wander.options(world, source.pos)
	local can_do = #(options) > 0
	if not can_do then return false end
	move_denizen(world, source, options[math.random(1, #options)])
	return true
end

local mundane_pursue = {}
function mundane_pursue.options(paths, source_pos)
	local options = {
		grid.travel(source_pos, 1, enum.cmd.north),
		grid.travel(source_pos, 1, enum.cmd.south),
		grid.travel(source_pos, 1, enum.cmd.east),
		grid.travel(source_pos, 1, enum.cmd.west)
	}

	local max_p = #options
	for i=max_p,1,-1 do
		local pos = options[i]
		if not paths[pos] then
			table.remove(options, i)
		end
	end
	return options
end

function mundane_pursue.possible(world, source, target_i)
	if not world.light[target_i] then
		return false
	elseif grid.distance(source.pos, target_i) <= 1 then
		return false
	else
		local options = mundane_pursue.options(world.walk_paths[target_i], source.pos)
		return #options > 0
	end
end

function mundane_pursue.utility(world, source, target_i)
	if mundane_pursue.possible(world, source, target_i) then
		return grid.distance(source.pos, target_i)
	else
		return 0
	end
end

function mundane_pursue.attempt(world, source, target_i)
	if not world.light[target_i] then
		return false
	end
	local min, min_i = grid.adjacent_min(source.pos, world.walk_paths[target_i])
	if min >= math.huge or min < 1 then
		return false
	end
	move_denizen(world, source, min_i)
	return true
end

function act.init()
	act[enum.power.mundane] = {
		wander = modesplit(mundane_wander),
		pursue = modesplit(mundane_pursue)
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()
