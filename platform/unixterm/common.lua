local base = require("core.base")
local enum = require("core.enum")
local visible = require("core.visible")

local common = {default = {}}

common.default.keys = {
	q = enum.cmd.quit,
	x = enum.cmd.exit,
	w = enum.cmd.north,
	s = enum.cmd.south,
	d = enum.cmd.east,
	a = enum.cmd.west,
	f = enum.cmd.drop,
	["1"] = enum.cmd.equip
}

common.default.colors = base.invert({
	"black",
	"red",
	"green",
	"yellow",
	"blue",
	"magenta",
	"cyan",
	"white"
})

common.default.symbols = {}
common.default.symbols.dark = " "
common.default.symbols.err = ":"
common.default.symbols.terrain = {
	[enum.tile.floor] = ".",
	[enum.tile.wall] = "#",
	[enum.tile.tough_wall] = "#",
	[enum.tile.stair] = "<"
}
common.default.symbols.monster = {
	[enum.monster.player] = "@",
}
common.default.symbols.tool = {
	[enum.tool.lantern] = "("
}

common.default.monster_symbol_mt = {
	__index = function(t, k)
		return enum.inverted.monster[k]
	end
}

function common.symbol_at(world, pos)
	local symbols = common.symbols
	local targ_kind, targ_enum = visible.at(world, pos)
	if not targ_kind then
		return symbols.dark
	elseif targ_enum == enum.tile then
		return symbols.terrain[targ_kind]
	elseif targ_enum == enum.monster then
		return symbols.monster[targ_kind]
	elseif targ_enum == enum.tool then
		return symbols.tool[targ_kind]
	else
		return symbols.err
	end
end

function common.color_at(world, pos)
	local invert = (pos == world.state.player_pos)
	local c = common.colors.white
	local dz = world.state.denizens[pos]
	if dz and dz.display then
		local hot = dz.display[enum.display.hot]
		local cold = dz.display[enum.display.cold]
		if hot and cold then
			c = common.colors.yellow
		elseif hot then
			c = common.colors.red
		elseif cold then
			c = common.colors.cyan
		end
	end
	return c, invert
end


function common.error_handler(msg)
	return msg.."\n"..debug.traceback()
end

function common.init(conf)
	common.symbols = conf.symbols
	common.keys = conf.keys
	common.colors = conf.colors
	setmetatable(common.symbols.monster, conf.monster_symbol_mt)
	return common
end

return common.init(common.default)
