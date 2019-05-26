local enum = require("src.enum")
local grid = require("src.grid")
local level = require("src.level")

local cmdutil = require("ui.cmdutil")

local ui = {}

function ui.init()
	error("Called ui.init")
end

function ui.shutdown()
	error("Called ui.shutdown")
end

ui.screen = {} --ui.screen[y][x], not the other way around
function ui.draw_level(lvl)
	for y=1,grid.MAX_Y do
		local row = {}
		ui.screen[y] = row
		for x=1,grid.MAX_X do
			row[x] = cmdutil.symbol_at(lvl, x, y)
		end
	end
end

ui.cmdlist = {}
for k,v in pairs(enum.cmd) do
	if k ~= "quit" then
		table.insert(ui.cmdlist, v)
	end
end

function ui.getinput()
	if math.random(1, 2) == 1 then
		return ui.cmdlist[math.random(1, #ui.cmdlist)], 1
	end

	local p = level.current.denizens[level.current.player_id]
	local _, x, y = grid.adjacent_min(level.current.paths.to_stair, p.x, p.y)
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

function ui.drawpaths()
	error("Called ui.drawpaths")
end

ui.statbar = {}
function ui.draw_stats(lvl)
	local p = lvl.denizens[lvl.player_id]
	ui.statbar.hp = p.hp
end

function ui.game_over()
	error("Called ui.game_over")
end

return ui
