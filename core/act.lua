local base = require("core.base")
local enum = require("core.enum")

local act_mundane = require("core.act.mundane")
local act_usetool = require("core.act.usetool")
local act_warp = require("core.act.warp")
local act_jump = require("core.act.jump")
local act_vampiric = require("core.act.vampiric")
local act_smash = require("core.act.smash")

local act = {
	MAX_MUNDANE_MOVE = act_mundane.MAX_MOVE,
	MAX_MUNDANE_MELEE = act_mundane.MAX_MELEE,
	make_warp_dlist = act_warp.make_dlist,
	jump_dlist = act_jump.dlist,
}

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
	act[enum.power.warp] = {
		wander = enum.selectf(enum.actmode, act_warp.wander),
		pursue = enum.selectf(enum.actmode, act_warp.pursue),
		flee = enum.selectf(enum.actmode, act_warp.flee),
		ranged = enum.selectf(enum.actmode, act_warp.ranged)
	}
	act[enum.power.jump] = {
		wander = enum.selectf(enum.actmode, act_jump.wander),
		pursue = enum.selectf(enum.actmode, act_jump.pursue),
		flee = enum.selectf(enum.actmode, act_jump.flee),
		ranged = enum.selectf(enum.actmode, act_jump.ranged)
	}
	act[enum.power.vampiric] = {
		melee = enum.selectf(enum.actmode, act_vampiric.melee)
	}
	act[enum.power.smash] = {
		pursue = enum.selectf(enum.actmode, act_smash.pursue),
		wander = enum.selectf(enum.actmode, act_smash.wander)
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()