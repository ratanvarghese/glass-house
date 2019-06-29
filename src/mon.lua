local grid = require("src.grid")
local enum = require("src.enum")
local flood = require("src.flood")
local level = require("src.level")
local tool = require("src.tool")

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
	lvl:move(denizen, denizen.x + d.x, denizen.y + d.y)
end

local function simple_follow(lvl, denizen)
	local _, x, y = flood.local_min(denizen.x, denizen.y, lvl.paths.to_player)
	if (denizen.x ~= x or denizen.y ~= y) and not lvl:move(denizen, x, y) then
		lvl:bump_hit(denizen, x, y, 1)
	end
end

local function warp_follow(lvl, denizen, warp_factor)
	local p = lvl.denizens[lvl.player_id]
	local line = grid.line(denizen.x, denizen.y, p.x, p.y)
	for line_i=warp_factor,1,-1 do
		local pt = line[line_i]
		if pt and lvl:move(denizen, pt.x, pt.y) then
			return
		end
	end
	simple_follow(lvl, denizen)
end

local function smash_follow(lvl, denizen)
	local p = lvl.denizens[lvl.player_id]
	local line = grid.line(denizen.x, denizen.y, p.x, p.y)
	local dest = line[2]
	local dest_i = grid.get_idx(dest.x, dest.y)
	if not lvl.denizens[dest_i] and lvl.terrain[dest_i].kind == enum.terrain.wall then
		lvl.terrain[dest_i].kind = enum.terrain.floor
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
	return true
end

function mon.pickup_all_tools(pile_array, denizen)
	local pile = tool.pickup_all_from_array(pile_array, denizen.x, denizen.y)
	if not pile then
		return
	end

	for i,v in ipairs(pile) do
		table.insert(denizen.inventory, v)
	end
end

return mon
