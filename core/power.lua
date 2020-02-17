local base = require("core.base")
local enum = require("core.enum")

local power = {}

power.MAX_LEN = 52 -- 2*(length of English alphabet)
power.DEFAULT = -1

power.define = {}

table.insert(power.define, {
	{kind = enum.power.light, min = 2, max = 5, versions = 2},
	{kind = enum.power.darkness, min = 1, max = 2, versions = 1},
	{kind = enum.power.vampiric},
	{kind = enum.power.heal},
	{kind = enum.power.slow, min = 2, max = 5, versions = 1},
	{kind = enum.power.sticky},
	{kind = enum.power.displace},
	{kind = enum.power.bodysnatch},
	{kind = enum.power.hot},
	{kind = enum.power.cold},
	{kind = enum.power.steal}
})

table.insert(power.define, {
	{kind = enum.power.warp, min = 2, max = 10, versions = 3},
	{kind = enum.power.smash},
	{kind = enum.power.peaceful},
	{kind = enum.power.clone, min = 3, max = 4, versions = 1},
	{kind = enum.power.summon, min = 3, max = 4, versions = 1},
	{kind = enum.power.jump},
	{kind = enum.power.tool},
})

function power.make_list(define_list)
	local res = {}
	for _,v in ipairs(define_list) do
		if v.versions then
			for _,factor in base.rn_distinct(v.min, v.max, v.versions) do
				local p = base.copy(v)
				p.max = nil
				p.min = nil
				p.versions = nil
				p.factor = factor
				table.insert(res, p)
			end
		else
			local p = base.copy(v)
			p.factor = power.DEFAULT
			table.insert(res, p)
		end
	end
	return res
end

function power.make_all()
	local categorized_list = {}
	local num_species = power.MAX_LEN
	for i,v in ipairs(power.define) do
		local list = power.make_list(v)
		table.insert(categorized_list, list)
		num_species = math.min(num_species, #list)
	end
	local res = {}
	for i=1,num_species do
		local t = {}
		for _,list in ipairs(categorized_list) do
			local list_i = math.random(1, #list)
			local p = table.remove(list, list_i)
			t[p.kind] = p.factor or true
		end
		table.insert(res, t)
	end
	return res
end

return power
