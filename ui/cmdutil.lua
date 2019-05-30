--Utilities for command line user interfaces
local grid = require("src.grid")
local enum = require("src.enum")
local level = require("src.level")

local cmdutil = {}

cmdutil.keys = {
	q = "quit",
	w = "north",
	a = "west",
	s = "south",
	d = "east",
	f = "drop",
	["1"] = "equip"
}

local symbols = {}
symbols.dark = " "
symbols.err = ":"
symbols.terrain = {
	floor = ".",
	wall = "#",
	stair = "<"
}
symbols.monster = {
	player = "@",
	angel = "A",
	dragon = "D"
}
symbols.tool = {
	lantern = "("
}
cmdutil.symbols = symbols

function cmdutil.symbol_at(lvl, x, y)
	local targ_kind, targ_enum = lvl:visible_kind_at(x, y)
	if not targ_kind then
		return symbols.dark
	end

	if targ_enum == enum.terrain then
		return symbols.terrain[enum.reverse.terrain[targ_kind]]
	elseif targ_enum == enum.monster then
		return symbols.monster[enum.reverse.monster[targ_kind]]
	elseif targ_enum == enum.tool then
		return symbols.tool[enum.reverse.tool[targ_kind]]
	end

	return symbols.err
end

function cmdutil.paths_grid(lvl, name)
	local paths = lvl.paths[name or "to_player"]
	return grid.make_full(function(x, y, i)
		local n = paths[i]
		if n == 0 then
			return "@"
		elseif n then
			return n % 10
		else
			return " "
		end
	end)
end

function cmdutil.symbol_grid(lvl)
	return grid.make_full(function(x, y, i)
		return cmdutil.symbol_at(lvl, x, y)
	end)
end

function cmdutil.row_strings(t)
	local rows = {}
	for y=1,grid.MAX_Y do
		local i = grid.get_idx(1, y)
		local j = grid.get_idx(grid.MAX_X, y)
		table.insert(rows, table.concat(t, "", i, j))
	end
	return rows
end

function cmdutil.full_string(t)
	return table.concat(cmdutil.row_strings(t), "\n")
end

return cmdutil
