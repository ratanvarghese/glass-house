local grid = require("src.grid")
local enum = require("src.enum")
local level = require("src.level")
local cmdutil = require("ui.cmdutil")

local ui = {}

function ui.init()
	print("Welcome to GLASS HOUSE")
end

function ui.shutdown()
	print("Bye!")
end

local old_lvl_string = ""
function ui.draw_level(lvl)
	local lvl_string = cmdutil.full_string(cmdutil.symbol_grid(lvl))
	if lvl_string ~= old_lvl_string then
		io.write(lvl_string, "\n")
	end
	old_lvl_string = lvl_string
end

function ui.get_input()
	io.write("> ")
	return enum.cmd[cmdutil.keys[io.read()]], 1
end

function ui.draw_paths(lvl)
	io.write(cmdutil.full_string(cmdutil.paths_grid(lvl)), "\n")
end

function ui.draw_stats(stats)
	local hp_line = string.format("HP: %2d", stats.hp)
	io.write(hp_line, "\n")
end

function ui.game_over(t)
	io.write(t.msg, "\n")
end

return ui
