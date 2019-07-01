local curses = require("curses")

local grid = require("src.grid")
local enum = require("src.enum")
local level = require("src.level")
local cmdutil = require("ui.cmdutil")

local ui = {}

local stdscr = false

function ui.init()
	stdscr = curses.initscr()
	curses.cbreak()
	curses.echo(false)
	curses.nl(false)
	stdscr:clear()
end

ui.shutdown = curses.endwin

function ui.draw_level(lvl)
	local rows = cmdutil.row_strings(cmdutil.symbol_grid(lvl))
	for y,v in ipairs(rows) do
		stdscr:mvaddstr(y, 1, v)
	end
	stdscr:refresh()
end

local function get_key()
	return string.char(stdscr:getch())
end

function ui.get_input()
	return enum.cmd[cmdutil.keys[get_key()]], 1
end

function ui.draw_paths(lvl, name)
	local rows = cmdutil.row_strings(cmdutil.paths_grid(lvl, name))
	for y,v in ipairs(rows) do
		stdscr:mvaddstr(y + grid.MAX_Y + 1, 1, v)
	end
	stdscr:refresh()
end

function ui.draw_stats(stats)
	local hp_line = string.format("HP: %2d", stats.hp)
	stdscr:mvaddstr(1, grid.MAX_X + 2, hp_line)
	stdscr:refresh()
end

function ui.game_over(t)
	stdscr:clear()
	stdscr:mvaddstr(10, 10, t.msg)
	stdscr:mvaddstr(12, 10, "Press any key to exit.")
	stdscr:refresh()
	get_key()
end

return ui
