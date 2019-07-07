local enum = require("src.enum")
local base = require("src.base")

property "enum: end with MAX" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_inverted)
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

local new_inverted = {
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
property "enum.init: accept new inverted" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(new_inverted)
		return base.equals(enum.inverted, new_inverted)
	end
}

property "enum.init: create new forward" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(new_inverted)
		for k,v in pairs(new_inverted) do
			if not base.equals(enum[k], base.invert(v)) then
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
		return not pcall(function() enum.init({init = new_inverted.tool}) end)
	end
}

property "enum.add_item: no altering prior items" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_inverted)
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
		enum.init(enum.default_inverted)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return targ_v < enum.tool.MAX and targ_v > enum.tool.MAX_STATIC
	end
}

property "enum.add_item: alters inverted" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_inverted)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		local targ_v = enum.tool[targ_k]
		return enum.inverted.tool[targ_v] == targ_k
	end
}

property "enum.add_item: no repeat items" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_inverted)
		local targ_k = "Amulet of Yendor"
		enum.new_item(enum.tool, targ_k)
		return not pcall(function() enum.new_item(enum.tool, targ_k) end)
	end
}

local function get_enum_names()
	local res = {}
	for k in pairs(enum.inverted) do
		table.insert(res, k)
	end
	return res
end

property "enum.rn_item: results in range" {
	generators = { int(1, #get_enum_names()) },
	check = function(i)
		enum.init(enum.default_inverted)
		local name = get_enum_names()[i]
		local res = enum.rn_item(enum[name])
		return res > 0 and res < enum[name].MAX
	end
}

property "enum.rn_item: never MAX or MAX_STATIC" {
	generators = { int(1, #get_enum_names()) },
	check = function(i)
		enum.init(enum.default_inverted)
		local name = get_enum_names()[i]
		local res = enum.rn_item(enum[name])
		return res ~= enum[name].MAX and res ~= enum[name].MAX_STATIC
	end
}

property "enum.rn_item: respect dynamic_only" {
	generators = { int(1, 2) },
	check = function(i)
		enum.init(new_inverted)
		local list = {"monster", "tool"}
		local name = list[i]
		local res = enum.rn_item(enum[name], true)
		return res > enum[name].MAX_STATIC
	end
}

property "enum.rn_item: error if dynamic_only cannot be respected" {
	generators = { int(1, #get_enum_names()) },
	check = function(i)
		enum.init(enum.default_inverted) --Default will not contain 'dynamic' enums
		local name = get_enum_names()[i]
		return not pcall(function() enum.rn_item(enum[name], true) end)
	end
}
