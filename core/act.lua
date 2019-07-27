local base = require("core.base")
local enum = require("core.enum")

local act_common = require("core.act.common")
local act_mundane = require("core.act.mundane")

local act = {}

function act.init()
	act[enum.power.mundane] = {
		wander = enum.selectf(enum.actmode, act_mundane.wander),
		pursue = enum.selectf(enum.actmode, act_mundane.pursue),
		flee = enum.selectf(enum.actmode, act_mundane.flee)
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()