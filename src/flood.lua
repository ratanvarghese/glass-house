local grid = require("src.grid")

local flood = {}

function flood.gradient(x, y, eligible, v, res)
	local res = res or {}
	local v = v or 0
	local i = grid.get_idx(x, y)
	if not eligible[i] or (res[i] and res[i] <= v) then
		return res
	end

	res[i] = v
	flood.gradient(x+1, y, eligible, v+1, res)
	flood.gradient(x-1, y, eligible, v+1, res)
	flood.gradient(x, y+1, eligible, v+1, res)
	flood.gradient(x, y-1, eligible, v+1, res)
	return res
end

function flood.search(x, y, eligible, f, finished)
	local finished = finished or {}
	local i = grid.get_idx(x, y)
	if finished[i] or not eligible[i] then
		return false
	end
	finished[i] = true
	if f(x, y, i) then
		return true, x, y
	end

	local res, res_x, res_y = flood.search(x+1, y, eligible, f, finished)
	if res then return res, res_x, res_y end
	local res, res_x, res_y = flood.search(x-1, y, eligible, f, finished)
	if res then return res, res_x, res_y end
	local res, res_x, res_y = flood.search(x, y+1, eligible, f, finished)
	if res then return res, res_x, res_y end
	local res, res_x, res_y = flood.search(x, y-1, eligible, f, finished)
	return res, res_x, res_y
end

function flood.local_min(x, y, t, max_steps, cur_steps)
	local cur_steps = cur_steps or 0
	local max_steps = max_steps or 1
	
	local list = {
		{t[grid.get_idx(x, y)] or math.huge, x, y}
	}
	if cur_steps < max_steps then
		table.insert(list, {flood.local_min(x+1, y, t, max_steps, cur_steps+1)})
		table.insert(list, {flood.local_min(x-1, y, t, max_steps, cur_steps+1)})
		table.insert(list, {flood.local_min(x, y+1, t, max_steps, cur_steps+1)})
		table.insert(list, {flood.local_min(x, y-1, t, max_steps, cur_steps+1)})
	end
	if #list > 0 then
		table.sort(list, function(a, b) return a[1] < b[1] end)
		return list[1][1], list[1][2], list[1][3]
	else
		return math.huge
	end
end

return flood
