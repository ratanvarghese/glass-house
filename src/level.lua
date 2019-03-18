local serpent = require("serpent")

local base = require("src.base")
local gen = require("src.gen")

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

function level:reset_light()
	self.light = {}
	for _,denizen in pairs(self.denizens) do
		self:light_area(denizen.light_radius, denizen.x, denizen.y)
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

function level:move(denizen, new_x, new_y)
	local new_id = base.getIdx(new_x, new_y)
	local target = self.terrain[new_id]
	if target.symbol == base.symbols.wall then
		return false
	elseif self.denizens[new_id] then
		return false
	end

	local old_id = base.getIdx(denizen.x, denizen.y)
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

function level:move_player(dx, dy)
	local p = self.denizens[self.player_id]
	assert(p, "ID error for player")
	return self:move(p, p.x + dx, p.y + dy)
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
		denizens_in_order = {},
		memory = {},
		paths = {},
		num = num
	}
	level.register(res)

	local terrain, init_x, init_y = gen.cave(res)
	res.terrain = terrain

	res.player_id = base.getIdx(init_x, init_y)
	local player = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		light_radius = 2
	}
	res:add_denizen(player)

	local angel = {
		symbol = base.symbols.angel,
		x = 40,
		y = 10,
		light_radius = 2
	}
	res:add_denizen(angel)

	local dragon = {
		symbol = base.symbols.dragon,
		x = 10,
		y = 10
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
	assert(type(tile)=="table", "Invalid tile at x="..x.." y="..y)

	if light then
		if denizen then
			return denizen.symbol
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
