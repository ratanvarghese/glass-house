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

property "base.reverse: output values match input keys" {
	generators = { tbl() },
	check = function(t)
		local reverse = base.reverse(t)
		for k,v in pairs(reverse) do
			if t[v] ~= k then
				return false
			end
		end
		return true
	end
}

property "base.reverse: all input values included as output keys" {
	generators = { tbl() },
	check = function(t)
		local reverse = base.reverse(t)
		local seek_repeats = {}
		local found_repeats = {}
		for k,v in pairs(t) do
			if seek_repeats[v] and reverse[v] == k then
				found_repeats[v] = true
			end
			if reverse[v] ~= k then
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
	check = function(t, i)
		local f = mapf[i]
		local res = base.map(t, f)
		for k,v in pairs(t) do
			if not base.equals(res[k], f(v)) then
				return false
			end
		end
		for k,v in pairs(res) do
			if not base.equals(v, f(t[k])) then
				return false
			end
		end
		return true
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
		for k,v in pairs(t) do
			if f(v) and res[k] == nil then
				return false
			elseif not f(v) and res[k] ~= nil then
				return false
			end
		end
		for k,v in pairs(res) do
			if t[k] == nil or not f(t[k]) then
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
