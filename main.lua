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
local ok, err = xpcall(function()
	local keep_going = true
	while keep_going do
		local old_level = level.current
		for _, denizen in ipairs(level.current.denizens_in_order) do
			ui.drawlevel()
			ui.drawstats()

			if not level.current.kill_set[denizen] then
				local i = level.current.denizens[base.getIdx(denizen.x, denizen.y)]
				assert(i == denizen, "ID error for denizen\n")

				if denizen.symbol == base.symbols.player then
					local c = ui.getinput()
					keep_going = player.handle_input(c)
				else
					mon.act(denizen)
				end
			end

			if keep_going and level.current.game_over then
				keep_going = false
			end

			if level.current ~= old_level or not keep_going then
				break
			end
		end
		level.current:check_kills()
	end

	if level.current.game_over then
		file.remove_save()
		ui.game_over(level.current.game_over)
	else
		local state = {
			current = level.current
		}
		file.save(state)
	end
end, base.error_handler)
ui.shutdown()

if not ok then
	print(err)
end
