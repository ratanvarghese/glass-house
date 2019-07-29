local base = require("core.base")
local enum = require("core.enum")

local act_mundane = require("core.act.mundane")
local act_usetool = require("core.act.usetool")

local act = {}

function act.init()
	act[enum.power.mundane] = {
		wander = enum.selectf(enum.actmode, act_mundane.wander),
		pursue = enum.selectf(enum.actmode, act_mundane.pursue),
		flee = enum.selectf(enum.actmode, act_mundane.flee),
		melee = enum.selectf(enum.actmode, act_mundane.melee)
	}
	act[enum.power.tool] = {
		pickup = enum.selectf(enum.actmode, act_usetool.pickup),
		drop = enum.selectf(enum.actmode, act_usetool.drop),
		equip = enum.selectf(enum.actmode, act_usetool.equip)
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()