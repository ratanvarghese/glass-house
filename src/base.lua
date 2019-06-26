local base = {}

function base.is_empty(t)
	return (next(t) == nil)
end

function base.true_f()
	return true
end

function base.reverse(t)
	local res = {}
	for k,v in pairs(t) do
		res[v] = k
	end
	return res
end

function base.map(t, f)
	local res = {}
	for k,v in pairs(t) do
		res[k] = f(v)
	end
	return res
end

function base.filter(t, f)
	local res = {}
	for k,v in pairs(t) do
		if f(v) then
			res[k] = v
		end
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

function base.rn_distinct(min, max, len)
	assert(min < max, "Bad range")
	assert(len <= (max - min), "Bad len")
	local i = 0
	local used = {}
	while i < len do
		local n = math.random(min, max)
		if not used[n] then
			used[n] = true
			i = i + 1
		end
	end

	local res = {}
	for k in pairs(used) do table.insert(res, k) end
	return res
end

return base
