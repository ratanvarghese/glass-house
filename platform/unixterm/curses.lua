--- Curses interface.
-- Implemented using LuaJIT ffi
-- @module platform.unixterm.curses

local tiny = require("lib.tiny")
local ffi = require("ffi")

local base = require("core.base")
local visible = require("core.visible")
local grid = require("core.grid")
local common = require("platform.unixterm.common")

local ui = {}
local curses, COLOR, color_codes, REVERSE_OFFSET

local messages = {}
local did_show_msg = false

--- Initialize `platform.unixterm.curses`
function ui.init()
	ffi.cdef[[
	void* initscr();
	int beep();
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
	ui.init_called = true
end

local function redraw(world, showmsg)
	if not ui.init_called then return end
	for pos,x,y in grid.points() do
		local c, reverse = common.color_at(world, pos)
		if reverse then
			c = c + REVERSE_OFFSET
		end
		local attr = curses.COLOR_PAIR(c)
		local s = common.symbol_at(world, pos)
		curses.attron(attr)
		curses.mvaddstr(y, x, s)
		curses.attroff(attr)
	end

	if showmsg then
		for _,x,y,cur_msg in grid.points(messages) do
			--local A_BLINK = 524288
			local attr = curses.COLOR_PAIR(common.colors.green + REVERSE_OFFSET)
			curses.attron(attr)
			curses.mvaddstr(y, x, cur_msg)
			curses.attroff(attr)
		end
		did_show_msg = true
	else
		did_show_msg = false
	end

	local stats = visible.stats(world)
	local hp_line = string.format("HP: %4d", stats.health.now)
	curses.mvaddstr(1, grid.MAX_X + 2, hp_line)
	curses.refresh()
end

--- Get user input
-- @treturn core.enum.cmd
-- @treturn int numeric input, such as inventory number
function ui.get_input(world)
	if not ui.init_called then error("Too early to get input") end
	while true do
		local s = string.char(curses.getch())
		if common.keys[s] then
			messages = {}
			return common.keys[s], tonumber(s)
		elseif s == "m" then
			redraw(world, not did_show_msg)
		end
	end
end

--- Update system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
function ui.update(system)
	redraw(system.world, true)
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function ui.make_system()
	local system = tiny.system()
	system.filter = tiny.requireAll("pos")
	system.update = ui.update
	return system
end

--- Shut down UI
-- @tparam bool dead Is the player dead?
function ui.shutdown(dead)
	curses.clear()
	if dead then
		curses.mvaddstr(10, 10, "You are dead.")
	end
	curses.mvaddstr(12, 10, "Press any key to exit.")
	curses.refresh()
	curses.getch()
	curses.endwin()
end

local function gen_can_write_msg(world)
	local res = {}
	for y=1,grid.MAX_Y do
		local max = 0
		for x=grid.MAX_X,1,-1 do
			local p = grid.get_pos(x, y)
			local _, _, lit = visible.at(world, p)
			if not lit then
				max = max + 1
				res[p] = max
			else
				max = 0
			end
		end
	end
	return res
end

local function closest_writable_p(world,  msg, can_write_msg, last_x, step_x)
	local px, py = grid.get_xy(world.state.player_pos)
	for x=px,last_x,step_x do
		local msg_p = grid.get_pos(x, py)
		if can_write_msg[msg_p] and can_write_msg[msg_p] >= #msg then
			return msg_p
		end
	end
end

local function gen_msg_p_list(world,msg,can_write_msg)
	local res = {
		closest_writable_p(world,msg,can_write_msg,1,-1),
		closest_writable_p(world,msg,can_write_msg,grid.MAX_X,1)
	}
	return base.extend_arr({},pairs(res))
end

function ui.say(msg, world)
	assert(type(msg) == "string", "Non-string messages not yet supported")

	local can_write_msg = gen_can_write_msg(world)
	local msg_p_list = gen_msg_p_list(world,msg,can_write_msg)

	if #msg_p_list > 0 then
		messages[msg_p_list[math.random(#msg_p_list)]] = msg
	end
	curses.beep()
end

return ui
