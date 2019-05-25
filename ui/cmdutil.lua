--Utilities for command line user interfaces
local grid = require("src.grid")
local level = require("src.level")

local cmdutil = {}

function cmdutil.paths_grid(lvl)
	return grid.make_full(function(x, y, i)
		local n = lvl.paths.to_player[i]
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
		return lvl:symbol_at(x, y)
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
