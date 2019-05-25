local base = require("src.base")
local grid = require("src.grid")
local file = require("src.file")
local level = require("src.level")
local loop = require("src.loop")

local ui = require("ui.fuzz")
local cmdutil = require("ui.cmdutil")

local TURNS_MAX = 500
if tonumber(arg[1]) then
	TURNS_MAX = tonumber(arg[1])
end

math.randomseed(os.time())
level.current = level.make(1)

local turns = 0
local ok, err = xpcall(function()
	for i=1,TURNS_MAX do
		if not loop.iter(ui) then
			break
		end
		turns = i
	end
end, base.error_handler)

local function write_err(f, err)
	f:write("Level saved at ",base.savefile, "\n\n")
	f:write(err, "\n")
	io.write(cmdutil.full_string(cmdutil.symbol_grid(level.current)), "\n")

	f:write("\n\nStatbar:\n")
	if ui and ui.statbar and ui.statbar.hp then
		f:write("HP:\t\t", ui.statbar.hp, "\n")
	else
		f:write("HP:\t\t ??? \n")
	end
	f:write("\n\nOther Stats:\n")
	f:write("level num:\t", level.current.num, "\n")
	f:write("turns:\t\t", turns, "\n")
	if level.current.game_over then
		f:write("game_over:\t", level.current.game_over.msg, "\n")
	end
end

if not ok then
	base.savefile = os.tmpname()
	file.save({
		current = level.current
	})

	local debug_filename = os.tmpname()
	local f = io.open(debug_filename, "w")
	write_err(f, err)
	f:close()

	print("Error occured, details at "..debug_filename)
	write_err(io.stdout, err)
end
