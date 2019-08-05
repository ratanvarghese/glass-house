local enum = require("core.enum")
local base = require("core.base")

property "enum: end with MAX" {
	generators = {},
	numtests = 1,
	check = function()
		enum.init(enum.default_inverted)
		local list = {enum.cmd, enum.tile, enum.tool, enum.monster}
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
	tile = {
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

property "enum.selectf: select correct mode" {
	generators = { int(1, #get_enum_names()), int(), any(), tbl()},
	check = function(enum_i, element_i, expected_res, expected_args)
		enum.init(enum.default_inverted)
		local enum_name = get_enum_names()[enum_i]
		local mode_enum = enum[enum_name]
		local mode_inverted = enum.inverted[enum_name]
		local element_i = base.clip(element_i, 1, mode_enum.MAX)
		local args = {}
		local t = {
			[mode_inverted[element_i-1] or "dummy1"] = function(...)
				print("Dummy -1 called")
			end,
			[mode_inverted[element_i]] = function(...)
				table.insert(args, {...})
				return expected_res
			end,
			[mode_inverted[element_i+1] or "dummy2"] = function(...)
				print("Dummy +1 called")
			end
		}

		local sel_f = enum.selectf(mode_enum, t)
		local res = sel_f(element_i, unpack(expected_args))
		return res == expected_res and #args == 1 and base.equals(args[1], expected_args)
	end
}

property "enum.selectf: error on bad mode" {
	generators = { int(1, #get_enum_names()), int(), tbl()},
	check = function(enum_i, element_i, args)
		enum.init(enum.default_inverted)
		local enum_name = get_enum_names()[enum_i]
		local mode_enum = enum[enum_name]
		local mode_inverted = enum.inverted[enum_name]
		local bad_element_i = base.clip(element_i, mode_enum.MAX*2, mode_enum.MAX*3)
		local good_element_i = base.clip(element_i, 1, mode_enum.MAX)
		local t = {
			[mode_inverted[good_element_i]] = function(...)
				print("Dummy called")
			end
		}
		local sel_f = enum.selectf(mode_enum, t)
		return not pcall(function() sel_f(bad_element_i, unpack(args)) end)
	end
}