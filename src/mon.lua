local grid = require("src.grid")
local enum = require("src.enum")
local flood = require("src.flood")
local level = require("src.level")
local tool = require("src.tool")
local time = require("src.time")
local bestiary = require("src.bestiary")

local mon = {}

function mon.update_countdowns(denizen)
	local nc = {}
	for k,v in pairs(denizen.countdowns) do
		if v > 1 then
			nc[k] = v - 1
		end
	end
	denizen.countdowns = nc
end

function mon.act(lvl, denizen)
	local slow_factor = denizen.powers[enum.power.slow]
	if slow_factor then
		local x1 = denizen.x - slow_factor
		local x2 = denizen.x + slow_factor
		local y1 = denizen.y - slow_factor
		local y2 = denizen.y + slow_factor
		grid.make_rect(x1, y1, x2, y2, function(x, y, i)
			local dz = lvl.denizens[i]
			if not dz then return end
			if dz.powers[enum.power.slow] then return end
			dz.countdowns[enum.countdown.slow] = 2
		end)
	end

	if lvl.light[lvl.player_id] and not denizen.powers[enum.power.peaceful] then
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
	
	local stuck_to = source.relations[enum.relations.stuck_to]
	if stuck_to and stuck_to ~= targ then
		local stuck_id = grid.get_idx(stuck_to.x, stuck_to.y)
		if lvl.denizens[stuck_id] then
			return false
		else
			source.relations[enum.relations.stuck_to] = nil
		end
	end

	if source.powers[enum.power.steal] and #targ.inventory > 0 then
		local stolen_idx = math.random(1, #targ.inventory)
		local stolen = table.remove(targ.inventory, stolen_idx)
		table.insert(source.inventory, stolen)
		lvl:reset_light()
		return false		
	end

	local source_id = grid.get_idx(source.x, source.y)
	if targ.powers[enum.power.displace] or source.powers[enum.power.displace] then
		assert(lvl.denizens[source_id] == source, "couldn't find source on level")
		assert(lvl.denizens[targ_id] == targ, "couldn't find targ on level")
		targ.x, source.x = source.x, targ.x
		targ.y, source.y = source.y, targ.y
		lvl.denizens[source_id] = targ
		lvl.denizens[targ_id] = source
		if source_id == lvl.player_id then
			lvl.player_id = targ_id
		elseif targ_id == lvl.player_id then
			lvl.player_id = source_id
		end
		return false
	end

	if source.powers[enum.power.bodysnatch] then
		if targ_id == lvl.player_id then 
			lvl.player_id = source_id
			return false
		end
		if source_id == lvl.player_id then
			lvl.player_id = targ_id
			return false
		end
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
		local src_sticky = source.powers[enum.power.sticky]
		local targ_sticky = targ.powers[enum.power.sticky]
		if src_sticky and not targ_sticky then
			targ.relations[enum.relations.stuck_to] = source
		elseif targ_sticky and not src_sticky then
			source.relations[enum.relations.stuck_to] = targ
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
	if dest and lvl:smash(dest.x, dest.y) then
		lvl:move(denizen, dest.x, dest.y)
	else
		simple_follow(lvl, denizen)
	end
end

local function do_clone(lvl, denizen, x, y)
	local clone = bestiary.make(denizen.kind, x, y)
	clone.hp = math.floor(denizen.hp / 2)
	denizen.hp = math.floor(denizen.hp / 2)
	lvl:add_denizen(clone)
	time.spend_move(denizen.clock)
end

local function do_summon(lvl, denizen, x, y)
	local kind = enum.rn_item(enum.monster, true)
	lvl:add_denizen(bestiary.make(kind, x, y))
	time.spend_move(denizen.clock)
end

local function spawn_follow(lvl, denizen, factor, clone)
	local player_x, player_y = lvl:player_xy()
	local line = grid.line(denizen.x, denizen.y, player_x, player_y)
	if #line > factor or #line <= 2 or (clone and denizen.hp < 2) then
		simple_follow(lvl, denizen)
		return
	end
	local _, x, y = flood.local_min(denizen.x, denizen.y, lvl.paths.to_player)
	if denizen.x == x and denizen.y == y then
		time.spend_move(denizen.clock)
		return
	end
	if clone then
		do_clone(lvl, denizen, x, y)
	else
		do_summon(lvl, denizen, x, y)
	end
end

function mon.follow_player(lvl, denizen)
	local warp_factor = denizen.powers[enum.power.warp]
	local clone_factor = denizen.powers[enum.power.clone]
	local summon_factor = denizen.powers[enum.power.summon]
	if warp_factor then
		warp_follow(lvl, denizen, warp_factor)
	elseif clone_factor then
		spawn_follow(lvl, denizen, clone_factor, true)
	elseif summon_factor then
		spawn_follow(lvl, denizen, summon_factor, false)
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
