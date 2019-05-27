local enum = require("src.enum")
local base = require("src.base")

property "enum: end with MAX" {
	generators = {},
	numtests = 1,
	check = function()
		local list = {enum.cmd, enum.terrain, enum.tool, enum.monster}
		for _, targ_enum in pairs(list) do
			local max = 1
			for k,v in pairs(targ_enum) do
				max = math.max(v, max)
			end
			if targ_enum.MAX ~= max then
				return false
			end
		end
		return true
	end
}

property "enum: add item without altering prior items" {
	generators = {},
	numtests = 1,
	check = function()
		local old_tool = base.copy(enum.tool)
		enum.new_item(enum.tool, "Tsurugi of Muramasa")
		for k,v in pairs(old_tool) do
			if v <= old_tool.MAX_STATIC and enum.tool[k] ~= v then
				return false
			end
		end
		return true
	end
}

property "enum: add item between MAX_STATIC and MAX" {
	generators = {},
	numtests = 1,
	check = function()
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return targ_v < enum.tool.MAX and targ_v > enum.tool.MAX_STATIC
	end
}

property "enum: add item alters reverse" {
	generators = {},
	numtests = 1,
	check = function()
		local targ_k = "Book of the Dead"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return enum.reverse.tool[targ_v] == targ_k
	end
}
