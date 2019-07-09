local base = require("src.base")
local enum = require("src.enum")
local grid = require("src.grid")
local time = require("src.time")
local gen = require("src.gen")
local tool = require("src.tool")
local flood = require("src.flood")
local bestiary = require("src.bestiary")

local level = {}

function level:walkable(x, y, i)
	local i = i or grid.get_idx(x, y)
	return (not self.denizens[i]) and (self.terrain[i].kind == enum.terrain.floor)
end

function level:paths_to(targ_x, targ_y)
	return flood.gradient(targ_x, targ_y, grid.make_full(function(x, y, i)
		return self:walkable(x, y, i) or (x == targ_x and y == targ_y)
	end))
end

function level:reset_paths()
	self.paths.to_player = self:paths_to(self:player_xy())
	self.paths.to_stair = self:paths_to(self.stair_x, self.stair_y)
end

function level:light_area(radius, x, y, dark, old_mem)
	if not radius then return end
	local x1, y1, x2, y2 = x-radius, y-radius, x+radius, y+radius
	if dark then
		grid.edit_rect(x1, y1, x2, y2, self.light, function() end)
		grid.edit_rect(x1, y1, x2, y2, self.memory, function(x, y, i)
			return old_mem[i]
		end)
	else
		grid.edit_rect(x1, y1, x2, y2, self.light, base.true_f)
		grid.edit_rect(x1, y1, x2, y2, self.memory, base.true_f)
	end
end

function level:reset_light()
	local old_mem = base.copy(self.memory)
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
	for _,denizen in pairs(self.denizens) do
		local radius = denizen.powers[enum.power.darkness]
		self:light_area(radius, denizen.x, denizen.y, true, old_mem)
	end
end

function level:set_light(b)
	self.light = grid.make_full(function() return b end)
end

function level:add_denizen(dz)
	self.add_set[dz] = true
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

function level:check_adds()
	for dz in pairs(self.add_set) do
		if self:walkable(dz.x, dz.y) then
			local i = grid.get_idx(dz.x, dz.y)
			self.denizens[i] = dz
			if i == self.player_id then
				table.insert(self.denizens_in_order, 1, dz)
			else
				table.insert(self.denizens_in_order, dz)
			end
		end
	end
	self.add_set = {}
end

function level:move(denizen, new_x, new_y)
	local new_id = grid.get_idx(new_x, new_y)
	local target = self.terrain[new_id]
	local stuck_to = denizen.relations[enum.relations.stuck_to]
	if stuck_to and stuck_to ~= target then
		local stuck_id = grid.get_idx(stuck_to.x, stuck_to.y)
		if self.denizens[stuck_id] then
			time.spend_move(denizen.clock)
			return false
		else
			denizen.relations[enum.relations.stuck_to] = nil
		end
	end

	local old_id = grid.get_idx(denizen.x, denizen.y)
	if target.kind == enum.terrain.wall or target.kind == enum.terrain.tough_wall then
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
	time.spend_move(denizen.clock)
	return true
end

function level:smash(x, y)
	local i = grid.get_idx(x, y)
	if not self.denizens[i] and self.terrain[i].kind == enum.terrain.wall then
		self.terrain[i].kind = enum.terrain.floor
		return true
	else
		return false
	end
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
		add_set = {},
		tool_piles = {},
		num = num,
		game_over = false
	}
	level.register(res)

	local terrain, init_x, init_y = gen.cave(res)
	res.terrain = terrain

	local _, stair_x, stair_y = flood.search(init_x, init_y, nil, function(x, y, i)
		return res.terrain[i].kind == enum.terrain.stair
	end)
	res.stair_x = stair_x
	res.stair_y = stair_y

	res.player_id = grid.get_idx(init_x, init_y)
	for k in pairs(bestiary.set) do
		local x, y = init_x, init_y
		if k ~= enum.monster.player then
			x, y = grid.rn_xy()
		end
		res:add_denizen(bestiary.make(k, x, y))
	end
	res:check_adds()

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

function level:player_xy()
	local p = self.denizens[self.player_id]
	return p.x, p.y
end

return level
