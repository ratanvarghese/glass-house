local base = require("src.base")
local level = require("src.level")
local item = require("src.item")

local player = {}

function player.climb_stairs()
	if level.current:denizen_on_terrain(level.current.player_id, base.symbols.stair) then
		level.current = level.make(level.current.num + 1)
	end
end

function player.handle_input(c)
	local p = level.current.denizens[level.current.player_id]
	assert(p, "ID error for player")

	local n = tonumber(c)
	local d
	if n then
		local obj = p.inventory[n]
		if obj then
			item.equip(obj, p)
			level.current:reset_light()
		end
	elseif c == base.conf.keys.quit then
		return false
	elseif c == base.conf.keys.drop then
		level.current:drop_item(p, 1)
	elseif c == base.conf.keys.north then
		d = base.direction.north
	elseif c == base.conf.keys.south then
		d = base.direction.south
	elseif c == base.conf.keys.west then
		d = base.direction.west
	elseif c == base.conf.keys.east then
		d = base.direction.east
	end

	if d then
		local nx = p.x + d.x
		local ny = p.y + d.y
		if level.current:move(p, nx, ny) then
			level.current:pickup_all_items(p)
			player.climb_stairs()
		else
			level.current:bump_hit(p, nx, ny, 1)
		end
	end
	return true
end

return player
