local ffi = require("ffi")

local grid = require("src.grid")
local enum = require("src.enum")
local level = require("src.level")
local cmdutil = require("ui.cmdutil")

local ui = {}

ffi.cdef[[
void* initscr();
int cbreak();
int noecho();
int nonl();
int clear();

int endwin();

int mvaddstr(int, int, const char*);
int move(int, int);
int refresh();
int getch();

]]

local curses = ffi.load("ncursesw")

function ui.init()
	curses.initscr()
	curses.cbreak()
	curses.noecho()
	curses.nonl()
	curses.clear()
end

ui.shutdown = curses.endwin

local px, py = 0, 0

function ui.draw_level(lvl)
	local rows = cmdutil.row_strings(cmdutil.symbol_grid(lvl))
	for y,v in ipairs(rows) do
		curses.mvaddstr(y, 1, v)
	end
	px, py = lvl:player_xy()
	curses.move(py, px)
	curses.refresh()
end

local function get_key()
	return string.char(curses.getch())
end

function ui.get_input()
	return enum.cmd[cmdutil.keys[get_key()]], 1
end

function ui.draw_paths(lvl, name)
	local rows = cmdutil.row_strings(cmdutil.paths_grid(lvl, name))
	for y,v in ipairs(rows) do
		curses.mvaddstr(y + grid.MAX_Y + 1, 1, v)
	end
	px, py = lvl:player_xy()
	curses.move(py, px)
	curses.refresh()
end

function ui.draw_stats(stats)
	local hp_line = string.format("HP: %2d", stats.hp)
	curses.mvaddstr(1, grid.MAX_X + 2, hp_line)
	curses.move(py, px)
	curses.refresh()
end

function ui.game_over(t)
	curses.clear()
	curses.mvaddstr(10, 10, t.msg)
	curses.mvaddstr(12, 10, "Press any key to exit.")
	curses.refresh()
	get_key()
end

return ui
