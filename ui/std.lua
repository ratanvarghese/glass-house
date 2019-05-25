local grid = require("src.grid")
local level = require("src.level")
local cmdutil = require("ui.cmdutil")

local ui = {}

function ui.init()
	print("Welcome to GLASS HOUSE")
end

function ui.shutdown()
	print("Bye!")
end

function ui.draw_level(lvl)
	io.write(cmdutil.full_string(cmdutil.symbol_grid(lvl)), "\n")
end

function ui.getinput()
	io.write("> ")
	return io.read()
end

function ui.draw_paths(lvl)
	io.write(cmdutil.full_string(cmdutil.paths_grid(lvl)), "\n")
end

function ui.draw_stats(lvl)
	local p = lvl.denizens[lvl.player_id]
	local hp_line = string.format("HP: %2d", p.hp)
	io.write(hp_line, "\n")
end

function ui.game_over(t)
	io.write(t.msg, "\n")
end

return ui
