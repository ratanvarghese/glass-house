local power = require("src.power")

property "power.make_list: without versions" {
	generators = { int(1, power.MAX_LEN), str() },
	check = function(max, prefix)
		local define_list = {}
		local found = {}
		for i=1,max do
			local name = prefix..tostring(i)
			local mon = math.random(1, 2) == 1
			table.insert(define_list, {name = name, monster_only = mon})
			found[name] = false
		end
		local res = power.make_list(define_list)
		for i,v in ipairs(res) do
			if found[v.name] == nil then
				return false
			end
			found[v.name] = true
		end
		for k,v in pairs(found) do
			if not v then
				return false
			end
		end
		return #res == max
	end
}

property "power.make_list: with versions" {
	generators = { int(1, 100), int(1, 100), int(2, power.MAX_LEN), str(), bool() },
	check = function(v1, v2, versions, name, monster_only)
		local min = math.min(v1, v2)
		local max = math.min(v1, v2)
		if min == max then max = min + 1 end
		local define_list = {
			{
				name = name,
				min = min,
				max = max,
				versions = versions,
				monster_only = monster_only
			}
		}
		local res = power.make_list(define_list)
		for i,v in ipairs(res) do
			if v.name ~= name then
				return false
			elseif v.min then
				return false
			elseif v.max then
				return false
			elseif v.versions then
				return false
			elseif v.monster_only ~= monster_only then
				return false
			elseif v.factor < min or v.factor > max then
				return false
			end
		end
		return #res == versions
	end
}

property "power.tool_list: remove only powers with monster_only" {
	generators = { int(2, power.MAX_LEN), str() },
	check = function(max, prefix)
		local define_list = {}
		local added = {}
		local monster_only = {}
		for i=1,max do
			local name = prefix..tostring(i)
			local mon = math.random(1, 2) == 1
			table.insert(define_list, {name = name, monster_only = mon})
			added[name] = true
			monster_only[name] = mon
		end
		local res = power.tool_list(define_list)
		for i,v in ipairs(res) do
			if not added[v.name] and not monster_only[v.name] then
				return false
			elseif added[v.name] and monster_only[v.name] then
				return false
			end
		end
		return true
	end
}
