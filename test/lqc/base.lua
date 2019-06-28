local base = require("src.base")

property "base.is_empty: true only if input empty" {
	generators = { tbl() },
	check = function(t)
		local expected = true
		for k,v in pairs(t) do
			expected = false
			break
		end

		return expected == base.is_empty(t)
	end
}

property "base.true_f: return true" {
	generators = { any(), any(), any() },
	check = function(a, b, c)
		return base.true_f(a, b, c)
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

local mapf = {
	type,
	tostring,
	tonumber,
	function(v) return v end,
	function(v) return not v end,
	function(v) return {v} end
}
property "base.map: act on all values, without adding extras" {
	generators = { tbl(), int(1, #mapf) },
	check = function(t, fi)
		local f = mapf[fi]
		local res = base.map(t, f)

		local offset = 0
		local t_i = 0
		for i,v in ipairs(res) do
			while f(t[i+offset]) == nil do
				offset = offset + 1
				if (i + offset) > #t then
					return false
				end
			end
			t_i = i + offset
			if not base.equals(v, f(t[t_i])) then
				return false
			end
		end

		while t_i < #t do
			t_i = t_i + 1
			if f(t[t_i]) ~= nil then
				return false
			end
		end

		return true
	end
}

property "base.map: padding" {
	generators = { tbl(), int(1, #mapf), any() },
	check = function(t, fi, pad)
		local f = mapf[fi]
		local pad = pad or false --pad == nil basically means no padding
		local res = base.map(t, f, pad)
		for i,v in ipairs(res) do
			if f(t[i]) == nil and v ~= pad then
				return false
			elseif f(t[i]) ~= nil and not base.equals(v, f(t[i])) then
				return false
			end
		end
		return #res == #t
	end,
	when_fail = function(t, fi, pad)
		local f = mapf[fi]
		local pad = pad or false --pad == nil basically means no padding
		local res = base.map(t, f, pad)
		local max = math.max(#res, #t)
		print("")
		for i=1,max do
			print("i:", i, "res[i]:", res[i], "t[i]:", t[i])
		end
	end
}

local filterf = {
	tonumber,
	function(v) return type(v) == "string" end,
	function(v) return type(v) == "table" end
}
property "base.filter: filter correct values" {
	generators = { tbl(), int(1, #filterf) },
	check = function(t, i)
		local f = filterf[i]
		local res = base.filter(t, f)
		local offset = 0
		local t_i = 0
		for i,v in ipairs(res) do
			while not f(t[offset + i]) do
				offset = offset + 1
				if (offset + i) > #t then
					return false
				end
			end
			t_i = offset + i
			if not base.equals(v, t[t_i]) then
				return false
			end
		end

		while t_i < #t do
			t_i = t_i + 1
			if f(t[t_i]) then
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
		local res = base.rn_distinct(min, max, len)
		for _,v in ipairs(res) do
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
		local res = base.rn_distinct(min, max, len)

		local seen = {}
		for _,v in ipairs(res) do
			if seen[v] then
				return false
			end
			seen[v] = true
		end
		return true
	end
}
