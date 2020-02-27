local base = require("core.base")

local enum = {}

enum.default_inverted = {}
enum.default_inverted.cmd = {
	"quit",
	"exit",
	"north",
	"south",
	"east",
	"west",
	"drop",
	"equip",
	"MAX"
}
enum.default_inverted.tile = {
	"floor",
	"wall",
	"tough_wall",
	"stair",
	"MAX"
}
enum.default_inverted.monster = {
	"player",
	"MAX_STATIC",
	"MAX"
}
enum.default_inverted.tool = {
	"lantern",
	"MAX_STATIC",
	"MAX"
}
enum.default_inverted.power = {
	"light",
	"warp",
	"smash",
	"tool",
	"vampiric",
	"heal",
	"clone",
	"darkness",
	"summon",
	"slow",
	"sticky",
	"displace",
	"bodysnatch",
	"steal",
	"hot",
	"cold",
	"jump",
	"mundane",
	"MAX"
}
enum.default_inverted.relations = {
	"stuck_to",
	"MAX"
}
enum.default_inverted.display = {
	"hot",
	"cold",
	"MAX"
}
enum.default_inverted.decidemode = {
	"player",
	"monster",
	"MAX"
}

function enum.init(inverted)
	enum.inverted = base.copy(inverted)
	for k,v in pairs(enum.inverted) do
		assert(enum.default_inverted[k], "Tried to overwrite enum."..k)
		enum[k] = base.invert(v)
	end
	return enum
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

	for k,v in pairs(enum.inverted) do
		if list == enum[k] then
			table.insert(v, max, item_name)
			break
		end
	end

	return max
end

return enum.init(enum.default_inverted)
