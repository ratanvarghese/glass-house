local base = require("src.base")
local enum = require("src.enum")
local grid = require("src.grid")
local gen = require("src.gen")
local tool = require("src.tool")
local flood = require("src.flood")
local bestiary = require("src.bestiary")

local level = {}

function level:walkable(x, y, i)
	return (not self.denizens[i]) and (self.terrain[i].kind == enum.terrain.floor)
end

function level:paths_to(targ_x, targ_y)
	return flood.gradient(targ_x, targ_y, grid.make_full(function(x, y, i)
		return self:walkable(x, y, i) or (x == targ_x and y == targ_y)
	end))
end

function level:reset_paths()
	local player = self.denizens[self.player_id]
	assert(player, "Player not found")
	self.paths.to_player = self:paths_to(player.x, player.y)

	local _, stair_x, stair_y = flood.search(player.x, player.y, nil, function(x, y, i)
		return self.terrain[i].kind == enum.terrain.stair
	end)
	self.paths.to_stair = self:paths_to(stair_x, stair_y)
end

function level:light_area(radius, x, y)
	if not radius then
		return
	end

	local x1, y1, x2, y2 = x-radius, y-radius, x+radius, y+radius 
	grid.edit_rect(x1, y1, x2, y2, self.light, base.true_f)
	grid.edit_rect(x1, y1, x2, y2, self.memory, base.true_f)
end

function level:reset_light()
	self.light = {}
	for _,denizen in pairs(self.denizens) do
		local default = denizen.powers[enum.power.light]
		local radius = tool.light_from_list(denizen.inventory, default)
		self:light_area(radius, denizen.x, denizen.y)
	end
	grid.make_full(function(x, y, i)
		local pile = self.tool_piles[i]
		local radius = tool.light_from_list(pile)
		self:light_area(radius, x, y)
	end)
end

function level:set_light(b)
	self.light = grid.make_full(function() return b end)
end

function level:kill_denizen(id)
	if id == self.player_id then
		self.game_over = {
			msg = "You died!"
		}
	else
		local victim = self.denizens[id]
		self.kill_set[victim] = true --Remove from denizens_in_order later
		self.denizens[id] = nil
	end
	self:reset_light()
	self:reset_paths()
end

function level:check_kills()
	local start = #self.denizens_in_order
	local finish = 1
	for i=start,1,-1 do
		local d = self.denizens_in_order[i]
		if self.kill_set[d] then
			table.remove(self.denizens_in_order, i)
		end
	end
	self.kill_set = {}
end

function level:bump_hit(source, targ_x, targ_y, damage)
	local targ_id = grid.get_idx(targ_x, targ_y)
	local targ = self.denizens[targ_id]
	if not targ then
		return false
	end
	targ.hp = targ.hp - damage
	if targ.hp <= 0 then
		self:kill_denizen(targ_id)
	end
	return true
end

function level:move(denizen, new_x, new_y)
	local old_id = grid.get_idx(denizen.x, denizen.y)
	local new_id = grid.get_idx(new_x, new_y)
	local target = self.terrain[new_id]
	if target.kind == enum.terrain.wall then
		if old_id == self.player_id then
			self.memory[new_id] = true
		end
		return false
	elseif self.denizens[new_id] then
		return false
	end

	assert(denizen == self.denizens[old_id], "ID error for denizen")
	denizen.x = new_x
	denizen.y = new_y
	self.denizens[new_id] = denizen
	self.denizens[old_id] = nil
	self:reset_light()

	if old_id == self.player_id then
		self.player_id = new_id
	end
	self:reset_paths()
	return true
end

function level:add_denizen(dz)
	self.denizens[grid.get_idx(dz.x, dz.y)] = dz
	table.insert(self.denizens_in_order, dz)
end

function level.register(lvl)
	local mt = {__index = level}
	setmetatable(lvl, mt)
end

function level.make(num)
	local res = {
		light = {},
		terrain = {},
		denizens = {},
		denizens_in_order = {}, --Safe to iterate over while adding/removing, check kill_set
		memory = {},
		paths = {},
		kill_set = {},
		tool_piles = {},
		num = num,
		game_over = false
	}
	level.register(res)

	local terrain, init_x, init_y = gen.cave(res)
	res.terrain = terrain

	res.player_id = grid.get_idx(init_x, init_y)
	for k in pairs(bestiary.set) do
		local x, y = init_x, init_y
		if k ~= "player" then
			x, y = grid.rn_xy()
		end
		res:add_denizen(bestiary.make(k, x, y))
	end

	res:reset_light()
	res:reset_paths()
	return res
end

function level:visible_kind_at(x, y)
	local i = grid.get_idx(x, y)
	local denizen = self.denizens[i]
	local tile = self.terrain[i]
	local light = self.light[i]
	local memory = self.memory[i]
	local tool_pile = self.tool_piles[i]
	assert(type(tile)=="table", "Invalid tile at x="..x.." y="..y)

	if i == self.player_id then
		return denizen.kind, enum.monster
	elseif light then
		if denizen then
			return denizen.kind, enum.monster
		elseif tool_pile and #tool_pile > 0 then
			return tool_pile[#tool_pile].kind, enum.tool
		else
			return tile.kind, enum.terrain
		end
	elseif memory and tile.kind ~= enum.terrain.floor then
		return tile.kind, enum.terrain
	else
		return false, false
	end
end

function level:denizen_on_terrain(denizen_id, terrain_kind)
	return (self.terrain[denizen_id].kind == terrain_kind)
end

return level
