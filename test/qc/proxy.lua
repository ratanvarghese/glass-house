local base = require("core.base")
local proxy = require("core.proxy")

property "proxy.read_write: return proxy table and control table" {
	generators = { tbl() },
	check = function(t)
		local xt, ct = proxy.read_write(t)
		local types_res = type(xt) == "table" and type(ct) == "table"
		local control_res = ct.reads == 0 and ct.writes == 0 and ct.source == t
		local proxy_res = base.is_empty(xt)
		local mt_res = getmetatable(xt) == ct.mt
		return types_res and control_res and proxy_res and mt_res
	end
}

property "proxy.read_write: read" {
	generators = { tbl(), int(), int(0, 100) },
	check = function(t, i, read_count)
		local t = base.is_empty(t) and {1} or t
		local i = base.clip(i, 1, #t)
		local xt, ct = proxy.read_write(t)
		local read_res = true
		for r=1,read_count do
			read_res = (xt[i] == t[i])
			if not read_res then return false end
		end
		return read_res and ct.reads == read_count
	end
}

property "proxy.read_write: write to source" {
	generators = { tbl(), tbl(), int(), int(0, 100) },
	check = function(t1, t2, i, write_count)
		local t1 = base.is_empty(t1) and {1} or t1
		local i = base.clip(i, 1, #t1)
		local xt, ct = proxy.read_write(t1)
		local read_res = true
		for w=1,write_count do
			xt[i] = t2[i]
			read_res = (xt[i] == t2[i] and t1[i] == t2[i])
			if not read_res then return false end
		end
		return read_res and ct.writes == write_count
	end
}

property "proxy.read_only: return proxy table and control table" {
	generators = { tbl() },
	check = function(t)
		local xt, ct = proxy.read_only(t)
		local types_res = type(xt) == "table" and type(ct) == "table"
		local control_res = ct.reads == 0 and ct.writes == 0 and ct.source == t
		local proxy_res = base.is_empty(xt)
		local mt_res = getmetatable(xt) == ct.mt
		return types_res and control_res and proxy_res and mt_res
	end
}

property "proxy.read_only: read" {
	generators = { tbl(), int(), int(0, 100) },
	check = function(t, i, read_count)
		local t = base.is_empty(t) and {1} or t
		local i = base.clip(i, 1, #t)
		local xt, ct = proxy.read_only(t)
		local read_res = true
		for r=1,read_count do
			read_res = (xt[i] == t[i])
			if not read_res then return false end
		end
		return read_res and ct.reads == read_count
	end
}

property "proxy.read_only: write error" {
	generators = { tbl(), any(), int()},
	check = function(t, a, i, write_count)
		local t = base.is_empty(t) and {1} or t
		local i = base.clip(i, 1, #t)
		local xt = proxy.read_only(t)
		return not pcall(function() xt[i] = a end)
	end
}

property "proxy.write_to_alt: return proxy table and control table" {
	generators = { tbl() },
	check = function(t)
		local xt, ct = proxy.write_to_alt(t)
		local types_res = type(xt) == "table" and type(ct) == "table"
		local control_res = ct.reads == 0 and ct.writes == 0 and ct.source == t
		local proxy_res = base.is_empty(xt)
		local alt_res = type(ct.alt) == "table" and base.is_empty(ct.alt)
		local mt_res = getmetatable(xt) == ct.mt
		return types_res and control_res and proxy_res and alt_res
	end
}

property "proxy.write_to_alt: read" {
	generators = { tbl(), int(), int(0, 100) },
	check = function(t, i, read_count)
		local t = base.is_empty(t) and {1} or t
		local i = base.clip(i, 1, #t)
		local xt, ct = proxy.write_to_alt(t)
		local read_res = true
		for r=1,read_count do
			read_res = (xt[i] == t[i])
			if not read_res then return false end
		end
		return read_res and ct.reads == read_count
	end
}

property "proxy.write_to_alt: write does not alter source, just alt" {
	generators = { tbl(), tbl(), int(), int(0, 100) },
	check = function(t1, t2, i, write_count)
		local t1 = base.is_empty(t1) and {1} or t1
		local i = base.clip(i, 1, #t1)
		local xt, ct = proxy.write_to_alt(t1)
		local read_res = true
		for w=1,write_count do
			local old_v = t1[i]
			local new_v
			if t2[i] == nil then
				new_v = old_v
			else 
				new_v = t2[i]
			end
			xt[i] = t2[i]
			read_res = (xt[i] == new_v and t1[i] == old_v and ct.alt[i] == t2[i])
			if not read_res then
				return false
			end
		end
		return read_res and ct.writes == write_count
	end
}
