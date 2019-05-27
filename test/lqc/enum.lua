local enum = require("src.enum")
local base = require("src.base")

property "enum: end with MAX" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_reverse)
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

local new_reverse = {
	cmd = {
		"rot",
		"MAX"
	},
	terrain = {
		"marsh",
		"MAX"
	},
	monster = {
		"Death",
		"MAX_STATIC",
		"bunny rabbit",
		"MAX"
	},
	tool = {
		"coffin",
		"MAX_STATIC",
		"coffin of identify",
		"MAX"
	}
}
property "enum.init: accept new reverse" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(new_reverse)
		return base.equals(enum.reverse, new_reverse)
	end
}

property "enum.init: create new forward" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(new_reverse)
		for k,v in pairs(new_reverse) do
			if not base.equals(enum[k], base.reverse(v)) then
				return false
			end
		end
		return true
	end
}

property "enum.init: error for banned changes" {
	generators = {},
	numtests = 1,
	check = function()
		return not pcall(function() enum.init({init = new_reverse.tool}) end)
	end
}

property "enum.add_item: no altering prior items" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_reverse)
		local old_tool = base.copy(enum.tool)
		enum.new_item(enum.tool, "Amulet of Yendor")
		for k,v in pairs(old_tool) do
			if v <= old_tool.MAX_STATIC and enum.tool[k] ~= v then
				return false
			end
		end
		return true
	end
}

property "enum.add_item: add between MAX_STATIC and MAX" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_reverse)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return targ_v < enum.tool.MAX and targ_v > enum.tool.MAX_STATIC
	end
}

property "enum.add_item: alters reverse" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_reverse)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return enum.reverse.tool[targ_v] == targ_k
	end
}

property "enum.add_item: no repeat items" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_reverse)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		return not pcall(function() enum.new_item(enum.tool, targ_k) end)
	end
}
