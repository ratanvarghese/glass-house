local tiny = require("lib.tiny")

local visible = require("core.visible")
local grid = require("core.grid")
local common = require("platform.unixterm.common")

local ui = {}

ui.displays = 0

function ui.init()
	print("Welcome to GLASS HOUSE")
	ui.ready = true
end

function ui.shutdown(dead)
	if dead then
		print("You died.")
	end
	print("Bye!")
end

function ui.get_input()
	io.write("> ")
	local s = io.read()
	return common.keys[s], tonumber(s)
end

local last_display = ""
function ui.display(system)
	if not ui.ready then return end
	local display_t = {}
	local last_y = -math.huge
	for pos,_,y in grid.points() do
		if y ~= last_y then
			table.insert(display_t, "\n")
		end
		table.insert(display_t, common.symbol_at(system.world, pos))
		last_y = y
	end

	local stats = visible.stats(system.world)
	table.insert(display_t, "\nHP:\t")
	table.insert(display_t, stats.health.now)

	local next_display = table.concat(display_t)
	if next_display ~= last_display then
		print(next_display)
	end
	last_display = next_display
end

function ui.make_system()
	local system = tiny.system()
	system.filter = tiny.requireAll("pos")
	system.update = ui.display
	return system
end

return ui
