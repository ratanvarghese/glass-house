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
int curs_set(int);
int start_color();
int use_default_colors();
int bkgd();
bool has_colors();
bool can_change_color();
int init_pair(short, short, short);
int COLOR_PAIR(int);
int attron(int);
int attroff(int);

int endwin();

int mvaddstr(int, int, const char*);
int move(int, int);
int refresh();
int getch();
]]

local curses = ffi.load("ncursesw")

local COLOR = false
local color_codes = {
	[cmdutil.colors.black] = 0,
	[cmdutil.colors.red] = 1,
	[cmdutil.colors.green] = 2,
	[cmdutil.colors.yellow] = 3,
	[cmdutil.colors.blue] = 4,
	[cmdutil.colors.magenta] = 5,
	[cmdutil.colors.cyan] = 6,
	[cmdutil.colors.white] = 7
}
local REVERSE_OFFSET = 16


function ui.init()
	curses.initscr()
	curses.cbreak()
	curses.noecho()
	curses.nonl()
	curses.clear()
	curses.curs_set(0)
	if curses.has_colors() and curses.can_change_color() then
		curses.start_color()
		curses.use_default_colors()
		for k,v in pairs(cmdutil.colors) do
			local fg = color_codes[v]
			local bg = -1
			curses.init_pair(v, fg, bg)
			curses.init_pair(v + REVERSE_OFFSET, color_codes[cmdutil.colors.black], fg)
		end
		COLOR = true
	end
end

ui.shutdown = curses.endwin

function ui.draw_level(lvl)
	grid.make_full(function(x, y, i)
		local c, reverse = cmdutil.color_at(lvl, x, y, i)
		if reverse then
			c = c + REVERSE_OFFSET
		end
		local attr = curses.COLOR_PAIR(c)
		curses.attron(attr)
		curses.mvaddstr(y, x, cmdutil.symbol_at(lvl, x, y))
		curses.attroff(attr)
	end)
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
	curses.refresh()
end

function ui.draw_stats(stats)
	local hp_line = string.format("HP: %4d", stats.hp)
	curses.mvaddstr(1, grid.MAX_X + 2, hp_line)
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
