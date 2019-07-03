local rows = {
"     ###########                                                      ",
"     ######...###.........                                            ",
"     ## ##..@.##.#........###                                         ",
"          ...............#######                                      ",
"     #   #..#####.........###########                                 ",
"     ##  ##### ####.......#############                               ",
"     #####     ####.b.....   #############                            ",
"               ####......#  ##############  #                         ",
"               ######.###. ###############                            ",
"               ##########.#####   #########                           ",
"               ##########..  ##   ###### ##                           ",
"               #########...  #    #      ##                           ",
"                 #####.#...       # ### ####                          ",
"                 ####.a....         ###  #                            ",
"                 ###.......         ####                              ",
"                 ####......         ####  #                           ",
"                 ####......        ######   #                         ",
"                 #####..#..         #####                             ",
"                                    ####   #                          ",
"                                      ##############                  ",
}
for _,v in ipairs(rows) do
	io.write(v, "\n")
end

local CURSESLIB = "ncursesw"
local TERM = os.getenv("TERM")
io.write("\nPress Enter to see the same rows with ffi-loaded '", CURSESLIB,"' and TERM='", TERM, "'.\n")
io.read()

local ffi = require("ffi")
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

local curses = ffi.load(CURSESLIB)
curses.initscr()
curses.cbreak()
curses.noecho()
curses.nonl()
curses.clear()

for y,v in ipairs(rows) do
	curses.mvaddstr(y, 1, v)
end
local px, py = 13, 3
curses.move(py, px)
curses.getch()
curses.endwin()
