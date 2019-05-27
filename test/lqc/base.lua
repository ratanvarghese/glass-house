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

property "base.map_k: creates mapping" {
	generators = { any(), any(), any(), any(), any(), any(), int(1, 100) },
	check = function(targ_k, targ_v1, targ_v2, targ_v3, extra_k, extra_v, size)
		if targ_k == nil or extra_k == nil then
			return true
		end

		local t = {}
		for i=1,size do
			table.insert(t, {[targ_k] = targ_v1, [extra_k] = extra_v})
			table.insert(t, {[targ_k] = targ_v2, [extra_k] = extra_v})
			table.insert(t, {[targ_k] = targ_v3, [extra_k] = extra_v})
		end

		local res = base.map_k(t, targ_k)
		local nil_offset = 0
		for i,v in ipairs(t) do
			if v[targ_k] == nil then
				nil_offset = nil_offset+1
			elseif res[i-nil_offset] ~= v[targ_k] then
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

