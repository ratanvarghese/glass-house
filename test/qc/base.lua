local base = require("core.base")

property "base.is_empty: true only if input empty" {
	generators = { tbl() },
	check = function(t)
		local expected = true
		for k in pairs(t) do
			expected = false
			break
		end

		return expected == base.is_empty(t)
	end
}

property "base.clip: expected value" {
	generators = { int(), int(), int() },
	check = function(a, b, c)
		local min = math.min(b, c)
		local max = math.max(b, c)
		local res = base.clip(a, min, max)
		if a < min then
			return res == min
		elseif a > max then
			return res == max
		else
			return res == a
		end
	end
}

property "base.clip: error on bad input" {
	generators = { int(), int(), int() },
	check = function(a, b, c)
		local min = math.min(b, c)
		local max = math.max(b, c)
		if min == max then
			min = min - 1
		end
		return not pcall(function() base.clip(a, max, min) end)
	end
}

property "base.invert: output values match input keys" {
	generators = { tbl() },
	check = function(t)
		local inverted = base.invert(t)
		for k,v in pairs(inverted) do
			if t[v] ~= k then
				return false
			end
		end
		return true
	end
}

property "base.invert: all input values included as output keys" {
	generators = { tbl() },
	check = function(t)
		local inverted = base.invert(t)
		local seek_repeats = {}
		local found_repeats = {}
		for k,v in pairs(t) do
			if seek_repeats[v] and inverted[v] == k then
				found_repeats[v] = true
			end
			if inverted[v] ~= k then
				seek_repeats[v] = true
			end
		end

		for k in pairs(seek_repeats) do
			if not found_repeats[k] then
				return false
			end
		end
		return true
	end
}

property "base.equals: obviously equal values" {
	generators = { any() },
	check = function(a)
		if type(a) ~= "table" then
			local b = a
			return base.equals(a, b)
		end

		local b = {}
		for k,v in pairs(a) do
			b[k] = v
		end
		return base.equals(a, b)
	end
}

property "base.equals: obviously unequal values" {
	generators = { any(), any() },
	check = function(a, b)
		if a == b and type(a) ~= "table" then
			a = true
			b = false
		elseif type(a) == "table" and type(b) == "table" and a[1] == b[1] then
			a[1] = true
			b[1] = false
		end
		return not base.equals(a, b)
	end
}

property "base.equals: equal table keys, equal values" {
	generators = { tbl(), any() },
	check = function(a, av)
		local b = {}
		for k,v in pairs(a) do b[k] = v end
		return base.equals({[a]=av}, {[b]=av})
	end
}

property "base.equals: equal table keys, unequal values" {
	generators = { tbl(), any(), any() },
	check = function(a, av, bv)
		if base.equals(av, bv) then
			av = true
			bv = false
		end
		local b = {}
		for k,v in pairs(a) do b[k] = v end
		return not base.equals({[a]=av}, {[b]=bv})
	end

}

property "base.equals: unequal table keys, equal values" {
	generators = { tbl(), tbl(), any() },
	check = function(a, b, av)
		if base.equals(a, b) then
			a = {}
			b = {1}
		end
		return not base.equals({[a]=av}, {[b]=av})
	end
}

property "base.equals: unequal table keys, unequal values" {
	generators = { tbl(), tbl(), any(), any() },
	check = function(a, b, av, bv)
		if base.equals(a, b) then
			a = {}
			b = {1}
		end
		if base.equals(av, bv) then
			av = true
			bv = false
		end
		return not base.equals({[a]=av}, {[b]=bv})
	end
}

property "base.copy: base.equals(original, copy)" {
	generators = { any() },
	check = function(a)
		return base.equals(a, base.copy(a))
	end
}

property "base.rn_distinct: error on bad range" {
	generators = { int(), int(), int() },
	check = function(a, b, len)
		local min = math.max(a, b)
		local max = math.min(a, b)
		return not pcall(function() base.rn_distinct(min, max, len) end)
	end
}

