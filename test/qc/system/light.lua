local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local light = require("core.system.light")

property "light.set_area: include target area" {
	generators = {
		tbl(),
		int(1, 10),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		any(),
		int(-10, 10),
		int(-10, 10)
	},
	check = function(t, radius, x, y, v, dx, dy)
		local t = base.copy(t)
		local pos = grid.get_pos(x, y)
		local dx = dx == 0 and 0 or (dx / math.abs(dx)) * math.min(math.abs(dx), radius)
		local dy = dy == 0 and 0 or (dy / math.abs(dy)) * math.min(math.abs(dy), radius)
		light.set_area(t, radius, pos, v)
		local res_pos = grid.get_pos(grid.clip(x + dx, y + dy))
		return t[res_pos] == v
	end
}

property "light.set_area: exclude non-targets" {
	generators = {
		tbl(),
		int(1, 10),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		any(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(t, radius, x, y, v, res_x, res_y)
		if math.abs(x - res_x) <= radius and math.abs(y - res_y) <= radius then
			return true
		end
		local res_pos = grid.get_pos(res_x, res_y)
		local pos = grid.get_pos(x, y)
		local t = base.copy(t)
		local old_v = t[res_pos]
		light.set_area(t, radius, pos, v)
		return t[res_pos] == old_v
	end,
	when_fail = function(t, radius, x, y, v, res_pos)
		local t = base.copy(t)
		local pos = grid.get_pos(x, y)
		local res_pos = res_pos
		local old_v = t[res_pos]
		local lo_p = grid.get_pos(grid.clip(x-radius, y-radius))
		local hi_p = grid.get_pos(grid.clip(x+radius, y+radius))
		print("")
		print("x, y:", x, y)
		print("radius:", radius)
		print("old_v:", old_v)
		print("res_pos:", res_pos)
		print("res x, y:", grid.get_xy(res_pos))
		print("pos:", pos)
		print("lo_p, x, y:", lo_p, grid.get_xy(lo_p))
		print("hi_p, x, y:", hi_p, grid.get_xy(hi_p))
	end
}

property "light.set_all: affect all points" {
	generators = {
		tbl(),
		any(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(t, v, res_pos)
		local t = base.copy(t)
		light.set_all(t, v)
		return t[res_pos] == v
	end
}

local function make_e(pow_light, tool_light, pow_dark, tool_dark, x, y)
	local pow_light = pow_light >= 0 and pow_light or nil
	local tool_light = tool_light >= 0 and tool_light or nil
	local pow_dark = pow_dark >= 0 and pow_dark or nil
	local tool_dark = tool_dark >= 0 and tool_dark or nil

	return {
		power = {
			[enum.power.light] = pow_light,
			[enum.power.darkness] = pow_dark
		},
		inventory = {
			{
				power = {
					[enum.power.light] = tool_light,
					[enum.power.darkness] = tool_dark
				}
			}
		},
		pos = grid.get_pos(x, y)
	}
end

property "light.set_from_entity: correct set_area calls with both power and tool" {
	generators = {
		int(-1, 10),
		int(-1, 10),
		int(-1, 10),
		int(-1, 10),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		tbl(),
		tbl(),
		tbl()
	},
	check = function(
			pow_light,
			tool_light,
			pow_dark,
			tool_dark,
			x,
			y,
			light_arr,
			mem_arr,
			dark_arr
		)
		local light_max = math.max(pow_light, tool_light)
		local dark_max = math.max(pow_dark, tool_dark)
		local e = make_e(pow_light, tool_light, pow_dark, tool_dark, x, y)

		local old_set_area = light.set_area
		local args = {}
		light.set_area = function(...) table.insert(args, {...}) end
		light.set_from_entity(e, light_arr, mem_arr, dark_arr)
		light.set_area = old_set_area

		if light_max < dark_max and dark_max >= 0 then
			return base.equals(args, {{dark_arr, dark_max, e.pos, true}})
		elseif light_max > dark_max and light_max >= 0 then
			local t1 = {light_arr, light_max, e.pos, true}
			local t2 = {mem_arr, light_max, e.pos, true}
			return base.equals(args, {t1, t2}) or base.equals(args, {t2, t1})
		else
			return #args == 0
		end
	end
}

property "light.set_from_entity: correct set_area calls with power only" {
	generators = {
		int(-1, 10),
		int(-1, 10),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		tbl(),
		tbl(),
		tbl()
	},
	check = function(pow_light, pow_dark, x, y, light_arr, mem_arr, dark_arr)
		local light_max = pow_light
		local dark_max = pow_dark
		local e = make_e(pow_light, -math.huge, pow_dark, -math.huge, x, y)
		e.inventory = nil

		local old_set_area = light.set_area
		local args = {}
		light.set_area = function(...) table.insert(args, {...}) end
		light.set_from_entity(e, light_arr, mem_arr, dark_arr)
		light.set_area = old_set_area

		if light_max < dark_max and dark_max >= 0 then
			return base.equals(args, {{dark_arr, dark_max, e.pos, true}})
		elseif light_max > dark_max and light_max >= 0 then
			local t1 = {light_arr, light_max, e.pos, true}
			local t2 = {mem_arr, light_max, e.pos, true}
			return base.equals(args, {t1, t2}) or base.equals(args, {t2, t1})
		else
			return #args == 0
		end
	end
}

property "light.set_from_entity: correct set_area calls with tool only" {
	generators = {
		int(-1, 10),
		int(-1, 10),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		tbl(),
		tbl(),
		tbl()
	},
	check = function(tool_light, tool_dark, x, y, light_arr, mem_arr, dark_arr)
		local light_max = tool_light
		local dark_max = tool_dark
		local e = make_e(-math.huge, tool_light, -math.huge, tool_dark, x, y)
		e.power = nil

		local old_set_area = light.set_area
		local args = {}
		light.set_area = function(...) table.insert(args, {...}) end
		light.set_from_entity(e, light_arr, mem_arr, dark_arr)
		light.set_area = old_set_area

		if light_max < dark_max and dark_max >= 0 then
			return base.equals(args, {{dark_arr, dark_max, e.pos, true}})
		elseif light_max > dark_max and light_max >= 0 then
			local t1 = {light_arr, light_max, e.pos, true}
			local t2 = {mem_arr, light_max, e.pos, true}
			return base.equals(args, {t1, t2}) or base.equals(args, {t2, t1})
		else
			return #args == 0
		end
	end
}

property "light.cancel_light: set common indices to nil" {
	generators = {
		tbl(),
		tbl()
	},
	check = function(light_arr, dark_arr)
		local light_arr = base.copy(light_arr)
		local dark_arr = base.copy(dark_arr)
		light.cancel_light(light_arr, dark_arr)
		for i in pairs(dark_arr) do
			if light_arr[i] then
				return false
			end
		end
		return true
	end
}
