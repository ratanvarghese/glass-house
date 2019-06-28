local base = require("src.base")

local power = {}

power.MAX_LEN = 52 -- 2*(length of English alphabet)

power.define = {}

power.define.passive = {
	{name = "light", min = 2, max = 5, versions = 2},
}

power.define.movement = {
	{name = "warp", min = 2, max = 10, versions = 3},
	{name = "break"}
}

power.define.fighting = {
	{name = "tool"},
	{name = "kick", min = 1, max = 4, versions = 2},
	{name = "punch", min = 1, max = 10, versions = 3}
}

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
	local all_passive = power.make_list(power.define.passive)
	local all_movement = power.make_list(power.define.movement)
	local all_fighting = power.make_list(power.define.fighting)

	local res = {}
	local num_species = math.min(#all_passive, #all_movement, #all_fighting)
	for i=1,num_species do
		local passive_i = math.random(1, #all_passive)
		local movement_i = math.random(1, #all_movement)
		local fighting_i = math.random(1, #all_fighting)

		local p = table.remove(all_passive, passive_i)
		local m = table.remove(all_movement, movement_i)
		local f = table.remove(all_fighting, fighting_i)

		table.insert(res, {p, m, f})
	end
	return res
end

return power
