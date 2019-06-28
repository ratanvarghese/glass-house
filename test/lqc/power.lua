local base = require("src.base")
local power = require("src.power")

local function versionless_define_list(max, prefix)
	local define_list = {}
	local define_set = {}
	for i=1,max do
		local name = prefix..tostring(i)
		local kind = i * 3
		table.insert(define_list, {name = name, kind = kind})
		define_set[name] = true
	end
	return define_list, define_set
end

property "power.make_list: (no versions) no extra items" {
	generators = { int(1, power.MAX_LEN), str() },
	check = function(max, prefix)
		local define_list, define_set = versionless_define_list(max, prefix)
		local res = power.make_list(define_list)
		for i,v in ipairs(res) do
			if not define_set[v.name] then
				return false
			end
		end
		return true
	end
}

property "power.make_list: (no versions) no missing items" {
	generators = { int(1, power.MAX_LEN), str() },
	check = function(max, prefix)
		local define_list, define_set = versionless_define_list(max, prefix)
		local res = power.make_list(define_list)
		local found = {}
		for i,v in ipairs(res) do
			found[v.name] = true
		end

		for k in pairs(define_set) do
			if not found[k] then
				return false
			end
		end
		return #res == max
	end
}

local function versioned_define_list(min, max, versions, name, t)
	local t = t or {}
	t.name = name
	t.kind = 0
	t.min = min
	t.max = max
	t.versions = versions
	return {t}
end

property "power.make_list: (versions) error on bad range" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(max, min, versions, name)
		local define_list = versioned_define_list(min, max, versions, name)
		return not pcall(function() return power.make_list(define_list) end)
	end
}

property "power.make_list: (versions) error on no range" {
	generators = { int(1, 50), int(2, power.MAX_LEN), str() },
	check = function(max_min, versions, name)
		local define_list = versioned_define_list(max_min, max_min, versions, name)
		return not pcall(function() return power.make_list(define_list) end)
	end
}

property "power.make_list: (versions) error with too many versions" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(min, max, extra_versions, name)
		local versions = (max - min) + extra_versions
		local define_list = versioned_define_list(min, max, versions, name)
		return not pcall(function() return power.make_list(define_list) end)
	end
}

property "power.make_list: (versions) no error on valid input" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(min, max, versions, name)
		local versions = math.min(versions, max - min)
		local define_list = versioned_define_list(min, max, versions, name)
		return pcall(function() return power.make_list(define_list) end)
	end
}

property "power.make_list: (versions) remove max/min/versions fields" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(min, max, versions, name)
		local versions = math.min(versions, max - min)
		local define_list = versioned_define_list(min, max, versions, name)
		local res = power.make_list(define_list)
		for _,v in ipairs(res) do
			if v.min or v.max or v.versions then
				return false
			end
		end
		return true
	end
}

property "power.make_list: (versions) preserve fields unrelated to versions" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str(), tbl() },
	numshrinks = 1, --Shrinking sometimes generates invalid min, max combinations
	check = function(min, max, versions, name, t)
		local versions = math.min(versions, max - min)
		local define_list = versioned_define_list(min, max, versions, name, t)
		local res = power.make_list(define_list)
		local related = {max = true, min = true, versions = true, factor = true}
		for _,v in ipairs(res) do
			for vk, vv in pairs(v) do
				if vk == "name" and vv ~= name then
					return false
				elseif not base.equals(vv, t[vk]) and not related[vk] then
					return false
				end
			end
		end
		return true
	end
} 

property "power.make_list: (versions) factors unique and in-range" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(min, max, versions, name)
		local versions = math.min(versions, max - min)
		local define_list = versioned_define_list(min, max, versions, name)
		local res = power.make_list(define_list)
		local used_factors = {}
		for _,v in ipairs(res) do
			if v.factor < min or v.factor > max then
				return false
			elseif used_factors[v.factor] then
				return false
			end
			used_factors[v.factor] = true
		end
		return true
	end
}

property "power.make_list: (versions) correct number of results" {
	generators = { int(1, 50), int(51, 100), int(2, power.MAX_LEN), str() },
	check = function(min, max, versions, name)
		local versions = math.min(versions, max - min)
		local define_list = versioned_define_list(min, max, versions, name)
		local res = power.make_list(define_list)
		return #res == versions
	end
}
