local termfx = require("termfx")

local base = require("src.base")
local file = require("src.file")
local level = require("src.level")

local ui
if arg[1] == "--stdio" or arg[1] == "-s" then
	ui = require("ui.std")
else
	ui = require("ui.rogue")
end

math.randomseed(os.time())

level.current = file.load()
if level.current then
	level.register(level.current)
else	
	level.current = level.make(1)
end

ui.init()
local ok, err = pcall(function()
	while true do
		ui.drawlevel()

		local c = ui.getinput()
		local dy, dx = 0, 0
		if c == "q" then
			break
		elseif c == "w" then
			dy = -1
		elseif c == "s" then
			dy = 1
		elseif c == "a" then
			dx = -1
		elseif c == "d" then
			dx = 1
		end
		level.current:move_player(dx, dy)
		if level.current:denizen_on_terrain(level.current.player_id, base.symbols.stair) then
			level.current = level.make(level.current.num + 1)
		end
	end
end)

ui.shutdown()

if ok then
	ok, err = pcall(function() file.save(level.current) end)
end

if not ok then
	print(err)
end
