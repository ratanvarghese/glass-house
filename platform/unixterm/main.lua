local argparse = require("lib.argparse")

local p = argparse("glass-house", "Glass House")
p:flag("-s --stdio")

local args = p:parse()
local ui
if args.stdio then
	ui = require("platform.unixterm.stdio")
else
	ui = require("platform.unixterm.curses")
end
local save = require("platform.unixterm.save")

local base = require("core.base")
local enum = require("core.enum")
local decide = require("core.decide")
local health = require("core.health")
local bestiary = require("core.bestiary")
local world = require("core.world")

math.randomseed(os.time())

local function exit_f(w, kill_save)
	ui.shutdown()
	if kill_save then
		save.remove()
	else
		local state = {
			world = world.store(w),
			enum_inverted = enum.inverted,
			bestiary_set = bestiary.set
		}
		save.save(state)
	end
	os.exit()
end
decide.init(exit_f, ui.get_input)
health.init(exit_f)

local state = save.load()
if state then
	enum.init(state.enum_inverted)
	bestiary.set = state.bestiary_set
	world.current = world.restore(ui, state.world)
else
	bestiary.make_set()
	world.current = world.make(ui, 1)
end

ui.init()
local ok, err = xpcall(function()
	while true do
		world.current.update(world.current, 1)
	end
end, base.error_handler)
ui.shutdown()
if not ok then
	print(err)
end
