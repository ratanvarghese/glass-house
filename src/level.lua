local base = require("src.base")
local gen = require("src.gen")

local level = {}

function level:reset_light()
	self.light = {}
	for _,denizen in pairs(self.denizens) do
		if denizen.light_radius then
			local min_x = math.max(denizen.x - denizen.light_radius, 1)
			local max_x = math.min(denizen.x + denizen.light_radius, base.MAX_X)
			local min_y = math.max(denizen.y - denizen.light_radius, 1)
			local max_y = math.min(denizen.y + denizen.light_radius, base.MAX_Y)
			for x = min_x,max_x do
				for y = min_y,max_y do
					local id = base.getIdx(x, y)
					self.light[id] = true
					self.memory[id] = true
				end
			end
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
	assert(denizen == self.denizens[old_id], "ID error for denizen\n"..debug.traceback())
	denizen.x = new_x
	denizen.y = new_y
	self.denizens[new_id] = denizen
	self.denizens[old_id] = nil
	self:reset_light()
	return true
end

function level:move_player(dx, dy)
	local p = self.denizens[self.player_id]
	assert(p, "ID error for player\n"..debug.traceback())
	local res = self:move(p, p.x + dx, p.y + dy)
	if res then
		self.player_id = base.getIdx(p.x, p.y)
	end

	return res
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
		num = num
	}
	level.register(res)

	local init_x, init_y = gen.cave(res)

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
