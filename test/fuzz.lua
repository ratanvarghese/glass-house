local base = require("src.base")
local file = require("src.file")
local level = require("src.level")
local loop = require("src.loop")

local ui = require("test.fuzzui")

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
	base.for_all_points(function(x, y, i)
		f:write(level.symbol_at(level.current, x, y))
		if y == base.MAX_Y then
			f:write("\n")
		end
	end)

	f:write("\n\nStatbar:\n")
	f:write("HP:\t\t", ui.statbar.hp, "\n")

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
