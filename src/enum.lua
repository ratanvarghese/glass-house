local base = require("src.base")

local enum = {}

enum.default_reverse = {
	cmd = {
		"quit",
		"north",
		"south",
		"east",
		"west",
		"drop",
		"equip",
		"MAX"
	},
	terrain = {
		"floor",
		"wall",
		"stair",
		"MAX"
	},
	monster = {
		"player",
		"angel",
		"dragon",
		"MAX_STATIC",
		"MAX"
	},
	tool = {
		"lantern",
		"MAX_STATIC",
		"MAX"
	}
}

function enum.init(reverse)
	enum.reverse = base.copy(reverse)
	for k,v in pairs(enum.reverse) do
		assert(enum.default_reverse[k], "Tried to overwrite enum."..k)
		enum[k] = base.reverse(v)
	end
end

function enum.new_item(list, item_name)
	local min = list.MAX_STATIC
	local max = list.MAX

	assert(min, "Missing min element of enum")
	assert(max, "Missing max element of enum")
	assert(min < max, "Disordered enum")
	assert(not list[item_name], "Repeat name in enum")

	list[item_name] = max
	list.MAX = max + 1

	for k,v in pairs(enum.reverse) do
		if list == enum[k] then
			table.insert(v, max, item_name)
			break
		end
	end

	return max
end

enum.init(enum.default_reverse)
return enum
