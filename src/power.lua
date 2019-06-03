local base = require("src.base")

local power = {}

power.MAX_LEN = 52 -- 2*(length of English alphabet)

power.define = {}

power.define.passive = {
	{name = "light", min = 2, max = 5, versions = 2},
}

power.define.movement = {
	{name = "warp", min = 2, max = 10, versions = 3},
	{name = "break", monster_only = true}
}

power.define.fighting = {
	{name = "tool", monster_only = true}
}

function power.make_list(define_list)
	local res = {}
	for _,v in ipairs(define_list) do
		if v.versions then
			local template = base.copy(v)
			template.max = nil
			template.min = nil
			template.versions = nil
			for i=1,v.versions do
				local p = base.copy(template)
				p.factor = math.random(v.min, v.max)
				table.insert(res, p)
			end
		else
			table.insert(res, base.copy(v))
		end
	end
	return res
end

function power.tool_list(define_list)
	return base.filter(define_list, function(v) return not v.monster_only end)
end

return power
