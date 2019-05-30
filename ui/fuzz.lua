local enum = require("src.enum")
local grid = require("src.grid")
local flood = require("src.flood")
local level = require("src.level")

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
	assert(player_s == cmdutil.symbols.monster.player, "Can't find player")

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

	local p = level.current.denizens[level.current.player_id]
	local _, x, y = flood.local_min(p.x, p.y, level.current.paths.to_stair)
	if x == p.x+1 then
		return enum.cmd.east, 1
	elseif x == p.x-1 then
		return enum.cmd.west, 1
	elseif y == p.y+1 then
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

return ui
