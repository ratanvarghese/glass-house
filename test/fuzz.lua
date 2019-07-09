local base = require("src.base")
local enum = require("src.enum")
local grid = require("src.grid")
local flood = require("src.flood")
local file = require("src.file")
local level = require("src.level")
local loop = require("src.loop")

local cmdutil = require("ui.cmdutil")

local ui = {}
function ui.init()
	error("Called ui.init")
end

function ui.shutdown()
	error("Called ui.shutdown")
end

ui.screen = {}
function ui.draw_level(lvl)
	ui.screen = cmdutil.symbol_grid(lvl)

	local player_s = ui.screen[lvl.player_id]
	local bad_symbols = {
		[cmdutil.symbols.dark] = true,
		[cmdutil.symbols.err] = true,
		[cmdutil.symbols.terrain.floor] = true,
		[cmdutil.symbols.terrain.wall] = true,
		[cmdutil.symbols.terrain.tough_wall] = true,
		[cmdutil.symbols.terrain.stair] = true,
		[cmdutil.symbols.tool.lantern] = true,
	}
	assert(not bad_symbols[player_s], "Can't find player") --Player can be bodysnatched

	grid.make_full(function(x, y, i)
		local ne = ui.screen[i] ~= cmdutil.symbols.err
		assert(ne, "Display error: x="..tostring(x)..", y="..tostring(y))
	end)
end

ui.cmdlist = {}
for k,v in pairs(enum.cmd) do
	if k ~= "quit" and k ~= "MAX" then
		table.insert(ui.cmdlist, v)
	end
end

function ui.get_input()
	if math.random(1, 2) == 1 then
		return ui.cmdlist[math.random(1, #ui.cmdlist)], 1
	end

	local px, py = level.current:player_xy()
	local _, x, y = flood.local_min(px, py, level.current.paths.to_stair)
	if x == px+1 then
		return enum.cmd.east, 1
	elseif x == px-1 then
		return enum.cmd.west, 1
	elseif y == py+1 then
		return enum.cmd.south, 1
	else
		return enum.cmd.north, 1
	end
end

function ui.draw_paths()
	error("Called ui.draw_paths")
end

ui.statbar = {}
function ui.draw_stats(stats)
	ui.statbar.hp = stats.hp
end

function ui.game_over()
	error("Called ui.game_over")
end

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
	f:write("Level saved at ",file.name, "\n\n")
	f:write(err, "\n")
	f:write(cmdutil.full_string(cmdutil.symbol_grid(level.current)), "\n")

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
	file.name = os.tmpname()
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
