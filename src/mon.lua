local grid = require("src.grid")
local enum = require("src.enum")
local flood = require("src.flood")
local level = require("src.level")
local tool = require("src.tool")
local time = require("src.time")

local mon = {}

function mon.act(lvl, denizen)
	if lvl.light[lvl.player_id] then
		mon.follow_player(lvl, denizen)
	else
		mon.wander(lvl, denizen)
	end
end

function mon.wander(lvl, denizen)
	local d = grid.rn_direction()
	local try_move = lvl:move(denizen, denizen.x + d.x, denizen.y + d.y)

	if denizen.powers[enum.power.smash] and not try_move then
		lvl:smash(denizen.x + d.x, denizen.y + d.y)
		lvl:move(denizen, denizen.x + d.x, denizen.y + d.y)
	end
end

local function calc_damage(source)
	local possible_damage = {1}
	if source.kind == enum.monster.player then
		table.insert(possible_damage, 2)
	end
	if source.powers[enum.power.kick] then
		table.insert(possible_damage, source.powers[enum.power.kick_strength])
	end
	if source.powers[enum.power.punch] then
		table.insert(possible_damage, source.powers[enum.power.punch_strength])
	end
	return math.max(unpack(possible_damage))
end


local function calc_hits(source)
	local possible_hits = {1}
	table.insert(possible_hits, source.powers[enum.power.kick])
	table.insert(possible_hits, source.powers[enum.power.punch])
	return math.max(unpack(possible_hits))
end

function mon.hit_or_heal(targ, damage)
	local old_hp = targ.hp
	local new_hp = targ.hp - damage
	if new_hp < 0 then new_hp = 0 end
	if new_hp > targ.max_hp then new_hp = targ.max_hp end
	targ.hp = new_hp
	return old_hp - new_hp
end

function mon.bump_hit(lvl, source, targ_x, targ_y)
	local targ_id = grid.get_idx(targ_x, targ_y)
	local targ = lvl.denizens[targ_id]
	time.spend_move(source.clock) --Regardless of whether or not there's a target!
	if not targ then
		return false
	end

	local predicted = calc_damage(source)
	if source.powers[enum.power.heal] then
		predicted = -predicted
	end
	local hits = calc_hits(source)
	for i=1,hits do
		local actual = mon.hit_or_heal(targ, predicted)
		if source.powers[enum.power.vampiric] then
			mon.hit_or_heal(source, -actual)
		end
		if targ.hp <= 0 then
			lvl:kill_denizen(targ_id)
			break
		end
	end
	return true
end

local function simple_follow(lvl, denizen)
	local _, x, y = flood.local_min(denizen.x, denizen.y, lvl.paths.to_player)
	if (denizen.x ~= x or denizen.y ~= y) and not lvl:move(denizen, x, y) then
		mon.bump_hit(lvl, denizen, x, y)
	end
end

local function warp_follow(lvl, denizen, warp_factor)
	local player_x, player_y = lvl:player_xy()
	local line = grid.line(denizen.x, denizen.y, player_x, player_y)
	for line_i=warp_factor,2,-1 do
		local pt = line[line_i]
		if pt and lvl:move(denizen, pt.x, pt.y) then
			return
		end
	end
	simple_follow(lvl, denizen)
end

local function smash_follow(lvl, denizen)
	local player_x, player_y = lvl:player_xy()
	local line = grid.line(denizen.x, denizen.y, player_x, player_y)
	local dest = line[2]
	if lvl:smash(dest.x, dest.y) then
		lvl:move(denizen, dest.x, dest.y)
	else
		simple_follow(lvl, denizen)
	end
end

function mon.follow_player(lvl, denizen)
	local warp_factor = denizen.powers[enum.power.warp]
	if warp_factor then
		warp_follow(lvl, denizen, warp_factor)
	elseif denizen.powers[enum.power.smash] then
		smash_follow(lvl, denizen)	
	else
		simple_follow(lvl, denizen)
	end
end

function mon.drop_tool(pile_array, denizen, tool_idx)
	if not denizen.inventory or #denizen.inventory < 1 then
		return false
	end

	local tool_to_drop = table.remove(denizen.inventory, tool_idx)
	tool.drop_onto_array(pile_array, tool_to_drop, denizen.x, denizen.y)
	time.spend_move(denizen.clock)
	return true
end

function mon.pickup_tool(pile_array, denizen, tool_idx)
	local targ_tool = tool.pickup_from_array(pile_array, tool_idx, denizen.x, denizen.y)
	if not targ_tool then
		return false
	end

	local inventory = denizen.inventory
	if inventory then
		table.insert(inventory, targ_tool)
	else
		denizen.inventory = {targ_tool}
	end
	time.spend_move(denizen.clock)
	return true
end

function mon.pickup_all_tools(pile_array, denizen)
	local pile = tool.pickup_all_from_array(pile_array, denizen.x, denizen.y) or {}
	local n = #pile
	for i,v in ipairs(pile) do
		table.insert(denizen.inventory, v)
	end
	if n > 0 then
		time.spend_move(denizen.clock)
	end
end

return mon
