local base = require("base")

local action = {}

function action.reset_light(lvl)
	lvl.light = {}
	for _,denizen in pairs(lvl.denizens) do
		if denizen.light_radius then
			local min_x = math.max(denizen.x - denizen.light_radius, 1)
			local max_x = math.min(denizen.x + denizen.light_radius, base.MAX_X)
			local min_y = math.max(denizen.y - denizen.light_radius, 1)
			local max_y = math.min(denizen.y + denizen.light_radius, base.MAX_Y)
			for x = min_x,max_x do
				for y = min_y,max_y do
					local id = base.getIdx(x, y)
					lvl.light[id] = true
					lvl.memory[id] = true
				end
			end
		end
	end
end

function action.move(lvl, old_x, old_y, new_x, new_y)
	local new_id = base.getIdx(new_x, new_y)
	local target = lvl.terrain[new_id]
	if target.symbol == base.symbols.wall then
		return false
	elseif lvl.denizens[new_id] then
		return false
	end

	local old_id = base.getIdx(old_x, old_y)
	local d = lvl.denizens[old_id]
	d.x = new_x
	d.y = new_y
	lvl.denizens[new_id] = d
	lvl.denizens[old_id] = nil
	action.reset_light(lvl)
	return true
end

function action.move_player(lvl, dx, dy)
	local p = lvl.denizens[lvl.player_id]
	if action.move(lvl, p.x, p.y, p.x + dx, p.y + dy) then
		lvl.player_id = base.getIdx(p.x, p.y)
	end

	return (lvl.terrain[lvl.player_id].symbol == base.symbols.stair)
end

return action
