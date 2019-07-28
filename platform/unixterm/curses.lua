local tiny = require("lib.tiny")
local ffi = require("ffi")

local visible = require("core.visible")
local grid = require("core.grid")
local common = require("platform.unixterm.common")

local ui = {}
local curses, COLOR, color_codes, REVERSE_OFFSET

function ui.init()
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
	curses = ffi.load("ncursesw")
	COLOR = false
	color_codes = {
		[common.colors.black] = 0,
		[common.colors.red] = 1,
		[common.colors.green] = 2,
		[common.colors.yellow] = 3,
		[common.colors.blue] = 4,
		[common.colors.magenta] = 5,
		[common.colors.cyan] = 6,
		[common.colors.white] = 7
	}
	REVERSE_OFFSET = 16

	curses.initscr()
	curses.cbreak()
	curses.noecho()
	curses.nonl()
	curses.clear()
	curses.curs_set(0)
	if curses.has_colors() and curses.can_change_color() then
		curses.start_color()
		curses.use_default_colors()
		for k,v in pairs(common.colors) do
			local fg = color_codes[v]
			local bg = -1
			curses.init_pair(v, fg, bg)
			curses.init_pair(v + REVERSE_OFFSET, color_codes[common.colors.black], fg)
		end
		COLOR = true
	end
	ui.shutdown = curses.endwin
	ui.init_called = true
end

function ui.get_input()
	if not ui.init_called then error("Too early to get input") end
	local s = string.char(curses.getch())
	return common.keys[s], tonumber(s)
end

function ui.update(system)
	if not ui.init_called then return end
	for pos,x,y in grid.points() do
		local c, reverse = common.color_at(system.world, pos)
		if reverse then
			c = c + REVERSE_OFFSET
		end
		local attr = curses.COLOR_PAIR(c)
		local s = common.symbol_at(system.world, pos)
		curses.attron(attr)
		curses.mvaddstr(y, x, s)
		curses.attroff(attr)
	end
	local stats = visible.stats(system.world)
	local hp_line = string.format("HP: %4d", stats.health.now)
	curses.mvaddstr(1, grid.MAX_X + 2, hp_line)
	curses.refresh()
end

function ui.make_system()
	local system = tiny.system()
	system.filter = tiny.requireAll("pos")
	system.update = ui.update
	return system
end

return ui
