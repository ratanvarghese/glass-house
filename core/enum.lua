--- Enumerated types.
-- Unlike in C and other programming environments, these enums are not always defined at
-- compile-time. Some are instead created when a new game starts.
-- Enums can be used in both their regular and inverted forms:
--	assert(enum.monster.player == 1)
--	assert(enum.inverted.monster[1] == "player")
-- @module core.enum
local base = require("core.base")

local enum = {}

--- Regular enums
-- @section regular

--- Command enum (initialized by `enum.init`)
-- @table enum.cmd

--- Tile enum (initialized by `enum.init`)
-- @table enum.tile

--- Monster species enum (initialized by `enum.init`)
-- @table enum.monster

--- Tool enum (initialized by `enum.init`)
-- @table enum.tool

--- Power enum (initialized by `enum.init`)
-- @table enum.power

--- Entity-entity species enum (initialized by `enum.init`)
-- @table enum.relations

--- Display options enum (initialized by `enum.init`)
-- @table enum.display

--- Decision mode enum (initialized by `enum.init`)
-- @table enum.decidemode

--- Inverted enums
-- @section inverted

--- Inverted enum table (initialized by `enum.init`)
-- @table enum.inverted

--- Inverted Command enum (initialized by `enum.init`)
-- @table enum.inverted.cmd

--- Inverted Tile enum (initialized by `enum.init`)
-- @table enum.inverted.tile

--- Inverted Monster species enum (initialized by `enum.init`)
-- @table enum.inverted.monster

--- Inverted Tool enum (initialized by `enum.init`)
-- @table enum.inverted.tool

--- Inverted Power enum (initialized by `enum.init`)
-- @table enum.inverted.power

--- Inverted Entity-entity species enum (initialized by `enum.init`)
-- @table enum.inverted.relations

--- Inverted Display options enum (initialized by `enum.init`)
-- @table enum.inverted.display

--- Inverted Decision mode enum (initialized by `enum.init`)
-- @table enum.inverted.decidemode

--- Default enums
-- @section default

--- Default inverted enum table.
-- Will differ slightly from `enum.inverted`, the actual inverted enum table
-- used in a given game.
enum.default_inverted = {}

--- Default inverted command enum
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

--- Default inverted tile enum
enum.default_inverted.tile = {
	"floor",
	"wall",
	"tough_wall",
	"stair",
	"MAX"
}

--- Default inverted monster species enum
enum.default_inverted.monster = {
	"player",
	"MAX_STATIC",
	"MAX"
}

--- Default inverted tool type enum
enum.default_inverted.tool = {
	"lantern",
	"MAX_STATIC",
	"MAX"
}

--- Default inverted power enum
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

--- Default inverted entity-entity relations enum
enum.default_inverted.relations = {
	"stuck_to",
	"MAX"
}

--- Default inverted display options enum
enum.default_inverted.display = {
	"hot",
	"cold",
	"MAX"
}

--- Default inverted decision mode enum
enum.default_inverted.decidemode = {
	"player",
	"monster",
	"MAX"
}

--- Initializer functions
-- @section init

--- Initialize `enum.inverted` and `enum`.
-- @tparam table inverted table of inverted enums
-- @treturn table the `core.enum` module
function enum.init(inverted)
	enum.inverted = base.copy(inverted)
	for k,v in pairs(enum.inverted) do
		assert(enum.default_inverted[k], "Tried to overwrite enum."..k)
		enum[k] = base.invert(v)
	end
	return enum
end

--- Add an item to an enum.
-- Only enums with a `MAX_STATIC` key are allowed to add items.
-- @tparam table list an enum
-- @tparam string item_name 
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