property "base.rn_distinct: error on equal min/max" {
	generators = { int(), int() },
	check = function(a, len)
		return not pcall(function() base.rn_distinct(a, a, len) end)
	end
}

property "base.rn_distinct: error on bad len" {
	generators = { int(), int(), int() },
	check = function(a, b, extralen)
		local min = math.min(a, b)
		local max = math.max(a, b, min + 1)
		local len = (max - min) + 1 + math.abs(extralen)
		return not pcall(function() base.rn_distinct(min, max, len) end)
	end
}

property "base.rn_distinct: results in range" {
	generators = { int(), int(), int() },
	check = function(a, b, len)
		local min = math.min(a, b)
		local max = math.max(a, b, min + 1)
		local len = math.min(max - min, len)
		for _,v in base.rn_distinct(min, max, len) do
			if v < min or v > max then
				return false
			end
		end
		return true
	end
}

property "base.rn_distinct: results distinct" {
	generators = { int(), int(), int() },
	check = function(a, b, len)
		local min = math.min(a, b)
		local max = math.max(a, b, min + 1)
		local len = math.min(max - min, len)

		local seen = {}
		for _,v in base.rn_distinct(min, max, len) do
			if seen[v] then
				return false
			end
			seen[v] = true
		end
		return true
	end
}

local function powgen(x, y)
	local _var = 0
	local _s = {x=x, y=y}
	local _f = function(_s, _var)
		if _var < _s.y then
			return _var + 1, math.pow(_s.x, _var + 1)
		else
			return nil
		end
	end
	return _f, _s, _var
end

property "base.extend_tbl: include all values from custom generator without adding extras" {
	generators = { int(1, 4), int(1, 4) },
	check = function(x, y)
		local res = base.extend_tbl({}, powgen(x, y))
		local count = 0
		for k,v in pairs(res) do
			if k < 1 or k > y or math.floor(k) ~= k then
				return false
			elseif v ~= math.pow(x, k) then
				return false
			end
			count = count + 1
		end
		return count == y
	end
}

property "base.extend_tbl: extend existing table" {
	generators = { tbl(), int(1, 4), int(1, 4) },
	check = function(old_t, x, y)
		local t = base.copy(old_t)
		base.extend_tbl(t, powgen(x, y))
		local count = 0
		for k,v in pairs(t) do
			if type(k) == "number" and k >= 1 and k <= y and math.floor(k) == k then
				if v ~= math.pow(x, k) then
					return false
				end
			elseif not base.equals(v, old_t[k]) then
				return false
			end
			count = count + 1
		end
		return count <= (#old_t + y)
	end
}

property "base.extend_arr: in order" {
	generators = { int(1, 4), int(1, 4) },
	check = function(x, y)
		local res = base.extend_arr({}, powgen(x, y))
		for i,v in ipairs(res) do
			if v ~= math.pow(x, i) then
				return false
			end
		end
		return #res == y
	end
}

property "base.extend_arr: extend existing array" {
	generators = { tbl(), int(1, 4), int(1, 4) },
	check = function(old_t, x, y)
		local t = base.copy(old_t)
		base.extend_arr(t, powgen(x, y))
		for i,v in ipairs(t) do
			if i <= #old_t and not base.equals(v,old_t[i]) then
				return false
			elseif i > #old_t and v ~= math.pow(x, i-#old_t) then
				return false
			end
		end
		return #t == (#old_t + y)
	end
}

local function oddnil(n)
	local _s = n
	local _var = 0
	local _f = function(_s, _var)
		if _var < _s and _var % 2 == 0 then
			return _var + 1, _s
		elseif _var < _s and _var % 2 ~= 0 then
			return _var + 1, nil
		else
			return nil
		end
	end
	return _f, _s, _var
end

property "base.extend_arr: exclude nil values" {
	generators = { int(1, 100) },
	check = function(half_n)
		local n = half_n * 2
		local res = base.extend_arr({}, oddnil(n))
		for i,v in ipairs(res) do
			if v ~= n then
				return false
			end
		end
		return #res == half_n
	end
}
