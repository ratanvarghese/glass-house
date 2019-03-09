local termfx = require("termfx")

local base = require("base")
local file = require("file")
local action = require("action")
local level = require("level")

math.randomseed(os.time())

level.current = file.load()
if not level.current then
	level.current = level.make(1)
end

termfx.init()
local ok, err = pcall(function()

	while true do
		termfx.clear()

		for y=1,base.MAX_Y do
			for x=1,base.MAX_X do
				termfx.printat(x, y, level.symbol_at(level.current, x, y))
			end
		end
		termfx.present()

		local evt = termfx.pollevent()
		local dy, dx = 0, 0
		if evt.char == "q" then
			break
		elseif evt.char == "w" then
			dy = -1
		elseif evt.char == "s" then
			dy = 1
		elseif evt.char == "a" then
			dx = -1
		elseif evt.char == "d" then
			dx = 1
		end

		if action.move_player(level.current, dx, dy) then
			level.current = level.make(level.current.num + 1)
		end
	end

end)

termfx.shutdown()

if ok then
	ok, err = pcall(function() file.save(level.current) end)
end

if not ok then
	print(err)
end
