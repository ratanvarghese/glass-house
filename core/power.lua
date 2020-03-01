--- Manage combinations of powers for monsters.
-- This module assists in procedurally generating monster species by
-- converting lists of `power.definition` into a list of `power.combination`. Each
-- `power.combination` can then be provided to a different species.
-- @module core.power

--- Table representing power definition.
-- A power definition is a table of the following form:
--	{
--		kind = [enum.power.*],
--		min = [int],
--		max = [int],
--		versions = [int]
--	}
-- If `min`, `max`, and `versions` are provided, the number of species with this power
-- will be equal to `versions`. Each of those species will have a distinct power factor
-- for this power, between `min` and `max`.
--
-- If `min`, `max` and `versions` are not provided, only one species will have this power.
-- The power factor will be `power.DEFAULT`, which indicates a meaningless power factor.
-- @typedef power.definition

--- Table representing power combination.
-- A power combination has the form:
--	{
--		[enum.power.*] = [int],
--		[enum.power.*] = [int],
--		...
--	}
-- Each species has it's own power combination.
-- @typedef power.combination

local base = require("core.base")
local enum = require("core.enum")

local power = {}

--- Maximum number of procedurally generated monster species
power.MAX_LEN = 52 -- 2*(length of English alphabet)

--- Indicates a meaningless power factor
power.DEFAULT = -1

--- A list *of* lists of `power.definition`
power.define = {}

table.insert(power.define, {
	{kind = enum.power.light, min = 2, max = 5, versions = 2},
	{kind = enum.power.darkness, min = 1, max = 2, versions = 1},
	{kind = enum.power.vampiric},
	{kind = enum.power.heal, min = 2, max = 5, versions = 2},
	{kind = enum.power.hot, min = 3, max = 5, versions = 1},
	{kind = enum.power.cold, min = 3, max = 5, versions = 1},
	{kind = enum.power.steal}
})

table.insert(power.define, {
	{kind = enum.power.warp, min = 2, max = 10, versions = 2},
	{kind = enum.power.smash},
	{kind = enum.power.clone, min = 3, max = 4, versions = 1},
	{kind = enum.power.summon, min = 3, max = 4, versions = 1},
	{kind = enum.power.jump},
	{kind = enum.power.tool},
	{kind = enum.power.displace},
	{kind = enum.power.bodysnatch},
	{kind = enum.power.slow, min = 2, max = 5, versions = 1},
	{kind = enum.power.sticky},
})

--- Convert a list of power definitions into a list of power definitions with a factor.
-- Power definitions in the output list will have an extra field, `.factor`.
-- @tparam {power.definition,...} define_list
-- @treturn {power.definition,...}
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

--- Produce a list of power combinations
-- @treturn {power.combination,...}
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