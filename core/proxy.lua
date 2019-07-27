local proxy = {}

local function common_init(source)
	local res = {}
	local control = {
		source = source,
		reads = 0,
		writes = 0
	}
	return res, control
end

local function common_result(res, control)
	setmetatable(res, control.mt)
	return res, control
end

function proxy.read_write(source)
	local res, control = common_init(source)
	control.mt = {
		__index = function(t, k)
			local v = control.source[k]
			control.reads = control.reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			control.source[k] = v
			control.writes = control.writes + 1
		end
	}
	return common_result(res, control)
end

function proxy.read_only(source)
	local res, control = common_init(source)
	control.mt = {
		__index = function(t, k)
			local v = control.source[k]
			control.reads = control.reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			error("Attempt to write to read-only proxy table")
		end
	}
	return common_result(res, control)
end

function proxy.write_to_alt(source)
	local res, control = common_init(source)
	control.alt = {}
	control.mt = {
		__index = function(t, k)
			local v = control.alt[k]
			if v == nil then
				v = control.source[k]
			end
			control.reads = control.reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			control.alt[k] = v
			control.writes = control.writes + 1
		end
	}
	return common_result(res, control)
end


function proxy.memoize(f)
	local res, control = common_init({})
	control.f = f
	control.mt = {
		__index = function(t, k)
			local v = control.source[k]
			if v == nil then
				v = control.f(k)
				control.source[k] = v
			end
			control.reads = control.reads + 1
			return v
		end,
		__newindex = function(t, k, v)
			error("Attempt to write to memoize proxy table")
		end
	}
	return common_result(res, control)
end
return proxy
