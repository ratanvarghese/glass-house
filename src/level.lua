local base = require("src.base")
local gen = require("src.gen")
local item = require("src.item")

local level = {}

function level:paths_iter(old)
	local res = {}
	local max = base.MAX_X * base.MAX_Y
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
			local old_v = old[i]
			if old_v then
				new_v = base.adjacent_min(old, x, y) + 1
				if new_v < old_v then
					res[i] = new_v
				else
					res[i] = old_v
				end
			end
		end
	end
	return res
end

function level:paths_to(targ_x, targ_y)
	local res = {}
	local max = base.MAX_X * base.MAX_Y
	local min = 0

	local targ_id = base.getIdx(targ_x, targ_y)
	for i,tile in pairs(self.terrain) do
		if i == targ_id then
			res[i] = min
		elseif not self.denizens[i] and tile.symbol == base.symbols.floor then
			res[i] = max
		end
	end

	while true do
		local old = base.shallow_copy(res)
		res = self:paths_iter(old)
		if base.shallow_equals(old, res) then
			break
		end
	end
	return res
end

function level:reset_paths()
	local player = self.denizens[self.player_id]
	assert(player, "Player not found")
	self.paths.to_player = self:paths_to(player.x, player.y)
end

function level:light_area(radius, x, y)
	if not radius then
		return
	end

	local min_x = math.max(x - radius, 1)
	local max_x = math.min(x + radius, base.MAX_X)
	local min_y = math.max(y - radius, 1)
	local max_y = math.min(y + radius, base.MAX_Y)
	for x = min_x,max_x do
		for y = min_y,max_y do
			local id = base.getIdx(x, y)
			self.light[id] = true
			self.memory[id] = true
		end
	end
end

local function light_from_item_list(list, default)
	if not list then
		return default
	end

	local use_res = false
	local res = 0
	for i,v in ipairs(list) do
		if v.light_radius then
			res = math.max(res, v.light_radius)
			use_res = true
		end
	end

	if use_res then
		return res
	else
		return default
	end

end


function level:reset_light()
	self.light = {}
	for _,denizen in pairs(self.denizens) do
		local radius = light_from_item_list(denizen.inventory, denizen.light_radius)
		self:light_area(radius, denizen.x, denizen.y)
	end

	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
			local pile = self.item_piles[i]
			local radius = light_from_item_list(pile, nil)
			self:light_area(radius, x, y)
		end
	end
end

function level:set_light(b)
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
			self.light[i] = b
		end
	end
end

function level:get_pile(x, y, make_missing)
	local i = base.getIdx(x, y)
	local pile = self.item_piles[i]
	if not pile and make_missing then
		pile = {}
		self.item_piles[i] = pile
	end
	return pile
end

function level:drop_item(denizen, item_idx)
	if not denizen.inventory or #denizen.inventory < 1 then
		return false
	end

	local item = table.remove(denizen.inventory, item_idx)
	local i = base.getIdx(denizen.x, denizen.y)
	local pile = self.item_piles[i]
	if pile then
		table.insert(pile, item)
	else
		self.item_piles[i] = {item}
	end
	return true
end

function level:pickup_item(denizen, item_idx)
	local pile = self:get_pile(denizen.x, denizen.y, false)
	if not pile or #pile < 1 then
		return false
	end

	local item = table.remove(pile, item_idx)
	local inventory = denizen.inventory
	if inventory then
		table.insert(inventory, item)
	else
		denizen.inventory = {item}
	end
	return true
end

function level:pickup_all_items(denizen)
	local pile = self:get_pile(denizen.x, denizen.y, false)
	if not pile or #pile < 1 then
		return false
	end

	local max=#pile
	for i=max,1,-1 do
		local item = table.remove(pile, i)
		table.insert(denizen.inventory, item)
	end
	return true
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
	local targ_id = base.getIdx(targ_x, targ_y)
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
	local old_id = base.getIdx(denizen.x, denizen.y)
	local new_id = base.getIdx(new_x, new_y)
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
	self.denizens[base.getIdx(dz.x, dz.y)] = dz
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
		item_piles = {},
		num = num,
		game_over = false
	}
	level.register(res)

	local terrain, init_x, init_y = gen.cave(res)
	res.terrain = terrain

	res.player_id = base.getIdx(init_x, init_y)
	local player = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		hp = 10,
		light_radius = 0,
		inventory = {
			item.make("lantern")
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
	local i = base.getIdx(x, y)
	local denizen = self.denizens[i]
	local tile = self.terrain[i]
	local light = self.light[i]
	local memory = self.memory[i]
	local item_pile = self.item_piles[i]
	assert(type(tile)=="table", "Invalid tile at x="..x.." y="..y)

	if light then
		if denizen then
			return denizen.symbol
		elseif item_pile and #item_pile > 0 then
			return base.symbols.item
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
