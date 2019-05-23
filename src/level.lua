local base = require("src.base")
local gen = require("src.gen")
local tool = require("src.tool")
local path = require("src.path")

local level = {}

function level:walkable(x, y, i)
	return (not self.denizens[i]) and (self.terrain[i].symbol == base.symbols.floor)
end

function level:paths_to(targ_x, targ_y)
	return path.to(targ_x, targ_y, function(x, y, i) return self:walkable(x, y, i) end)
end

function level:reset_paths()
	local player = self.denizens[self.player_id]
	assert(player, "Player not found")
	self.paths.to_player = self:paths_to(player.x, player.y)

	for _,v in pairs(self.terrain) do
		if v.symbol == base.symbols.stair then
			self.paths.to_stair = self:paths_to(v.x, v.y)
		end
	end
end

function level:light_area(radius, x, y)
	if not radius then
		return
	end

	base.for_rect(x-radius, y-radius, x+radius, y+radius, function(x, y, i)
		self.light[i] = true
		self.memory[i] = true
	end)
end

function level:reset_light()
	self.light = {}
	for _,denizen in pairs(self.denizens) do
		local radius = tool.light_from_list(denizen.inventory, denizen.light_radius)
		self:light_area(radius, denizen.x, denizen.y)
	end
	base.for_all_points(function(x, y, i)
		local pile = self.tool_piles[i]
		local radius = tool.light_from_list(pile, nil)
		self:light_area(radius, x, y)
	end)
end

function level:set_light(b)
	base.for_all_points(function(x, y, i)
		self.light[i] = b
	end)
end

function level:drop_tool(denizen, tool_idx)
	if not denizen.inventory or #denizen.inventory < 1 then
		return false
	end

	local tool_to_drop = table.remove(denizen.inventory, tool_idx)
	tool.drop_onto_array(self.tool_piles, tool_to_drop, denizen.x, denizen.y)
	return true
end

function level:pickup_tool(denizen, tool_idx)
	local targ_tool = tool.pickup_from_array(self.tool_piles, tool_idx, denizen.x, denizen.y)
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

function level:pickup_all_tools(denizen)
	local pile = tool.pickup_all_from_array(self.tool_piles, denizen.x, denizen.y)
	if not pile then
		return
	end

	for i,v in ipairs(pile) do
		table.insert(denizen.inventory, v)
	end
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
	local targ_id = base.get_idx(targ_x, targ_y)
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
	local old_id = base.get_idx(denizen.x, denizen.y)
	local new_id = base.get_idx(new_x, new_y)
	local target = self.terrain[new_id]
	if target.symbol == base.symbols.wall then
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
	self.denizens[base.get_idx(dz.x, dz.y)] = dz
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

	res.player_id = base.get_idx(init_x, init_y)
	local player = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		hp = 1000,
		light_radius = 0,
		inventory = {
			tool.make("lantern")
		}
	}
	res:add_denizen(player)

	local angel = {
		symbol = base.symbols.angel,
		x = 40,
		y = 10,
		light_radius = 2,
		hp = 10
	}
	res:add_denizen(angel)

	local dragon = {
		symbol = base.symbols.dragon,
		x = 10,
		y = 10,
		hp = 20
	}
	res:add_denizen(dragon)

	res:reset_light()
	res:reset_paths()
	return res
end

function level:symbol_at(x, y)
	local i = base.get_idx(x, y)
	local denizen = self.denizens[i]
	local tile = self.terrain[i]
	local light = self.light[i]
	local memory = self.memory[i]
	local tool_pile = self.tool_piles[i]
	assert(type(tile)=="table", "Invalid tile at x="..x.." y="..y)

	if light then
		if denizen then
			return denizen.symbol
		elseif tool_pile and #tool_pile > 0 then
			return base.symbols.tool
		else
			return tile.symbol
		end
	elseif memory and tile.symbol ~= base.symbols.floor then
		return tile.symbol
	else
		return base.symbols.dark
	end
end

function level:denizen_on_terrain(denizen_id, terrain_symbol)
	return (self.terrain[denizen_id].symbol == terrain_symbol)
end

return level
