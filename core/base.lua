--- Basic functions
-- @module core.base

local base = {}

--- Return true if table `t` is empty
-- @tparam table t
-- @treturn bool
function base.is_empty(t)
	return (next(t) == nil)
end

--- Clip `n` within range.
-- If `n` is too small, return `min`. If `n` is too big, return `max`.
-- Otherwise, return `n`.
-- @tparam number n
-- @tparam number min
-- @tparam number max
function base.clip(n, min, max)
	assert(min <= max, "Bad boundaries")
	return math.min(math.max(n, min), max)
end

--- Return table with inverted key/value pairs
-- @tparam table t
-- @treturn table
-- @usage
--out = base.invert({"Hello", "World"})
--assert(out.Hello == 1)
function base.invert(t)
	local res = {}
	for k,v in pairs(t) do
		res[v] = k
	end
	return res
end

--- Check deep equality of `x` and `y`.
-- Based on [this Stack Overflow answer](https://stackoverflow.com/a/25976660).
-- @param x
-- @param y
-- @tparam[opt] table done Don't assign this, it is used internally by recursive calls. 
function base.equals(x, y, done)
	local done = done or {}
	local tx, ty = type(x), type(y)
	if tx ~= ty then return false end
	if tx ~= "table" then return x == y end

	if done[x] then return done[x] == y end
	done[x] = y

	local y_keys = {}
	for ky in pairs(y) do
		y_keys[ky] = true
	end

	for kx, vx in pairs(x) do
		local vy
		if type(kx) == "table" then
			local found
			for ky in pairs(y_keys) do
				if base.equals(kx, ky, done) then
					found = ky
					break
				end
			end
			if found == nil then
				return false
			else
				y_keys[found] = nil
				vy = y[found]
			end
		else
			y_keys[kx] = nil
			vy = y[kx]
		end
		if not base.equals(vx, vy, done) then
			return false
		end
	end
	return base.is_empty(y_keys)
end

--- Deep copy of `a`.
-- Based on [this Stack Overflow answer](https://stackoverflow.com/a/26367080).
-- @param a
-- @tparam[opt] table seen Don't assign this, it is used internally by recursive calls. 
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

--- Iterate over distinct random numbers in a `for` loop.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam int min
-- @tparam int max
-- @tparam int len
-- @usage for i,v in base.rn_distinct(1, 10, 3) --Generate 3 ints in range [1:10]
--     do print(i,v) --print the index, then the random number
-- end
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

--- Append values of iterator to a table
-- @usage t = base.extend_arr({"Earth"}, ipairs({"Mercury", "Venus"}))
--assert(t[2] == "Mercury")
function base.extend_arr(res, _f, _s, _var)
	for k,v in _f,_s,_var do table.insert(res, v) end
	return res
end

return base
