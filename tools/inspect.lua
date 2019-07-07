local serpent = require("serpent")

local conf_i = 0
local conf_arg = arg[conf_i + 1]
local conf = {
	power_replace = false
}
if conf and string.sub(conf_arg, 1, 1) == "-" then
	conf_i = conf_i + 1
	if string.find(conf_arg, "p") then
		conf.power_replace = true
	end
end

local f = loadstring(io.read("*all"))
setfenv(f, {})
local origin = f()
local t = origin

for i,v in pairs(arg) do
	if i > conf_i then
		local v_num = tonumber(v)
		if v_num then
			t = t[v_num]
		else
			t = t[v]
		end
	end
end

local function do_replace_power(a, done)
	local done = done or {}
	if type(a) ~= "table" then
		return a
	elseif done[a] then
		return done[a]
	end
	local res = {}
	for k,v in pairs(a) do
		if k == "powers" then
			res[k] = {}
			for i,factor in pairs(v) do
				local name = origin.enum_inverted.power[i]
				res[k][name.."_"..tostring(i)] = factor
			end
		else
			res[k] = do_replace_power(v)
		end
	end
	done[a] = res
	return res
end

if conf.power_replace then
	t = do_replace_power(t)
end

print(serpent.block(t))
