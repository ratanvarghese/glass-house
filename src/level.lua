local base = require("src.base")
local gen = require("src.gen")
local action = require("src.action")

local level = {}

function level.make(num)
	local res = {
		light = {},
		terrain = {},
		denizens = {},
		memory = {},
		num = num
	}

	local init_x, init_y = gen.cave(res)
	res.player_id = base.getIdx(init_x, init_y)
	res.denizens[res.player_id] = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		light_radius = 2
	}

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

return level
