local base = require("src.base")
local file = require("src.file")
local level = require("src.level")
local player = require("src.player")
local mon = require("src.mon")

local ui
if arg[1] == "--stdio" or arg[1] == "-s" then
	ui = require("ui.std")
else
	ui = require("ui.rogue")
end

math.randomseed(os.time())

local state = file.load()
if state then
	level.current = state.current
	level.register(level.current)
else	
	level.current = level.make(1)
end

ui.init()
local ok, err = pcall(function()
	local keep_going = true
	while keep_going do
		ui.drawlevel()

		local old_level = level.current
		for _, denizen in ipairs(level.current.denizens_in_order) do
			local dz_idx = level.current.denizens[base.getIdx(denizen.x, denizen.y)]
			assert(dz_idx == denizen, "ID error for denizen\n"..debug.traceback())

			if denizen.symbol == base.symbols.player then
				local c = ui.getinput()
				keep_going = player.handle_input(c)
			else
				mon.act(denizen)
			end

			if level.current ~= old_level then
				break
			end
		end
	end
end)
ui.shutdown()

if ok then
	state = {
		current = level.current
	}
	ok, err = pcall(function()
		file.save(state)
	end)
end

if not ok then
	print(err)
end
