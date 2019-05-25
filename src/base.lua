local base = {}

base.savefile = ".save.glass"
base.symbols = {
	player = "@",
	angel = "A",
	dragon = "D",
	floor = ".",
	wall = "#",
	stair = "<",
	dark = " ",
	tool = "("
}

base.conf = {}

base.conf.keys = {
	quit = "q",
	north = "w",
	south = "s",
	west = "a",
	east = "d",
	drop = "f"
}


function base.is_empty(t)
	return (next(t) == nil)
end

function base.map_k(list, targ_k)
	local res = {}
	for k,v in pairs(list) do
		local targ_v = v[targ_k]
		if targ_v or targ_v == false then
			res[k] = targ_v
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

return base
