local base = {}

function base.is_empty(t)
	return (next(t) == nil)
end

function base.clip(n, min, max)
	assert(min <= max, "Bad boundaries")
	return math.min(math.max(n, min), max)
end

function base.invert(t)
	local res = {}
	for k,v in pairs(t) do
		res[v] = k
	end
	return res
end

function base.error_handler(msg)
	return msg.."\n"..debug.traceback()
end

function base.equals(a, b)
	local type1, type2 = type(a), type(b)
	if type1 ~= type2 then
		return false
	elseif type1 ~= "table" and type2 ~= "table" then
		return a == b
	elseif #a ~= #b then
		return false
	end

	for k,v in pairs(a) do
		if not base.equals(v, b[k]) then
			return false
		end
	end

	for k,v in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

--Based on http://stackoverflow.com/questions/640642
function base.copy(a, seen)
	if type(a) ~= "table" then
		return a
	end
	if seen and seen[a] then
		return seen[a]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(a))
	s[a] = res
	for k,v in pairs(a) do
		res[base.copy(k, s)] = base.copy(v, s)
	end
	return res
end

local function rn_distinct_iter(invariant, n)
	if n >= invariant.len then
		return nil, nil
	end
	local new
	while true do
		new = math.random(invariant.min, invariant.max)
		if not invariant.done[new] then
			invariant.done[new] = true
			break
		end
	end
	return n+1, new
end

function base.rn_distinct(min, max, len)
	assert(min < max, "Bad range")
	assert(len <= (max - min), "Bad len")
	local invariant = {
		min = min,
		max = max,
		len = len,
		done = {}
	}
	local f = rn_distinct_iter 
	return f, invariant, 0
end

function base.gen_tbl(f, ...)
	local res = {}
	for k,v in f(...) do res[k] = v end
	return res
end

function base.gen_arr(f, ...)
	local res = {}
	for k,v in f(...) do table.insert(res, v) end
	return res
end

return base
