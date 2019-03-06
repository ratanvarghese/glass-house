local termfx = require("termfx")

local symbols = {
	floor = " ",
	wall = "#",
	player = "@",
	stair = ">"
}

local denizens = {
	{
		symbol = symbols.player,
		x = 10,
		y = 10
	}
}



termfx.init()

local keepGoing = true
local ok, err = pcall(function()

while keepGoing do
	termfx.clear()
	termfx.printat(denizens[1].x, denizens[1].y, denizens[1].symbol)
	termfx.present()

	local evt = termfx.pollevent()
	if evt.char == "q" then
		keepGoing = false
	elseif evt.char == "w" then
		denizens[1].y = denizens[1].y - 1
	elseif evt.char == "s" then
		denizens[1].y = denizens[1].y + 1
	elseif evt.char == "a" then
		denizens[1].x = denizens[1].x - 1
	elseif evt.char == "d" then
		denizens[1].x = denizens[1].x + 1
	end
end

end)

termfx.shutdown()

if not ok then
	print(err)
end
