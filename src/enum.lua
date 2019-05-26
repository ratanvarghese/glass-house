local base = require("src.base")

local enum = {}

enum.reverse = {}

enum.reverse.cmd = {
	"quit",
	"north",
	"south",
	"east",
	"west",
	"drop",
	"equip",
	"MAX"
}

enum.reverse.terrain = {
	"floor",
	"wall",
	"stair",
	"MAX"
}

enum.reverse.monster = {
	"player",
	"angel",
	"dragon",
	"MAX_STATIC",
	"MAX"
}

enum.reverse.tool = {
	"lantern",
	"MAX_STATIC",
	"MAX"
}

for k,v in pairs(enum.reverse) do
	enum[k] = base.reverse(v)
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
	return max
end

return enum
