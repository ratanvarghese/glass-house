local base = require("src.base")
local enum = require("src.enum")

local power = {}

power.MAX_LEN = 52 -- 2*(length of English alphabet)

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
	{kind = enum.power.cold}
})

table.insert(power.define, {
	{kind = enum.power.warp, min = 2, max = 10, versions = 3},
	{kind = enum.power.smash},
	{kind = enum.power.peaceful},
	{kind = enum.power.clone, min = 3, max = 4, versions = 1},
	{kind = enum.power.summon, min = 3, max = 4, versions = 1}
})

table.insert(power.define, {
	{kind = enum.power.tool},
	{kind = enum.power.kick, min = 1, max = 4, versions = 2},
	{kind = enum.power.punch, min = 1, max = 10, versions = 3},
	{kind = enum.power.steal},
	{kind = enum.power.jump}
})

function power.make_list(define_list)
	local res = {}
	for _,v in ipairs(define_list) do
		if v.versions then
			local factor_list = base.rn_distinct(v.min, v.max, v.versions)
			for _,factor in ipairs(factor_list) do
				local p = base.copy(v)
				p.max = nil
				p.min = nil
				p.versions = nil
				p.factor = factor
				table.insert(res, p)
			end
		else
			table.insert(res, base.copy(v))
		end
	end
	return res
end

function power.make_all()
	local categorized_list = base.map(power.define, power.make_list)
	local num_species = math.min(unpack(base.map(categorized_list, table.maxn)))
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
