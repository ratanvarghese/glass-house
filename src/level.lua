local base = require("src.base")
local gen = require("src.gen")
local action = require("src.action")

local level = {}

local function add_denizen(lvl, dz)
	lvl.denizens[base.getIdx(dz.x, dz.y)] = dz
	table.insert(lvl.denizens_in_order, dz)
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

	local init_x, init_y = gen.cave(res)
	res.player_id = base.getIdx(init_x, init_y)
	local player = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		light_radius = 2
	}
	add_denizen(res, player)
	action.reset_light(res)
	return res
end

function level.symbol_at(lvl, x, y)
	local i = base.getIdx(x, y)
	local denizen = lvl.denizens[i]
	local tile = lvl.terrain[i]
	local light = lvl.light[i]
	local memory = lvl.memory[i]
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

function level.denizen_on_terrain(lvl, denizen_id, terrain_symbol)
	return (lvl.terrain[denizen_id].symbol == terrain_symbol)
end

return level
