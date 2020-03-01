--- Create proxy tables.
-- See [Programming in Lua](https://www.lua.org/pil/13.4.4.html).
-- Most of these are only used for testing, if they are used at all.
-- The exception is `proxy.memoize` which could be useful at runtime.
--
-- Most functions return a proxy table and a control table. The
-- control table contains the source table, and information about reads
-- and writes to the proxy.
-- @module core.proxy

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

--- Create a proxy table offering read/write access to the source.
-- See [Programming in Lua](https://www.lua.org/pil/13.4.4.html).
-- The control table has the following form:
--	{
--		source = source,
--		reads = [int],
--		writes = [int]
--	}
-- @tparam table source
-- @treturn table proxy table
-- @treturn table control table
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


--- Create a proxy table offering read-only access to the source.
-- See [Programming in Lua](https://www.lua.org/pil/13.4.5.html).
-- Attempting to write to the proxy will throw an error.
-- The control table has the following form:
--	{
--		source = source,
--		reads = [int],
--		writes = [int] --Hopefully always zero
--	}
-- @tparam table source
-- @treturn table proxy table
-- @treturn table control table
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


--- Create a proxy table that sends all writes to an alternate table.
-- Writing to the proxy will change an "alt" table. Reading from the proxy
-- will read from the "alt" table before checking the source table.
-- Thus, the source table can remain unchanged, with all updates happening
-- to the alt.
-- The control table has the following form:
--	{
--		source = source,
--		reads = [int],
--		writes = [int],
--		alt = [table]
--	}
-- @tparam table source
-- @treturn table proxy table
-- @treturn table control table
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

--- Create a proxy table that calls a function when reading a new key.
-- See [Programming in Lua](https://www.lua.org/pil/17.1.html).
-- When reading a key from the proxy table for the first time,
-- the key is passed to the function `f`, and the result of `f` is stored in the
-- source table. Whenever that key is accessed again, the proxy table can use
-- the value stored in the source. Thus, `f` is only called once for each input.
-- Attempting to write to the proxy will throw an error.
-- The control table has the following form:
--	{
--		f = f
--		source = [table],
--		reads = [int],
--		writes = [int] --Hopefully always zero
--	}
-- @tparam func f
-- @treturn table proxy table
-- @treturn table control table
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
